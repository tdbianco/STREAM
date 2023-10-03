function split = splitTable(tab, varargin)

    % check that all arguments are valid variable names
    argVal = false(size(varargin));
    for arg = 1:length(varargin)
        argVal(arg) = ismember(varargin{arg}, tab.Properties.VariableNames);
    end
    if ~all(argVal)
        error('All input arguments must be valid table variable names.')
    end
    
    % check that data types of requested variables are numeric or char
%     varIsNumeric    = cellfun(@(x) isnumeric(tab.(x){1}), varargin);
    varIsChar       = cellfun(@(x) ischar(tab.(x){1}), varargin);
    if ~all(varIsChar) 
        error('All requested table variables must be char.')
    end
    % find indices of requested variables
    vidx = cellfun(@(x) find(strcmpi(x, tab.Properties.VariableNames)), varargin);
       
    % make sig
    vars = tab{:, vidx};
    sig = cell(size(tab, 1), 1);
    for r = 1:size(tab, 1)
        for arg = 1:length(varargin)
            sig{r} = sprintf('%s_%s', sig{r}, vars{r, arg});
        end
        sig{r} = sig{r}(2:end);
    end
    [sig_u, ~, sig_s] = unique(sig);
   
    % split
    numSplits = length(sig_u);
    split = struct;
    for s = 1:numSplits
        idx = sig_s == s;
        split(s).tab = tab(idx, :);
        split(s).label = sig_u{s};
        for arg = 1:length(varargin)
            split(s).(varargin{arg}) = tab(idx, :).(varargin{arg}){1};
        end
    end
    
end