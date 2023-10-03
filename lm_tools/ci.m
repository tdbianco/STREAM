function [lower, upper] = ci(x)

    SEM = nanstd(x)/sqrt(length(x));            
    ts = tinv([0.025  0.975],length(x)-1);     
    CI = nanmean(x) + ts*SEM;    
    lower = CI(1);
    upper = CI(2);

end