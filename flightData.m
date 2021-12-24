function [t, M, v, alt] = flightData(filename)
%FLIGHTDATA Just pulls time, Mach, velocity, altitude data from a Sim file 
%NOT SURE IF OPENROCKET OR RAS

%Read In File
flight = readtable(filename);

%% RASAERO
t = flight{:,'Time_sec_'}; %[s]
M = flight{:,'MachNumber'};
v = flight{:,'Velocity_ft_sec_'} * 0.3048; %[m/s]
alt = flight{:,'Altitude_ft_'} * 0.3048; %[m/s]


end
