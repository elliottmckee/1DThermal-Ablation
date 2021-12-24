%% CEA_Table_Assembly
%Elliott McKee
%10/24/2021


%{
Overview:
-This script serves as a tool to combine the data from many CEA Runs, into a single lookup table, for usage in
the main script. 
-This is driven by the desire for relatively high-fidelity lookup tables, but CEA has limits on temperature
and pressure evaluations


Atmospheric Model Notes:
-

Instructons:
- 

Dependancies:
-

%}


%% Housekeeping
clc;clear;close all;



%% Read in and assemble mega table
files = dir ('*.txt');

%Big Data Structure
Data.t = [];
Data.p = [];
Data.rho = [];
Data.h = [];
Data.s = [];
Data.gam = [];
Data.u = [];
Data.cp = [];



for i = 1:size(struct2table(files), 1)
    %Read in each file
    temp = readtable(files(i).name);
    
    %Append together
    Data.t = [ Data.t; temp.t];
    Data.p = [Data.p; temp.p];
    Data.rho = [Data.rho; temp.rho];
    Data.h = [Data.h; temp.h];
    Data.s = [Data.s; temp.s];
    Data.gam = [Data.gam; temp.gam];
    Data.u = [Data.u; temp.u];
    Data.cp = [Data.cp; temp.cp];

end


%% Convert to Table, Sort temps
%This should handle all the sorting needed, as if there is ties in the first column, it sorts using the second
%column
Data =  sortrows(struct2table(Data));


%% Partition into AirModel Struct

%Temperature Vector
AirModel.t =  unique(Data.t);
%Pressure Vector
AirModel.p = unique(Data.p) * 100000; %[BAR to PA]

%Properties
AirModel.rho = reshape(Data.rho, length(AirModel.t), length(AirModel.p))'; 
AirModel.h = reshape(Data.h, length(AirModel.t), length(AirModel.p))'; 
AirModel.s = reshape(Data.s, length(AirModel.t), length(AirModel.p))'; 
AirModel.gam = reshape(Data.gam, length(AirModel.t), length(AirModel.p))'; 
AirModel.u = reshape(Data.u, length(AirModel.t), length(AirModel.p))'; 
AirModel.cp = reshape(Data.cp, length(AirModel.t), length(AirModel.p))'; 


%% Request Notes on Atmospheric Model
% AirModel.units = { 'K'; 'Pa'; 'Kg/m^3'; 'KJ/Kg'; 'KJ/KgK'; '-'; 'KJ/Kg'; 'KJ/KgK'}; 
% 
% 
% str = input('Enter any notes relevant to the Atmospheric Model: \n','s');
% AirModel.notes = str;
% 
% 
% %% Save File
% save('AirModel_N2_O2only', 'AirModel')


%% Load in Previous Data


%% Verification plots
figure()

subplot(2,3,1)
surface( AirModel.p, AirModel.t, AirModel.rho)

view(3)
title('Density')
xlabel('Pres. [bar]')
ylabel('Temp [K]')

subplot(2,3,2)
surface( AirModel.p, AirModel.t, AirModel.h)
view(3)
title('Enthalpy')
xlabel('Pres. [bar]')
ylabel('Temp [K]')

subplot(2,3,3)
surface( AirModel.p, AirModel.t, AirModel.s)
view(3)
title('Entropy')
xlabel('Pres. [bar]')
ylabel('Temp [K]')

subplot(2,3,4)
surface( AirModel.p, AirModel.t, AirModel.gam)
view(3)
title('Gamma')
xlabel('Pres. [bar]')
ylabel('Temp [K]')

subplot(2,3,5)
surface( AirModel.p, AirModel.t, AirModel.u)
view(3)
title('Internal Energy')
xlabel('Pres. [bar]')
ylabel('Temp [K]')

subplot(2,3,6)
surface( AirModel.p, AirModel.t, AirModel.cp)
view(3)
title('Specific Heat')
xlabel('Pres. [bar]')
ylabel('Temp [K]')



%Refined Spline interpolated version of density
[Xref, Yref] = meshgrid(linspace(AirModel.p(1), AirModel.p(end), 100), linspace(AirModel.t(1), AirModel.t(end), 100));
Vq = interp2(AirModel.p, AirModel.t, AirModel.rho, Xref, Yref, 'spline', 10);

figure()
surface( Xref, Yref, Vq)
view(3)
xlabel('Pressure')
ylabel('Temperature')

















