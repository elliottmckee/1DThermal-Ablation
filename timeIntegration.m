function [Sim, Abl, Wall] = timeIntegration(t, Sim, Wall, Abl, Flight)
%timeIntegration Handles the forward time-stepping, finite difference
%integration for the wall defined in parameters.m. This should be able to
%handle Ablative, Structural, and Ablative+Structural wall configurations.

%For Ablative, calculates the rate of change of material thickness, element temp,
%element density, and elemental component densities.

%For structural, just calculates the element temperatures pretty much.

%ODE45 DOESNT WORK FOR THIS SINCE RECURSION OF Q_HW terms
    %ACUTALLY CAN LIKELY DO NOW, SINCE NO MORE RECURSION ISSUE

%{
Handles the Initialization of the output vectors, and the main time loop
for the forward time integration.

NOTES:
%}


%% Initialize Vectors
%Vectors Required for all Analysis
Sim.q_hwVec = zeros(1,length(t));          %[W.m^2] Hot Wall Heat Flux

%Structural Wall Vectors
if(~isempty(Wall))
    Wall.TVec = zeros(Sim.N,length(t));                                      %[K] Temperature of Each Structure Wall Element w/ Time
    Wall.TVec(:,1) = Sim.T0*ones(Sim.N,1);                                   %[K] Initialize Material Temperature at t=0
end

%Ablative Vectors Initialization
Abl = initAblate(Sim, Abl, t);

%Other additional vectors for Debugging n whatnot
Sim.hVec = zeros(1,length(t)); %Heat Transfer Coeff
Sim.tRecoVec = zeros(1,length(t)); %Recovery Temp


%% Calculated Values
%Timestep size (requires linear timestep)
dt = t(2)-t(1);


%% Main Time Loop
for i = 1:length(t)-1
    
    
    %% Calculate Hot Wall Heat Flux, Ablative Densites, etc. if exist
    %Calculate Heat Flux based on Environment Specified
    if(strcmp(Sim.thermalModel, 'Aerothermal'))
        %Aerothermal Modelling
        [Abl,  Sim]  = AerothermalWallFlux(Sim, Wall, Abl, Flight, t(i), dt, i);
        
    elseif(strcmp(Sim.thermalModel, 'Arcjet'))
        %Arcjet Heating q_hw function
        [Abl, Sim] = ArcjetTestCase(Sim, Abl, dt, i);
        
    else
        error('Error in Hot Wall Heat Flux Specification. See "Sim.hotWallCase"')
    end
    
    
    
    
    %% Get Temperature Rate of Change
    %Actually calcualtes the finite difference heat conduction through wall
    if(isempty(Wall))
        %If no wall, Ablative Only
        [Sim, Abl] = tempChange_abl(Sim, Abl, i, dt);
        
    elseif(isempty(Abl))
        %If no Abl, Structure Wall Only
        [Sim, Wall] = tempChange_wall(Sim, Wall, i, dt);
        
    else
        error('ADD BOTH MODELING HERE')
    end
    
    
    %% Save Temperature Probe Values for Ablative Layer
    if (~isempty(Abl) && ~isempty(Abl.tempProbe))
        Abl.tempProbeVec(:,i) = tempProbe(Sim, Abl, Abl.deltaVec(i), Abl.TVec(:,i));
    end
    
    
end
end

