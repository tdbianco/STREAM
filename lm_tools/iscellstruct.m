function is = iscellstruct(c)

    if ~iscell(c)
        is = false;
        return
    end
    
    is = all(cellfun(@isstruct, c));

end