%% HiFire-5B Conversion
%Elliott McKee
%3/15/2021

%{
Juliano and the boys decided to be real dweebs and not give Altitude data
in their Hifire-5B reports. However, they did give Reynolds number and
mach. 

I need to back out the Altitude profile from the flight, in order to be
able to feed it into the thermal sim as another verification case. 

ASSUMING:
gamma = 1.4
R = 287 J/KgK
%}

%Requires additional STDATM function (for viscosity)
addpath('sky-s-standard-atmosphere-c9d2e35')

%% Housekeeping
clc;clear;close all;


%% Load HiFire-5B Data
MachData = readtable('5B_MachTime');
ReData = readtable('5B_ReTime');


%Need corresponding datapoints. Mach plot goes from 513 to 518 seconds Fig 6
tVec = linspace(513, 518, 100);

machVec = interp1(MachData.Time, MachData.Mach, tVec, 'linear', 'extrap');
ReVec = interp1(ReData.Time, ReData.Re, tVec, 'linear', 'extrap');



%%  Back out Estimated Altitude from Mach and Re
altVec = linspace(0,100000,1000);

%Get properties
air = atmos(altVec, 'structOutput', true);

%Get Dynamic Viscosity 
air.mu = air.rho.*air.nu;

% For a given Mach
for i = 1:length(tVec)

    %Evaluate Reynolds Number at every altitude. Compare to Given Re
    Re_error = abs(ReVec(i) - (air.rho .* machVec(i) .* sqrt(1.4*287 * air.T)) ./ air.mu);
    %Get Minimum value
    [~, minIndex] = min(Re_error);
    
    %Put Minimum value into altitude vector. 
    altEstimated(i) = altVec(minIndex);

end

%Re-construct Velocity
%Get properties
airEST = atmos(altEstimated, 'structOutput', true);
vVec = machVec .* sqrt(1.4 * 287 * airEST.T)



%Assemble relevant data
out = [tVec', machVec', vVec', altEstimated']


writematrix(out,'M.csv')


plot(tVec, altEstimated)