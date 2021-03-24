function [] = plotting_wall_hifire(t, Sim, Wall)
%PLOTTING_WALL 
%{
General Plotting function for Handling Wall properties.

plot_hifire chooses whether to plot Hifire data. 
%}


%Wall Temperatures SHOULD BE IN K
figure()
subplot(2,1,1)

hold on 
plot(t, Wall.TVec(1,:), 'r')        %Hot Wall 
plot(t, Wall.TVec(Sim.N,:), 'b') %Inner Wall
grid minor
title('Wall Temperatures')
xlabel('Time (s)')
ylabel('Temp (K)')
legend('Hot Wall', 'Inner Wall','location','Southeast')


%Heat Transfer and Recovery Temperature Plots
%figure()
subplot(2,1,2)

yyaxis left
hold on 
plot(t, Sim.hVec)        %Heat Transfer Coefficient
ylabel('Heat Transfer Coeff (W/m^2K)')
xlabel('Time (s)')

yyaxis right
hold on
plot(t, Sim.tRecoVec)        %Recovery Temperature

grid minor
ylabel('Recovery Temp (K)')
title('Heat Trans Coeff & Recovery Temp')
legend('h', '$T_{recovery}$', 'interpreter', 'latex','location','Southeast')


end

