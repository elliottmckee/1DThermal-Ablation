function [] = plotting_wall_hifire5B(t, Sim400, Wall400, Sim650, Wall650, Sim800, Wall800, Flight)
%PLOTTING_WALL 
%{
General Plotting function for Handling Wall properties.

plot_hifire chooses whether to plot Hifire data. 
%}

%Load HiFire data
Hf400 = readtable('5B_TempTime400');
Hf650 = readtable('5B_TempTime650');
Hf800 = readtable('5B_TempTime800');

%Covert Temps to K
Hf400.Temp = Hf400.Temp + 273;
Hf650.Temp = Hf650.Temp + 273;
Hf800.Temp = Hf800.Temp + 273;




%Wall Temperatures SHOULD BE IN K
figure()

subplot(1,3,1)
hold on 
%Simulated
plot(t, Wall400.TVec(1,:), 'r')        %Hot Wall 400
%Hifire5B Data
plot(Hf400.Time, Hf400.Temp, 'r--', 'LineWidth',1) %HiFire Flight Data

%grid minor
title('Wall Temperatures')
xlabel('Time (s)')
ylabel('Temp (K)')
legend('Sim-400mm', 'HF5B-400mm', 'location','Northwest')


subplot(1,3,2)
hold on 
plot(t, Wall650.TVec(1,:), 'b')        %Hot Wall 650
plot(Hf650.Time, Hf650.Temp, 'b--', 'LineWidth',1) %HiFire Flight Data
%grid minor
title('Wall Temperatures')
xlabel('Time (s)')
ylabel('Temp (K)')
legend('Sim-650mm', 'HF5B-650mm', 'location','Northwest')

subplot(1,3,3)
hold on 
plot(t, Wall800.TVec(1,:), 'm')        %Hot Wall 800
plot(Hf800.Time, Hf800.Temp, 'm--', 'LineWidth',1) %HiFire Flight Data

%grid minor
title('Wall Temperatures')
xlabel('Time (s)')
ylabel('Temp (K)')
legend('Sim-800mm', 'HF5B-800mm', 'location','Northwest')


%Heat Transfer and Recovery Temperature Plots
figure()
%subplot(2,1,2)

yyaxis left
hold on 
plot(t, Sim400.hVec)        %Heat Transfer Coefficient
%plot(HiFire_h_TReco.h, HiFire_h_TReco.Var2,'--')        %Simek-Ulsu Data
ylabel('Heat Transfer Coeff (W/m^2K)')
xlabel('Time (s)')

yyaxis right
hold on
plot(t, Sim400.tRecoVec)        %Recovery Temperature
%plot(HiFire_h_TReco.TRec, HiFire_h_TReco.Var4,'--')        %Simek-Ulsu Data

grid minor
ylabel('Recovery Temp (K)')
title('Heat Trans Coeff & Recovery Temp')
legend('h', 'Ulsu h Data', '$T_{recovery}$', '$Ulsu T_{Recovery}$', 'interpreter', 'latex','location','Southeast')


%% Plot Flight Profile
figure()

sgtitle('HiFire-5B Descent Profile')
subplot(1,2,1)
plot(Flight.t, Flight.M)
grid minor
title('Mach')
xlabel('Time (s)')
ylabel('Mach')

subplot(1,2,2)
plot(Flight.t, Flight.alt)
grid minor
title('Alt')
xlabel('Time (s)')
ylabel('Alt (KM)')




end

