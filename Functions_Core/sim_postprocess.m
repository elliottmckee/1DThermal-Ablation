function [] = sim_postprocess(config_filename, output_filename, Sim, Flight, Wall, Abl)
%SIM_POSTPROCESS Post processes a Sim instance xD
%{
This post-processing script serves two main functions:
1. To determine any calculated/derived values that are to be calculated at the end of the script
    EXAMPLES:
        - Integrating to get the total heat flux
        - Determining total surface ablation recession distance,
        - Max Temp
        - Literally can add anything you need here
2. To package together all the input and output files for a given sim instance into a single location
    This is for 2 main reasons:
        - To be able to look back at the inputs to a simulation, to check that eveything is set up correctly,
        etc.
        - To be able to run the following plotting functions directly from this centralized file, such that
        you don't have to run a new sim to modify the plotting script. 

%}


%% Postprocessing Calculations and Quantities of Interest
%Literally add anything else you could want or need here in terms of calculated values.

%Get total recession of ablative material
if(~isempty(Abl))
    Abl.Recess_tot = Abl.delta0_ab - Abl.deltaVec(end)
end


%Determine Max Structural Wall Temp of Outer (Hot) surface, get corresponding time at which that occurs
Wall.maxTemp_outer = max(Wall.TVec(1,:));
%Get timestep index corresponding to Max Hot Wall Temp
Wall.maxTemp_outer_index = find(Wall.TVec(1,:) == Wall.maxTemp_outer );
%Get time corresponding to Max Hot Wall Temp
Wall.maxTemp_outer_time = Sim.t(Wall.maxTemp_outer_index);

%Determine Max Structural Wall Temp of Outer (Hot) surface, get corresponding time at which that occurs
Wall.maxTemp_inner = max(Wall.TVec(end,:));
%Get timestep index corresponding to Max Hot Wall Temp
Wall.maxTemp_inner_index = find(Wall.TVec(end,:) == Wall.maxTemp_inner );
%Get time corresponding to Max Hot Wall Temp
Wall.maxTemp_inner_time = Sim.t(Wall.maxTemp_inner_index);


% Integrate Heat Flux
Sim.totalHeatLoad = trapz(Sim.t, Sim.q_hwVec); %[J/m^2]





%% Packaging together of all data 
% This takes the Sim files (Sim, Flight, Wall, Abl), and the corresponding config file that was used to generate them, 
% Into a single folder within /Output_Files

% Parse desired Output Foldername
[outfilepath, outfolder, ~] = fileparts(output_filename);

%If filepath is empty/not-specified, default to saving to /Output_Files
if isempty(outfilepath)
    outpath = 'Output_Files';
else
    outpath = outfilepath;
end

% Append Date/Timestamp to desired output foldername
outfolder = fullfile( outpath, strcat(outfolder, '_', datestr(now,'mm-dd-yyyy_HH-MM')));

% Copy Config File to Output Folder
mkdir(outfolder)
copyfile(config_filename, outfolder)

% Save Simulation Files
sim_fileout = fullfile(outfolder, 'sim_files_out.mat');
save( sim_fileout, 'Sim', 'Flight', 'Wall', 'Abl')



end

