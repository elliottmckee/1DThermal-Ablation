%% CEA_INPUTS
%Elliott McKee
%10/24/2021


%{
Overview:
-Given desired P-T table lookup ranges, and a desire # of CEA runs that you can do while maintaining your
sanity, will give you the inputs to CEA for such a model. 
-Kinda annoying because need set interval, but CEA is really finicky as well
- CEA can only handle 12 inputs of t and p simultaneously

Atmospheric Model Notes:
-


Instructons:
- Use TABULATION output on online CEA- MUST USE FOLLOWING OUTPUT VARIABLES (order doesn't matter)
%{
1. t
2. p
3. rho 
4. h
5. s
6. gam
7. u
8. cp
%}

Dependancies:
-

%}


%% Housekeeping
clc;clear;close all;



%% Desired number of CEA Runs
%This will create an even lookup table, with resolution dictated by the number of CEA runs you want to do
%More CEA Runs = Higher resolution
nRuns = 4; %MUST HAVE INTEGER SQUARE ROOT (i.e. 1, 4, 9, 16, etc.)

%% Table Ranges
%Desire Temperature bounds for lookup tables
T_low = 200; %[K] desired lower bound for temperature
T_hi = 2300; %[K] desired upper bound for temperature

%Desire Pressure bounds for lookup tables
P_low = 0.5; %[Pa] desired lower bound for Pressure
P_hi = 101325; %[Pa] desired upper bound for Pressure


%% Discretize input ranges
T_Vec_old = linspace(T_low, T_hi, sqrt(nRuns)*12)'; %[K]
P_Vec_old = linspace(P_low, P_hi, sqrt(nRuns)*12)'; %[Pa]


%% Round Values
t_Diff = max(diff(round(T_Vec_old, 1)));
p_Diff = max(diff(round(P_Vec_old, 1)));


%% Re-construct Evaluation points that are evenly spaced, without too many decimals because fuck CEA
T_Vec = [];
P_Vec = [];


for i = 1:sqrt(nRuns)*12
    T_Vec = [T_Vec; T_Vec_old(1) + t_Diff*(i-1)];
    P_Vec = [P_Vec; P_Vec_old(1) + p_Diff*(i-1)];
end

%% Convert Pa to Bar
p_Diff = p_Diff / 100000;
P_Vec = P_Vec./100000;

%% Print the Inputs to CEA Run
ctr = 1;

for i = 1:sqrt(nRuns)
    for j = 1:sqrt(nRuns)
        fprintf('~~~~~~~~~~~~~~~~~~~\n')
        fprintf('CEA Run Input Deck %i: (check units)\n ', ctr)
        
        fprintf('\t Temperature (K): \n')
        fprintf('\t\t Low Value: %f\n',    T_Vec(12*(i-1) + 1))
        fprintf('\t\t High Value: %f\n', T_Vec(12*i) - .1*t_Diff)
        fprintf('\t\t Interval: %f\n\n', t_Diff)
        
        fprintf('\t Pressure (BAR): \n')
        fprintf('\t\t Low Value: %f\n',  P_Vec(12*(j-1) + 1)  )
        fprintf('\t\t High Value: %f\n', P_Vec(12*j) - .1*p_Diff)
        fprintf('\t\t Interval: %f\n\n', p_Diff )
        
        %Create .txt files
        filestr = sprintf('CEARUN%i_T_%.0f_%.0f_P_%.0f_%.0f.txt', ctr, T_Vec_old(12*(i-1) + 1), T_Vec_old(12*i), P_Vec(12*(j-1) + 1)*100000, P_Vec(12*j)*100000');
        fprintf('\t Filename: \n')
        fprintf(strcat('\t\t',filestr,'\n'))
        
        if isfile(filestr) 
            error('Filename Already exists')
        end
        
        fileID = fopen(filestr, 'wt');
        fclose(fileID);
        
        %Increment counter
        ctr = ctr+1;
    end
end

























