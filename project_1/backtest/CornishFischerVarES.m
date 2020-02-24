function [DailyCFVar,MonthlyCFVar,DailyCFES,MonthlyCFES] = CornishFischerVarES(Data,P,cl)
%CornishFischerVarES Computes the Corner-Fischer expansion, VaR and ES.        
%Per Alexander (2008)
    z = norminv(cl,0,1); % Standard normal variate 
    s = skewness(Data); % Skewness
    k = kurtosis(Data); % Kurtosis
    mu = mean(Data); % mean
    sigma = LSV(Data); % Lower semi standard deviation
    x = z + (s*(z^2-1))/6 + (k*z*(z^2-3))/24 - ((s^2)*z*(2*(z^2)-5))/36; % Cornish-Fischer expansion
    DailyCFVar = (-mu+sigma*x)*P;
    MonthlyCFVar = (-mu*21+sigma*sqrt(21)*x)*P;
    z1 = normpdf(z,0,1)/(1-cl);
    x1 = z1 + (s*(z1^2-1))/6 + (k*z1*(z1^2-3))/24 - ((s^2)*z1*(2*(z1^2)-5))/36;
    DailyCFES = (-mu+sigma*x1)*P;
    MonthlyCFES = (-mu*21+sigma*sqrt(21)*x1)*P;
end