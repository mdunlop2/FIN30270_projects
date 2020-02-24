function [DailyMCVar,MonthlyMCVar,DailyMCES,MonthlyMCES] = MonteCarlo(Data,iter,P,cl,seed)
%MonteCarlo Calculates Var and ES using Monte Carlo simulation. Student t
%distribution chosen to sample from. 
    pd = fitdist(Data,'tLocationScale');
    Losses = zeros(iter,1);
    rng(seed) % set seed for random number generation
    
    Losses = P*random('tLocationScale',pd.mu,pd.sigma,pd.nu,[iter,1]);
    LossesSorted = sort(-1*Losses);
    
    index = cl*iter;
    % If index value is an integer, VaR and ES follows immediately
    if index-round(index)==0    
       DailyMCVar=LossesSorted(index);
       DailyMCES = mean(LossesSorted(index:iter));
    end
    if index-round(index)>0||index-round(index)<0 

    upper_index=ceil(index); % Loss observation just above VaR 
    upper_var=LossesSorted(upper_index); % Loss observation just above VaR or upper VaR

    lower_index=floor(index); % Loss observation just below VaR 
    lower_var=LossesSorted(lower_index); % Loss observation just below VaR or lower VaR


    % If lower and upper indices are the same, VaR is upper VaR
    if upper_index==lower_index
       DailyMCVar=upper_var;
       DailyMCES = mean(LossesSorted(upper_index:iter));
    end

    % If lower and upper indices different, VaR is weighted average of upper and lower VaRs
    if upper_index~=lower_index
    lower_weight=(upper_index-index)/(upper_index-lower_index); % weight on lower_var
    upper_weight=(index-lower_index)/(upper_index-lower_index); % weight on upper_var
    DailyMCVar=lower_weight*lower_var+upper_weight*upper_var;   % VaR
    DailyMCES = mean(LossesSorted(upper_index:iter));
    end

    end
    MonthlyMCVar = DailyMCVar*sqrt(21);
    MonthlyMCES = DailyMCES*sqrt(21);
end