function eta = aerothermal_BlowingFactor(mDot, h_unblown, lam)
%BLOWINGFACTOR Calculates the Blowing Factor Given in [1]
% This is for the arcjet verification case given in [1]. 
% As such, values are hard-coded here


%NOTES:
%   -Uses Bianachi expression for Phi/Blowing correction
%   - Incorporates Recovery Factor

%% Phi
Phi = (2*lam*mDot) / h_unblown;

%% Blowing Factor
eta = Phi / (exp(Phi) - 1);

%mAtLaB cAnT rEsOlVe iNdEtErmiNanT fOrMS
if isnan(eta)
    eta = 1;
end 
end
