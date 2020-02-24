%Data = readtable('IBM.csv','PreserveVariableNames',true);
Data = readtable('NVDA.csv','PreserveVariableNames',true);

%% Parameters
n1 = height(Data);
n = 2519; % Number of days to train on (Will lead to 2520 days)
n_obs = n1 - n - 1; % Number of past predictions
P = 1; % Portfolio size
cl = 0.99; % Confidence level
iter = 5000; % Monte Carlo simulation
seed = 1; % MC sim
R=800; % Coefficient of Risk Aversion
nt=10000; % Number of steps for trapezodial rule
%%
Daily_VaR = zeros(n_obs,5);
Monthly_VaR = zeros(n_obs,5);
Daily_ES = zeros(n_obs,5);
Monthly_ES = zeros(n_obs,5);
SRM = zeros(n_obs,1);
for i = 1:n_obs
    Returns = (Data{i+1:n+i+1,6}./Data{i:n+i,6})-1; % AdjClose col 6
    
    [Daily_VaR(i,1),Monthly_VaR(i,1),Daily_ES(i,1),Monthly_ES(i,1)] = HistoricalVarES(Returns,P,cl);
    [Daily_VaR(i,2),Monthly_VaR(i,2),Daily_ES(i,2),Monthly_ES(i,2)] = NormalVarES(Returns,P,cl);
    [Daily_VaR(i,3),Monthly_VaR(i,3),Daily_ES(i,3),Monthly_ES(i,3)] = StudentVarES(Returns,P,cl);
    [Daily_VaR(i,4),Monthly_VaR(i,4),Daily_ES(i,4),Monthly_ES(i,4)] = CornishFischerVarES(Returns,P,cl);
    [Daily_VaR(i,5),Monthly_VaR(i,5),Daily_ES(i,5),Monthly_ES(i,5)] = MonteCarlo(Returns,iter,P,cl,seed);
    
    TrapWeightedVals = Trapezoidal(Returns,R,nt);
    SRM(i)=TrapWeightedVals*P; 
end


Hist_ES = Daily_ES(1:n_obs-1,1); % Past Hist ES estimates
Norm_ES = Daily_ES(1:n_obs-1,2); % Past Normal ES estimates
Student_ES = Daily_ES(1:n_obs-1,3); % Past Student ES estimates
CF_ES = Daily_ES(1:n_obs-1,4); % Past Cornish-Fischer ES estimates
MC_ES = Daily_ES(1:n_obs-1,5); % Past MC ES estimates

Hist_Var = -1*Daily_VaR(1:n_obs-1,1); % Past Hist Var estimates
Norm_Var = -1*Daily_VaR(1:n_obs-1,2); % Past Normal Var estimates
Student_Var = -1*Daily_VaR(1:n_obs-1,3); % Past Student Var estimates
CF_Var = -1*Daily_VaR(1:n_obs-1,4); % Past Cornish-Fischer Var estimates
MC_Var = -1*Daily_VaR(1:n_obs-1,5); % Past MC Var estimates
HistReturns = ((Data{n1-n_obs+2:n1,6}./Data{n1-n_obs+1:n1-1,6})-1); % Actual P&L
Date = Data{n1-n_obs+1:n1-1,1}; % Dates

plot(Date,HistReturns)
title('Actual Returns vs 99% VaR estimates')
xlabel('Date')
ylabel('NVDA Returns')
hold on
plot(Date,Hist_Var)
plot(Date,Norm_Var)
plot(Date,Student_Var)
plot(Date,CF_Var)
plot(Date,MC_Var)
legend('Historical VaR','Normal VaR','Student-t VaR','Cornish-Fischer VaR','Monte Carlo VaR')

EstimatedVar = [Hist_Var,Norm_Var,Student_Var,CF_Var,MC_Var];
EstimatedES = [Hist_ES,Norm_ES,Student_ES,CF_Var,MC_ES];
exceedances = zeros(n_obs-1,5);
for i = 1:n_obs-1
    for j = 1:5
        if HistReturns(i) < EstimatedVar(i,j)
            exceedances(i,j) = 1;
        end
    end
end
x = sum(exceedances);
binotest = 1-binocdf(x,n_obs-1,1-cl); % Kupiec test
QPS = sum((exceedances-(1-cl)*n_obs).^2)*(2/n_obs); % The Frequency-of-tail-losses (Lopez I) Approach

exceedances2 = zeros(n_obs-1,5); % Blanco-Ihle approach
for i = 1:n_obs-1
    for j = 1:5
        if HistReturns(i) < EstimatedVar(i,j)
            exceedances2(i,j) = 1 + (EstimatedES(i,j)-HistReturns(i))^2;
        end
    end
end

