                              

%{
Useful websites and tutorials:
- http://www.mathworks.com/matlabcentral/
- http://www.mathworks.com/help/pdf_doc/matlab/getstart.pdf
- http://www.kevinsheppard.com/images/5/56/MATLAB_Notes_2013.pdf
_https://www.kevinsheppard.com/MFE_MATLAB_Introduction 
-https://www.kevinsheppard.com/images/0/06/MATLAB_Introduction_2013.pdf (We
will go through some of the lessons and exercise here)
%}


clear all;
close all;
clc;

%{
Remeber to set the path to the folder where all your files are (if you did
not do it manually)
- path('newpath') changes the search path to newpath, where newpath is a string array of folders
- addpath(folderName1,...,folderNameN) adds the specified folders to the top of the search path.
%}


%% 
%-------------------------Variable definition------------------------------
%matrix -> capital letter; 
%vector -> lower-case letter
 
v = [1 2 3 4]; 		%row vector
%%

v = [1; 2; 3; 4] 	%column vector

%%
v = [1 2 3 4]' 		%column vector

%%
v = 1:0.5:10    %steps of 0.5 from 1 to ten

%%
v = 1:10 		%default step: 1, row vector

%%
M = [1 2 3; 4 5 6; 7 8 9]

%%
M = zeros(2,2)          %1 number: square; 2 numbers: rectangular
M(1,1) =1; M(1,2)=2;    %position numbers in a matrix
M(2,1)=3; M(2,2) =4; 

%%
%------------------------Matrix manipulation-------------------------------
%  Access to matrix entry

M = [1 2 3; 4 5 6; 7 8 9]

%%
[row, col] = size(M)
row./2

M(:,1)
%%
M(1,:)

%%
c = M(:,1)      %first column
r = M(1,:)      %first row
cs = M(:,1:2)   %first 2 colums
rs = M(1:2,:)   %first 2 rows
rc = M(1:2,1:2) %submatrix 2x2 (upper left)

% Specific values
%Linear index
find(M>1)       %output in linear index
M(find(M>1))    %output in elements

%% Matrix operations
M1'                 %transpose
M1/M2               %M1 divided by M2
M1\M2               %M2 divided by M1

%Element-wise operations
M1.*M2
M1./M2
M1.\M2
M1.^M2

%% Single matrix manipulation
X = [1 2;3 4]
X(3,3) = 2          %add scalar in a specific position
M = [X [1; 2; 3]]   %add column
M = [M; [1:5:16]]   %add row
M = M(1:3,:)        %delete row
M = M(:,1:3)        %delete column
M1 = [1 2;3 4]
M2 = [5 6;7 8]


%% 
%--------------------Data import and visualization-------------------------

%XLS import Note: data is monthly returns downloaded from Yahoo

[data, text, raw] = xlsread('Data','Returns', 'A1:E241');

data = 100*data;

%% ------------------Covert Excel dates to matlab dates--------------------------------
DateString = text(2:end,1);
DateFormat = 'mm/dd/yyyy';
dates = datenum(DateString, DateFormat); 
Ex_date=datestr(dates);

%%
[row, col] = size(data);

%%
%Get returns for each asset

aapl = data(:,1);           % Apple Inc
nke = data(:,2);            % Nike Inc
coke = data(:,3);           % Coca-cola
cog  = data(:,4);           % Cabot Oil and Gas

%%
%Summary statistics for a Portfolio including the four assets
mu = mean(data);

Sigma = cov(data);

Variance = diag(Sigma)';

Std = sqrt(Variance);

%Try any other interesting things for example writing a function to compute the stats above.

%% 
% Simple plots in Matlab
startDate = datenum('02/01/1996');
endDate = datenum('01/12/2015');
xData = linspace(startDate,endDate,240);

plot(xData, aapl);
datetick('x','yyyy','keeplimits')
title('Plot of Apple Returns');
xlabel('Date');
ylabel('Apple'); 



