function out = renameDups(in)

    % takes a cell array of strings, which may contain duplicate values.
    % Runs of dups are found, and relabelled with '_2', '_3' etc.  

    if ~isvector(in) || ~iscellstr(in)
        error('Input must be a cell array of strings vector.')
    end

    [u, i, s] = unique(in);
    
    % check for dups
    if length(u) == length(in)
        out = in;
        return
    end

    % find dups
    dupIdx = arrayfun(@(x, y) isequal(x, y), s(1:end - 1), s(2:end));
    dupLoc = find(dupIdx);
    ct = findcontig(dupIdx, true);
    if ~isempty(dupLoc)
        ct = [ct; dupLoc, dupLoc, ones(length(dupLoc), 1)];
    end
    numDups = size(ct, 1);
    
    % loop through and rename dups with ascending counter
    for d = 1:numDups
        on = ct(d, 1) + 1;
        off = ct(d, 2) + 1;
        counter = 2;
        for c = on:off
            in{c} = [in{c}, '_', num2str(counter)];
            counter = counter + 1;
        end
    end
    
    out = in;
 
end