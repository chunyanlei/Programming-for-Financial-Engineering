% Chunyan Lei
% 2018.6.10

% Final Project
% Black-Scholes model & Heston model
% data: 50ETF call options which can be traded at 2017.12.29 (maturity:1m 2m 3m 6m)
% data source: Wind

%-----------------------------------------------------------------------------------
% 
% 1. Import 50ETF data(underlying asset) and find some propertis of it
%
%-----------------------------------------------------------------------------------

clear all
close all

data_asset='/Users/leichunyan/Downloads/50etf.xlsx'

% I don't know why I can't xlsread asset_value directly at this step
% So I use the way a little bit more complicated as follows:
[~,~,asset_value] = xlsread(data_asset, 'E2:E601');
asset_value=str2num(cell2mat(asset_value));   %change the format from cell to char and finally to num
[~,matlabDateVec]=xlsread(data_asset,'A2:A601');
[year,month,day]=datevec(matlabDateVec);
dateNumber = datenum(year, month, day);

S0=2.858;
r0=0.037909;
%1.1 NOT NORMAL DISTRIBUTION
%1.1.1
% This part is to show that 50ETF return is not normally distributed, that's the reason
% BS model can't meet the pricing needs
logr=zeros(600,1);
for i=1:599
    logr(i)=log(asset_value(i))-log(asset_value(i+1));
end

% From the picture, we can see that the distribution has high kurtosis and fat
% tail compared to normal distribution. So it's not normally distributed.
hist(logr,35);
title('Log Return Frequency')
ylabel('Freq')
xlabel('Log Return')
print('50 ETF Log Return Frequency','-djpeg');
% Another way which is more convincable: use JB test
isNormal=jbtest(logr);   %isNormal=1 shows that logr is not normally distributed.
logr_kurt=kurtosis(logr);  %>3 shows the high kurtosis property(cause the kurtosis of Normal distribution==3).
logr_skew=skewness(logr);  %<0 shows left-skewed

% 1.2 I mplied Volatility Smiles
% calculate the implied volatility of options on 2017.12.29
data_imp='/Users/leichunyan/Downloads/2017.12.29.xlsx';
maturities = xlsread(data_imp, 'G2:G27');
global strike;
global close_price;
strike=xlsread(data_imp,'D2:D27');
close_price=xlsread(data_imp,'O2:O27');

%sort by stirke in ascending order
[n,m]=size(maturities);
for s=1:n
    for k=1:(n-s)
        if strike(k)>strike(k+1)
           tmp1=strike(k);
           strike(k)=strike(k+1);
           strike(k+1)=tmp1;
           tmp2=maturities(k);
           maturities(k)=maturities(k+1);
           maturities(k+1)=tmp2;
           tmp3=close_price(k);
           close_price(k)=close_price(k+1);
           close_price(k+1)=tmp3;
        end
    end
end
    
% set the maturity date for each option
global maturity_date;
for i=1:26      % the 4th Wednesday if it is not legel holiday
    if maturities(i)==1  % maturity date is 2018.1.24
        maturity_date(i)=datenum(2018,1,24);
    elseif maturities(i)==2  %2018.2.28
        maturity_date(i)=datenum(2018,2,28);
    elseif maturities(i)==3  %2018.3.28
        maturity_date(i)=datenum(2018,3,28);
    else
        maturity_date(i)=datenum(2018,6,27);
    end
end

T=((maturity_date-datenum(2017,12,29))/365)';
global imp_vol;
for i=1:26
    imp_vol(i)=blsimpv(S0,strike(i),r0,(maturity_date(i)-datenum(2017,12,29))/365,close_price(i));
end

figure(2)
for i=[1,2,3,6]
    tmpx=[];
    tmpy=[];
    cnt=1
    for j=1:26
        if maturities(j)==i  % find the maturity equals to 1,2,3,6 months seperately
            tmpx(cnt)=strike(j);    %strike
            tmpy(cnt)=imp_vol(j);   %implied volatility
            cnt=cnt+1;
        end
    end
    plot(tmpx,tmpy)
    hold on
end
plot([S0 S0],[0.14,0.205],'--');
legend('1 month','2 month','3 month','6 month','Spot Price');
xlabel('Strike');
ylabel('Implied Volatility');
title('Volatility Smiles')
print('Volitility Smiles','-djpeg');
hold off

% 1.3 JUMPS
% whether there exists jump
% calculate the probabilities under which the daily change is above 3*stardand deviation
% and compare with the probabilty under normal distribution 
logr_std=std(logr);
cnt1=0;cnt2=0;cnt3=0;
for i=2:600
    if logr(i)-logr(i-1)>3*logr_std
        cnt3=cnt3+1;
    end
    if logr(i)-logr(i-1)>2*logr_std
        cnt2=cnt2+1;
    end
    if logr(i)-logr(i-1)>logr_std
        cnt1=cnt1+1;
    end
