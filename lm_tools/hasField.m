function val = hasField(s, f)

    % usage hasField(s, f)
    %
    % returns TRUE if field name f is a field in struct s, otherwise
    % returns FALSE
    
    if ~isstruct(s)
        error('Must pass a struct')
    end
    
    if ~ischar(f) && ~iscellstr(f)
        error('Field name must be char or cell array of string')
    end
    
    
    if ischar(f), f = {f}; end
    
    fields = fieldnames(s);
    val = all(cellfun(@(x) any(strcmpi(fields, x)), f));

end
