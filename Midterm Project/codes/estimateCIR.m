% Computer Programming in Financial Engineering
% Midterm Project
% Question 1 (b)
% Estimating the CIR model

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


%  Part of nonlinear least squares

xdata=r0;  % The input of data

myfun=@(x,xdata) Pfunction(x,xdata,maturitiesInYears);


%class
[estimatedParas,renorm,residual]=lsqcurvefit(myfun,paravec_0,xdata,prices,0);


rbar_hat=estimatedParas(1);
gamma_hat=estimatedParas(2);
alpha_hat=estimatedParas(3);

fprintf('rbar_hat equals to %5.5f\n', rbar_hat)
fprintf('gamma_hat equals to %5.5f\n', gamma_hat)
fprintf('alpha_hat equals to %5.5f\n', alpha_hat)

