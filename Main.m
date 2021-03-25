%{
1D AERODYNAMIC HEATING WITH ABLATION
CU SOUNDING ROCKET LABORATORY 
---------------------------------------------------------------------------
THIS SCRIPT MODELS THE AERODYNAMIC HEATING WITH OR WITHOUT ABLATION
 FOR A ROCKET NOSECONE OVER A VELOCITY/ALTITUDE FLIGHT PROFILE. 

THE HEAT TRANSFER SIMULATION IS A ONE-DIMENSIONAL MODEL USING THE FINITE 
DIFFERENCE METHOD. HEAT TRANSFER IN THE AXIAL DIRECTION IS IGNORED.
---------------------------------------------------------------------------
AUTHORS: Elliott McKee (elliott.mckee@colorado.edu), Owen Kaufmann
COLLABORATORS: 
This document was created from research done by Owen, as well as a 
initial version drafted by him. 

CREATED: 2021-02-06
LAST MODIFIED: 2021-03-16
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

%}

%{
NOTES:

I have un-vectorized this and made this only work at a single downstream x
location, for simplicity in implementation. Can add back in
future if needed. Otherwise, just run separate sims. 

Can likely re-ODE45 now that no general recursion

THE MATERIAL PROPERTIES ARE ABSOLUTELY POSSIBLY INCORRECT. DEFINITELY CHECK

Check Mach/Shock relations

Add Interface Modelling


CURRENTLY:
- Verify Aerothermal+Ablation!
- ASSUMES CONICAL GEOMETRY (can make variable) REMOVED
- IMPLEMENT STABILITY CRITERION CHECK
- CHECK DENSITY CHANGE W/ TEMP? (ARRHENIUS)
    -Seems right as of rn
- Do we want unit width for exposed surface area? Blowing effect seems dependant on it. ASSUMING UNIT RN
- Find better fix for clipping extrapolated values



FUTURE: 
- Look into Conical Shocks, as opposed to 2D oblique
    See Compressible Flow CH10 by Anderson.
- Look into more stagnation point heating specifically

%}


%% Housekeeping
clc;
clear;
close all;

%Add Relevant Subfolders to Path
addpath('CSVs')
addpath('Functions_Arcjet')
addpath('Functions_Aerothermal')
addpath('Functions_HiFire')
addpath('Functions_Pyrolysis')



%% INITIALIZE PARAMETER/DATA STRUCTS
%Inputs
x = .400; %[m] Downstream X location (Doesn't matter for Arcjet, 200mm for HiFire, 400,650,850mm for HF-5B. See Ulsu)
depthProbe_Temp = [0.0222 0.0172 0.0098]; %[m] Ablative Layer Temperature Probe Locations. Leave empty to ignore

%Initialize Parameter/Data Structs
%                                 parameters(location, WallType, AblativeType, simFilePath, depthProbe_Temp, heatingType, intial Temp)
%[Sim, Wall, Abl, Flight] = parameters(x, 'NA', 'PICA',  'NA', depthProbe_Temp, 'Arcjet', 280);    %Arcjet Verify
[Sim, Wall, Abl, Flight] = parameters(x, 'Al6061', 'NA',  'HiFire', depthProbe_Temp, 'Aerothermal', 280);    %Hifire Parameters
%[Sim, Wall, Abl, Flight] = parameters(x, 'NA', 'PICA',  'HiFire', depthProbe_Temp, 'Aerothermal', 280); %Other   


%% MAIN INTEGRATION LOOP
%t = 0:.001:15; %time vector (Arcjet testcase)
t = 0:.004:215; %time vector (Hifire, normal)
%t = 510:.001:520; %time vector (Hifire-5B)

%Integration loop call
[Sim, Abl, Wall] = timeIntegration(t, Sim, Wall, Abl, Flight);


% %HiFire-5B VERIFICATION TESTCASE
% [Sim, Wall, Abl, Flight] = parameters(.400, 'Al6061', 'NA',  'HiFire5B', depthProbe_Temp, 'Aerothermal', 368);    %Hifire5B Parameters
% %Integration loop call
% [Sim400, Abl400, Wall400] = timeIntegration(t, Sim, Wall, Abl, Flight);
% 
% [Sim, Wall, Abl, Flight] = parameters(.600, 'Al6061', 'NA',  'HiFire5B', depthProbe_Temp, 'Aerothermal', 361.2);    %Hifire5B Parameters
% %Integration loop call
% [Sim650, Abl650, Wall650] = timeIntegration(t, Sim, Wall, Abl, Flight);
% 
% %HiFire-5B Verification
% [Sim, Wall, Abl, Flight] = parameters(.800, 'Al6061', 'NA',  'HiFire5B', depthProbe_Temp, 'Aerothermal', 360.7);    %Hifire5B Parameters
% %Integration loop call
% [Sim800, Abl800, Wall800] = timeIntegration(t, Sim, Wall, Abl, Flight);
% %Plotting
% plotting_wall_hifire5B(t, Sim400, Wall400, Sim650, Wall650, Sim800, Wall800, Flight) %HiFire Verification Plotting


%% Calculate Total Recession
if(~isempty(Abl))
Recess_tot = Abl.delta0_ab - Abl.deltaVec(end)
end


%% Structural Wall Plotting
if(~isempty(Wall))
plotting_wall_hifire(t, Sim, Wall) %HiFire Verification Plotting
%plotting_wall(t, Sim, Wall)          
end


%% Ablative Wall Plotting
if(~isempty(Abl))
plotting_abl_arcjet(t, Sim, Abl, Recess_tot) %Arcjet Verification Plotting
end




