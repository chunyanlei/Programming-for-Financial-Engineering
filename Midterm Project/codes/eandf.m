% Computer Programming in Financial Engineering
% Midterm Project 
% Question 1 (e)
% Rolling Window Estimation

clear
close all

dataFile='/Users/leichunyan/Desktop/PKU/大四下/金融工程软件编程/Midterm Project/USTreasSpotRates.xlsx'

%=================================================
%
% Read the spot rates, their maturities, and the dates
%
%=================================================

maturitiesInMonths = xlsread(dataFile, 'D4:O4');
maturitiesInYears=maturitiesInMonths/12;
spotRates = xlsread(dataFile, 'D5:O647'); 

year = xlsread(dataFile, 'A5:A647');
month = xlsread(dataFile, 'B5:B647');
day = xlsread(dataFile, 'C5:C647');

matlabDateNumber = datenum(year, month, day);

obs=size(spotRates,1);
r0=spotRates(:,1);


prices=zeros(size(spotRates));
for i=1:643
    for j=1:12
        prices(i,j)=100*exp(-spotRates(i,j)*maturitiesInYears(1,j));
    end
end

% Initial Guess of Parameters
rbar=0.04; 
gamma=1.24;
alpha=1.2373;

% Stack parameter guesses into a single vector

paravec_0=[rbar,gamma,alpha];

pricingErr=zeros(623,12);

%  Part of nonlinear least squares
for i=25:643
xdata=r0(i-24:i-1);  % The input of data

myfun=@(x,xdata) Pfunction(x,xdata,maturitiesInYears);


%class
[estimatedParas,renorm,residual]=lsqcurvefit(myfun,paravec_0,xdata,prices(i-24:i-1,:),0,inf);


rbar_hat=estimatedParas(1);
gamma_hat=estimatedParas(2);
alpha_hat=estimatedParas(3);


estimatedP=Pfunction(estimatedParas,r0(i),maturitiesInYears);
par=partial(estimatedParas,r0(i),maturitiesInYears);   %dZ/dr=-B*Z

for k=1:12
    % Each month after estimation, use the estimated CIR model to 
    % produce the relative pricing errors for the cross-section of bonds. 
    pricingErr(i-24,k)=(prices(i-24,k)-estimatedP(k))/estimatedP(k);
end

end

% report the results from 2007.1 to 2008.1
fprintf('--------------------------------------\n')
fprintf('-------Relative Pricing Errors--------\n')
for t=1:12
    fprintf('    2007.%02d    %8.4f\n',t,pricingErr(548-25+t,12))
end

fprintf('    2008.01    %8.4f\n',pricingErr(548-24+12,12))


%=================================
%
% Question 1 (f)
% A dynamic arbitrage strateg
%
%=================================
fprintf('  time     hedge ratio      maturity of most overpriced\n')
month=6;
strReturns=zeros(643-24,1);

Ut=zeros(643-24,1);
pait=zeros(643-24,1);
Wealth=100;
for s=25:642
    minErr=pricingErr(s-24,1);
    maxErr=pricingErr(s-24,1);
    maxErrID=1;
    minErrID=1;
    
    % search the min and max relative pricing error

    for k=1:12
        if pricingErr(s-24,k)<minErr
            minErr=pricingErr(s-24,k);
            minErrID=k;
        end
        if pricingErr(s-24,k)>maxErr
            maxErr=pricingErr(s-24,k);
            maxErrID=k;
        end
    end
    
    par=partial(estimatedParas,r0(s),maturitiesInYears);
    delta=par(maxErrID)/par(minErrID);
    
    % if the condition meets 
    if(maxErr>0 && minErr<0)
        % cause pai*Ut=Wt, Ut=Wt/pai
        pait(s-24)=-prices(s-24,maxErrID)+delta*prices(s-24,minErrID);
        Ut(s-24)=Wealth/(-prices(s-24,maxErrID)+delta*prices(s-24,minErrID));
        strReturns(s-24)=Ut(s-24)*((-prices(s+1-24,maxErrID)+delta*prices(s+1-24,minErrID))-(-prices(s-24,maxErrID)+delta*prices(s-24,minErrID)))/(Ut(s-24)*((-prices(s+1-24,maxErrID)+delta*prices(s+1-24,minErrID))));
        Wealth=Wealth+Ut(s-24)*((-prices(s+1-24,maxErrID)+delta*prices(s+1-24,minErrID))-(-prices(s-24,maxErrID)+delta*prices(s-24,minErrID)));
    end
    
    if s>=349 && s<=355
        %print the results from 1990.6-1990.12
        %fprintf('%d %d %.4f %.4f  %.4f  %.4f\n',maxErrID,minErrID,maxErr,minErr,par(maxErrID),par(minErrID));
        fprintf('1990.%02d  %10.4f    %16.2f\n',month,delta,maturitiesInYears(maxErrID));
        month=month+1;
    end

end

%a=strReturns>0
% bo
fprintf('Mean and Std of Historical Returns of the Dynamic Strategy\n')
fprintf('           mean          std\n')
fprintf('    %12.4f  %12.4f\n',mean(strReturns),std(strReturns))
