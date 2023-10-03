function [paths_sessions, tracker] = teRecFindSessions(path_data)
% Recursively finds sessions in a folder tree. Returns the path to all
% discovered sessions, as well as the contents of the tracker. 

    % rec find all files
    allFiles = recdir(path_data);
    
    % add current path to allFiles in case it is itself a session
    allFiles{end + 1} = path_data;
    numFiles = length(allFiles);
    teEcho('Finding valid sessions...\n');
    
    % find valid te sessions
    is = false(numFiles, 1);
    tracker = cell(numFiles, 1);
    tic
    for f = 1:numFiles
        [is(f), ~, ~, tracker{f}] = teIsSession(allFiles{f});
    end
    toc
    
    % filter for valid sessions   
    paths_sessions = allFiles(is);
    tracker = tracker(is);
    teEcho('%d sessions found.\n', sum(is));

end