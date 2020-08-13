% Computer Programming in Financial Engineering
% Midterm Project 
% Question 1 (a)
% Caculating ZCB bond prices 

clear
close all

dataFile='~/Midterm Project/USTreasSpotRates.xlsx'

maturitiesInMonths = xlsread(dataFile, 'D4:O4');
maturitiesInYears=maturitiesInMonths/12;
spotRates = xlsread(dataFile, 'D5:O647'); 

year = xlsread(dataFile, 'A5:A647');
month = xlsread(dataFile, 'B5:B647');
day = xlsread(dataFile, 'C5:C647');

matlabDateNumber = datenum(year, month, day);

% Caculate the bond prices for each T and r     
% P=S*exp(-rT)

prices=zeros(size(spotRates));
for i=1:643
    for j=1:12
        prices(i,j)=100*exp(-spotRates(i,j)*maturitiesInYears(1,j));
    end
end

Mean=mean(prices)
Std=std(prices)

% print the results required: mean and std
fprintf('   maturity     mean     standard deviation\n')
for i=1:12
    fprintf('%8d   %10.2f   %10.2f\n',i,Mean(1,i),Std(1,i))
end
