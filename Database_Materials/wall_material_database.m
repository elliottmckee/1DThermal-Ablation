function [Wall] = wall_material_database( material_type, Wall)
% Author: Elliott McKee
% Created: 12/24/2021

% For the wall material specified, returns the relevant material properties for use in the simulation

%The Material to be used must be specified in this script prior to the use of generate_config.m

% Will Return an error if you attempt to pull values from a material that is not-specified

%{
INPUTS: 
    -string material_type: string specifying the desired structural material (for options, see below, or add)
    -struct Wall: main struct that contains the Wall configration data

OUTPUTS: 
    - rho: material density [kg/m^3] 
    - Cp: material specific heat [J/Kg]
    - k: material thermal conductivity
%}

%% Database If-Else Chain (Could probably make into a dedicated struct if desired, but this seemed less error-prone)

%% ALUMUNUM 6061
if(strcmp(material_type, 'Al6061'))
    %Aluminum 6061 Properties pulled from Matweb: http://www.matweb.com/search/DataSheet.aspx?MatGUID=b8d536e0b9b54bd7b69e4124d8f1d20a
    Wall.rho = 2700; %[kg/m^3] Density
    Wall.Cp = 896; %[J/KgC] Specific Heat
    Wall.k = 167; %[W/mK]Thermal Conductivity

    
%% EPOXY (NOT VERY ACCURATE AT ALL)
elseif(strcmp(material_type, 'epoxy_placeholder'))
    %Very Rough Properties of Epoxy
    Wall.rho = 1107.2; %[kg/m^3] Aeropoxy Density https://www.aircraftspruce.com/catalog/cmpages/aeropoxy.php 
    Wall.Cp = 1000; %[J/KgC] Specific Heat of Epoxies https://www.sciencedirect.com/science/article/pii/S1359835X03003440
    Wall.k = .288; %[W/mK]Thermal Conductivity http://www.matweb.com/search/datasheet_print.aspx?matguid=8337b2d050d44da1b8a9a5e61b0d5f85
    
    
%% IF NO WALL SPECIFIED
elseif(strcmp(material_type, 'NA'))
    %Clear Wall, instatiate as empty struct
    clear Wall
    Wall = [];
    
    
%% ERROR CATCH
else
    error('Unsupported Wall Type')
end

end

