function [probeTemps] = tempProbe(Sim, Abl, delta, TVec)
%TEMPPROBE Returns the interpolated temps described in Sim.tempProbe

% Create Y location vector
yVec = 0:delta/(Sim.N-1):delta;

%Interpolate to get temps at specific Y locations
probeTemps = interp1(yVec, flip(TVec), Abl.tempProbe);
end

