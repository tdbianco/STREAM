function [guid] = parProgress(guid, current, total)

    progPath = [tempdir, '_progress'];
    if ~exist(progPath, 'dir')
        mkdir(progPath);
    end
    
    if nargin == 2 && ischar(current) && strcmpi(current, 'CLEANUP')
        guidPath = [progPath, filesep, guid];
        delete([guidPath, filesep, '*.*']);
        rmdir(guidPath);
        return
    end

    if strcmpi(guid, 'INIT')
        guid = GetGUID;
        guidPath = [progPath, filesep, guid];
        if exist(guidPath, 'dir')
            rmdir(guidPath);
        end
        mkdir(guidPath);
        return
    else
        guidPath = [progPath, filesep, guid];
    end
    
    save([guidPath, filesep, num2str(current), '.mat'], 'current', 'total');

end