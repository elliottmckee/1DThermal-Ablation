function [] = plotting_abl_arcjet(t, Sim, Abl, Recess_tot)
%PLOTTING_ABL_ARCJET Summary of this function goes here
%   Plots ablative Stuff. Plots Alongside Arcjet verification data

%THIS HAS NOT BEEN UPDATED TO NEW STRUCT OUTPUT FRAMEWORK


%% Load Verification Data
tempDistData = readtable('verify_TempDist.csv');
tempTimeData = readtable('verify_TempVTime.csv');
densityDistData = readtable('verify_DensityDist.csv');
covingThermoData = readtable('CovingtonDataDist.csv');


%% Calculations for Plotting
%Time Index/Probe for Distribution Plots
tProbe = 15; %[s]
temp = find(t<=tProbe);
tProbe_ind = temp(end);

%Calculate Element Thickness at Probe Point
yProbe = 0:Abl.deltaVec(tProbe_ind)/(Sim.N-1):Abl.deltaVec(tProbe_ind);


%% Surface Temp v. Time
figure()
%subplot(2,2,1)
hold on
%Simulated
plot(t,Abl.TVec(1,:)-273.1,'LineWidth', 2)
%plot(t,TVec(Sim.N/2,:))
%plot(t,TVec(Sim.N,:))

%Verification
plot(tempTimeData.PyroX,tempTimeData.PyroY, '--')
plot(tempTimeData.Cov2004X,tempTimeData.Cov2004Y, '--')
plot(tempTimeData.UsluX,tempTimeData.UsluY, '--')

axis([0 30 0 3500])
grid minor
title('Surface Temp v. Time')
xlabel('Time (s)')
ylabel('Temp (C)')
legend('Simulation', 'CovtonPyro', 'CovtonSimulated', 'Simsek (trying to copy)',  'location', 'southeast')


%% Heat Flux v. Time
figure()
subplot(2,2,2)
plot(t, Sim.q_hwVec)
grid minor
title('Heat Flux v. Time')
xlabel('Time (s)')
ylabel('Heat Flux')


%% Thickness v. Time
subplot(2,2,3)
plot(t, Abl.deltaVec)
grid minor
title('Thickness v. Time')
xlabel('Time (s)')
ylabel('Thickness')


%% Surface Density v. Time
subplot(2,2,4)
hold on
plot(t, Abl.rhoVec_tot(1,:))
plot(t, Abl.rhoVec_tot(Sim.N/2,:))
plot(t, Abl.rhoVec_tot(Sim.N,:))
grid minor
title('Surface Density v. Time')
xlabel('Time (s)')
ylabel('Density')
legend('HotWall', 'Half', 'InnerWall')


%% Temperature Distribution at tProbe
figure()
hold on
plot(yProbe, Abl.TVec(:,tProbe_ind)-273.1,'b') %[K]
xline(yProbe(end), 'b--') %[K] 
plot(yProbe+Recess_tot, Abl.TVec(:,tProbe_ind)-273.1,'b:') %[K] Subtract Recess offset

%Verify
plot(tempDistData.Var1/1000,tempDistData.Var2, 'r')
%xline(tempDistData.Var1(end)/1000, 'r--')
xline(24.64/1000, 'r--') %Acutal Simsek final value
title('Temperature Thru-Wall Distibution')
xlabel('Thru-Wall Dist (m)')
ylabel('Temp (C)')
axis([0 .0274 0 3000])
grid minor
legend('Simulated', 'Simulated Post Recession Width', 'Simulated w/ Recession Offset','Simsek', 'Simsek Post-Recession Width')


%% Density Distribution at tProbe
figure()
hold on
plot(yProbe, Abl.rhoVec_tot(:,tProbe_ind),'b')
plot(yProbe+Recess_tot, Abl.rhoVec_tot(:,tProbe_ind),'b:')
%Verify
plot(densityDistData.Var1/1000,densityDistData.Var2, 'r--')
title('Density Thru-Wall Distibution')
xlabel('Thru-Wall Dist (m)')
ylabel('Density (Kg/m^3)')
grid minor
legend('Simulated', 'Simulated w/ Recession Offset', 'Simsek')



%% Compare w/ COVINGTON THERMOCOUPLE DATA
%Probe Temp v. Time
figure()
hold on
%Simulation Probe Data
plot(t(1:end-1), Abl.tempProbeVec(1,1:end-1)-273.1, 'r', 'LineWidth', 2)
%FIAT
plot(covingThermoData.FIAT__52cm(6:20) - covingThermoData.FIAT__52cm(6), covingThermoData.Var8(6:20), '--r')
%Covington Thermocouple
plot(covingThermoData.TC1__52cm(7:22) - covingThermoData.TC1__52cm(7), covingThermoData.Var2(7:22), 'sr')

plot(t(1:end-1), Abl.tempProbeVec(2,1:end-1)-273.1, 'c', 'LineWidth', 2)
plot(covingThermoData.FIAT_1_02cm(6:25) - covingThermoData.FIAT_1_02cm(6), covingThermoData.Var10(6:25), '--c')
plot(covingThermoData.TC2_1_02cm(6:13) - covingThermoData.TC2_1_02cm(6), covingThermoData.Var4(6:13), 'sc')

plot(t(1:end-1), Abl.tempProbeVec(3,1:end-1)-273.1, 'b', 'LineWidth', 2)
plot(covingThermoData.FIAT_1_76cm(5:10) - covingThermoData.FIAT_1_76cm(5), covingThermoData.Var12(5:10), '--b')
plot(covingThermoData.TC3_1_76cm(7:12) - covingThermoData.TC3_1_76cm(7), covingThermoData.Var6(7:12), 'sb')

axis([0 16 0 1600])
grid minor
title('Sim+Thermocouple Temperature at Specified Depths v. Time')
xlabel('Time (s)')
ylabel('Temp (C)')
legend('Sim- .52cm', 'FIAT- .52cm', 'TC-.52cm', 'Sim-1.02cm', 'FIAT- 1.02cm' , 'TC-1.02cm', 'Sim- 1.76cm', 'FIAT- 1.76cm' , 'TC-1.76cm',  'location', 'northwest')


%% OTHER
%Eta v. Time
figure()
subplot(2,1,1)
hold on
plot(t, Abl.etaVec)
grid minor
title('EtaVec v. Time')
xlabel('Time (s)')
ylabel('Eta')

%sDot v. Time
subplot(2,1,2)
hold on
plot(t, Abl.sDotVec)
grid minor
title('sDot v. Time')
xlabel('Time (s)')
ylabel('sDot')


end

