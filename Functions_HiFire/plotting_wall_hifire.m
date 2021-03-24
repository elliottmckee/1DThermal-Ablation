function [] = plotting_wall_hifire(t, Sim, Wall, plot_hifire)
%PLOTTING_WALL 
%{
General Plotting function for Handling Wall properties.

plot_hifire chooses whether to plot Hifire data. 
%}

%Load HiFire data
HiFireTemps = readtable('HiFire_Temps.csv');
HiFire_h_TReco = readtable('HiFire_h_Treco.csv');


%Wall Temperatures SHOULD BE IN K
figure()
subplot(2,1,1)

hold on 
plot(t, Wall.TVec(1,:), 'r')        %Hot Wall 
plot(t, Wall.TVec(Sim.N,:), 'b') %Inner Wall
plot(HiFireTemps.SimsekData, HiFireTemps.Var2, '--') %Ulsu Data
plot(HiFireTemps.HiFire_5Data, HiFireTemps.Var4, '--', 'LineWidth',2) %HiFire Flighy Data
grid minor
title('Wall Temperatures')
xlabel('Time (s)')
ylabel('Temp (K)')
legend('Hot Wall', 'Inner Wall', 'Ulsu Data','HiFire Flight Data','location','Southeast')


%Heat Transfer and Recovery Temperature Plots
%figure()
subplot(2,1,2)

yyaxis left
hold on 
plot(t, Sim.hVec)        %Heat Transfer Coefficient
plot(HiFire_h_TReco.h, HiFire_h_TReco.Var2,'--')        %Simek-Ulsu Data
ylabel('Heat Transfer Coeff (W/m^2K)')
xlabel('Time (s)')

yyaxis right
hold on
plot(t, Sim.tRecoVec)        %Recovery Temperature
plot(HiFire_h_TReco.TRec, HiFire_h_TReco.Var4,'--')        %Simek-Ulsu Data

grid minor
ylabel('Recovery Temp (K)')
title('Heat Trans Coeff & Recovery Temp')
legend('h', 'Ulsu h Data', '$T_{recovery}$', '$Ulsu T_{Recovery}$', 'interpreter', 'latex','location','Southeast')


end

