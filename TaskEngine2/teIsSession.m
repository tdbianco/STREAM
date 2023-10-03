function [is, reason, file_tracker, tracker] = teIsSession(path_session)
% checkes that a passed path is a) a folder, and b) contains a valid
% teTracker file

    % if path_session is a cellstr containing multiple files, recursively
    % call this function with each element 
    if iscellstr(path_session)
        [is, reason, file_tracker, tracker] =...
            cellfun(@teIsSession, path_session, 'uniform', false);
        return
    end

    % check for valid folder
    validFolder = exist(path_session, 'dir');
    if ~validFolder
        is = false;
        reason = 'not folder';
        file_tracker = [];
        tracker = [];
        return
    end
     
    % search for tracker file
    file_tracker = teFindFile(path_session, '*tracker*');
    if isempty(file_tracker)
        is = false;
        reason = 'file not found';
        file_tracker = [];
        tracker = [];
        return
    end
    
    % load tracker and check contents
    try
        tmp = load(file_tracker);
        tracker = tmp.tracker;
        % if tracker is serialised (as a result of a fast save),
        % deserialize it
        if isa(tracker, 'uint8')
            try
                tracker = getArrayFromByteStream(tracker);
            catch ERR_deserialise
                error('Error whilst attempting to deserialise the tracker. Error was:\n\n%s',...
                    ERR_deserialise.message)
            end
        end
        
    catch ERR_load
        is = false;
        reason = ERR_load.message;
        tracker = [];
        return
        
    end
    
    % check data type
    if ~isa(tracker, 'teTracker')
        is = false;
        reason = 'file is not of class teTracker';
        return
    end
    
    % check contents
    if ~isprop(tracker, 'GUID') 
        is = false;
        reason = 'missing property: GUID';
        return
        
    elseif ~isprop(tracker, 'Log')
        is = false;
        reason = 'missing property: Log';
        return
        
    end
    
    % everything is OK
    is = true;
    reason = [];
    
end
    