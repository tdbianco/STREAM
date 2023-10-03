function ext = teDiscoverExternalData(path_session)
% Discovers external data within a Task Engine 2 session folder. Returns
% subclasses of the teExternalData object for each discovered data type.
% ext is a struct containing fieldnames pertaining to each type of external
% data, and values in the form of an instance of a teExternalData subclass

% default empty struct as output arg

%     ext = struct;
    ext = teCollection('teExternalData');
    
% check input args

    if ~exist('path_session', 'var') || isempty(path_session)
        error('Must provide a path to a session folder.')
    end
    
    if ~exist(path_session, 'dir')
        error('Path not found.')
    end
    
    % check session folder
    if ~teIsSession(path_session)
        error('Not a valid session')
    end
    
% find subfolders

    % get all files and folders within session folder, and filter for only
    % (sub)folders
    d = dir(path_session);
    d(~[d.isdir]) = [];
    
    % remove OSX crap from list of folders
    idx_crap = ismember({d.name}, {'.', '..'});
    d(idx_crap) = [];
    
    % get number of folders, and give up if no folders found
    numFolders = length(d);
    if numFolders == 0
        return
    end
    
    % compare subfolder names to lookup table
    lookup = {...
    %   folder name         % prop name         % class
        'eyetracking',      'EyeTracking',      'teExternalData_EyeTracking'        ;...
        'enobio',           'Enobio',           'teExternalData_Enobio'             ;...
        'screenrecording',  'ScreenRecording',  'teExternalData_ScreenRecording'    ;...
        'fieldtrip',        'Fieldtrip',        'teExternalData_Fieldtrip'          ;...
        };
    
    for f = 1:numFolders
        
        % search for folder name in lookup
        found = find(strcmpi(d(f).name, lookup(:, 1)));
        
        % if found, create a field in the output struct (ext), and make its
        % value an instance of the appropriate teExternalData_ subclass (as
        % found in the second col of the lookup table)
        if found
            
            type = lookup{found, 1};
%             propName = lookup{found, 2};
            className = lookup{found, 3};
                
            % build an absolute path to the external data folder
            path_ext = fullfile(path_session, d(f).name);
            
            % check folder is not empty
            d_tmp = dir(path_ext);
            emptyFolder = length(d_tmp) == 2 &&...
                all(ismember({d_tmp.name}, {'.', '..'}));
            
            if ~emptyFolder
                
                ext(type) = feval(className, path_ext);

%                 % use dynamic fieldnames to name the field after the folder of
%                 % external data (e.g. 'eyetracking'). Then use feval to
%                 % dynamically instantiate the appropriate subclass. Pass it the
%                 % path tco the external data folder, so that it can load/do
%                 % whatever with it. 
%                 ext.(lookup{found, 2}) = feval(lookup{found, 3}, path_ext);
                
            end
    
        end
        
    end
    
end