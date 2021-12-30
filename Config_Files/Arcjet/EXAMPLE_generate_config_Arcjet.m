function [] = generate_config()
% Generates the configuration structs required for use in the Thermal Sim
%{
PURPOSE: To provide a single script that can be used to specify a configuration for a simulation
    instance. For a given vehicle configuration, this will ideally jusy have to be run once, and then you
    can have this configuration file saved such that you don't need to regenerate it for each simulation instance. 
    
    The user should modify any/all of the below parameters as required to match their desiredsimulation.

    ALL OF THESE PROPERTIES CAN BE OVER-WRITTEN ONCE LOADED INTO THE MAIN SCRIPT AS NEEDED.
    Any derived structures/values will be generated by sim_initialize(), so you must overwrite before calling
    that

    This includes the specification of : 
            - Time/discretization
            - Structural Property Configuration
            - Models to be used
            - more!

    Once run, this will save the required scripts to a .mat file, under the name/filepath specified, such that we can
    later load the requisite scripts into the workspace using load() in main()


USAGE: 
    - The user must define the output file name/path (outFilePath below) to save the generated config structs to. 
    - Thes user then must modify all the following parameters and values as needed to match their
    given/desired simulation instance


INPUTS:
    -outFilePath: path to save the requisite files to
        -Example: 'Config_Files/Test/example.mat
    
OUTPUTS:
    -Saves a .mat file containing the configuration structs to location specified by outFilePath

NOTES:
- 
%} 


%% Add All Subfolders to Path
cd ..                                                          %Step up a folder
%%%%% needed for examples only
cd ..
cd ..
%%%%%
addpath(genpath('1DThermal-Ablation'))    %Add 1DThermal-Ablation, and all subfolders, to Matlab Path
cd 1DThermal-Ablation                              %Return to original directory


