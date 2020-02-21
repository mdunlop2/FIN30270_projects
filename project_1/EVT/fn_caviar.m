function [VAR] = fn_caviar(DATA,THETA)
%**************************************************************************
% Applies the Asymmetric CAViaR Method
% Deployed by Manganelli et al (2002)
%*************************************
% INPUTS:
%
% DATA : Array, shape (n, 1)
%           - Historical returns data
%             which we are measuring
%             VaR for
% THETA: Float
%           - VaR Confidence Level
%*************************************
% OUTPUTS:
% 
% VAR  : Float
%           - Return corresponding to
%             the THETA-percentile 
%**************************************************************************

% Define some variables.
ytot        = DATA;
inSampleObs = 2892;				    % Number of in sample observations.
totalObs    = size(ytot,1);			% Number of total observations.
y = ytot(1:inSampleObs,:);
nSamples    = size(y,2);

nInitialVectors = [100000, 4]; % Number of initial vector fed in the uniform random number generator for AS model.
nInitialCond = 15;             % Select the number of initial conditions for the optimisation.

MaxFunEvals = 500; % Parameters for the optimisation algorithm. Increase them in case the algorithm does not converge.
MaxIter     = 500;
options = optimset('LargeScale', 'off', 'HessUpdate', 'dfp','MaxFunEvals', MaxFunEvals, ...
                    'display', 'off', 'MaxIter', MaxIter, 'TolFun', 1e-10, 'TolX', 1e-10);
warning off

rand('seed', 50)                  % Set the random number generator seed for reproducability (seed used in the paper = 50).

%
% Define some matrices.
VaR            = zeros(size(ytot,1), size(ytot, 2));
Hit            = VaR;
DQinSample     = zeros(1, nSamples);
DQoutOfSample  = DQinSample;


%
% Compute the empirical THETA-quantile for y (the in-sample vector of observations).
for t = 1:nSamples
   ysort(:, t)          = sortrows(y(1:300, t), 1);
   row_ind = round(300*THETA);
   empiricalQuantile(t) = ysort(row_ind, t);
end


% placeholder until we get this working
VAR = THETA;
end

