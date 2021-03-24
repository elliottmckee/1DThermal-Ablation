function [q_hw, h] = aerothermal_heatflux(Sim, h, T_r, T_w, T_inf, eta)
%AEROTHERMAL_HEATFLUX Calculates the hot wall heat flux using Equation 4
%from Uslu

%One equation in a function so eta's can be varied I guess.

%% Calculate Hot Wall Heatflux
q_hw = eta*h*(T_r - T_w) - Sim.sigma*Sim.emis*(T_w^4 - T_inf^4);

end

