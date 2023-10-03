function found = findFilename(fileName, filePath)

    d = jdir(filePath);
    found = {};
    
    for curFile = 1:size(d, 1)
        
        if ~d(curFile).isdir
            
            res = strfind(d(curFile).name, fileName);
            if ~isempty(res)
                found = [found; [filePath, filesep, d(curFile).name]];
            end
            
        end
        
    end
    
    if length(found) == 1, found = found{1}; end
    
end