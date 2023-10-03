function i = lm_interpLogicalVector(m, time, criterion)

    if ~exist('criterion', 'var') || isempty(criterion)
        criterion = 0.150;
        warning('Length criterion was not supplied, using default value of 150ms.')
    end
    
    % find runs of missing or out-of-AOI samples
    ctm = findcontig2(m, true);
    
    % if no runs of missing samples, return the input vector as the output
    % (i.e. no need to interpolate)
    if isempty(ctm)
        i = m;
        return
    end

    % convert to secs
    [ctm_time, ctm]         = contig2time(ctm, time);

    % remove gaps longer than criterion 
    tooLong                 = ctm_time(:, 3) > criterion;
    ctm(tooLong, :)         = [];
    ctm_time(tooLong, :)    = [];
    dur                     = ctm_time(:, 3);

    % find samples on either side of the edges of missing data
    e1                      = ctm(:, 1) - 1;
    e2                      = ctm(:, 2) + 1;

    % remove out of bounds 
    outOfBounds             = e1 == 0 | e2 > size(m, 1);
    e1(outOfBounds)         = [];
    e2(outOfBounds)         = [];
    ctm(outOfBounds, :)     = [];
    dur(outOfBounds)        = [];
    
    % loop through each gap and fill in
    i = m;
    for e = 1:length(e1)
        i(e1(e):e2(e)) = true;
    end    
    
    fprintf('Interpolated %d gaps, prop moved from %.2f to %.2f.\n',...
        length(e1), prop(m), prop(i))
    
end
