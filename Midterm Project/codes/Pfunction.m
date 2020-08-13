function Pvals = Pfunction(x,xdata, maturities)

% Dfunction produces a panel of spot rates 
% xdata is the instantaneous interest rate with T by 1 dimension
% x is the parameter values

rbar=x(1); gamma=x(2); alpha=x(3);
Avals = Afunction(rbar, gamma, alpha, maturities);

Bvals=Bfunction(rbar, gamma, alpha, maturities);
Pvals=zeros(length(xdata), length(maturities)); %Pvals is a T by d matrix

for i=1:size(xdata,1)
    
P=exp(Avals- Bvals*xdata(i));

% At each point in time, the CIR model produces a prediction for 
% the cross section of yields
Pvals(i,:)=P*100;

end


%