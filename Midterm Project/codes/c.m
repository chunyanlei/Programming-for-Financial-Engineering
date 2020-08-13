% Computer Programming in Financial Engineering
% Midterm Project 
% Question 1 (c)
% Plot yield curves

%---------Initialize the Parameters---------------
gamma=1.24;
rbar=0.04;
alpha1=1.2373;
alpha2=alpha_hat;

x1=[rbar,gamma,alpha1];
x2=[rbar,gamma,alpha2];

xdata=0.02;

plot(Dfunction(x1,xdata,maturitiesInYears))
hold on 
plot(Dfunction(x2,xdata,maturitiesInYears))
hold off

xlabel('Maturities')
ylabel('Yield')
legend('alpha=1.2373','estimated alpha=0.0225')
title('Yield Curve of CIR model')

print('Yield Curve of CIR model','-djpeg')