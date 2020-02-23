function [kupiec] = fn_kupiec(returns,VaR)
%**************************************************************************
% Function to score a VaR Method
% 
% INPUTS:
% returns : Array, (n) % Actual Return
% VaR     : Array, (n) % Predicted VaR
%
% OUTPUTS:
% kupiec  : Double
% 
%**************************************************************************
T = length(returns);
exceedences = 0;
for t=1:T
    if -returns(t) > VaR(t)
        exceedences = exceedences + 1;
    end

end
kupiec = exceedences / T;
end
