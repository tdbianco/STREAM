function uitableAutoColumnHeaders(h, multiplier)

    if ~exist('multiplier', 'var') || isempty(multiplier)
        multiplier = 1;
    elseif ~isnumeric(multiplier) && ~iscalar(multiplier)
        error('multiplier argument must be a numeric scalar.')
    end
    
    % get column headers and data
    hdr = get(h, 'ColumnName');
    tab = get(h, 'Data');
    
    if isempty(tab), return, end
    
    % preallocate
    numCols = size(tab, 2);
    numRows = size(tab, 1);
    widths = zeros(numRows + 1, numCols);
    
    % get width of each cell
    for c = 1:numCols
        
        val = hdr{c};
        if isnumeric(val), val = num2str(val); end
        widths(1, c) = length(val);
        % check for listbox and add some width if found
        if length(h.ColumnFormat) >= c && iscell(h.ColumnFormat{c}) &&...
                length(h.ColumnFormat{c}) > 1
            widths(1, c) = widths(1, c) + 3;
        end
            
        for r = 1:numRows
            
            val = tab(r, c);
            if iscell(val), val = val{:}; end
            if isnumeric(val), val = num2str(val); end
            
            % if cell contains HTML tags, remove these
            if ischar(val) && instr(lower(val), '<html>')
                % find tags
                i1 = strfind(val, '<');
                i2 = strfind(val, '>');
                if length(i1) == length(i2)
                    % mark tags for removal
                    for t = 1:length(i1)
                        val(i1(t):i2(t)) = '#';
                    end
                end
                
                % remove tags
                val = strrep(val, '#', '');
                % remove spaces
                val = strrep(val, ' ', '');
                
            end
                
            widths(r + 1, c) = length(val);
            
        end
        
    end
    
    % collapse rows to get max width of any cell in each col
    width_hdr = widths(1, :);
    if size(widths, 1) > 1
        width_dta = max(widths(2:end, :) * multiplier, 1);
    else
        width_dta = [];
    end
    width_max = max([width_hdr; width_dta]);
    
    % assume 8 px per char, calculate width in px
    width_px = width_max * (.6 * get(h, 'FontSize'));
    
    % set widths in uitable
    set(h, 'ColumnWidth', num2cell(width_px * multiplier));
    
end