function tryToMakePath(pth)

    if ~exist(pth, 'dir')
        try
            [suc, msg] = mkdir(pth);
            if ~suc
                error('Error whilst attempting to make path (%s):\n\n%s\n',...
                    pth, msg);
            end
        catch ERR
            error('Error whilst attempting to make path (%s):\n\n%s\n',...
                pth, ERR.message);
        end
    end

end