function [Sim, Abl] = tempChange_abl(Sim, Abl, i, dt)
%UPDATETEMPS Update Temperatures according to
%   finite difference method

%% Pulling Named Variables from Sim, Abl
TVec = Abl.TVec(:,i);
rho = Abl.rhoVec_tot(:,i);
q_hw = Sim.q_hwVec(i);
delta = Abl.deltaVec(i);

%% Calculated Values
% Calculate dy
dy = delta/(Sim.N - 1);
%Calculate Cp vs. Temp for Each Point
%Cp  = interp1(Abl.cpLUTab.Var1,Abl.cpLUTab.Var2, TVec,'spline', mean(Abl.cpLUTab.Var2));
Cp  = interp1(Abl.cpLUTab.Var1,Abl.cpLUTab.Var2, TVec,'linear', 'extrap');

%Calculate k vs. Temp for Each Point
%k  = interp1(Abl.kLUTab.Var1,Abl.kLUTab.Var2, TVec,'spline', mean(Abl.kLUTab.Var2));
k  = interp1(Abl.kLUTab.Var1,Abl.kLUTab.Var2, TVec,'linear', 'extrap');


% %CP and k as function of Temp CLIPPING ENDS INSTEAD OF EXTRAP
% Cp = zeros(Sim.N,1);
% k = zeros(Sim.N,1);
% Cp(TVec < Abl.cpLUTab.Var1(1)) = Abl.cpLUTab.Var2(1);
% Cp(TVec > Abl.cpLUTab.Var1(end)) = Abl.cpLUTab.Var2(end);
% Cp((TVec > Abl.cpLUTab.Var1(1)) & (TVec < Abl.cpLUTab.Var1(end))) = interp1(Abl.cpLUTab.Var1,Abl.cpLUTab.Var2, TVec((TVec > Abl.cpLUTab.Var1(1)) & (TVec < Abl.cpLUTab.Var1(end))), 'linear');
% k(TVec < Abl.kLUTab.Var1(1)) = Abl.kLUTab.Var2(1);
% k(TVec > Abl.kLUTab.Var1(end)) = Abl.kLUTab.Var2(end);
% k((TVec > Abl.kLUTab.Var1(1)) & (TVec < Abl.kLUTab.Var1(end))) = interp1(Abl.kLUTab.Var1,Abl.kLUTab.Var2, TVec((TVec > Abl.kLUTab.Var1(1)) & (TVec < Abl.kLUTab.Var1(end))), 'linear');

%Just Taking the mf mean
%k = ones(Sim.N,1)* mean(Abl.kLUTab.Var2(1:12));
%Cp = ones(Sim.N,1)* mean(Abl.cpLUTab.Var2);

%Playing with it to match data:
%k = ones(Sim.N,1)* mean(Abl.kLUTab.Var2(1:12));

    
%% Stability Check
%Numerical Stability Check for Surface Point? Idk its given in [1]
%DONT THINK WE CAN DO FOR TESTCASE
%Fo = k*dt/(rho(1) * Cp * dy^2);
%Bi = 


%% Get Temperature Rate of Change for Each Element
dTdt = zeros(size(rho));
%Hot Wall
dTdt(1) =  1./(dy*rho(1).*Cp(1)) .* (q_hw + k(1).*(TVec(2) - TVec(1))./dy);

%Middle Components
for j = 2:Sim.N-1
    %Non-Boundary/Middle Nodes
    dTdt(j) = k(j)./(rho(j).*Cp(j)).*(TVec(j+1) - 2.*TVec(j) + TVec(j-1))./dy.^2;
end

%Inner Wall
T_int = TVec(Sim.N); % ADIABATIC FOR NOW
dTdt(end) = k(end)./(rho(end).*Cp(j)).*(T_int - 2.*TVec(end) + TVec(end-1))./dy.^2;


%% Update Temps
Abl.TVec(:,i+1) = Abl.TVec(:,i) + dTdt * dt;


end

