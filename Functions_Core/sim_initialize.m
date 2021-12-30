function [Sim, Flight, Wall, Abl] = sim_initialize(Sim, Flight, Wall, Abl)
% Generates/pre-allocates the derived structs required for use in the Thermal Sim
%{
Purpose: Takes in the data structs from the base configuration, and pre-allocates all the necessary data
    structs necessary for simulation, and adds them to the respective structures

INPUTS:
    -Sim: Struct containing Sim parameters
    -Flight: Struct containing Flight data
    -Wall: Struct Containing Wall wall data
    -Abl: Struct containing Ablative wall data
    
OUTPUTS:
    -Sim: Struct containing Sim parameters
    -Flight: Struct containing Flight data
    -Wall: Struct Containing Wall wall data
    -Abl: Struct containing Ablative wall data

NOTES/Future Improvements: 
-
%} 


%% SIM STRUCTURE
Sim.q_hwVec = zeros(1,length(Sim.t));          %[W.m^2] Hot Wall Heat Flux Vector
Sim.hVec = zeros(1,length(Sim.t));                 %Heat Transfer Coeff vector with time
Sim.tRecoVec = zeros(1,length(Sim.t));          %Recovery Temp vector with time

%% WALL STRUCTURE 
% This provides the derived structures for the Structural (assumed non-ablative) Wall
    
%Pre-allocate Temperature data structures
if(~isempty(Wall))
    Wall.coords = linspace(0, Wall.delta, Sim.N); %[m]
    % Simply a vector containing the the coordinates of the node edges in the through-wall direction for the
    % structural layer
    
    Wall.TVec = zeros(Sim.N,length(Sim.t));                                      %[K] Temperature of Each Structure Wall Element w/ Time
    Wall.TVec(:,1) = Sim.T0*ones(Sim.N,1);                                   %[K] Initialize Material Temperature at t=0
end

    

%% ABLATIVE STRUCTURE
Abl = initAblate(Sim, Abl, Sim.t);



%% FLIGHT STRUCTURE
%Reads in Flight data, organizes 

% Special Case: Read in HiFire Data
if strcmp(Flight.filepath, 'HiFire')
    [Flight.t, Flight.M, Flight.v, Flight.alt] = ConvertHiFire();
    
    % Special Case: Read in HiFire5B Data
elseif strcmp(Flight.filepath, 'HiFire5B')
    [Flight.t, Flight.M, Flight.v, Flight.alt] = ConvertHiFire5B();
    
    % Special Case: No flight profile (used for Arcjet verification case)
elseif strcmp(Flight.filepath, 'NA')
    Flight = [];
    
    %Default: Read in General Flight data
else
    [Flight.t, Flight.M, Flight.v, Flight.alt] = flightData(Flight.filepath);
end



end

