% Load the Data

[ Returns ] = xlsread('VaR_Data','C3:C2002'); % This is the full data set

%% Estimate Normal VaR

hp=1; % One day holding period
P=10000; % Portfolio Size
cl=0.99; % VaR Confidence LevelPL=Returns*P;
mu=mean(Returns);
sigma=std(Returns);
y=(-mu*hp'+sigma*sqrt(hp')*norminv(1-cl,0,1))*P;

%% Estimate Monte Carlo Simulation VaRs

P=10000; % Portfolio Size
cl=0.99; % VaR Confidence Level
mu=mean(Returns);
sigma=std(Returns);
df=5; % Degrees of Freedom for Student-t distribution
samples=15000; % Number of samples conducted for Monte Carlo Simulation

MCNRets=normrnd(mu,sigma,samples,1); % Monte Carlo Simulation based on normal distribution
MCNVaR=historicalVaR(MCNRets,P,cl)

MCTRets=trnd(5,samples,1)*sqrt(3/5)*sigma+mu; % Monte Carlo Simulation based on Student-t distribution
MCTVaR=historicalVaR(MCTRets,P,cl)
