function choices = oddball_pond_listVideoChoices(pres)
% looks in the /oddball/stimuli/videos folder, and lists subfolder names.
% Easch of these subfolders contains video files from a particular TV show.
% This function therefore returns a list of available videos from which the
% experimenter can choose one for the kid to watch during the oddball task

    % check that the presenter has a path to the oddball stim
    path_stim = pres.Paths('oddball_pond_stim');
    if isempty(path_stim)
        error('Could not find a path with key ''oddball_stim'' in the presenter''s Paths collection.')
    end
    
    % check path to /stim/videos folder exists
    path_oddball_videos = fullfile(pres.Paths.oddball_pond_stim, 'videos');
    if ~exist(path_oddball_videos, 'dir')
        error('/oddball/stimuli/videos folder not found.')
    end
    
    % get all files/folders 
    subfolders = dir(path_oddball_videos);
    % filter out folders and . / ..
    idx_filter = ~[subfolders.isdir] | ismember({subfolders.name}, {'.', '..'});
    subfolders(idx_filter) = [];
    % check not empty
    if isempty(subfolders)
        error('/oddball/stimuli/videos was found but does not contain any subfolders.')
    end
    
    % return subfolder names as list of choices
    choices = {subfolders.name};

end