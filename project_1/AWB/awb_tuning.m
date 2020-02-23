%**************************************************************************
% Script to Tune Age-Weighted Bootstrap
% 
% REQUIRES:
% fn_awb
% 
% Performs a grid-search for LAMBDA to optimise VaR Estimation
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
len_train = 2520; % Information available before we use test set
len_test  = length(IBM) - len_train;
len_train_window = len_train - round(len_train/2);
len_valid = len_train - len_train_window; % validation returns to tune parameters

% create matrix for gridsearch
n_grid_l = 21;
n_grid_t = 21;
lambda_grid = linspace(0.85,0.99,n_grid_l);
theta_grid  = linspace(0.9,0.99,n_grid_t);
% create storage for VaR estimates
Daily_VaR = zeros(2,length(theta_grid),length(lambda_grid), len_valid);
% create storage for the historical Expected Shortfall
hist_ES   = zeros(2,length(theta_grid),length(lambda_grid), len_valid);
% Create storage for the bactest scores
QPS_grid      = zeros(2,length(theta_grid),length(lambda_grid));
Kupiec_grid   = zeros(2,length(theta_grid),length(lambda_grid));
% iterate over each stock
for s =1:2
    for t=1:length(theta_grid)
        theta = theta_grid(t);
        for l =1:length(lambda_grid)
            lambda = lambda_grid(l);
            % Backtest on every training sample
            % using previous len_window observations
            for i =1:len_valid
                % select the training data
                ret_train = ret(i:len_train_window+i,s);
                % select the training dates
                date_train = date(i:len_train_window+i);
                Daily_VaR(s, t, l, i) = fn_awb(ret_train, date_train, theta, lambda);
                % Get the Expected Shortfall from the Method
                hist_ES(s, t, l, i) = fn_ES(ret_train, theta);
            end
            % score the backtest results
            QPS_grid(s, t, l) = fn_QPS(ret(len_train_window:len_train_window+len_valid-1), hist_ES(s,t,l,:), Daily_VaR(s,t,l,:));
            % get a Kupic Score
            Kupiec_grid(s, t, l) = fn_kupiec(ret(len_train_window+1:len_train_window+len_valid), Daily_VaR(s,t,l,:));
        end
    end
    % plot the surface here
end
[T, L] = meshgrid(theta_grid, lambda_grid);
Z = squeeze(QPS_grid(1, 1:length(theta_grid), 1:length(lambda_grid))).';
figure
surf(T,L,Z, 'FaceAlpha',0.5)
title('Lambda, Confidence interval and QPS Score')
xlabel('Confidence Level')
ylabel('Lambda')
zlabel('QPS Score: IBM')
ylim([0.85,0.99])
xlim([0.9,0.99])


