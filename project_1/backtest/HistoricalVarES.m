function [DailyHistVar,MonthlyHistVar,DailyHistES,MonthlyHistES] = HistoricalVarES(Data,P,cl)
%HistoricalVarES Calculates the historical Var and ES
    LossesNegative=-P*Data;   % Transforms losses to positive values
    LossesSorted=sort(LossesNegative); % Sorts losses in ascending order - i.e. largest lost at the bottom
    n=length(LossesSorted);
    index=cl*n;  % This index value may or may not be an integer
    % If index value is an integer, VaR follows immediately
    if index-round(index)==0    % If index value is an integer, VaR and ETL follow immediately
       DailyHistVar=LossesSorted(index);
       DailyHistES = mean(LossesSorted(index:n));
    end
    
    % If index not an integer, take VaR as linear interpolation of loss observations just above and below 'true' VaR
    if index-round(index)>0||index-round(index)<0 

    upper_index=ceil(index); % Loss observation just above VaR 
    upper_var=LossesSorted(upper_index); % Loss observation just above VaR or upper VaR

    lower_index=floor(index); % Loss observation just below VaR 
    lower_var=LossesSorted(lower_index); % Loss observation just below VaR or lower VaR


    % If lower and upper indices are the same, VaR is upper VaR
    if upper_index==lower_index
       DailyHistVar=upper_var;
       DailyHistES = mean(LossesSorted(upper_index:n));
    end

    % If lower and upper indices different, VaR is weighted average of upper and lower VaRs
    if upper_index~=lower_index
    lower_weight=(upper_index-index)/(upper_index-lower_index); % weight on lower_var
    upper_weight=(index-lower_index)/(upper_index-lower_index); % weight on upper_var
    DailyHistVar=lower_weight*lower_var+upper_weight*upper_var;   % VaR
    DailyHistES = mean(LossesSorted(upper_index:n));
    end

    end
    MonthlyHistVar = DailyHistVar*sqrt(21);
    MonthlyHistES = DailyHistES*sqrt(21);
end









