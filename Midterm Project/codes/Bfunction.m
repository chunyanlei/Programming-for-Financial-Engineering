function Bvals = Bfunction(rbar, gamma, alpha, maturities)
%
% Function returns B(maturity) in the CIR model.
% P = exp(A(maturity) - B(maturity)*r)
%
% with the pseudo risk-neutral SDE parameterization 
%
% dr = gamma*(r-bar - r)dt + \sqrt{\alpha r} dX
%
% 'maturities' can be a vector.  If so, 'Bvals' is also a vector. 
%

psi = sqrt(gamma^2 + 2*alpha); 
expTerm = exp(psi*maturities) - 1; 

Bvals = 2*expTerm ./ ((gamma + psi)*expTerm + 2*psi); 

return
