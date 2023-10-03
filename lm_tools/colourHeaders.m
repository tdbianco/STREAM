function cols = colourHeaders(data, div)

    if ~iscellstr(data)
        error('Data must be a cell array of strings.')
    end
    
    if ~exist('div', 'var') || isempty(div)
        div = '_';
    end
    
    % split by _
    parts = cellfun(@(x) strsplit(x, div), data, 'uniform', false); 

    % find max number of parts
    maxParts = max(cellfun(@length, parts));
    allParts = cell(size(data, 1), maxParts);
    
    % fill in cell matrix
    for r = 1:size(allParts, 1)
        for c = 1:size(allParts, 2)
            if length(parts{r}) >= c
                allParts{r, c} = parts{r}{c};
            end
        end
    end
    
    % find unique values for first part
    [first_u, ~, first_s] = unique(allParts(:, 1));
    
    % assign unique colours to first part
    cols_master = 0.5 + (lines(length(first_u)) / 2);
    cols = cols_master(first_s, :);
    
%     % add a ligthness value for the second part
%     empty = cellfun(@isempty, allParts(:, 2));
%     [second_u, ~, second_s] = unique(allParts(~empty, 2));
%     lt_step = 1 / length(second_u);
%     lt_master = 0:lt_step:1 - lt_step;
    
end