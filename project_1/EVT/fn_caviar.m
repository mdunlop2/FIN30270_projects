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
MODEL = 2; % Asymmetric Slope

REP			  = 5;                % Number of times the optimization algorithm is repeated.
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

for t = 1 : nSamples
    disp('__________________')
    disp(' ')
    SMPL = ['disp(', '''', ' Caviar Asymmetric : Sample number: ', int2str(t), '''', ' )']; eval(SMPL)
    disp('__________________')

%   
%   
%**************************** Optimization Routine ******************************************  
    initialTargetVectors = unifrnd(0, 1, nInitialVectors);
      
    RQfval = zeros(nInitialVectors(1), 1);
    for i = 1:nInitialVectors(1)
        RQfval(i) = RQobjectiveFunction(initialTargetVectors(i,:), 1, MODEL, inSampleObs, y(:,t), THETA, empiricalQuantile(t));
    end
    Results          = [RQfval, initialTargetVectors];
    SortedResults    = sortrows(Results,1);
    
    if (MODEL == 1) | (MODEL == 3)
        BestInitialCond  = SortedResults(1:nInitialCond,2:4);
    elseif MODEL == 2
        BestInitialCond  = SortedResults(1:nInitialCond,2:5);
    elseif MODEL == 4
        BestInitialCond  = SortedResults(1:nInitialCond,2);
    end
    
    for i = 1:size(BestInitialCond,1)
        [Beta(i,:), fval(i,1), exitflag(i,1)] = fminsearch('RQobjectiveFunction', BestInitialCond(i,:), options, 1, MODEL, inSampleObs, y(:,t), THETA, empiricalQuantile(t));
        for it = 1:REP
            [Beta(i,:), fval(i,1), exitflag(i,1)] = fminunc('RQobjectiveFunction', Beta(i,:), options, 1, MODEL, inSampleObs, y(:,t), THETA, empiricalQuantile(t));
            [Beta(i,:), fval(i,1), exitflag(i,1)] = fminsearch('RQobjectiveFunction', Beta(i,:), options, 1, MODEL, inSampleObs, y(:,t), THETA, empiricalQuantile(t));
            if exitflag(i,1) == 1
                break
            end
        end
    end
    SortedFval  = sortrows([fval, Beta, exitflag, BestInitialCond], 1);
    
    
    if (MODEL == 1) | (MODEL == 3)
        BestFval         = SortedFval(1, 1);
        BetaHat(:, t)    = SortedFval(1, 2:4)';
        ExitFlag         = SortedFval(1, 5);
        InitialCond(:,t) = SortedFval(1, 6:8)';
        
    elseif MODEL == 2
        BestFval         = SortedFval(1, 1);
        BetaHat(:, t)    = SortedFval(1, 2:5)';
        ExitFlag         = SortedFval(1, 6);
        InitialCond(:,t) = SortedFval(1, 7:10)';
        
    elseif MODEL == 4
        BestFval         = SortedFval(1, 1);
        BetaHat(:, t)    = SortedFval(1, 2);
        ExitFlag         = SortedFval(1, 3);
        InitialCond(:,t) = SortedFval(1, 4);
        
    end

%**************************** End of Optimization Routine ******************************************
    % Compute VaR and Hit for the estimated parameters of RQ.
    VaRHit  = RQobjectiveFunction(BetaHat(:,t)', 2, MODEL, totalObs, ytot(:,t), THETA, empiricalQuantile(t));
    VaR(:,t) = VaRHit(:,1); Hit(:,t) = VaRHit(:,2);
end			% End of the t loop.

% placeholder until we get this working
VAR = VaR;
end

