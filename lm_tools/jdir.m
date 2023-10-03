function out = jdir(path)

    % make java file object, then get file list
    fo = java.io.File(path);
    fl = fo.listFiles;
    
    % extract names and whether each entry is a dir 
    name = arrayfun(@(x) char(x.getName), fl, 'UniformOutput', false);
    isDir = arrayfun(@(x) x.isDirectory, fl);
    fullPath = arrayfun(@(x) char(x.getAbsolutePath), fl, 'UniformOutput', false);
    parent = arrayfun(@(x) char(x.getParent), fl, 'UniformOutput', false);
    bytes = arrayfun(@(x) x.length, fl);
    
    % flag for whether 
    
    % put in struct
    out = struct(...
        'name', name,...
        'bytes', num2cell(bytes),...
        'isdir', num2cell(isDir),...
        'fullPath', fullPath,...
        'parent', parent);
    
%     modified = arrayfun(@(x) x.lastModified, fl, 'UniformOutput', false);

end