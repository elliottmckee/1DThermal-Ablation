function [Abl, Sim] = ArcjetTestCase(Sim, Abl, dt, i)
%ARCJETTESTCASE Calculates Hot Wall Heat flux according to the Arcjet
%verification case specified in Uslu, based off of the Arcjet test perfomed by
%Covington 2004.

%{
INPUTS:
-Sim: Struct containing Simulation Parameters
-Abl: Struct containing Ablative Material Layer Parameters
-delta: Ablative Thickness at given timestep
-TVec: Temperature vector at the timestep specified (n,1)
-rho_tot: Vector of Total Ablative Density at Given Timestep (n,1)
-rho_comp: Vector of Component Ablative Density at Given Timestep (n,1,# of ablative components)

OUTPUTS:
- q_hw: Arcjet Hot Wall Heatflux [W/m^2]
- sDot: Surface Recession Rate [m/s]
- dRho: Time Rate of Change of Ablative Element Total Density [kg/m^3*s] (n,1)
- dRho_comp: Time Rate of Change of Ablative Element Component Density [kg/m^3*s]  (n,1,# of ablative components)
- eta: Blowing Factor (Unused Later. Just Maintained for debugging)
%}


%% Calculate Unblown Heat Flux (Eta = 1)
q_hw_unblown = arcjetFlux(Abl, Sim, i, 1);


%% Calculate Pyrolysis Gas Generation Based on specified Material Function
%Calculate Rate of Change in all of the densities (TOTAL + COMPONENT)
[dRho, dRho_comp, mDot_g] = pyrolysisGas(Sim, Abl, i);


%% Calculate Surface Recession to get Total mDot,
[Abl.sDotVec(i), mDot_tot] = mDot_Ablate(Abl, i, mDot_g, q_hw_unblown);


%% Blowing Factor
Abl.etaVec(i) = blowingFactor_Arcjet(Sim, Abl, i, mDot_tot, q_hw_unblown);


%% Correct Hot Wall Heat Flux w/ Blowing
Sim.q_hwVec(i) = arcjetFlux(Abl, Sim, i, Abl.etaVec(i));


%% Update Ablative Thickness
Abl.deltaVec(1,i+1) = Abl.deltaVec(i) + Abl.sDotVec(i) * dt;
%% Update Ablative Densities
Abl.rhoVec_tot(:,i+1) = Abl.rhoVec_tot(:,i) + dRho*dt ;
Abl.rhoVec_comp(:,i+1,:) = squeeze(Abl.rhoVec_comp(:,i,:)) + dRho_comp*dt;



end

