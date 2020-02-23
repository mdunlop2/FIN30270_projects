function [ES] = fn_ES(returns, THETA)
%**************************************************************************
% Function to get the Historical Expected Shortfall
% 
% INPUTS:
% returns : Array, (n) % Actual Return
% THETA   : Double     % VaR level
%
% OUTPUTS:
% ES      : Double     % Expected Shortfall
% 
%**************************************************************************
n = length(returns);
% find the ES at the THETA Percentile
cum_prob = 0;
LossesSorted = sort(-returns);
for i=2:n
    if cum_prob < THETA
        VaR_LB = LossesSorted(i-1);
        cum_prob = cum_prob + 1/n;
        if i == n
            ES = mean(LossesSorted(LossesSorted > VaR_LB));
            break
        end
    else
        ES = mean(LossesSorted(LossesSorted > VaR_LB));
        break
    end
end

end

