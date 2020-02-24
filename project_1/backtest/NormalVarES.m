function [DailyVaR,MonthlyVar,DailyES,MonthlyES] = NormalVarES(Data,P,cl)
%NormalVarES This function produces the daily and monthly VaR and ES
%predictions based on the normal distribution
%   Detailed explanation goes here
    mu = mean(Data); % Mean 
    z = norminv(cl,0,1); % Standard Normal Variate
    sigma = LSV(Data); % Lower semi-standard deviation
    DailyVaR = (-mu+sigma*z)*P;
    MonthlyVar = (-mu*21+sigma*sqrt(21)*z)*P; % Holding period is 21 days, assume that there are 21 trading days in a month
    DailyES = (-mu+sigma*((normpdf(z,0,1))/(1-cl)))*P;
    MonthlyES = (-mu*21+sigma*sqrt(21)*((normpdf(z,0,1))/(1-cl)))*P;
end