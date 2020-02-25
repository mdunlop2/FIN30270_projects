function [binotest] = KupiecTest(HistoricReturns,EstimatedVaR,cl)
%KupiecTest 

    [n,m] = size(EstimatedVaR);
    C = zeros(n,m);
    for i = 1:n
        for j = 1:m
            if HistoricReturns(i) < EstimatedVaR(i,j)
                C(i,j) = 1;
            end
        end
    end
    x = sum(C);
    binotest = 1-binocdf(x,n,1-cl); % Kupiec test
end


