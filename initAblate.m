function [Abl] = initAblate(Sim, Abl, t)
%INITABLATE Initializes all of the vectors associated with the Ablative Analysis
% Sets required vectors as empty if not present

%If Ablative Struct is not empty
if(~isempty(Abl))
    
    %Ablative Wall Vectors
    Abl.deltaVec = zeros(1,length(t));                                      %[m] Total Material Thickness vs. Time
    Abl.TVec = zeros(Sim.N,length(t));                                    %[K] Temperature of Each Ablative Element w/ Time
    Abl.rhoVec_tot = zeros(Sim.N,length(t));                                 %[kg/m^3] Element Total Material Density
    Abl.rhoVec_comp = zeros(Sim.N,length(t), Abl.nSpec_ab);         %[kg/m^3] Element Component Material Densities (STACKED MATRICES FOR EACH COMPonent)
    %Temperature Probe for Ablative Vector
    Abl.tempProbeVec = zeros(length(Abl.tempProbe), length(t));    %[K] Temperature Probe values
    %Im just gonna start outputting everything for debugging maybe
    Abl.sDotVec = zeros(1,length(t));                                            %[m/s] recession rate
    Abl.etaVec = zeros(1,length(t));                                               %[m/s] blowing coeff
    
    
    %Init Initial values
    Abl.deltaVec(1) = Abl.delta0_ab;                                             %[m] Initial Ablative Thickness
    Abl.TVec(:,1) = Sim.T0*ones(Sim.N,1);                                      %[K] Initial Material Temperature
    Abl.rhoVec_tot(:,1) = Abl.rho0*ones(Sim.N,1);                                 %[Kg/m^3] Initalize Material Density
    Abl.rhoVec_comp(:,1,1) = Abl.rho_v_comp(1)*ones(Sim.N,1);            %Ablative Components...
    Abl.rhoVec_comp(:,1,2) = Abl.rho_v_comp(2)*ones(Sim.N,1);           %
    Abl.rhoVec_comp(:,1,3) = Abl.rho_v_comp(3)*ones(Sim.N,1);           %
    

%If No Ablative Specified, set as empty (redundant?)
else
    Abl = [];
end


end