end

p1=cnt1/600;   %p1<31.7%   because of high kurtosis
p2=cnt2/600;   %p2>4.4%
p3=cnt3/600;   %p3>0.3%   i.e. there may be some extreme values

%-----------------------------------------------------------------------------------
% 
% 2. Option Pricing with Black-Scholes Model
%
%-----------------------------------------------------------------------------------

% Calculate the past 20 trading days' historical volatility (2017.12.1-2017.12.28)
% and annualize it.
[~,~,asset_value_past20] = xlsread(data_asset, 'E113:E132');
asset_value_past20=str2num(cell2mat(asset_value_past20));   %change the format from cell to char and finally to num
[~,matlabDateVec_past20]=xlsread(data_asset,'A113:A132');
[year_,month_,day_]=datevec(matlabDateVec_past20);
dateNumber_past20 = datenum(year_, month_, day_);

logr_past20=[];
for i=1:19
    logr_past20(i)=log(asset_value_past20(i))-log(asset_value_past20(i+1));
end

vol_past20_annual=std(logr_past20)*sqrt(252);

for i=1:26
    bs_price(i)=blsprice(S0,strike(i),r0,(maturity_date(i)-datenum(2017,12,29))/365,vol_past20_annual);
end 

% A graph of Black-Scholes Price and Real Market Price
figure(3)
for j=[1,2,3,6]
    cnt=1;
    for i=1:26
        if j~=6
            subplot(2,2,j)
        else
            subplot(2,2,4)
        end
        if maturities(i)==j
            strike_tmp(cnt)=strike(i);
            bs_tmp(cnt)=bs_price(i);
            close_tmp(cnt)=close_price(i);
            cnt=cnt+1;
        end
    end
    plot(strike_tmp,bs_tmp);
    hold on
    plot(strike_tmp,close_tmp);
    xlabel([num2str(j),'m']);
    ylabel('price');
    legend('BS price','Market Price');
    hold off
end
print('BS model result 2017.12.29','-djpeg');

%calculate the mean pricing error and std error 
for i=1:26
    ERR_BS(i)=bs_price(i)-close_price(i);
end

ME_BS=mean(ERR_BS);
std_BS=std(ERR_BS);

%-----------------------------------------------------------------------------------
% 
% 3. Option Pricing with Heston Model (Using Fourier pricing method)
%
%-----------------------------------------------------------------------------------
%Heston Calibration Driver
% 
% starting point for unknown coefficient x0
x0=[6.5482  0.0731  2.3012  -0.4176  0.1838];
%   kap       th      sig     rho        vt
% Call LevenbergMarquardt solver build in function to solve for
% unknown x and residual norm.
disp('Heston Model Calibrating......');
[x,resnorm]=lsqnonlin(@HestonDiff,x0,[],[]);
fprintf('----------------------------------------------\n');
fprintf('   kap     th     sig     rho     vt\n');
fprintf('%6.4f  %6.4f  %6.4f  %6.4f  %6.4f   \n',x(1),x(2),x(3),x(4),x(5));
fprintf('----------------------------------------------\n');
% compute Call option using parameters calibrated as x
for i=1:26
    heston_price(i)=HestonCall(S0,strike(i),r0,x(3),T(i),x(5),x(1),x(2),0,x(4));
end
%HestonCall(St,K,r,sig,T,vt,kap,th,lda,rho)

figure(4)
for j=[1,2,3,6]
    cnt=1;
    for i=1:26
        if j~=6
            subplot(2,2,j)
        else
            subplot(2,2,4)
        end
        if maturities(i)==j
            strike_tmp(cnt)=strike(i);
            heston_tmp(cnt)=heston_price(i);
            close_tmp(cnt)=close_price(i);
            cnt=cnt+1;
        end
    end
    plot(strike_tmp,heston_tmp);
    hold on
    plot(strike_tmp,close_tmp);
    xlabel([num2str(j),'m']);
    ylabel('price');
    legend('Heston price','Market Price');
    hold off
end
printf('Heston model result 2017.12.29','-djpeg');

%calculate the mean pricing error and std error 
for i=1:26
    ERR_HES(i)=heston_price(i)-close_price(i);
end

ME_HES=mean(ERR_HES);
std_HES=std(ERR_HES);

fprintf('-------------------------------------\n');
fprintf('          Mean ERR          std ERR          \n');
fprintf('BS      %8.8f       %8.8f    \n',ME_BS,std_BS);
fprintf('Heston   %6.8f       %8.8f    \n',ME_HES,std_HES);
fprintf('-------------------------------------\n');
%Seems that Heston model fits the data better?
%So, next, use the next trading day data to test the robustness of the
%parameters.

