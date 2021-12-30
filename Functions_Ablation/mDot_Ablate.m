function [sDot, mDot_tot] = mDot_Ablate(Abl, i, mDot_gas, q_hw)
%MDOT_ABLATE Calculates the Total mDot for ablation

%Will have to change if don't have plots for Qstar vs. Temp. 
%Likely means we will have to assume constant. 

%Extrapolation Bad


%% Calcualte Qstar as a function of q_hw
%Interpolate Heat of Ablation
Qstar = interp1(Abl.QstarLUTab.Var1,Abl.QstarLUTab.Var2, q_hw, 'linear', 'extrap');


%% Pull Values from Structs & Rename
rho_surf = Abl.rhoVec_tot(1,i); 
Tsurf = Abl.TVec(1,i);

%% Calculate Surface Recession
if  Tsurf > Abl.T_threshold
    %Get Surface Recession
    sDot = -q_hw/(rho_surf * Qstar);
else
    sDot = 0;
end

%I kept getting un-recession rates OVERRIDE
if sDot > 0
    sDot = 0;
    fprintf('Negative Recession\n')
end

%% Sum Mass Contributions
mDot_tot = -rho_surf*sDot + mDot_gas;

end

