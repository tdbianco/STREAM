function Z = nanzscore(X)
    valWithoutNaNs = X(~isnan(X));
    valMean = mean(valWithoutNaNs);
    valSD = std(valWithoutNaNs);
    Z = (X-valMean)/valSD;
end