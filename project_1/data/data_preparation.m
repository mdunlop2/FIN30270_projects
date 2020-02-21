IBM_full  = readtable('data/IBM.csv');
NVDA_full = readtable('data/NVDA.csv');

T = 21; % Number of trading days in a month
Years = 20; % Number of years for calculaton
n = height(IBM_full); % Number of days of data
q = n - Years.*12.*T;

IBM  = (IBM_full{q:n,6}./IBM_full{q-1:n-1,6})-1; % AdjClose col 6
NVDA = (NVDA_full{q:n,6}./NVDA_full{q-1:n-1,6})-1; % AdjClose col 6
Date = IBM_full{q:n,1};

% put it into Manganelli 's Format, 2 cols
ret = [IBM NVDA];
writematrix(ret, 'data/ret.csv');
writematrix(Date, 'data/date.csv');

T = 21; % Number of trading days in a month
Years = 10; % Number of years for calculaton
n = length(ret(:,1)); % Number of days of data
q = n - Years.*12.*T;

figure
plot(Date,ret(:,2))