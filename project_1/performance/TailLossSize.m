function [QPS] = TailLossSize(HistoricReturns,EstimatedVaR,EstimatedES)
%TailLossSize 
    [n,m] = size(EstimatedVaR);
    C = zeros(n,m); 
    for i = 1:n
        for j = 1:m
            if HistoricReturns(i) < EstimatedVaR(i,j)
                C(i,j) = HistoricReturns(i);
            end
        end
    end
    QPS = sum((EstimatedES-C).^2)*(2/n);
end