function found = instr(search, sought)

    % put search into cellstr
    if ischar(search)
        search = {search};
    end
    if ~iscellstr(search)
        error('search argument must be string or cell string.')
    end
    
    % put sought into cellstr
    if ischar(sought)
        sought = {sought};
    end
    numSearch = length(search);
    if ~iscellstr(sought)
        error('sought argument must be string or cell string')
    end
    numSought = length(sought);
    
    % loop through search and look for sought
    found = false(size(search));
    for se = 1:numSearch
        found(se) = any(cellfun(@(x) ~isempty(strfind(search{se}, x)),...
            sought));
    end

end