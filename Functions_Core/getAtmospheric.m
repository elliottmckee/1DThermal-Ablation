function [mach, T_inf,a_inf,P_inf, P_0_inf, rho_inf, gamma] = getAtmospheric(t, Flight)
%GETATMOSPHERIC Get Atmospheric/Freestream Atmospheric properties
% at given time t, throughout the flight trajectory

%NOTES:
%   -Extrapolation Bad
%   -Gamma Constant

%% Get Altitude at Time, t
alt = interp1(Flight.t, Flight.alt, t, 'linear', 'extrap');
mach = interp1(Flight.t, Flight.M, t, 'linear', 'extrap');


%% Pull Atmospheric Props at Current Alt
[T_inf,a_inf,P_inf,rho_inf] = atmoscoesa(alt); % 1976 COESA Atm Model (ONLY TO ~80 KM, will throw warning)
    

%% Assuming Gamma Constant
gamma = 1.4;

%% Total Pressure
%M_inf = v(j)/a_inf;
P_0_inf = P_inf * (1 + (gamma-1)/2*mach^2)^(gamma/(gamma-1));

    
end

