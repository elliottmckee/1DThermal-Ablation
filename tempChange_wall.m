function [Sim, Wall] = tempChange_wall(Sim, Wall, i, dt)
%UPDATETEMPS Update Temperatures according to
%   finite difference method


%% Pulling Named Variables from Sim, Abl
TVec = Wall.TVec(:,i);
q_hw = Sim.q_hwVec(i);
delta = Wall.delta;


%% Calculated Values
% Calculate dy
dy = delta/(Sim.N - 1);

%% Material Properties
Cp = Wall.Cp;
rho = Wall.rho;
k = Wall.k;


%% Stability Check
%Numerical Stability Check for Surface Point? Idk its given in [1]
%DONT THINK WE CAN DO FOR TESTCASE
%Fo = k*dt/(rho(1) * Cp * dy^2);
%Bi = 


%% Update Temps
dTdt = zeros(size(TVec));
%Hot Wall
dTdt(1) =  1./(dy*rho.*Cp) .* (q_hw + k.*(TVec(2) - TVec(1))./dy);

%Middle Components
for j = 2:Sim.N-1
    %Non-Boundary/Middle Nodes
    dTdt(j) = k./(rho.*Cp).*(TVec(j+1) - 2.*TVec(j) + TVec(j-1))./dy.^2;
end

%Inner Wall
T_int = TVec(Sim.N); % ADIABATIC FOR NOW
dTdt(end) = k./(rho.*Cp).*(T_int - 2.*TVec(end) + TVec(end-1))./dy.^2;


%% Update Temperatures
Wall.TVec(:,i+1) = Wall.TVec(:,i) + dTdt * dt;

end

