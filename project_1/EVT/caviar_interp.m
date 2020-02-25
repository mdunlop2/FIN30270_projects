%**************************************************************************
% Script to Interpret CAViaR Parameters
% 
%**************************************************************************

% obtain the data
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
len_y = length(IBM);
DATA = ret(len_y-len_train:len_y,:);

THETA = 0.99;

for s=1:2
    % Define some variables.
    ytot        = DATA(:,s);
    totalObs    = size(ytot,1);			% Number of total observations.
    inSampleObs = totalObs -1;   	    % Number of in sample observations.
    y = ytot(1:inSampleObs,:);
    nSamples    = size(y,2);
    MODEL = 2; % Asymmetric Slope

    REP			  = 1;                % Number of times the optimization algorithm is repeated.
    nInitialVectors = [10000, 4];      % Number of initial vector fed in the uniform random number generator for AS model.
    nInitialCond = 15;                % Select the number of initial conditions for the optimisation.

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
   ysort          = sortrows(y);
   row_ind = round(length(ysort).*THETA);
   empiricalQuantile(1) = ysort(row_ind);

    t = nSamples;
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

    % return today's prediction
    % We use THETA as the lower tail so need to reverse Manganelli's output
    VaR_last = -VaR(length(VaR),t);
    B1 = BetaHat(1);
    B2 = BetaHat(2);
    B3 = BetaHat(3);
    B4 = BetaHat(4);
    fprintf('Share %.1f: B_1 %.4f B_2 %.4f B_3 %.4f B_4 %.4f \n ', s, B1, B2, B3, B4);
end

