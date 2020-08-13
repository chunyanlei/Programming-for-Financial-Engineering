function Avals = Afunction(rbar, gamma, alpha, maturities)
%
% Function returns A(maturity) in the CIR model.
% P = exp(A(maturity) - B(maturity)*r)
%
% with the pseudo risk-neutral SDE parameterization 
%
% dr = gamma*(r-bar - r)dt + \sqrt{\alpha r} dX
%
% 'maturities' can be a vector.  If so, 'Avals' is also a vector. 
%

psi = sqrt(gamma^2 + 2*alpha); 

expTerm = exp(psi*maturities) - 1; 
expTerm2 = exp( 0.5*(psi + gamma)*maturities ); 

tmpTerm = 2*gamma*rbar/alpha; 

numer = 2*psi*expTerm2; 
denom = (gamma + psi)*expTerm + 2*psi; 

Avals = tmpTerm * log(numer ./ denom); 

return
