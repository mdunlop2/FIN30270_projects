function [sigma] = LSV(Data)
%LSV Calculates the Lower semi-standard deviation
    mu = mean(Data);
    n = length(Data(Data<mu));
    sigma = sqrt(sum((Data(Data<mu)-mu).^2)./(n-1));
end