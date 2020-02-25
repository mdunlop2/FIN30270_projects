%**************************************************************************
% Script to Assess Semi-Parametric Methods
%
% execute_backtest.m MUST BE EXECUTED BEFORE THIS SCRIPT
% 
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
% len_test = 10;
win = len_train;
len_train_window = len_train;

% obtain the test period used
ret_test = ret(len_train_window+1:len_train_window+len_test,:);

% obtain VaR estimates from backtest
% saved in 3d csv that I can't read back!!!!!

%**************************************************************************
% Macro Parameters
n_methods = 8;  % Number of mthods to test
THETA = 0.99;   % VaR Percentage (Confidence Level)
P = 1;          % portfolio size
LAMBDA = 0.85;

%**************************************************************************
% Assess performance
% James has already evaluated his Parametric Methods
% Will now evaluate semi-parametric methods
methods = ["Age-Weighted","CAViaR"];
VaR_map = [7];

full = length(IBM);

% Daily_VaR_awb = zeros(len_test,1);
% Daily_VaR_CAViaR = zeros(len_test,1);

for s=1:2
    for i = 1:len_test
        returns = ret(full-win-len_test+i:full-len_test+i, s);
        dates = date( full-win-len_test+i:full-len_test+i);
        % Daily_VaR_awb(i) = fn_awb(returns, dates, THETA, LAMBDA);
        % Daily_VaR_CAViaR(i) = fn_caviar(returns, THETA);
        % fprintf('%.4f Complete \n', i/(len_test.*2));
    end
    K_awb = KupiecTest(ret_test(1:len_test-1),-Daily_VaR_awb(2:len_test), THETA);
    K_CAViaR = KupiecTest(ret_test(1:len_test-1),-Daily_VaR_CAViaR(2:len_test), THETA);
    fprintf('Share: %.1f Method: Kupiec AWB: %.4f CAViaR %.4f \n',s,K_awb, K_CAViaR)
    L_awb = LopezITest(ret_test(1:len_test-1),-Daily_VaR_awb(2:len_test), THETA);
    L_CAViaR = LopezITest(ret_test(1:len_test-1),-Daily_VaR_CAViaR(2:len_test), THETA);
    fprintf('Share: %.1f Method: Lopez AWB: %.4f CAViaR %.4f \n',s,L_awb, L_CAViaR)
    
    
end



