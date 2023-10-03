function tab_filt = filterTable(tab, varargin)

    % check that input args can be paired
    numPairs = length(varargin);
    if mod(numPairs, 2) ~= 0
        error('Input arguments must be pairs of ''variable''/''function''.')
    end
    % check that pairs are of the right data type
    if ~all(cellfun(@ischar, varargin(1:2:end)))
        error('First argument of each pair must be ''variable'' as char.')
    end
    if ~all(cellfun(@(x) isa(x, 'function_handle'), varargin(2:2:end)))
        error('Second argument of each pair must be ''function'' as function handle.')
    end
    % extract vars/fcns
    vars = varargin(1:2:end);
    fcns = varargin(2:2:end);
    % attempt to execute each function
    idx = false(size(tab, 1), 1);
    for v = 1:length(vars)
        idx = idx | fcns{v}(tab.(vars{v}));
    end
    tab_filt = tab(idx, :);

end