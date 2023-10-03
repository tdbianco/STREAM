function [res, lastUpdate] = recdir(path, recMax, res, percRange, stat,...
    lastUpdate, recNum)
   
    if ~exist(path, 'dir')
        error('Path does not exist.')
    end
    
    if nargin == 2 && ischar(recMax) && strcmpi(recMax, '-silent')
        silent = true;
    else
        silent = false;
    end
    
    if ~exist('res', 'var') || isempty(res)
        res = {};
    end
    
    if ~exist('percRange', 'var') || isempty(percRange)
        percRange = [0, 100];
    end
    
    if ~exist('stat', 'var') 
        if ~silent
            stat = ECKStatus('');
        else 
            stat = struct;
        end
    end
    
    if ~exist('lastUpdate', 'var') || isempty(lastUpdate)
        lastUpdate = now;
    end
    
    if ~exist('recMax', 'var') || isempty(recMax)
        recMax = inf;
    end
    
    if ~exist('recNum', 'var') || isempty(recNum)
        recNum = 0;
    else
        recNum = recNum + 1;
    end
    
    if recNum > recMax, return, end
    
    % report progress
    if (now - lastUpdate) * 86400 > .25
        if length(path) > 50
            progPath = ['...', path(end - 50:end)];
        else
            progPath = path;
        end
        stat.Status = sprintf('Finding files in %.1f%% [%s]', percRange(1),...
            progPath);
        lastUpdate = now;
    end
    
    % get file/folder list
    d = jdir(path);
    
    % append to results var
    res = [res; {d.fullPath}'];
    
    % find directories to scan
    dirsToScan = {d(cell2mat({d.isdir})).fullPath};
    numDirsToScan = length(dirsToScan);
    
    % calculate percentage progress
    pStep = (percRange(2) - percRange(1)) / (numDirsToScan);
    pRange = percRange(1):pStep:percRange(2);
    
    % recursively scan folders
    for f = 1:numDirsToScan
        [res, lastUpdate] =...
            recdir(dirsToScan{f}, recMax, res, pRange(f:f + 1), stat,...
            lastUpdate, recNum);
    end
    
    if percRange(2) == 100
        stat.Status = sprintf('Found %d files and folders in %s.\n',...
            size(res, 1), path);
    end
    
end