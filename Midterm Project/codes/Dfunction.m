function [ Dvals ] = Dfunction(x,xdata, maturities)
% Dfunction produces a panel of spot rates 
% xdata is the instantaneous interest rate with T by 1 dimension
% x is the parameter values

rbar=x(1); gamma=x(2); alpha=x(3);
Avals = Afunction(rbar, gamma, alpha, maturities);

Bvals=Bfunction(rbar, gamma, alpha, maturities);

Dvals=zeros(length(xdata), length(maturities));

for i=1:size(xdata,1)
    
Pvals=exp(Avals- Bvals*xdata(i));

Dvals(i,:)=-log(Pvals)./maturities;  
% At each point in time, the CIR model produces a prediction for 
% the cross section of yields
end

