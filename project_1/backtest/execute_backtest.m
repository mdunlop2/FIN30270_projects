%**************************************************************************
% Script to Backtest All Methods
% 
% 1. Automatically tune parameters based on Validation Set Performance
% 2. Evaluate all var estimates on the Test Set
%**************************************************************************

% Load in the returns data
ret = readmatrix('data/ret.csv');
% load the dates from the csv file
IBM_full  = readtable('data/IBM.csv');
T = 21; % Number of trading days in a month
Years = 20; % Number of years for calculaton
n = height(IBM_full); % Number of days of data
q = n - Years.*12.*T;
Date = IBM_full{q:n,1};

% REPLACE WITH LOOP OVER SHARES!
% {
%   REPLACE WITH LOOP OVER METHODS
%   {
%       REPLACE WITH LOOP OVER METHOD PARAMETERS
%       {
%           REPLACE WITH LOOP OVER VALIDATION SET
%               {}
%
VAR = fn_caviar(ret(:,1), 0.05);

%       CHOOSE OPTIMAL PARAMETERS
%       }
%   }
% }

%** Plotting **************************************************************
figure
plot(Date,VAR)
% histogram(VAR)