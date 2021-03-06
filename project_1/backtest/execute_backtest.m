%**************************************************************************
% Script to Backtest All Methods
% 
% 1. Automatically tune parameters based on Validation Set Performance
% 2. Evaluate all var estimates on the Test Set
%**************************************************************************

% define the data used for Validation
IBM_full  = readtable('data/IBM.csv');
NVDA_full = readtable('data/NVDA.csv');

T = 21; % Number of trading days in a month
Years = 20; % Number of years for calculaton
n = height(IBM_full); % Number of days of data
q = n - Years.*12.*T;

IBM  = (IBM_full{q:n,6}./IBM_full{q-1:n-1,6})-1; % AdjClose col 6
NVDA = (NVDA_full{q:n,6}./NVDA_full{q-1:n-1,6})-1; % AdjClose col 6
date = IBM_full{q:n,1};

ret = [IBM, NVDA];
% len_train = 2520; % Information available before we use test set
len_train = round(length(IBM)/2);
len_test  = length(IBM) - len_train;
len_train_window = len_train;

%**************************************************************************
% Macro Parameters
n_methods = 8;  % Number of mthods to test
THETA = 0.99;   % VaR Percentage (Confidence Level)
P = 1;          % portfolio size

%**************************************************************************
% Hannon's Parameters
iter = 5000; % Monte Carlo simulation
seed = 1; % MC sim
R=800; % Coefficient of Risk Aversion
nt=10000; % Number of steps for trapezodial rule
n_obs = len_test;
n_Hannon = 6; % Number of hannon's methods
Monthly_VaR = zeros(n_obs,n_Hannon);
Daily_ES = zeros(n_obs,n_Hannon);
Monthly_ES = zeros(n_obs,n_Hannon);
SRM = zeros(n_obs,1);

%**************************************************************************
% Matthew's Parameters
LAMBDA = 0.8;

%**************************************************************************
% create storage for VaR estimates
Daily_VaR = zeros(2, n_methods, len_test);
% create storage for the historical Expected Shortfall
hist_ES   = zeros(2, n_methods, len_test);
% Create storage for the bactest scores
QPS_grid      = zeros(2,n_methods);
Kupiec_grid   = zeros(2,n_methods);
% iterate over each stock
for s =1:2
    
    % Backtest on every training sample
    % using previous len_window observations
    for i =1:len_test
        % select the training data
        ret_train = ret(i:len_train_window+i,s);
        % select the training dates
        date_train = date(i:len_train_window+i);
        %******************************************************************
        % Backtest Hannon's Code
        [Daily_VaR(s, 1, i),Monthly_VaR(i,1),Daily_ES(i,1),Monthly_ES(i,1)] = HistoricalVarES(ret_train,P,cl);
        [Daily_VaR(s, 2, i),Monthly_VaR(i,2),Daily_ES(i,2),Monthly_ES(i,2)] = NormalVarES(ret_train,P,cl);
        [Daily_VaR(s, 3, i),Monthly_VaR(i,3),Daily_ES(i,3),Monthly_ES(i,3)] = StudentVarES(ret_train,P,cl);
        [Daily_VaR(s, 4, i),Monthly_VaR(i,4),Daily_ES(i,4),Monthly_ES(i,4)] = CornishFischerVarES(ret_train,P,cl);
        [Daily_VaR(s, 5, i),Monthly_VaR(i,5),Daily_ES(i,5),Monthly_ES(i,5)] = MonteCarlo(ret_train,iter,P,cl,seed);
        [Daily_VaR(s, 8, i),Monthly_VaR(i,6),Daily_ES(i,6),Monthly_ES(i,6)] = LognormalVarES(ret_train,P,cl);
        %******************************************************************
        % Backtest Matthew's Code
        Daily_VaR(s, 6, i) = fn_awb(ret_train, date_train, THETA, LAMBDA);
        Daily_VaR(s, 7, i) = fn_caviar(ret_train, THETA);
        % Get the Expected Shortfall from the Method
        hist_ES(s,i) = fn_ES(ret_train, theta);
        fprintf('Sample %.4f of %.4f complete', i, len_test);
    end
    % score each method
    for m = 1:n_methods
        % score the backtest results
        QPS_grid(s, m) = fn_QPS(ret(len_train_window+1:len_train_window+len_test), hist_ES(s,m,:), Daily_VaR(s,m,:));
        fprintf('QPS Score for Method %.1f of %.1f Methods Complete\n',m,n_methods)
        % get a Kupic Score
        Kupiec_grid(s,m) = fn_kupiec(ret(len_train_window+1:len_train_window+len_test), Daily_VaR(s,m,:));
        fprintf('Kupiec Score for Method %.1f of %.1f Methods Complete\n',m,n_methods)
    end
