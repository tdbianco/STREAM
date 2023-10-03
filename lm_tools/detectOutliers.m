function [lowIdx, highIdx] = detectOutliers(data, sds)

    if ~isa(data, 'double') && isnumeric(data), data = double(data); end
    
    % find mean + SD
    m = nanmean(data(:));
    sd = nanstd(data(:));
    
    % make criterion
    crit = sd * sds;
    
    % get indices of low and high outliers
    lowIdx = data < m - crit;
    highIdx = data > m + crit;

end