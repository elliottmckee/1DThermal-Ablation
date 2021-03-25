function [Sim, Wall, Abl, Flight] = parameters(x, wallType, ablativeType, simFilepath, depthProbe_Temp, heatFluxModel, T0)
%{
All the parameters relating to the sim are loaded into "organized" Structs in this
script. 

INPUTS:
    -x: downsteam X location [m]
    -wallType: String corresponding to a desired structural wall material. 
    Must be coded below. If no structural wall, enter 'NA'
    -ablativeType: String corresponding to a desired ablative material. 
    Must be coded below. If no ablative, enter 'NA'
    -simFilepath: filename pointing to Desired Flight Profile Sim Data
    -depthProbe_Temp: Vector containing locations at which to temp probe the
    ablative wall 
    -heatFluxModel is used to set which thermal model is used- Aerothermal
    or Arcjet
    -T0 is initial material Temps. Initializes all layers to this temp
    

OUTPUTS:
    -Sim: Struct containing general simulation description parameters
    -Wall: Struct containing material properties and definition of
    Solid Wall Layer
    - Abl: Struct containing material properties and definition of
    Ablative Insulation Layer
    - Flight: Struct containing flight trajectory data

NOTES: 
- Must make Specific Material Functions for Initialization of specific materials
%} 


%% SIM-GENERAL
%Flags: 
Sim.thermalModel = heatFluxModel; % Set to 'Arcjet' for Arcjet heating Verification Case as opposed to default  'Aerothermal'. 

%Nosecone Angle
Sim.theta = deg2rad(7); % NOSE CONE HALF ANGLE (7deg for Hifire Minor Axis)

%Air Parameters
Sim.T0 = T0; % [K] INITIAL AMBIENT TEMP (Initial Ablative+Structural wall temp)
Sim.Rair = 287; % [J/KgK]IDEAL GAS CONSTANT FOR AIR

Sim.sigma = 5.6704e-8; % [W/(m^2*K^4)] STEFAN-BOLTZMANN CONSTANT
Sim.emis = .8; %[] Exposed Surface Material Emissivity 

% MACH NUMBER COEFFICIENT FOR BL TRANSITION CRITERIA. 
% USE 0.2 FOR FUSELAGE AND NO SWEEP WING, USE 0.1 FOR SWEPT WING.
Sim.C_m = 0.2; 

%Grid Definition
Sim.x = x; %[m] Downstream x location, 
Sim.N = 26; % NUMBER OF DISCRETE NODES (THROUGH/INTO WALL)

% Air Property Tables:
%Currently pulling values from Fundamentals of Thermal Fluid Sciences
%It says these values are invariant w.r.t. Pressure under IGL assumptions
AirProps = readtable('air_pres_indepent.csv');
Sim.CPvTemp = [AirProps.Temp, AirProps.Cp_J_KgK_]; %[J/KgK]CP
Sim.KvTemp =  [AirProps.Temp, AirProps.k_W_mK_];  %[W/mK]
Sim.MUvTemp =  [AirProps.Temp, AirProps.mu_kg_mS_]; %[kg/ms]
Sim.PRvTemp =  [AirProps.Temp, AirProps.Pr]; %[Unitless] 

%Additional Air Enthalpy Lookup Table
hLUT = readtable('Air_Enthalpy_Table_1bar.csv');
Sim.hLUT =  [hLUT.T, hLUT.h]; %[]



%% WALL STRUCTURE
% Sets Wall type/properties based on wallType function input. 

if(strcmp(wallType, 'Al6061'))
    %Aluminum 6061 Properties pulled from Matweb: http://www.matweb.com/search/DataSheet.aspx?MatGUID=b8d536e0b9b54bd7b69e4124d8f1d20a
    Wall.rho = 2700; %[kg/m^3] Density
    Wall.Cp = 896; %[J/KgC] Specific Heat
    Wall.k = 167; %[W/mK]Thermal Conductivity
    
    %Geometric
    Wall.delta = 0.02; %[m] Wall Thickness
    
