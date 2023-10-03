function [out] = prepAnnotation(in, rowHead)

    if  ~(iscell(in) || ismatrix(in))
        error('Input must be a 2D matrix or cell array.')
    end
    
    if exist('rowHead', 'var') && ~isempty(rowHead) 
        in = [rowHead; in];
    end
    
    if length(rowHead) ~= size(in, 2)
        error('Number of row headings (%d) must match number of columns (%d).',...
            length(rowHead), size(in, 2))
    end

    % preallocate
    out = cell(size(in, 1), 1);
    
    % number of spaces to put between columns
    tabSpace = 5;
    
    % max length of column
    maxLen = max(cellfun(@(x) size(x, 2), in));

    for curRow = 1:size(in, 1)
        for curCol = 1:size(in, 2)
            curCell = in{curRow, curCol};
            if isnumeric(curCell), curCell = num2str(curCell); end
            curCell = [curCell, repmat(' ', 1, maxLen(curCol) - length(curCell))];
            if curCol == 1
                out{curRow} = [out{curRow}, curCell];
            else
                out{curRow} = [out{curRow}, repmat(' ', 1, tabSpace),...
                    curCell];
            end
        end
    end
    


end