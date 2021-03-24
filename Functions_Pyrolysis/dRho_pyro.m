function [dRho] = PICA_pyro(rho, T)
%PICA_pyro Takes in vectors of element density, element component densities, and  temperature, 
% calculates the rate of change of the overall density of the Ablative
% material due to pyrolysis. HARD CODED VALUES FOR PICA ABLATIVE
%{
%AUTHOR: Elliott McKee
   
This is attempting to model equation 15 in [1]. In the state given there,
it models each of the different (Resin and Reinforcement) components.
Finding the required coefficients proved to be a challenge, and is
definitely somewhere that can be improved upon. 

CORK P-50 values can be found in,  Aerothermodynamics of Pre-Flight and
In-Flight Testing Methodologies for Atmospheric Entry Probes, Isil Sakraker 2016, 
SLACK ME IF I DONT POST IN DRIVE. It gives the Arrehnious Rate coefficients for 
two reactions that were seen in Thermogravimetric Analysis data. After a lot of work, and
tracking sources, I have mostly convinced myself that the rate coefficients
provided will perform identically in the differing forms of equations
between the documents. There is some nuance to this though, as arrhenious
coeffs are most often described on a per-component basis as discussed
above. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FOR THE LOVE OF ALL THINGS HOLY, PLEASE SOMEONE ACTUALLY VERIFY THIS SCRIPT SOMEHOW.
I can't even confirm that the units for R are correct for Isil. 
Check actual Universal Gas constant
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Also, I am going to hard code a lot of values here, for the time being.

I will also leave some math I needed to decode what was given in the doc
with the coeffs- just as a reference if needed

%}


%% Pyrolysis Reaction Values
%Using Test 1 values from [1], p.90
%Densities
rho_v = 466.66; %Kg/m^3 Virgin Density
rho_c = 298.38; %Kg/m^3 Char Density

%Arrhenius Coeffs
B = [4987.26 9999.98]; %[1/s?] Pre-Exponential Constants
E = [82678.65  51439.49]; %[no fucking idea fuck this guy] Activation Energies
N = [1.07 3.57]; %[-] Reaction Orders

%Ideal Gas Constant
R = 8.314; %[J/Kmol]

% Other Document Stuff
%alp = linspace(0,1,10)
%rho = rho_v - Alp .* (rho_v-rho_c);
% dAlp_i = B_i .* ((rho_v - rho_c) ./ rho_v) .^ (N_i-1) * (1-Alp_i) .^(N_i) .* exp(-E_i./(R*T)) ;
%Convert back to rho from alpha
%dRho =  - dAlp .* (rho_v-rho_c);

%% Density Change Calculation
[m,n] = size(rho);
dRho = zeros(m,n);

% For Each Reaction Component
for i = 1:length(B)
    %Calculate Change in Density
    dRho = dRho - B(i) .* exp(-E(i)./(R*T)) .* rho_v .* ((rho-rho_c)./rho_v).^N(i);
end


end