end
% write all of our results to csv
writematrix(Daily_VaR, "backtest/Daily_VaR.csv")
writematrix(hist_ES, "backtest/hist_ES.csv")
writematrix(QPS_grid, "backtest/QPS_grid.csv")
writematrix(Kupiec_grid, "backtest/Kupiec_grid.csv")
writematrix(Monthly_VaR, "backtest/Monthly_VaR.csv")
writematrix(Daily_ES, "backtest/Daily_ES.csv")
writematrix(Monthly_ES, "backtest/Monthly_ES.csv")

%**************************************************************************
% plot histograms of VaR vs actual returns
test_dates = date(len_train+1:len_train+len_test);
test_returns = ret(len_train_window+1:len_train_window+len_test,1);
% IBM
S = 1;
figure('Position', [10 10 900 600])
hold on
plot(test_dates, test_returns, 'color','k'); M0 = 'Actual Return';
plot(test_dates, squeeze(-Daily_VaR(S,1,:))), M1 = 'Historical VaR';
plot(test_dates, squeeze(-Daily_VaR(S,2,:))), M2 = 'Normal VaR';
plot(test_dates, squeeze(-Daily_VaR(S,3,:))), M3 = 'Student-t VaR';
plot(test_dates, squeeze(-Daily_VaR(S,4,:))), M4 = 'Cornish-Fischer VaR';
plot(test_dates, squeeze(-Daily_VaR(S,5,:))), M5 = 'Monte Carlo VaR';
plot(test_dates, squeeze(-Daily_VaR(S,6,:))), M6 = 'Age-Weighted VaR';
plot(test_dates, squeeze(-Daily_VaR(S,8,:))), M8 = 'Lognormal VaR';
plot(test_dates, squeeze(-Daily_VaR(S,7,:))), M7 = 'CAViaR';

legend(M0,M1',M2,M3,M4,M5,M6,M8,M7, 'Location', 'northwest')
title('Actual Returns vs 99% VaR estimates')
xlabel('Date')
ylabel('IBM Returns')
ylim([-0.3 0.1])
saveas(gcf,'backtest/IBM-backtest.pdf')

% NVDA
% IBM
S = 2;
figure('Position', [10 10 900 600])
hold on
plot(test_dates, test_returns, 'color','k'); M0 = 'Actual Return';
plot(test_dates, squeeze(-Daily_VaR(S,1,:))), M1 = 'Historical VaR';
plot(test_dates, squeeze(-Daily_VaR(S,2,:))), M2 = 'Normal VaR';
plot(test_dates, squeeze(-Daily_VaR(S,3,:))), M3 = 'Student-t VaR';
plot(test_dates, squeeze(-Daily_VaR(S,4,:))), M4 = 'Cornish-Fischer VaR';
plot(test_dates, squeeze(-Daily_VaR(S,5,:))), M5 = 'Monte Carlo VaR';
plot(test_dates, squeeze(-Daily_VaR(S,6,:))), M6 = 'Age-Weighted VaR';
plot(test_dates, squeeze(-Daily_VaR(S,8,:))), M8 = 'Lognormal VaR';
plot(test_dates, squeeze(-Daily_VaR(S,7,:))), M7 = 'CAViaR';

legend(M0,M1',M2,M3,M4,M5,M6,M8,M7, 'Location', 'northwest')
title('Actual Returns vs 99% VaR estimates')
xlabel('Date')
ylabel('NVDA Returns')
ylim([-0.3 0.1])
saveas(gcf,'backtest/NVDA-backtest.pdf')
%**********************



