function size = getClassSize(obj, size)

    if ~isobject(obj)
        error('''obj'' must be a class instance.')
    end
    
    % if this is the first time this function is called (i.e. no recursion)
    % the init size to zero
    size = 0;
    
    % get properties
    props = properties(obj);
    numProps = length(props);
    for p = 1:numProps
        % if the property is not a class instance, calculate it's size. If
        % it is a class instance, recursively call this function to
        % calculate internal sizes
        if ~isobject(obj.(props{p}))
            % get variable for property value
            var = obj.(props{p});
            % get variable info
            w = whos('var');
            % add size
            size = size + w.bytes;
        else
            size = getClassSize(var, size);
        end
    end
    
end