%-----------------------------------------------------------------------------------
% 
% 4. Test with next trading day(2018.1.2)
% With the totally same method as before
%
%-----------------------------------------------------------------------------------
data_imp2='/Users/leichunyan/Downloads/2018.1.2.xlsx';
maturities2 = xlsread(data_imp2, 'G2:G37');
strike2=xlsread(data_imp2,'D2:D37');
close_price2=xlsread(data_imp2,'O2:O37');
S2=2.9070;
%sort by stirke in ascending order
[n2,m2]=size(maturities2);
for s=1:n2
    for k=1:(n2-s)
        if strike2(k)>strike2(k+1)
           tmp1=strike2(k);
           strike2(k)=strike2(k+1);
           strike2(k+1)=tmp1;
           tmp2=maturities2(k);
           maturities2(k)=maturities2(k+1);
           maturities2(k+1)=tmp2;
           tmp3=close_price2(k);
           close_price2(k)=close_price2(k+1);
           close_price2(k+1)=tmp3;
        end
    end
end
    
% set the maturity date for each option
for i=1:36      % the 4th Wednesday if it is not legel holiday
    if maturities2(i)==1  % maturity date is 2018.1.24
        maturity_date2(i)=datenum(2018,1,24);
    elseif maturities2(i)==2  %2018.2.28
        maturity_date2(i)=datenum(2018,2,28);
    elseif maturities2(i)==3  %2018.3.28
        maturity_date2(i)=datenum(2018,3,28);
    else
        maturity_date2(i)=datenum(2018,6,27);
    end
end
r2=0.036767;
T2=((maturity_date2-datenum(2017,12,29))/365)';
heston_price2=[];
for i=1:36
    heston_price2(i)=HestonCall(S2,strike2(i),r2,x(3),T2(i),x(5),x(1),x(2),0,x(4));
end

figure(5)
for j=[1,2,3,6]
    cnt=1;
    for i=1:36
        if j~=6
            subplot(2,2,j)
        else
            subplot(2,2,4)
        end
        if maturities2(i)==j
            strike_tmp(cnt)=strike2(i);
            heston_tmp(cnt)=heston_price2(i);
            close_tmp(cnt)=close_price2(i);
            cnt=cnt+1;
        end
    end
    plot(strike_tmp,heston_tmp);
    hold on
    plot(strike_tmp,close_tmp);
    xlabel([num2str(j),'m']);
    ylabel('price');
    legend('Heston price','Market Price');
    hold off
end
print('Heston model 2018.1.2(using 2017.12.29 parameters)','-djpeg');

for i=1:36
    ERR_HES2(i)=heston_price2(i)-close_price2(i);
end

ME_HES2=mean(ERR_HES2);
std_HES2=std(ERR_HES2);

%However, using BSM again
%------------------------------------------------------------------------
[~,~,asset_value_past20_2] = xlsread(data_asset, 'E111:E130');
asset_value_past20_2=str2num(cell2mat(asset_value_past20_2));   %change the format from cell to char and finally to num
[~,matlabDateVec_past20_2]=xlsread(data_asset,'A111:A130');
[year_2,month_2,day_2]=datevec(matlabDateVec_past20_2);
dateNumber_past20_2 = datenum(year_2, month_2, day_2);

logr_past20_2=[];
for i=1:19
    logr_past20_2(i)=log(asset_value_past20_2(i))-log(asset_value_past20_2(i+1));
end

vol_past20_annual_2=std(logr_past20_2)*sqrt(252);

for i=1:36
    bs_price_2(i)=blsprice(S2,strike2(i),r2,T2(i),vol_past20_annual_2);
end 

% A graph of Black-Scholes Price and Real Market Price
figure(6)
for j=[1,2,3,6]
    cnt=1;
    for i=1:36
        if j~=6
            subplot(2,2,j)
        else
            subplot(2,2,4)
        end
        if maturities2(i)==j
            strike_tmp(cnt)=strike2(i);
            bs_tmp(cnt)=bs_price_2(i);
            close_tmp(cnt)=close_price2(i);
            cnt=cnt+1;
        end
    end
    plot(strike_tmp,bs_tmp);
    hold on
    plot(strike_tmp,close_tmp);
    xlabel([num2str(j),'m']);
    ylabel('price');
    legend('BS price','Market Price');
    hold off
end
print('BS model result 2018.1.2','-djpeg');

for i=1:36
    ERR_BS2(i)=bs_price_2(i)-close_price2(i);
end

ME_BS2=mean(ERR_BS2);
std_BS2=std(ERR_BS2);

fprintf('-------------------------------------\n');
fprintf('          Mean ERR          std ERR          \n');
fprintf('BS      %8.8f       %8.8f    \n',ME_BS2,std_BS2);
fprintf('Heston   %6.8f       %8.8f    \n',ME_HES2,std_HES2);
fprintf('-------------------------------------\n');