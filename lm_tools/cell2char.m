function out = cell2char(in, replaceChar)

    if ~exist('replaceChar', 'var') || isempty(replaceChar)
        replaceChar = '_';
    end

    if ischar(in), out = in; return, end
    if ~iscell(in), error('Input must be cell.'), end

    out = '';
    for i = 1:length(in)
        val = in{i};
        if ischar(val)
            out = [out, replaceChar, val];
        elseif isnumeric(val)
            out = [out, replaceChar, num2str(val)];
        elseif iscell(val)
            subVal = cell2char(val);
            out = [out, replaceChar, subVal];
        end
    end
    
    if strcmpi(out(1), replaceChar), out = out(2:end); end

end