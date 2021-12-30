function checkStability(Sim, Wall, Abl, dt, i)
%CHECKSTABILITY Performs the Stability Criterion Check given in Ulsu
%Performs check on surface/exposed element

%{
NOTES: 
-From Hifire testing, this check is  pretty spot on. If it throws an error
here, the results were boofed. If not, they were fine. Up to within .001s
tolerance, from my guessing and checking. 
%}

%% Pull Required Values of Surface Element
h = Sim.hVec(i);

%If No Ablative, Structure is exposed
if ( isempty(Abl) )
dy = Wall.delta/(Sim.N - 1);
rho_s = Wall.rho;
Cp_s = Wall.Cp;
k_s = Wall.k;

%If Ablative is exposed, more annoying to deal with but yeah
else
dy = Abl.deltaVec(i)/(Sim.N - 1);
rho_s = Abl.rhoVec_tot(1,i);
Cp_s  = interp1(Abl.cpLUTab.Var1,Abl.cpLUTab.Var2, Abl.TVec(1,i), 'linear', 'extrap');
k_s = interp1(Abl.kLUTab.Var1,Abl.kLUTab.Var2, Abl.TVec(1,i),'linear', 'extrap');
end
    


%% Perform Stability Check 
F0 = (k_s*dt) / (rho_s * Cp_s * dy^2);
Bi = (h*dy) / k_s;

if ( F0*(1+Bi) > .5)
    warning('Stability Criterion not met. Consider increasing time resolution (smaller time step) or \n decreasing the spatial wall resolution (decrease the number of wall nodes, Sim.N)')
end

end

