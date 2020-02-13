%%
% [ Returns ] = xlsread('VaR_Data','C3:C2002'); % This is the full data set
[ Returns ] = xlsread('VaR_Data','C3:C2001'); % This is the data set with one observation removed
%% Parameters
P=10000; %  Size of the portfolio
PL=Returns*P; % Historical P&L for portfolio at that size
mu=mean(Returns); % Average returns of portfolio
sigma=std(Returns); % Standard Deviation for the returns of portfolio
cl=0.99; % Chosen confidence level

%% Set up the loss data as we need
LossesNegative=-PL;   % Transforms losses to positive values
LossesSorted=sort(LossesNegative); % Sorts losses in ascending order - i.e. largest lost at the bottom
n=length(LossesSorted);

%% Test if we have an integer cut off
index=cl*n;  % This index value may or may not be an integer

% If index value is an integer, VaR follows immediately
if index-round(index)==0    % If index value is an integer, VaR and ETL follow immediately
   VaR=LossesSorted(index); 
end

% If index not an integer, take VaR as linear interpolation of loss observations just above and below 'true' VaR
if index-round(index)>0||index-round(index)<0 

upper_index=ceil(index); % Loss observation just above VaR 
upper_var=LossesSorted(upper_index); % Loss observation just above VaR or upper VaR

lower_index=floor(index); % Loss observation just below VaR 
lower_var=LossesSorted(lower_index); % Loss observation just below VaR or lower VaR

% If lower and upper indices are the same, VaR is upper VaR
if upper_index==lower_index
   VaR=upper_var;
end

% If lower and upper indices different, VaR is weighted average of upper and lower VaRs
if upper_index~=lower_index
lower_weight=(upper_index-index)/(upper_index-lower_index); % weight on lower_var
upper_weight=(index-lower_index)/(upper_index-lower_index); % weight on upper_var
VaR=lower_weight*lower_var+upper_weight*upper_var;   % VaR
end

end
