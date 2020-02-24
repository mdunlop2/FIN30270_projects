function [DailyStudentVar,MonthlyStudentVar,DailyStudentES,MonthlyStudentES] = StudentVarES(Data,P,cl)
%StudentVarES Fits a Student's t distribution to the data and calculates
%Daily and Monthly VaR and ES
    mu = mean(Data); % mean
    sigma = LSV(Data); % Lower semi standard deviation
    pd = fitdist(Data,'tLocationScale'); % fit to a student t
    v = pd.nu; % Degrees of freedom
    DailyStudentVar = (-mu+sigma*sqrt((v-2)/v)*tinv(cl,v))*P;
    MonthlyStudentVar = (-mu*21+sigma*sqrt(21)*sqrt((v-2)/v)*tinv(cl,v))*P;
    DailyStudentES = (-mu+sigma*(tpdf(tinv(cl,v),v))*(v-2+tinv(cl,v)^2)/((v-1)*(1-cl)))*P; % Formula per Alexander (2008), P.131
    MonthlyStudentES = (-mu*21+sigma*sqrt(21)*(tpdf(tinv(cl,v),v))*(v-2+tinv(cl,v)^2)/((v-1)*(1-cl)))*P;
end

