function rotateTable(tab, vars_split, vars_summarise)

    % if single args, put in cell array
    if ~iscell(vars_split), vars_split = {vars_split}; end
    if ~iscell(vars_summarise), var_summarise = {vars_summarise}; end

    split = splitTable(tab, vars_split{:});
    


end