function s = structFieldsToLowercase(s)

    fnames_orig = fieldnames(s);                                            % get original fieldnames
    fnames_lower = lower(fnames_orig);                                      % make lowercase names
    numFields = length(fnames_orig);
    
    for f = 1:numFields                                                     % loop through all fields
        if ~strcmp(fnames_orig{f}, fnames_lower{f})                         % only change if current name ISN'T all lowercase
            s.(fnames_lower{f}) = s.(fnames_orig{f});                       % add new lowercase field
            s = rmfield(s, fnames_orig{f});                                 % remove old field
        end
    end
    
end