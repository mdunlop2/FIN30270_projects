%%
[ Returns ] = xlsread('VaR_Data','C3:C2002');
%% Parameters
R=400; % Coefficient of Risk Aversion
n=10000; % Number of steps for trapezodial rule
P=10000; % Size of portfolio
PL=Returns*P; % P&L for portfolio
mu=mean(Returns); % Average returns of portfolio
sigma=std(Returns); % Standard Deviation for the returns of portfolio

%% Trapezodial Rule

a=1/n; % These two lines are the limits of integration
b=(n-1)/n; % These two lines are the limits of integration     
h=(b-a)/(n-1);         % Increment

p=zeros(n,1); % Empty vector to be filled
for i=1:n              % Domain of integration 
    p(i)=a+(i-1)*h; 
end

w=zeros(n,1); % Empty vector to be filled
w(1)=h/2; % Initial trap weight
w(n)=h/2; % Final trap weight   
for i=2:n-1  % Other trap weights
    w(i)=h;
end

%% Specify f(x)for the Spectral Risk Measure 

phi=zeros(n,1); % Empty vector to be filled
var=zeros(n,1); % Empty vector to be filled
f=zeros(n,1); % Empty vector to be filled
for i=1:n
    phi(i)= R*exp(-R*(1-p(i)))/(1-exp(-R)); % Spectral weights in risk measure 
    var(i)=mu+sigma*norminv(p(i),0,1); % Normal Parametric VaRs
    f(i)=var(i)*phi(i); % f(i), weighted VaR
end

%% Estimate the value of SRM
TrapWeightedVals=w'*f;
SRM=TrapWeightedVals*P; 
