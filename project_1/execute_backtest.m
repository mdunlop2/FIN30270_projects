%**************************************************************************
% Script to Backtest All Methods
% 
% 1. Automatically tune parameters based on Validation Set Performance
% 2. Evaluate all var estimates on the Test Set
%**************************************************************************

% Load in the returns data
ret = readmatrix('data/ret.csv');

% REPLACE WITH LOOP OVER SHARES!
% {
% REPLACE WITH LOOP OVER METHODS
%   {
% REPLACE WITH LOOP OVER METHOD PARAMETERS
%       {
% REPLACE WITH LOOP OVER VALIDATIexecON SET
%
VAR = fn_caviar(ret, 0.05)
% CHOOSE OPTIMAL PARAMETERS
%       }
%   }
% }