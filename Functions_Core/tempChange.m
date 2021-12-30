function [dTdt] = tempChange(Sim, Abl, q_hw)
%UPDATETEMPS Gets time rate of change of temperatures for Ablative, Wall,
%or Ablative+Wall combination


%% Calculated Values
% Calculate dy
dy = delta/(Sim.N - 1);
%Calculate Cp vs. Temp for Each Point
%Cp  = interp1(Abl.cpLUTab.Var1,Abl.cpLUTab.Var2, TVec,'spline', mean(Abl.cpLUTab.Var2));
Cp  = interp1(Abl.cpLUTab.Var1,Abl.cpLUTab.Var2, TVec,'linear', 'extrap');

%Calculate k vs. Temp for Each Point
%k  = interp1(Abl.kLUTab.Var1,Abl.kLUTab.Var2, TVec,'spline', mean(Abl.kLUTab.Var2));
k  = interp1(Abl.kLUTab.Var1,Abl.kLUTab.Var2, TVec,'linear', 'extrap');

    
%% Stability Check
%Numerical Stability Check for Surface Point? Idk its given in [1]
%DONT THINK WE CAN DO FOR TESTCASE
%Fo = k*dt/(rho(1) * Cp * dy^2);
%Bi = 


%% Update Temps
dTdt = zeros(size(rho));
%Hot Wall
dTdt(1) =  1./(dy*rho(1).*Cp(1)) .* (q_hw + k(1).*(TVec(2) - TVec(1))./dy);

%Middle Components
for i = 2:Sim.N-1
    %Non-Boundary/Middle Nodes
    dTdt(i) = k(i)./(rho(i).*Cp(i)).*(TVec(i+1) - 2.*TVec(i) + TVec(i-1))./dy.^2;
end

%Inner Wall
T_int = TVec(Sim.N); % ADIABATIC FOR NOW
dTdt(end) = k(end)./(rho(end).*Cp(i)).*(T_int - 2.*TVec(end) + TVec(end-1))./dy.^2;







end

