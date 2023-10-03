function c = extractNumeric(c)

    % check input is cell array
    if ~iscell(c) && ~ischar(c)
        error('Input must be a char or a cell array')
    end
    
    if ischar(c)
        c = {c};
        convertBackFromCell = true;
    else
        convertBackFromCell = false;
    end
    
    % make index of char elements
    if ~iscellstr(c)
        ch = cellfun(@ischar, c);
    else
        ch = true(size(c));
    end
    
    % process
    c(ch) = cellfun(@(x) str2double(regexp(x, '\d*', 'match')), c(ch),...
        'uniform', false);
    
    if convertBackFromCell
        c = c{1};
    end
    
%     % convert numeric to cell
%     nm = cellfun(@isnumeric, c);
%     c(nm) = cellfun(@num2cell, c(nm), 'uniform', false);
    
end