%% Specify Output Filepath/Name
outFilePath = 'Config_Files\Arcjet\Arcjet_Verify.mat'; %Can be a name or filepath. Ideally a .mat file (Matlab will automatically append if you don't)


%% SIM - GENERAL PROPERTIES/CONFIGURATION
% The SIM data structure contains the main, general configuration properties for running the Thermal Sim

% Time Discretization
Sim.t = 0:.001:15;
    % Just specifies a time vector for the forward-time integration. Look at the flight data in RAS or
    % something to determine what to set this as. There will be a Stability warning that will be automatically detected and 
    % thrown if you set the resolution too low. If you 
    % Relevant Examples:
        % Arctjet Verification Case: 0:.001:15
        % Hifire Verification Case: 0:.004:215
        % Hifire 5B Verification Case: 510:.001:520

% Downstream Location to Analyze
Sim.x = 0.2; %[m] 
    % Downstream/Along-body X location to perform the following analysis on. Measured from Nosecone tip
    % Relevant Examples: 
        %Doesn't matter for Arcjet
        % .20 m for HiFire, 
        % .40, .65, .85m for HF-5B. (See Ulsu)
        % x = 0.254m; %[10in to m], roughly near front of OBBY NC
   
%Grid Definition
Sim.N = 26; 
    % Number of Discrete Nodes (spatial discretization in the through-wall direction)

% Thermal Model Specification
Sim.thermalModel = 'Arcjet'; 
    %Specify what type of Applied Heating Model/Environment to Simulate
    % Aerothermal is the main application for this script. There is an Arcjet model, that is based off of a
    % calibrated cole wall heat flux. See Ulsu-Simsek for more information.
    % You should 99.99999% of the time be using Aerothermal, unless debugging the Ablative model. 
        % Options: - 'Aerothermal'
        %               - 'Arcjet'
       
% Nosecone Angle
Sim.theta = deg2rad(7);
    % Specify Nose-cone half-angle (RADIANS CONVERTED TO DEG)
        % HiFire has a 7 degree Minor Axis
        % In Middle-ish of Obsidian 5:1 VK, we see 5deg incident angle
            
% Initial Temperature
Sim.T0 = 288; %[K]
    % Initial Ambient Temperature of Air. Structure is assumed to be in Thermal Equilibrium w/ this value at
    % T-0
    
% Surface Emissivity
Sim.emis = .8; %[] 
    % Exposed Surface Material Emissivity, for Radative Heat out of Material
    
% "Constants" Specification
Sim.Rair = 287; % [J/KgK]
    % Ideal Gas Constant for Air. This is assuming Calorically-Perf-Gas, so likely breaks down at high temps
Sim.sigma = 5.6704e-8; % [W/(m^2*K^4)] 
    % Stefan-Boltzmann constant for use in Black Body Radiation

% Mach Number Coefficient for BL Transition Criteria (see Ulsu-Simsek) 
Sim.C_m = 0.2; 
    % Used for the calculation of when the BL is Laminar/Turbulent.
    % Reccomended (ULSU): USE 0.2 FOR FUSELAGE AND NO SWEEP WING, USE 0.1 FOR SWEPT WING.
        % Fuselage/No Sweep Wing: 0.2
        % Swept Wing: 0.1
    % Coefficients/correlations like these, especially for this use case of predicting transition, are
    % extrodinarily coarse, and results should be interpreted with that in mind.

% Air Property Tables:
AirProps = readtable('CSVs/air_pres_indepent.csv');
Sim.CPvTemp = [AirProps.Temp, AirProps.Cp_J_KgK_]; %[J/KgK]CP
Sim.KvTemp =  [AirProps.Temp, AirProps.k_W_mK_];  %[W/mK]
Sim.MUvTemp =  [AirProps.Temp, AirProps.mu_kg_mS_]; %[kg/ms]
Sim.PRvTemp =  [AirProps.Temp, AirProps.Pr]; %[Unitless] 
    % Currently pulling values from Fundamentals of Thermal Fluid Sciences
    % It says these values are invariant w.r.t. Pressure under IGL assumptions
    % Can capture the dependance (at equilibrium) on temperature AND PRESSURE, by using CEA. 
    % I have even made tools to do so, but at the temps desired, the above properties are indeed suprisingly independant of
    % pressure. 
    
% Additional Air Enthalpy Lookup Table (Not Required)
hLUT = readtable('Air_Enthalpy_Table_1bar.csv');
Sim.hLUT =  [hLUT.T, hLUT.h]; %[]


%% WALL STRUCTURE
% This provides the material and geometric specification for the Structural (assumed non-ablative) Wall

% Structural Wall Thickness
    Wall.delta = 0.02; %[m]
    % Defines Wall Thickness 
        % - HIFIRE: 0.02m
        % - Obsidian (Rough): 0.03m;
        
% Structural Wall Material/Thermal Properties
[Wall] = wall_material_database( 'NA', Wall); %[kg/m^3], [J/KgC], [W/mK]
    % Pulls the values for the wall material specified by the argument to the above function
        % See function for possible options
    % You must define new materials in wall_material_database() before you can use them
    % If you do not, the above should throw an error
    % IF YOU DO NOT HAVE A STRUCTURAL LAYER (for ablative-only analysis), YOU MUST INPUT 'NA' ABOVE
        % Will simply delete the struct 'Wall' and will re-instatiate as an empty struct        
    
%[DO NOT ADD ANYTHING TO THE STRUCT WALL BELOW THIS]. DUE TO BEHAVIOR OF wall_material_database() above. 
    % The Sim relies on wall being empty (Wall = []) or not, for checks later on


%% ABLATIVE PROPERTIES
% This provides the material and geometric specification for the Ablative (pyrolyzing, TPS) Wall
% THIS IS STILL REALLY RUDIMENTARY, AND RELATIVELY UN-VERIFIED. ONLY SUPPORTS PICA RN
% I (Elliott) HAVE REALLY ROUGH PROPERTIES FOR THINGS LIKE CORK AS WELL TOO THOUGH

% Ablative Wall Thickness
Abl.delta0_ab = 27.4e-3; % [m] 
    % Defines Initial Ablative Material Thickness
        % For Ulsu-Simsek Testcase: 27.4e-3m
    
% Define Temperature Probe (probes ablative layer for temps at given through-wall distance)
Abl.tempProbe = [0.0222 0.0172 0.0098]; %[m] Specify Ablative Layer Temperature Probe Locations. Leave empty to ignore
    % TL;DR: Set the desired depths to probe for temperature throughout the flight.
        % "I want to know the temp at .001 meters into the ablative" this is how you do that
        % Leave empty [] if not desired or relevant
    % Basically, since the surface of the ablative material recesses, the mesh also
    % changes. So, there is a little extra legwork if you want the temperature at a specific depth. 
    % Not certain on how this is defined- if it is the depth from the original, nominal external surface, or
    % it is outward from the structural layer. 
    
% Ablative Wall Material/Thermal Properties
[Abl] = ablative_material_database( 'PICA', Abl); %[a lot of outputs here]
    % Pulls the values for the ablative material specified by the argument to the above function
            % See function for possible options
    % You must define new materials in ablative_material_database() before you can use them
    % If you do not, the above should throw an error
    % IF YOU DO NOT HAVE A ABLATIVE LAYER (for structural-only analysis), YOU MUST INPUT 'NA' ABOVE
        % Will simply delete the struct 'Abl' and will re-instatiate as an empty struct        
        
%[DO NOT ADD ANYTHING TO THE STRUCT Abl BELOW THIS]. DUE TO BEHAVIOR OF ablative_material_database() above. 
    % The Sim relies on wall being empty (Abl = []) or not, for checks later on


%% FLIGHT DATA
%Specify Flight Filepath (or just Name, since all subfolders are automatically added to PATH)
Flight.filepath = 'HiFire';
    % This is how you point to the OpenRocket/RASAero Sim file to be used in the analysis
        % 'Hifire', 'Hifire5B' datasets for verification cases
        % Example: flightFilepath = 'Obsidianv1.4_OmotorVegas.csv'


%% Save to .mat file
save( outFilePath, 'Sim', 'Wall', 'Abl', 'Flight')


end

