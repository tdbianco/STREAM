function s = orderfieldssparse(s, fields)

    % ensure col vector
    if size(fields, 1) < size(fields, 2)
        fields = fields';
    end
    % get fieldnames, find those not specified
    fn = fieldnames(s);
    missing = setdiff(fn, fields);
    % order
    fields = [fields; missing];
    s = orderfields(s, fields);
    
end