function [ret]=HestonDiff(x)
%--------------------------------------------------------------------------
%PURPOSE: Computes the difference between Heston model price and market price
%RETURN: a vector of values 

%Parameters:x[kap,th,sig,rho,vt]     Let lda=0 according to risk neutral
%pricing

%--------------------------------------------------------------------------

St=2.858;
global strike;
K=strike;
r=0.037909;
global maturity_date;
global close_price;
T=(maturity_date-datenum(2017,12,29))/365;  % time to maturity
kap=x(1);
th=x(2);
sig=x(3);
rho=x(4);
vt=x(5);
lda=0;
HestonPriTmp=zeros(26,1);
diff=zeros(26,1);
for i=1:26
    HestonPriTmp(i)=HestonCall(St,K(i),r,sig,T(i),vt,kap,th,lda,rho);
    diff(i)=HestonPriTmp(i)-close_price(i);
end

ret=diff;

end


