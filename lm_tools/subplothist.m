function subplothist(m, varargin)

    if nargin == 1
        varargin = {};
    end
    
    % get num cols
    numCols = size(m, 2);

    % if table, use variable names, other make index of var names
    if istable(m)
        hdr = m.Properties.VariableNames;
        m = table2array(m);
    else
        hdr = arrayfun(@(x) sprintf('Var%0d', x), 1:numCols, 'uniform', false);
    end
    
    figure
    nsp = numSubplots(numCols);
    for c = 1:numCols
        subplot(nsp(1), nsp(2), c)
        histogram(m(c, :), varargin{:})
        title(hdr{c})
    end
    
    
    
    
end