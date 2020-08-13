% Computer Programming in Financial Engineering
% Midterm Project 
% Question 1 (d)
% Simulate equition (2) by Euler method

%
% Code for simulating a process 
% drt = gamma*(rbar-rt)dt + sqrt(alpha*max(rt,0)) sigma dX
%
% Initialize the random number generator

clear
close all

myStartNum = 123;
rng(myStartNum); 

% set up the time step Delta t and the squared time step 
timeStepsPerYear = 252;
simulationHorizon=1; %one-year
% set up the time step Delta t and the squared time step
deltat = 1/timeStepsPerYear; 
sqrt_deltat = sqrt(deltat);
numSims=10000;
initialVal=0.02;  %r0=0.02

alpha=1.2373;
gamma=1.24;
rbar=0.04;

% How big is a simulated path of r from the initial observation to
% T?  

totalNumSteps = simulationHorizon*timeStepsPerYear;

allSim=zeros(numSims,totalNumSteps);
SimulatedValues=zeros(1,totalNumSteps);
SimulatedPaths=zeros(1,totalNumSteps);
rt=zeros(numSims,1);  

for thisSim = 1:numSims

  % start at the initial value 
  oldVal = initialVal;

  
  % more efficient to generate all random variables at once rather
  % than one by one, but this is not important.  
  randomVars = randn(totalNumSteps, 1); 

  % For this single simulation 'thisSim', step through the entire
  % path from beginning to end, re-calculating 'm' and 's' at each
  % step.  
  
  for thisDelta = 1:totalNumSteps
    
    % get the random realization for this step.  
    thisShock = randomVars(thisDelta); 
    
    drt=gamma*(rbar-oldVal)*deltat+sqrt(alpha*(max(oldVal,0)))*sqrt_deltat*thisShock;
    
    new_rt=drt+oldVal;
    
    SimulatedValues(1,thisDelta)=drt;
    SimulatedPaths(1,thisDelta)=new_rt;
        
    oldVal=new_rt;
    
    if thisDelta==totalNumSteps
        rt(thisDelta)=new_rt;
    end
    
  end
  allSim(thisSim,:)=SimulatedPaths;
end

%plot the first 50 paths
figure(2);
for i=1:50
    hold on
    plot(allSim(i,:));
end

title('50 Simulations of CIR model ')
ylabel('rt')
xlabel('time')
print('Simulation of CIR','-djpeg')

fprintf('    mean      std\n')
fprintf('%.4e  %6.4f\n',mean(rt),std(rt))
