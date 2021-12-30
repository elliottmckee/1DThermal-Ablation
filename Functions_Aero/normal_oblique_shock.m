function [beta] = normal_oblique_shock(theta, M1, g)
%{
Author: Elliott McKee
1/21/2021

INPUTS:
-turning angle, theta
-Upstream Mach No, M1
-Gas Gamma Value, g
    
Outputs:
-Shock wave angle, beta

Overview: 
Attempts to solve the 2D Wedge T-B-M relation for a given theta, M, and gamma. If
fsolve returns that no solution is found, it is assumed that there is a
detached, approximately normal shock, and sets the shock angle to pi/2 (See Anderson, Fundamentals of Aerodynamics, p. 623)

Notes: 
-There isn't perfect aggreement w/ Chart in Anderson (Fundamentals of
Aerodynamics, p. 625)
-Appears to mostly pull the weak shock solution (desirable as strong
generally nonphysical), but no guarantee
-There are some cases, at low machs, (1-1.05)ish, that give non-physical
results for turning angles. These get overridden in if-elses below to a
normal shock
-Likely doesn't catch all possible error flags from fsolve. Throws error if
gets any un-handled error flags below. 
%}


%% Calculate Beta for Oblique/Normal Shocks
% Theta-Beta-M relation (See Anderson, Fundamentals of Aerodynamics, p. 624)
fun = @(beta) tan(theta)-2*cot(beta)*(M1^2*sin(beta)^2-1)...
               / (M1^2*(g + cos(2*beta)) + 2);

% Specify Fsolve tolerance
opts = optimoptions('fsolve','Display','off', 'FunctionTolerance',1e-8);
% Solve using Fsolve. If no solution, will throw an error flag
[beta_oblique,~,exitflag,~] = fsolve(fun, theta, opts);


%Check if M = 1. If equals one (or near 1), weird results happen. 
if (M1 == 1)
    %Set beta to normal shock solution, pi/2
    beta = pi/2;

%If exitflag == 1, "Equation solved. First-order optimality is small.
elseif (exitflag == 1 && beta_oblique < pi/2)
    %Use Oblique Solution
    beta = beta_oblique;

%If exitflag == -2, Equation not solved. See fsolve for more info
elseif (exitflag == -2 || beta_oblique >= pi/2)
    %Set beta to normal shock solution, pi/2
    beta = pi/2;
    
else
    error('Unknown exitflag or other error thrown using fsolve- check normal_oblique_shock')
end

end
