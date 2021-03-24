function eta = blowingFactor_Arcjet(Sim, Abl, i, mDot, q_hw)
%BLOWINGFACTOR Calculates the Blowing Factor Given in [1]
% This is for the arcjet verification case given in [1]. 
% As such, values are hard-coded here


%NOTES:
%   - Assumes Recovery Factor of Unity
%   - Uses slightly different equations from aerodynamic case


%% Hard-Coding:
lam = .4; 
Htot = 29.5e6; %[J/Kg]


%% Calculate Adiabatic-Wall and Wall Enthalpy
%Assuming Adiabatic Wall Enthalpy == Total Enthalpy
h_aw = Htot;

%Air Enthalpy Evaluated at Wall Temp Mean of data is default if out or range interpolation
%h_w = interp1(Sim.hLUTair.T,Sim.hLUTair.h, TVec(1),'spline', mean(Sim.hLUTair.h));
h_w = interp1(Sim.hLUT(:,1), Sim.hLUT(:,2), Abl.TVec(1,i),'linear', 'extrap');


%% Phi
Phi = (2*lam*mDot*(h_aw - h_w)) / q_hw;


%% Blowing Factor
eta = Phi / (exp(Phi) - 1);

%mAtLaB cAnT rEsOlVe iNdEtErmiNanT fOrMS
if isnan(eta)
    eta = 1;
end
    
end

