function [Abl, Sim] = AerothermalWallFlux(Sim, Wall, Abl, Flight, t, dt, i)
%AerothermalWallFlux implements the aerothermal heating model
% given in Ulsu


%% Get Atmospheric/FreeStream Properties at t, based on flight profile
[M_inf, T_inf, a_inf,P_inf, P_0_inf, rho_inf, gam] = getAtmospheric(t, Flight);


%% Calculate Local Properties (Shock Interactions)
%Sounds like Ulsu-Simsek is using Normal Shocks....??
%Using 2D Oblique Wedge Relations RN
%Definitely can upgrade to 3D Conical Solution if necessary

%Get Flow properties downstream of shock
if M_inf<=1
    % SUBSONIC:
    M_L   = M_inf;     % ASSUMING M_Local = M_inf FOR SUBSONIC
    T_L   = T_inf;           % ASSUMING T_L = T_inf FOR SUBSONIC
    P_L   = P_inf;            % ASSUMING P_L = P_inf FOR SUBSONIC
    %rho_L = rho_inf;         % ASSUMING rho_L = rho_inf FOR SUBSONIC
    %P_0_L = P_0_inf;
else
    % SUPERSONIC (OBLIQUE/NORMAL SHOCK CALC):
    beta  = normal_oblique_shock(Sim.theta, M_inf, gam);
    Mn1   = M_inf*sin(beta); %Handles both Oblique and Normal, as above fn returns pi/2 if normal
    
    [Mn2, p2op1, rho2orho1, t2ot1, ~, p02op01 ] = shock_calc(Mn1, gam);
    % Determine Mach downstream of Shock
    % CHECK/VERIFY
    if beta < pi/2 % IF OBLIQUE SHOCK
        M_L   = Mn2/sin(beta-Sim.theta);
    else
        M_L   = Mn2;
    end
    

    %If just normal shock
    %[mach, t2ot1, p2op1, rho, M_L, P0, P1] = flownormalshock(1.4, M_inf);

    %P_0_L = p02op01*P_0_inf;
    P_L   = p2op1*P_inf;
    T_L   = t2ot1*T_inf;
    %v_L   = M_L*sqrt(gam*Sim.Rair*T_L);
    %rho_L = rho2orho1 * rho_inf;
end


%If no ablative, use structural wall as exposed wall, do not correct for blowing
if(isempty(Abl))
    
    %% Calculate Heat Transfer Coefficient
    [Sim.hVec(i), Sim.tRecoVec(i), ~] = aerothermal_coeff(Sim, Wall.TVec(1,i), M_L, T_L, P_L, gam);
    %% Calculate Hot Wall Heat Flux
    [Sim.q_hwVec(i), ~] = aerothermal_heatflux(Sim, Sim.hVec(i), Sim.tRecoVec(i), Wall.TVec(1,i), T_inf, 1);
   
    %% Stability Criterion Check
    checkStability(Sim, Wall, Abl, dt, i)
    
    
%If ablative, use ablative material for exposed wall. Correct for blowing
else
    
    %% Calculate Heat Transfer Coefficient
    [h, Sim.tRecoVec(i), lam] = aerothermal_coeff(Sim, Abl.TVec(1,i), M_L, T_L, P_L, gam); %Uses ablative temp vec, as that represents exposed wall
    %% Calculate Unblown Hot Wall Heat Flux
    [q_hw_unblown, h] = aerothermal_heatflux(Sim, h, Sim.tRecoVec(i), Abl.TVec(1,i), T_inf, 1);
    
    
    %% Ablation Analysis
    %Get Density change of components and total, gas mass flow from continuity
    [dRho, dRho_comp, mDot_g] = pyrolysisGas(Sim, Abl, i);
    
    %Calculate surface ablation, total mass flowrate
    [Abl.sDotVec(i), mDot_tot] = mDot_Ablate(Abl, i, mDot_g, q_hw_unblown);
    
    %Calculate the Blowing factor correction
    Abl.etaVec(i) = aerothermal_BlowingFactor(mDot_tot, h, lam);
    
    %Correct heat flux with above Blowing correction
    Sim.q_hwVec(i) = aerothermal_heatflux(Sim, h, Sim.tRecoVec(i), Abl.TVec(1,i), T_inf, Abl.etaVec(i));
    Sim.hVec(i) = h*eta;
    
    %% Stability Criterion Check
    checkStability(Sim, Wall, Abl, dt, i)
    
    
    %% Update Ablative Thicknesses and Densities
    % Update Thickness
    Abl.deltaVec(1,i+1) = Abl.deltaVec(i) + Abl.sDotVec(i) * dt;
    % Update Densities
    Abl.rhoVec_tot(:,i+1) = Abl.rhoVec_tot(:,i) + dRho*dt ;
    Abl.rhoVec_comp(:,i+1,:) = squeeze(Abl.rhoVec_comp(:,i,:)) + dRho_comp*dt;
    
end 
end

