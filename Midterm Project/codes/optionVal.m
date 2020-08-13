function [optionPrice returnSeed] = ...
    optionVal(initialVal, CBFace, ...
                             CBMaturity, optionExpiration, ...
                             strike, knockOutLevel, ...
                             simSeed)

%
% This function returns the 'realized' simulated price for a knock-out
% call option on a ZCB.  
%
% Features of the call option are input arguments to this function,
% as is the current instantaneous interest rate 'initialVal'.  The
% interest rate follows a Vasicek process with pseudo risk-neutral dynamics
%
% drt = gamma*(rbar-rt)dt + sqrt(alpha*max(rt,0)) sigma dX
%
% A single simulation is produced, using the random number
% generator seed 'simSeed'.  The ending random number seed is
% returned as 'returnSeed'. 
%
%====================================================================
facevalue=[2.5,2.5,2.5,2.5,2.5,2.5,2.5,2.5,2.5,2.5,100];
maturities=[0.5,1,1.5,2,2.5,3,3.5,4,4.5,5,5];
% Initialize the random number generator
rng(simSeed); 

% Parameters of the process.  I could pass these through the
% function, but for illustrative purposes they are hard-wired here.
gamma=1.24;
alpha=1.2373;
rbar=0.04;

% How many time steps per year?
timeStepsPerYear = 252; 

% set up the time step Delta t and the squared time step 
deltat = 1/timeStepsPerYear;
sqrt_deltat = sqrt(deltat); 
optionExpiration=3;

% How big is a simulated path of r from the initial observation to
% T?  I need to keep track of r(t) from t=0 (the beginning) to
% t=(optionExpiration - Delta t).  These r's are used for
% discounting the option's payoff.  
totalNumSteps = optionExpiration*timeStepsPerYear;

% In Matlab it is faster to generate all random variables
% at once rather than one by one.  
randomVars = randn(totalNumSteps, 1); 

% Step through the entire path from beginning to end.  The option
% payoff is discounted by exp(-(Delta t)*sum(simulated r)).  This
% discount factor can be built up step-by-step through the path.
% Also calculate, at each step, the price of the ZCB, to evaluate
% the knock-out provision.   

oldr = initialVal;
optionStriked = 0; 
discountFactor = 1; 

interestRate=zeros(totalNumSteps,1);

for thisStep = 1:totalNumSteps
  discountFactor = discountFactor*exp(-deltat*oldr); 
  % retrieve the random realization for this step.  
  thisShock = randomVars(thisStep); 
  
  % Get the drift and diffusion of the SDE for this step.  
  driftTerm = gamma*(rbar - oldr);
  diffusionTerm = sqrt(alpha*(max(oldr,0)));

  % update the Euler simulated V.  
  newr = oldr + driftTerm*deltat + ...
         diffusionTerm*sqrt_deltat*thisShock;
  
  % Get ready to step forward in time by redefining the 'old' r.
  oldr = newr;
  interestRate(thisStep)=newr;
end

Avals=Afunction(rbar, gamma, alpha, 2);
Bvals=Bfunction(rbar, gamma, alpha, 2);
% What is the ZCB bond price at the expiration of the option?  
CB_at_expiration=0;
for i=7:11
    CB_at_expiration=CB_at_expiration+exp(Avals- Bvals*interestRate(totalNumSteps))*facevalue(i);
end

if (CB_at_expiration >knockOutLevel)
    optionStriked = 1; 
end
% calculate the option payoff.  
if (optionStriked) 
  optionPayoff = max(0, CB_at_expiration - strike);
else
  optionPayoff = 0;
end
optionPrice = optionPayoff*discountFactor; 

% send the current state of the random number generator back to the
% calling function. 
returnSeed = rng; 
return
