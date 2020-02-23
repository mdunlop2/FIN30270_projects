function [QPS] = fn_QPS(returns, ES, VaR)
%**************************************************************************
% Function to score a VaR Method
% 
% INPUTS:
% returns : Array, (n) % Actual Return
% ES      : Array, (n) % Expected Shortfall
% VaR     : Array, (n) % Predicted VaR
%
% OUTPUTS:
% QPS     : Double
% 
%**************************************************************************
T = length(returns);
QPS = 0;
for t=1:T
    if returns(t) < -VaR(t)
        C_t = -(returns(t) + VaR(t));
    else
        C_t = 0;
    end
    QPS = QPS + 2.*(C_t - ES(t)).^(2);
end
end

