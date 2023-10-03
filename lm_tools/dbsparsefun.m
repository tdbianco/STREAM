function res = dbsparsefun(fcn, c, varargin)

%     if islogical(c) || isnumeric(c)
%         res = arrayfun(fcn, c, varargin{:});
%     elseif iscell(c)
%         res = cellfun(fcn, c, varargin{:});
%     end
    
    res = false(size(c));
    if iscell(c)
        for i = 1:numel(c)
            out = fcn(c{i});
            if isempty(out)
                out = false;
            elseif ~islogical(out)
                out = true;
            end
            res(i) = out;
        end
    elseif isnumeric(c) || islogical(c)
        for i = 1:numel(c)
            res(i) = fcn(c(i));
        end
    else
        error('Must be cell, logical or numerical data.')
    end
    
end