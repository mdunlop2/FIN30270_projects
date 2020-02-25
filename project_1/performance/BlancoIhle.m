function [QPS] = BlancoIhle(HistoricReturns,EstimatedVaR,EstimatedES)
%BlancoIhle
    [n,m] = size(EstimatedVaR);
    C = zeros(n,m); % Blanco-Ihle approach
    for i = 1:n
        for j = 1:m
            if HistoricReturns(i) < EstimatedVaR(i,j)
                C(i,j) = (HistoricReturns(i)-EstimatedVaR(i,j))/EstimatedVaR(i,j);
            end
        end
    end
    QPS = sum((C-EstimatedES).^2)*(2/n);
end