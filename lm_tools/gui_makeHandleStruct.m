function handles = gui_makeHandleStruct(h)

    % get all objects
    all = findall(h);
    
    % get their tags
    tags = arrayfun(@(x) x.Tag, all, 'uniform', false);
    
    % remove those with empty tags
    empty = cellfun(@isempty, tags);
    all(empty) = [];
    tags(empty) = [];
    
    % loop through and make struct of all tags, associate each with the
    % corresponding handle
    handles = struct;
    for i = 1:length(all)
        handles.(tags{i}) = all(i);
    end

end