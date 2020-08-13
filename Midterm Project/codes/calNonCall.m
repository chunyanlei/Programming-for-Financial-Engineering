function nonCall=calNonCall(rbar,gamma,alpha,facevalue,maturities,rt)

Avals=Afunction(rbar, gamma, alpha, maturities);
Bvals=Bfunction(rbar, gamma, alpha, maturities);
nonCall=exp(Avals- Bvals*rt)*facevalue;

return