function sem = nansem(X)

    sd  = nanstd(X);
    N   = length(X);
    sem = sd / sqrt(N);
    
end