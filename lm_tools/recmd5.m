function hash = recmd5(pth)

    % determine if path or file
    if exist(pth, 'file') == 2
        type = 'file';
    elseif exist(pth, 'dir') == 7
        type = 'dir';
    else
        error('Path not recognised as file or folder.')
    end

    % get files and file info
    switch type
        case 'file'
            % just one file - put in cell array
            files = {pth};
        case 'dir'
            % folder - recursively search for files
            files = recdir(pth, '-silent');
    end
    info = cellfun(@dir, files, 'uniform', false);
    
    % check for empty (as in, non-readable) file info
    nonRead = cellfun(@isempty, info);
    info(nonRead) = [];
    
    % get sizes and dates
    sizes = cellfun(@(x) x.bytes, info);
    datetimes = cellfun(@(x) x.datenum, info);
    
    % hash sizes and dates
    hash = CalcMD5(num2str([sizes; datetimes]), 'Char');
    
end