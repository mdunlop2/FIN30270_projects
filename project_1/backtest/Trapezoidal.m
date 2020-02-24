function [TrapWeightedVals] = Trapezoidal(Data,R,nt)
%Trapezoidal Computes trapezoidal weights for SRM
    mu = mean(Data);
    sigma = LSV(Data);
    a=1/nt; % These two lines are the limits of integration
    b=(nt-1)/nt; % These two lines are the limits of integration     
    h=(b-a)/(nt-1);         % Increment

    p=zeros(nt,1); % Empty vector to be filled
    for i=1:nt              % Domain of integration 
        p(i)=a+(i-1)*h; 
    end

    w=zeros(nt,1); % Empty vector to be filled
    w(1)=h/2; % Initial trap weight
    w(nt)=h/2; % Final trap weight   
    for i=2:nt-1  % Other trap weights
        w(i)=h;
    end

    % Specify f(x)for the Spectral Risk Measure 

    phi=zeros(nt,1); % Empty vector to be filled
    var=zeros(nt,1); % Empty vector to be filled
    f=zeros(nt,1); % Empty vector to be filled
    for i=1:nt
        phi(i)= R*exp(-R*(1-p(i)))/(1-exp(-R)); % Spectral weights in risk measure 
        var(i)=mu+sigma*norminv(p(i),0,1); % Normal Parametric VaRs
        f(i)=var(i)*phi(i); % f(i), weighted VaR
    end

    % Estimate the value of SRM
    TrapWeightedVals=w'*f;
end

