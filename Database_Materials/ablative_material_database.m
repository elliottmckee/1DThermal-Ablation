function [Abl] = ablative_material_database( material_type, Abl)
% Author: Elliott McKee
% Created: 12/24/2021

% For the ABLATIVE material specified, returns the relevant material properties for use in the simulation

%The Material to be used must be specified in this script prior to the use of generate_config.m

% Will Return an error if you attempt to pull values from a material that is not-specified

%{
INPUTS: 
    -string material_type: string specifying the desired structural material (for options, see below, or add)
    -struct Abl: main struct that contains the Ablative Wall Configuration Data

OUTPUTS: 
    - A lot, see below I guess
%}


%% Database If-Else Chain (Could probably make into a dedicated struct if desired, but this seemed less error-prone)


%% PICA Properties (Lot of extra properties left lying around. Definitely Check these if these are needed)
if (strcmp(material_type, 'PICA'))
%Ablation Temp Threshold
Abl.T_threshold = 1000; %2000;% (Dec, Braun)  644; % [K] ABLATION TEMPERATURE THRESHOLD



%Number of Species Present for Arrhenious
Abl.nSpec_ab = 3;

Abl.rho0 = 264.1; % [kg/m^3] ABLATIVE INITIAL MATERIAL DENSITY
Abl.rho_v_comp =  [229 972 160]; % [kg/m^3] ABLATIVE MATERIAL COMPONENT  VIRGIN DENSITIES
Abl.rho_c_comp = [0 792 160]; % [kg/m^3] Ablative Component Char densities

%Arrhenius Coeffs
Abl.B = [1.4e4 4.48e9 0]; %[1/s] Pre-Exponential Constants
Abl.E_R = [8555.6  20444.4 0]; %[K] E/R Activation Energies/R
Abl.N = [3 3 0]; %[-] Reaction Orders

%Resin Fraction ALTERED TO MATCH SIMSEK (LIKELY INCORRECT)
Abl.Gamma = 0.1; 

%Ablative Material Prop Lookup Tables
Abl.cpLUTab = readtable('CSVs/PICA_AblativeProps/_CpvTemp.csv'); %[J/KgK] Cp vs T
Abl.kLUTab = readtable('CSVs/PICA_AblativeProps/_TCon_Temp.csv'); %[W/mK] K vs T
Abl.QstarLUTab = readtable('CSVs/PICA_AblativeProps/_EffHeatAbl_ConvHeatFlux.csv'); %[J/kg] Q*? vs Convective Heat Flux [W/m^2]


%% IF NO ABLATIVE SPECIFIED
elseif(strcmp(material_type, 'NA'))
    %Clear Abl, instatiate as empty struct
    clear Abl
    Abl = [];

    
%% ERROR CATCH
else
    error('Unspecified Ablative Type')
end

end




