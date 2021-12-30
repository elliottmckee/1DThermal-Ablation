function [h, T_r, lam] = aerothermal_coeff(Sim, Twall, M_L, T_L, P_L, gam)
%FLOWPROPS_ECKERT Calculates the Eckert Reference Temperature of the Flow
% Uses Eckert Temp to calculate flow properties


%% Calculate Recovery Factor
%{
The Recovery Factor is a function of the local air properties at a given
point. However, we cannot calculate Eckert's Reference temperature until
we have it. 

MACHADO 2008 USES PRANDTL NUMBER EVALUATED AT WALL TEMP TO CALCULATE
    THE ADIABATIC WALL/RECOVERY TEMP. ALSO HAS IT CONSTANT????

For now, I will be calculating Prandtl by taking un-corrected local values.
-If you look in SIMON 1966, there appears to be a difference between Tr and
Tr_star. This could be the correct way, to calculate, but need to try and
find original source for Eckert relation.


FUTURE:
-Recursive Property definition Issue
    -Read into Eckert Ref temp approach more formally
    -Try looping through this until flow properties  achieve specific tolerance
    -IDK ask USLU??
    -I think current approach is fine. Calculating Re with edge values,
    then correcting the following properties. Maybe don't need to check
    turbulence twice
%}



%% Interpolate Air Props at Local Temp

%Viscosity
if T_L > 3000
    warning('T_L for interpolation is greater than 3000K, where viscosity starts becoming dependant on pressure')
end
Mu_L = interp1(Sim.MUvTemp(:,1), Sim.MUvTemp(:,2), T_L);





Pr_L = interp1(Sim.PRvTemp(:,1), Sim.PRvTemp(:,2), T_L);


%Calculate Local Density
rho_L = P_L / (Sim.Rair*T_L);

%Calculate Local Velocity
u_L = M_L * sqrt(gam*Sim.Rair*T_L);

%Calculate Reynolds Number
Re_L = (rho_L*u_L*Sim.x)/Mu_L;



%% Check Laminar or Turbulent, Get Recovery Factor
%Laminar to Turbulent Transition as given in Quinn and Gong
if (log10(Re_L) <= 5.5 + Sim.C_m*M_L)
    %Laminar Recovery Factor
    r = sqrt(Pr_L);
else
    %Turbulent Recovery Factor
    r = Pr_L^(1/3);
end


%% Calculate Eckert RefTemp
%Calculate Recovery Temp
T_r = T_L*(1 + r* ((gam-1)/2) * M_L^2);

%Eckert Reference Temp
T_star = T_L + 0.5 * (Twall - T_L) + .22*(T_r - T_L);


%% Get Air Properties at Eckert Ref Temp
%Table Interpolated Props
Mu_star = interp1(Sim.MUvTemp(:,1), Sim.MUvTemp(:,2), T_star );
Pr_star = interp1(Sim.PRvTemp(:,1), Sim.PRvTemp(:,2), T_star );
k_star = interp1(Sim.KvTemp(:,1), Sim.KvTemp(:,2), T_star );


%Density
%Calculate Local Density
rho_star = P_L / (Sim.Rair*T_star);

%Calculate Reynolds Number
Re_star = (rho_star*u_L*Sim.x)/Mu_star;




%% Heat Transfer Coefficient
%Laminar to Turbulent Transition as given in Quinn and Gong
if (log10(Re_star) <= 5.5 + Sim.C_m*M_L)
    %Laminar Heat Transfer Coeff (USLU)
    h = (k_star/Sim.x) * 0.33206 * Re_star ^ (1/2) * Pr_star ^ (1/3);
    lam = .5;
else
    %Turbulent Heat Transfer Coeff
    h = (k_star/Sim.x) * 0.02914 * Re_star ^ (4/5) * Pr_star ^ (1/3);
    lam = .4;
end

end

