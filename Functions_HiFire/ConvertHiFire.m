function [tNew, MachNew, vNew, altNew] = ConvertHiFire()
%% Convert HiFire Data
%Elliott McKe

%{
I have the following HiFire Data: [t, v, alt]
-Taken from a digitized plot of what is given in Ulsu- likely not very
accurate

Want: [t, M, v, alt]
%}

%% Calcualate Mach v. Time
vel_time = readtable('HiFire_Velocity_ms.csv');
alt_time = readtable('HiFire_Alt_m.csv');


%% Interpolate Values at every .01 Seconds
tNew = 0:.01:max(max(vel_time.Var1));

vNew = interp1(vel_time.Var1, vel_time.Var2, tNew, 'linear', 'extrap');
altNew = interp1(alt_time.Var1, alt_time.Var2, tNew, 'linear', 'extrap');

%Overwrite Negative Velocities with .01
vNew(vNew <= 0) = .01;


%% Calculate Mach at Every Point
%Get Atmoscoesa Speed of Sound
[~, a, ~, ~] = atmoscoesa(altNew);

%Calculate Mach
MachNew = vNew./a;

end

