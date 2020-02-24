function [DailyLNVar,MonthlyLNVar,DailyLNES,MonthlyLNES] = LognormalVarES(Data,P,cl)
%LognormalVarES Summary of this function goes here
    z = norminv(cl,0,1); % Standard normal variate 
    mu = geomean(1+Data)-1; % geometric mean
    sigma = exp(LSV(1+Data))-1; % geometric standard deviation
    DailyLNVar = (1 - exp(mu-z*sigma))*P;
    MonthlyLNVar = (1 - exp(mu*21-z*sqrt(21)*sigma))*P;
    
    % ETL estimation
    n=1000;                          % Number of slices into which tail is divided 
    cl0=cl;                          % Initial confidence level
    term1=DailyLNVar;                                                                                             
    delta_cl=(1-cl)/n;      % Increment to confidence level as each slice is taken
    for i=1:n-1
    cl=cl0+i*delta_cl;                           % Revised cl
    term1=term1+P-exp(sigma*norminv(1-cl,0,1)+mu+log(P));
    end;
    DailyLNES=term1/n;                                           % ETL

    term2=MonthlyLNVar;                                                                                             
    delta_cl=(1-cl)/n;      % Increment to confidence level as each slice is taken
    for i=1:n-1
    cl=cl0+i*delta_cl;                           % Revised cl
    term2=term2+P-exp(sigma*sqrt(21)*norminv(1-cl,0,1)+mu*21+log(P));
    end;
    MonthlyLNES=term2/n; 
end

     