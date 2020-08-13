% Computer Programming in Financial Engineering
% Midterm Project 
% Question 1 (g)
% Pricing of callable bonds
clear
close all

gamma=1.24;
alpha=1.2373;
rbar=0.04;

%=======================================================
%
%Caculate the non-callable part, which can be seemed as a ZCB with face 
%value 102.5 and maturity 5 years, also 10 ZCBs with face value 100*5%/2=2.5, 
%and maturity relatively 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5,5.
%
%=======================================================
rt=0.04;
facevalue=[2.5,2.5,2.5,2.5,2.5,2.5,2.5,2.5,2.5,2.5,100];
maturities=[0.5,1,1.5,2,2.5,3,3.5,4,4.5,5,5];
nonCall=0;

for i=1:11
    nonCall=nonCall+calNonCall(rbar,gamma,alpha,facevalue(i),maturities(i),rt);
end

%=======================================================
%
%Caculate the callable part, that is option value
%
%=======================================================


CBMaturity = 5;
CBFace = 100; 
optionExpiration = 3;
strike=100;
knockOutLevel = 100; 


r0 = 0.04;


numSims = 4000;
masterRandomSeed = 123; 
oldSeed = masterRandomSeed; 

 [optionPrice returnSeed] = ...
      optionVal(r0, CBFace, CBMaturity, ...
                               optionExpiration, ...
                               strike, knockOutLevel, ...
                                oldSeed);
%=====================================================

allOptionPrices = zeros(numSims, 1); 

oldSeed = masterRandomSeed; 
for thisSim = 1:numSims

  [optionPrice returnSeed] = ...
      optionVal(r0, CBFace, CBMaturity, ...
                               optionExpiration, ...
                               strike, knockOutLevel, ...
                                oldSeed);
  allOptionPrices(thisSim) = optionPrice; 

  % calculate up and down values of the option payoff, changing r0 by
  % epsilon.
 
  
  oldSeed = returnSeed;
end

callableVal=mean(allOptionPrices);
callableBondPrice=nonCall-callableVal;

fprintf('Noncallable part: %12.4f\n',nonCall)
fprintf('Callable part: %15.4f\n',callableVal)
fprintf('------------------------------\n')
fprintf('Callable Bond Price: %9.4f\n',callableBondPrice)