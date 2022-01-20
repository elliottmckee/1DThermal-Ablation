%{
1D AERODYNAMIC HEATING WITH ABLATION
CU SOUNDING ROCKET LABORATORY 
---------------------------------------------------------------------------
THIS SCRIPT MODELS THE AERODYNAMIC HEATING WITH OR WITHOUT ABLATION
 FOR A ROCKET NOSECONE OVER A SPECIFIED MACH-ALTITUDE FLIGHT PROFILE. 

THE HEAT TRANSFER SIMULATION IS A ONE-DIMENSIONAL MODEL USING THE FINITE 
DIFFERENCE METHOD. HEAT TRANSFER IN THE AXIAL/DOWNSTREAM DIRECTION IS IGNORED.
---------------------------------------------------------------------------
AUTHORS: Elliott McKee (elliott.mckee@colorado.edu), 
COLLABORATORS: Owen Kaufmann
The initial version was created from research done by Owen Kaufmann

CREATED: 2021-02-06
LAST MODIFIED: 2021-12-24
---------------------------------------------------------------------------
REFERENCES: 
-I (Elliott McKee) have a ton more references not listed here

[1] Uslu, Sitki & Simsek, Bugra. (2019). One-Dimensional Aerodynamic 
    Heating and Ablation Prediction. Journal of Aerospace Engineering. 
    32. 10.1061/%28ASCE%29AS.1943-5525.0001042. 

[2] Uslu, Sitki & Simsek, Bugra. (2020). VALIDATION OF AERODYNAMIC HEATING 
    PREDICTION TOOL. 40. 53-63. 

[3] Jansen, ASEN 3111 Shock Calc Functions.

[4] https://www.youtube.com/watch?v=uLkuEr6M40o&t=1302s&ab_channel=KodyPowell

[5] Bertin, J.J. 1994. Hypersonic aerothermodynamics. Reston, VA: AIAA.

[6] Bianchi, D. 2007. â€œModeling of ablation phenomena in space applications.â€?
Ph.D. dissertation, Dept. of Mechanics and Aeronautics, UniversitÃ  di
Roma â€œLa Sapienzaâ€?

[7] Aerothermodynamics of Pre-Flight and In-Flight Testing Methodologies for
Atmospheric Entry Probes, VON KARMAN INSTITUTE FOR FLUID DYNAMICS
Isil Sakraker

[8] https://www.engineeringtoolbox.com/air-properties-viscosity-
    conductivity-heat-capacity-d_1509.html

[9] Enthalpy Table: https://www.engineeringtoolbox.com/air-properties-d_1257.html
    CAN IMPROVE W/ https://www.cambridge.org/us/files/9513/6697/5546/Appendix_E.pdf
    CEA is likely a viable option here as well (only for increasing resolution. We generally actually don't need HT effects unless Stagnation pt.)
%}

%{
NOTES:

I have un-vectorized this and made this only work at a single downstream x
location, for simplicity in implementation. Can add back in
future if needed. Otherwise, just run separate sims. 

Can likely re-ODE45 now that there is no general recursion (vectorized ODE45)

THE MATERIAL PROPERTIES ARE ABSOLUTELY POSSIBLY INCORRECT. DEFINITELY CHECK IF USING IN DESIGN

Add Interface Modelling


CURRENTLY:
- Find ways to verify coupled Aerothermal+Ablation!
- ASSUMES CONICAL GEOMETRY (can make variable) REMOVED?
- CHECK DENSITY CHANGE W/ TEMP? (ARRHENIUS ABLATION MODEL)
    -Seems right as of rn, according to Covington Arcjet data
- Find better fix for clipping extrapolated material property values


FUTURE: 
- Look into Conical Shocks, as opposed to 2D oblique (add as input parameter)
    See Compressible Flow CH10 by Anderson.
- Look into more stagnation point, fin LE heating specifically (FAY-RIDELL)
- Look for a model for THERMAL CONDUCTIVITY and PRANDTL that captures pressure dependance (CEA, not super necessary?)
-Add something to force turbulent flow? Can probably just modify C_m in a certain way to acheive this

%}


%% Housekeeping
clc;
clear;
close all;



%% Add all subfolders to Path
cd ..                                                          %Step up a folder
addpath(genpath('1DThermal-Ablation'))    %Add 1DThermal-Ablation, and all subfolders, to Matlab Path
cd 1DThermal-Ablation                              %Return to original directory



%% Generate Configuration Files
% Generate configuration file (only have to do this once, generally, per simulation configuration)
% You must make sure that this config file matches the case to be analyzed.
%generate_config();



%% Setup
%Specify Configuration Filename to read from. Generate these using generate_config() 
%   EX: config_filename = 'Config_Files/Hifire_5/Hifire_5.mat'
config_filename = 'Config_Files/EXAMPLES/Hifire_5/Hifire_5.mat';
%Specify output Folder name. The current date/time will be appended to this foldername for uniqueness
% If you want to overwrite and save to a different directory, you should be able to as well. 
% EX: output_filename = 'Output_Test'
output_filename = 'Example_HiFire_5_Out';


% Load in Structs from Config File
load(config_filename);



%% Overwrite Values
%If you need to over-write anything in the current configuration, do so here (needs to be done BEFORE sim_initialize())
%   EXAMLPLES: Sim.x = 0.5; Flight.filepath = 'newtrajectory.csv';



%% Initialize and Run Simulation
% Intialize Simulation Instance/Structures
[Sim, Flight, Wall, Abl] = sim_initialize(Sim, Flight, Wall, Abl);
% Run Simulation
[Sim, Abl, Wall] = timeIntegration(Sim, Flight, Wall, Abl);



%% Postprocessing (making this more Offical-TM)
sim_postprocess(config_filename, output_filename, Sim, Flight, Wall, Abl)




%% Postprocessing (NEED TO CONSOLIDATE ALL OF THE BELOW INTO A COHESIVE PLOTTING SCRIPT)
%plotting_wall_hifire(Sim.t, Sim, Wall) %HiFire Verification Plotting


%% Structural Wall Plotting Baseline
%if(~isempty(Wall))
%plotting_wall_hifire(Sim.t, Sim, Wall) %HiFire Verification Plotting
%plotting_wall(Sim.t, Sim, Wall)          
%end


%% Ablative Wall Plotting Baseline
%if(~isempty(Abl))
%plotting_abl_arcjet(Sim.t, Sim, Abl, Recess_tot)%Arcjet Verification Plotting
%end


%% Additional Plotting Section
%Temperature Distribution at max temp section
%figure()
%plot(Wall.coords, flip(Wall.TVec(:,index_maxtemp)))

%title('Through Wall Temperature Distribution')
%xlabel('Through-Wall Position (m)')
%ylabel('Temperature (K)')


% Additional Plotting Section
% 
% %% Temperature Distribution at specific times
% %Get indices corresponding to specific times
% plotInd1 = find( t == 0 )
% plotInd2 = find( t == 5 )
% plotInd3= find( t == 10 )
% plotInd4 = find( t == 20 )
% 
% %Get y vector for discretized points 
% y = linspace(0, Wall.delta, Sim.N)
% 
% figure()
% hold on
% 
% plot(y, Wall.TVec(:,plotInd1), 'Color', [0,0,1])
% plot(y, Wall.TVec(:,plotInd2), 'Color', [0,0,0.5])
% plot(y, Wall.TVec(:,plotInd3), 'Color', [0.5,0,0])
% plot(y, Wall.TVec(:,plotInd4), 'Color', [1,0,0])
% 
% title('Through Wall Temperature Distribution Plots w/ Time')
% xlabel('Through Wall Distance (m)')
% ylabel('Temperatuere (K)')
% legend('0 Seconds', '5 Seconds', '10 Seconds', '20 Seconds')
% 
% 
% %% Surface Temperature w/ Time
% 
% figure()
% hold on
% 
% plot(t, Wall.TVec(1,:), 'r')
% plot(t, Wall.TVec(end,:), 'b')
% 
% 
% title('Wall Temperatures vs. Time')
% xlabel('Time (s)')
% ylabel('Temperatuere (K)')
% legend('Hot Wall Temp', 'Interior Wall Temp')






