function q_hw = arcjetFlux(Abl, Sim, i, eta)
%ARCJETFLUX Calculates the heat flux using the equations and verification
%testcase given in Eq. 33 of [1]

%% Constants
q_cw = 5.8e6; %[W/m^2] Cold Wall Heat Flux
%P_atm = .45; %[atm] Pressure?? I think total pres actually. 
Htot = 29.5e6; %[J/Kg] Total Arcjet stream enthalpy

%% Calculate Material Cp vs. Temp
Twall = Abl.TVec(1,i);
%Cp  = interp1(Abl.cpLUTab.Var1, Abl.cpLUTab.Var2, Twall, 'spline', mean(Abl.cpLUTab.Var2));
Cp  = interp1(Abl.cpLUTab.Var1, Abl.cpLUTab.Var2, Twall, 'linear', 'extrap');

% %Clip ends instead of interpolate
% if (Twall < Abl.cpLUTab.Var1(1)) 
%     Cp = Abl.cpLUTab.Var2(1); 
% elseif (Twall > Abl.cpLUTab.Var1(end)) 
%     Cp = Abl.cpLUTab.Var2(end) ;
% else
%     Cp  = interp1(Abl.cpLUTab.Var1, Abl.cpLUTab.Var2, Twall, 'linear');
% end

%Just Taking the mf mean
%Cp = mean(Abl.cpLUTab.Var2);


%% Calculate Hot Wall heat flux
%Assuming T0 for T_inf
q_hw = eta * q_cw * (1 - (Cp*Twall)/(Htot))   -   Sim.sigma * Sim.emis * (Twall^4 - Sim.T0^4);

%Check to override negative heatfluxes
if(q_hw < 0)
   q_hw = 0;
end

end

