function partialZ = partial(x,xdata, maturities)

% Dfunction produces a panel of spot rates 
% xdata is the instantaneous interest rate with T by 1 dimension
% x is the parameter values

rbar=x(1); gamma=x(2); alpha=x(3);
Avals = Afunction(rbar, gamma, alpha, maturities);

Bvals=Bfunction(rbar, gamma, alpha, maturities);
Pvals=zeros(1, length(maturities)); %Pvals is a T by d matrix
    
P=exp(Avals- Bvals*xdata);
% At each point in time, the CIR model produces a prediction for 
% the cross section of yields
Pvals(:)=P*100;

partialZ=-Bvals.*Pvals;

end


%