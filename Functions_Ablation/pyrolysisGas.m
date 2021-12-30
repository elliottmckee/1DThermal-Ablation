function [dRho, dRho_comp, mDot_g] = pyrolysisGas(Sim, Abl, i)
%PICA_pyro Takes in vectors of element density, element component densities, and  temperature, 
% calculates the rate of change of the overall density of the Ablative
% material due to pyrolysis.
%
% Should be able to handle different amounts of resin/reinforcement components, though this
% function should be checked for every new material added. 
%

%{
%AUTHOR: Elliott McKee
   
This is attempting to model equation 15 in [1]. In the state given there,
it models each of the different (Resin and Reinforcement) components.
Finding the required coefficients proved to be a challenge, and is
definitely somewhere that can be improved upon. 

CORK P-50 values can be found in,  Aerothermodynamics of Pre-Flight and
In-Flight Testing Methodologies for Atmospheric Entry Probes, Isil Sakraker 2016, 
SLACK ME IF I DONT POST ANYWHERE.

PICA Phenolic-Carbon Ablator coefficients can be found in:
Optimum Design of Ablative Thermal Protection Systems for Atmospheric Entry Vehicles
Riccio et al. <- The data here is partial and lowkey sus
AND: 
https://ntrl.ntis.gov/NTRL/dashboard/searchResults/titleDetail/N6810031.xhtml
TONS OF MATS HERE

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FINDING SOME WAY TO VERIFY THIS WOULD BE AWESOME
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

NOTES: 
-The values given in the documents referenced are all over the place
-The below assumes that the volume resin fraction is constant...? (Gamma)

%}

%OLD VALUES PICA? Leaving here- 
%Virgin Densities
%rho_v = Abl.rho0; % [kg/m^3] Ablative Total Density
%rho_v_comp = Abl.rho0_comp; % [kg/m^3] Ablative Component Densites
%rho_v_comp = [324 973 1560]; %[229,972,160]; % [kg/m^3] Ablative Component Virgin
%rho_v_comp = [229,972,160]; % [kg/m^3] Ablative Component Virgin
%Char Densities
%rho_c_comp = [0 519 1560];%[0 792 160]; % [kg/m^3] Ablative Component Char
%rho_c_comp = [0 792 160]; % [kg/m^3] Ablative Component Char



%% Component Density Change Calculation
%Initialize Density Rate of Change Matrix (Stacked Vectors)
dRho_comp = zeros(Sim.N, Abl.nSpec_ab);


% For Each Reaction Component
for j = 1:Abl.nSpec_ab
    %Calculate Change in Density
    dRho_comp(:, j) = (-Abl.B(j) .* exp(-Abl.E_R(j)./Abl.TVec(:,i)) .* Abl.rho_v_comp(j)) .* (((Abl.rhoVec_comp(:,i,j)-Abl.rho_c_comp(j))./Abl.rho_v_comp(j)).^Abl.N(j));
end


%% Total Contribution to Total Density Change
dRho = Abl.Gamma*(dRho_comp(:,1) + dRho_comp(:,2)) + (1-Abl.Gamma)*dRho_comp(:,3);


%% Get Pyrolysis Gas Generation
%Convert Material Thickness to Element Thickness
dy = Abl.deltaVec(i)/(Sim.N - 1);

%Sum density change*cell volume across all elements. ASSUMES UNIT AREA
mDot_g = -sum(dRho*1*dy);


end

