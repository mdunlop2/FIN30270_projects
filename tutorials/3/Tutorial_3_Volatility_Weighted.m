% Load the Data

[ Returns ] = xlsread('VaR_Data_Tutorial_10','C3:C2503'); % This is the full data set

%%

P=10000; % Portfolio Size
cl=0.99; % VaR Confidence Level
n=length(Returns); % Full Sample size
lambdaHW = 0.94; % EWMA Lambda
sam=500; % Sample size for EWMA estimation

sigmaHW=zeros(length(n-sam),1);

for t=sam+1:n % Loop to calculate the volatility weighted returns
    
periods=zeros(length(sam),1);
for i=1:sam;
period=((lambdaHW^(i-1)*Returns(t+1-i).^2));  % Calculating the lambda decay factor times squared returns for each sample period in the EWMA
periods(i)=period;
end

Sum=sum(periods);
sigHW=sqrt((1-lambdaHW)*Sum); % Volatility estimate from EWMA for each time period
sigmaHW(t,:)=sigHW;

end

VolWRet=Returns(sam+2:n).*(sigmaHW(end)./sigmaHW(sam+1:n-1)); % Volatility weighted returns based on most recent volatility estimate


HWVaR=historicalVaR(VolWRet,P,cl) % Volatility Weighted VaR


hold on
axis=[501:1:2501];
plot(axis,sigmaHW(501:2501),'b')
xlabel('Time Horizon (Years)','horizontal','center','Fontweight','bold');
ylabel('Daily Volatility (%)','rotation',90,'horizontal','center','Fontweight','bold');