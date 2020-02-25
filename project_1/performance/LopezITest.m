function [QPS] = LopezITest(HistoricReturns,EstimatedVaR,cl)
%LopezITest 
% Estimated VaR - All values are negative
% Historic Returns are + for profit, - for loss
    [n,m] = size(EstimatedVaR);
    C = zeros(n,m);
    for i = 1:n
        for j = 1:m
            if HistoricReturns(i) < EstimatedVaR(i,j) % Loss is larger than estimated
                C(i,j) = 1;
            end
        end
    end
    QPS = sum((C-(1-cl)).^2)*(2/n); % The Frequency-of-tail-losses (Lopez I) Approach
end