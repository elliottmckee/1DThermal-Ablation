function [TVec, MVec, VVec, altVec] = ConvertHiFire5B()
%% Convert HiFire Data
%Elliott McKe

%{
I have the following HiFire Data: [t, v, alt]
-Taken from a digitized plot of what is given in Ulsu- likely not very
accurate

Want: [t, M, v, alt]
%}

%% Calcualate Mach v. Time
Data = readtable('Hifire5BData.csv');

%Split Out Values
TVec = Data.Time;
MVec = Data.Mach;
VVec = Data.Velocity;
altVec = Data.Altitude;



end