%If no Structural wall defined
elseif(strcmp(wallType, 'NA'))
    Wall = [];
else
    error('Unsupported Wall Type')
end
    


%% ABLATIVE PROPERTIES
% Sets Ablative Insulation type/properties based on wallType function input


%PICA Properties (Lot of extra properties left lying around. Definitely Check these if used)
if (strcmp(ablativeType, 'PICA'))
    
%Ablative Thicknesses
Abl.delta0_ab = 27.4e-3; % [m] INTIAL ABLATIVE THICKNESS

%Ablation Temp Threshold
Abl.T_threshold = 1000; %2000;% (Dec, Braun)  644; % [K] ABLATION TEMPERATURE THRESHOLD

%Temperature Probe (probes ablative layer for temps at given through-wall distance)
Abl.tempProbe = depthProbe_Temp; 

%Number of Species Present for Arrhenious
Abl.nSpec_ab = 3;

%Abl.rho0 = 1462.5; % [kg/m^3] ABLATIVE INITIAL MATERIAL DENSITY
Abl.rho0 = 264.1; % [kg/m^3] ABLATIVE INITIAL MATERIAL DENSITY
%Abl.rho0_comp = [324 973 1560]; % [229 972 160]; % [kg/m^3] ABLATIVE MATERIAL COMPONENT DENSITIES
Abl.rho_v_comp =  [229 972 160]; % [kg/m^3] ABLATIVE MATERIAL COMPONENT  VIRGIN DENSITIES
Abl.rho_c_comp = [0 792 160]; % [kg/m^3] Ablative Component Char densities

%Arrhenius Coeffs
Abl.B = [1.4e4 4.48e9 0]; %[1/s] Pre-Exponential Constants
Abl.E_R = [8555.6  20444.4 0]; %[K] E/R Activation Energies/R
Abl.N = [3 3 0]; %[-] Reaction Orders

%Abl.Gamma = .372; %Resin Fraction
%Abl.Gamma = .0646; %Resin Fraction
Abl.Gamma = 0.1; %Resin Fraction ALTERED TO MATCH SIMSEK (LIKELY INCORRECT)

%Cp_ab = 1972; % [J/(kg*K)] ABLATIVE MATERIAL SPECIFIC HEAT
%k_ab =  0.078; % [W/mK] ABLATIVE THERMAL CONDUCTIVITY (ROUGH)

%Ablative Material Prop Lookup Tables
Abl.cpLUTab = readtable('_CpvTemp.csv'); %[J/KgK] Cp vs T
Abl.kLUTab = readtable('_TCon_Temp.csv'); %[W/mK] K vs T
Abl.QstarLUTab = readtable('_EffHeatAbl_ConvHeatFlux.csv'); %[J/kg] Q*? vs Convective Heat Flux [W/m^2]


%If no ablative described, do not instantiate ablative struct
elseif(strcmp(ablativeType, 'NA'))
    Abl = [];
else
    error('Unspecified Ablative Type')
end

%% FLIGHT DATA
%Pulls flight data, organizes into structs
%I Think this is currently using an OpenRocket simulation file....?

%Read in HiFire Data
if strcmp(simFilepath, 'HiFire')
    [Flight.t, Flight.M, Flight.v, Flight.alt] = ConvertHiFire();

%Read in HiFire5B Data
elseif strcmp(simFilepath, 'HiFire5B')
    [Flight.t, Flight.M, Flight.v, Flight.alt] = ConvertHiFire5B();
    
%No flight profile (used for Arcjet verification case)
elseif strcmp(simFilepath, 'NA')
    Flight = [];
    
%Default: Read in General Flight data
else
    [Flight.t, Flight.M, Flight.v, Flight.alt] = flightData(simFilepath);
end

end

