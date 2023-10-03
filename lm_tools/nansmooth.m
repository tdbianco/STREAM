function sm = nansmooth(raw, fun, window, method)

    if ~exist('fun', 'var') || isempty(fun)
        fun = '@smooth';
    end
    
    if ~exist('window', 'var') || isempty(window)
        window = 5;
    end
    
    if ~exist('method', 'var') || isempty(method)
        method = 'moving';
    end
    
    % find non-missing sections
    miss = raw == -1 | isnan(raw);
    ct = findcontig(~miss, true);

    % loop through and smooth valid section
    for s = 1:size(ct, 1)
        raw(ct(s, 1):ct(s, 2)) =...
            feval(fun, raw(ct(s, 1):ct(s, 2)), window, method);
    end
    
    sm = raw;
    
end