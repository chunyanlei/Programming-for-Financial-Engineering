2018.6.10 
# Final Project
##  Black-Scholes model & Heston model

data: 50ETF call options which can be traded on 2017.12.29 (maturity:1m 2m 3m 6m)
data source: Wind
2018.6.10 

data:
50etf.xlsx is the 50 ETF data from 2016.1.4-2018.6.13, including close price, net unit asset value which are used in the codes.

Treasury bond interest rate.xls is 1-year treasury bond interest rate from 2002.1.4-2018.6.14, where we can find the 1-year treasury bond interest rate of a specific trading day.

2017.12.29.xlsx is the 50 ETF call option data traded on 2017.12.29, including close price, strike price, maturity which are used in the codes.

2018.1.2.xlsx is the 50 ETF call option data traded on 2018.1.2, including close price, strike price, maturity which are used in the codes.

=============================================
Matlab Documents:
main.m -> the main programming codes, where we can get all the final results in the report.

HestonCall.m and CF_Heston.m -> to construct the explicit solution of Heston model. Used for calibrate Heston model if parameters are unknown and for pricing option if parameters have already been calibrated.

HestonDiff.m -> a function that returns a vector of values for the pricing error(=model price-market price)   Used to calibrate Heston model, by searching for the parameters that minimize the pricing error.
