function [VaR] = fn_awb(returns, dates, THETA, LAMBDA)
%**************************************************************************
% Script to Perform Age-Weighted Historical VaR
% 
% INPUTS:
% returns: array (double)
% dates  : array (datetime)
% THETA  : float
% LAMBDA : float
%
% OUTPUTS:
% VaR    : float
%**************************************************************************
n = length(returns);
% generate age-weight column
t_diff  = days(dates(n) - dates); % time difference in days
w       = (LAMBDA.^(t_diff)).*(1-LAMBDA)/(1-(LAMBDA.^n));
Losses  = -returns;

% make a matrix
% Sort this by the loss size
[LossesSorted I] = sort(Losses);
ret_mat_s = [LossesSorted w(I)];


% find the VaR at the THETA Percentile
cum_prob = 0;
for i=2:n
    if cum_prob < THETA
        VaR_LB = ret_mat_s(i-1,1);
        VaR_UB = ret_mat_s(i,1);
        prob_delta = ret_mat_s(i,2);
        cum_prob = cum_prob + ret_mat_s(i-1,2);
    else
        break
    end
end

% do linear interpolation to find the VaR
VaR = VaR_LB + (THETA - cum_prob).*((VaR_UB - VaR_LB)/prob_delta);
% VaR = VaR_LB;
end

