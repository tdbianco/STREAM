function found = teFindFile(path_in, search)
% finds a file within a folder using wildcard matching. For example, if we
% wish to find a tracker file that is names 'tracker_BATTERY_SUBJECTID.mat'
% then we use the wildcard '*tracker*' to return this file. 

    % check that path is a folder
    if ~exist('path_in', 'var') || isempty(path_in) || ~exist(path_in, 'dir')
        error('''path'' must be a folder.')
    end
    
    % check that search is char
    if ~ischar(search) 
        error('''search'' must be a char.')
    end
    
    % search for files
    d = dir(sprintf('%s%s%s', path_in, filesep, search));
    
    % make full paths
    found = cellfun(@(filename) fullfile(path_in, filename), {d.name},...
        'uniform', false);
    
    % if is scalar cell array, return as char
    if isscalar(found)
        found = found{1};
    end

end