classdef teTracker < dynamicprops

    properties
        Path_Root = fullfile(pwd, 'data')
    end
    
    properties (SetAccess = private)
        RandSeed
        Path_Subject
        Path_Session
        Path_Diary
        Path_Tracker
        Path_EyeTracker        
        Resuming = false
        CreationTime
    end
    
    properties (Dependent, SetAccess = private)
        Valid = false
        ValidationErrors = 'No variables defined'
        GUID
        SessionStartTimeString
        SessionEndTimeString
    end
    
    properties (SetAccess = ?tePresenter)
        Log
        Lists
        RegisteredEvents@teEventCollection
        LastUpdate = nan
        SessionStartTime = nan
        SessionEndTime = nan        
    end
    
    properties (SetAccess = private, GetAccess = {?tePresenter, ?teData})
        prID 
        prCurrentLevel = 1
        prVariables = {}
        prValidationErrors
        prFilesystemPathsMade = false
        prGUID
        prPreviousSessionEyeTracking
        prWasLoaded
    end
    
    events
        ResumeSession
    end
    
    methods
        
        function obj = teTracker(path_data)
            % if a data path has been passed, check it and apply
            if exist('path_data', 'var') && ~isempty(path_data)
                if ~exist(path_data, 'dir')
                    error('Path %s does not exist.', path_data)
                else
                    obj.Path_Root = path_data;
                end
            end
            % seed rng
            rng('shuffle')
            obj.RandSeed = rng;
            obj.GeneratePaths
            % make GUID 
            obj.prGUID = GetGUID;
            % record creation time
            obj.CreationTime = datetime('now');
        end
                
        function AddVariable(obj, varargin)
            
        % parse inputs
        
            parser          =   inputParser;
            isfun           =   @(f) isa(f, 'function_handle') || exist(f, 'file') == 2;
            addRequired(    parser, 'name',                     @ischar     )
            addParameter(   parser, 'makeSubFolders',   false,  @islogical  )
            addParameter(   parser, 'level',            [],     @isnumeric  )
            addParameter(   parser, 'valFun',           [],     isfun       )
            addParameter(   parser, 'options',          []                  )
            parse(          parser, varargin{2:end});
            name            =   parser.Results.name;
            makeSubFolders  =   parser.Results.makeSubFolders;
            level           =   parser.Results.level;
            options         =   parser.Results.options;
            valFun          =   parser.Results.valFun;
            
            % validate options
            if ~isempty(options)
                validDataType = iscellstr(options) || isnumeric(options);
                if ~validDataType || ~isvector(options)
                    error('''options'' must be a numeric vector or a vector cell array of strings.')
                end
            end
            
        % process level
        
            if isempty(level)
                % if not specified, use current
                level = obj.prCurrentLevel;
                obj.prCurrentLevel = obj.prCurrentLevel + 1;
            elseif level < obj.prCurrentLevel
                % cannot specify an already-used level
                error('Minimum available level is %d.', obj.prCurrentLevel)
            elseif level >= obj.prCurrentLevel
                % valid level was specified, increase current level to be
                % one above it
                obj.prCurrentLevel = level + 1;
            end
            
        % store
        
            % store variable info 
            obj.prVariables(end + 1, 1:5) =...
                {name, makeSubFolders, level, options, valFun};
            % add dynamic prop
            dynprop = obj.addprop(name);
            dynprop.SetMethod = dynSet(obj, name);
            % try to make paths
            obj.GeneratePaths
            
        end
        
        function [vars, vals] = GetVariables(obj)
        % returns the dynamic props (custom variables, e.g. ID, wave) set 
        % up in the tracker. Normally in a private property, sometimes we
        % want these (e.g. during pipeline processes)
        
            vars = obj.prVariables(:, 1);
            vals = cellfun(@(x) obj.(x), vars, 'UniformOutput', false);
            
        end
        
        function GeneratePaths(obj)
            if ~obj.Valid, return, end
            % default subfolders and tags are blank
            subFold = '';
            tags = '';
            % find all variables that spawn subfolders, sort by their level
            idx = cell2mat(obj.prVariables(:, 2));
            if any(idx)
                % sort by level
                var = obj.prVariables(idx, :);
                [~, so] = sort(cell2mat(var(:, 3)), 'descend');
                var = var(so, :);
                % make subfolders
                for sf = 1:size(var, 1)
                    % get property value
                    val = obj.(var{sf, 1});
                    % convert to string
                    if isnumeric(val), val = num2str(val); end
                    % append to sub-folder string
                    subFold = [subFold, filesep, val];
                    tags = [tags, '_', val];
                end
            end
            % make ISO 8601 date/time string 
            sesTime = datestr(obj.CreationTime, 'yyyy-mm-ddTHHMMss');
            % make subject path from root, date/time and subfolders
            obj.Path_Subject = fullfile(obj.Path_Root, subFold);
            % make session path from root, date/time and subfolders
            obj.Path_Session = fullfile(obj.Path_Subject, sesTime);
            % make other paths
%             obj.Path_ScreenRecording = fullfile(obj.Path_Session,...
%                 sprintf('screenrec%s.mp4', tags));
            obj.Path_Diary = fullfile(obj.Path_Session,...
                sprintf('diary%s.txt', tags));            
%             obj.Path_Log = fullfile(obj.Path_Session,...
%                 sprintf('log%s.mat', tags));
            
            obj.Path_EyeTracker = fullfile(obj.Path_Session,...
                'eyetracking', sprintf('eyetracking%s.mat', tags));
            obj.Path_Tracker = fullfile(obj.Path_Session,...
                sprintf('tracker%s.mat', tags));
        end
        
        function MakeFilesystemPaths(obj)
            % check tracker is valid
            if ~obj.Valid
                error('Tracker not in a valid state.')
            end
            % does session folder exist?
            if ~exist(obj.Path_Session, 'dir')
                % try to make session folder
                try
                    % session folder
                    [dir_suc, dir_msg] = mkdir(obj.Path_Session);
                    if ~isempty(obj.Path_EyeTracker)
                        [et_suc, et_msg] = mkdir(fullfile(...
                            obj.Path_Session, 'eyetracking'));
                    end
                    obj.prFilesystemPathsMade = true;
                    if ~dir_suc
                        error('Attempted to make session path, error was: \n\n%s',...
                            dir_msg);
                    end
                    if ~et_suc
                        error('Attempted to make session path, error was: \n\n%s',...
                            et_msg);
                    end                        
                catch ERR
                    error('Attempted to make session path, error was: \n\n%s',...
                        ERR.message);                    
                end
            else
                % session folder exists - this should not be possible in
                % normal operation, since the session folder is tagged with
                % date/time. However, if this method was called more than
                % once (albeit that this would be a redundant thing to do)
                % then that would trigger this condition. Throw an error,
                % because it's a weird thing to do
                error('Session folder already exists.')
            end
%             end
        end
        
        function CheckResume(obj)
            
        % search for session folders for this dataset. If there is no
        % subject folder, no session folders, or the session folders are
        % not valid, then we cannot resume
                
            % does a subject folder exist?
            if ~exist(obj.Path_Subject, 'dir')
                % no folder, so we are not resuming
                warning('A data folder with matching metadata was found, but no session folders were present to resume from:\n\n%s',...
                    obj.Path_Subject)
                return
            end
            
            % get session folders
            d = dir(obj.Path_Subject);
            % remove non-folders
            d(~[d.isdir]) = [];
            
            % get session folder names
            ses = {d.name};
            % remove OS junk
            ses(ismember(ses, {'.', '..'})) = [];
            
            % if no session folders, we are not resuming
            if isempty(ses)
                warning('A data folder with matching metadata was found, but no session folders were present to resume from:\n\n%s',...
                    obj.Path_Subject)                
                return
            end
            
            % convert session folder list to absolute paths
            ses = cellfun(@(filename) fullfile(obj.Path_Subject, filename),...
                ses, 'uniform', false);
            
            % check validity of session folders
            [sesVal, sesReason, ~, trackers] = cellfun(@teIsSession, ses,...
                'uniform', false);
            sesVal = cell2mat(sesVal);
            % filter out trackers from invalid sessions
            trackers(~sesVal) = [];
            % if none valid, give up
            if ~any(sesVal), return, end
            
        % now that we have a list of valid sessions, check that they can be
        % resumed. This means that a) they have at least one list that is
        % compiled and b) that the list is unfinished
            
            % loop through all found session folders 
            numTrackers = length(trackers);
            smry(numTrackers) = struct;
            canResume = false(numTrackers, 1);
            for t = 1:numTrackers
                
                % if tracker's list collection is empty, we can do no more
                if isempty(trackers{t}.Lists)
                    canResume(t) = false;
                    continue
                end
                
                % get compilation status of all lists
                listsAreCompiled = ...
                    cellfun(@(x) x.IsCompiled, trackers{t}.Lists.Items);
                
                % get number of total items in each list
                numItems = cellfun(@(x) length(x.prComp), trackers{t}.Lists.Items);
                
                % get current position in each list
                currentPos = cellfun(@(x) x.prCompIdx, trackers{t}.Lists.Items);
                
                % calculate list progress, defined as currentPos /
                % numItems. If numItems is zero, then progress is zero,
                % otherwise we get a div by zero warning
                progress = zeros(size(numItems));
                notZero = numItems ~= 0;
                progress(notZero) = currentPos(notZero) / numItems(notZero);
                
                % find lists that are not finished (i.e. current position
                % is not at the end of the compiled list items)
                listNotFinished = currentPos <= numItems;
                
                % put this all together into a flag for whether the list
                % can be resumed
                listCanResume = listsAreCompiled & listNotFinished;
                
                % calculate and check session start time...
                if ~isnan(trackers{t}.SessionStartTime)
                    startTime = datestr(trackers{t}.SessionStartTime,...
                        'dddd, mmmm yyyy, HH:MM:SS');
                    startTimeValid = true;
                else
                    startTime = '?';
                    startTimeValid = false;
                end
                % ...end time...
                if ~isnan(trackers{t}.SessionEndTime)
                    endTime  = datestr(trackers{t}.SessionEndTime,...
                        'HH:MM:SS');
                    endTimeValid = true;
                else
                    endTime = '?';
                    endTimeValid = false;
                end
                % ...and duration
                if startTimeValid && endTimeValid
                    duration_secs = trackers{t}.SessionEndTime -...
                        trackers{t}.SessionStartTime;                      
                else
                    duration_secs = 0;
                end
                duration = datestr(duration_secs, 'HH:MM:SS');
                
                % summarise
                smry(t).ValidSession        = sesVal(t);
                smry(t).AnyValidLists       = any(listCanResume);
                smry(t).ValidLists          = trackers{t}.Lists.Keys(listCanResume);
                smry(t).ListProgress        = sprintf('%.2f%%', progress);
                smry(t).SessionTime         = sprintf('%s - %s', startTime, endTime);
                smry(t).SessionDuration     = duration;
                canResume(t)                = sesVal(t) & any(listCanResume);
                
            end
            % is not resumable sessions, give up
            if ~any(canResume), return, end
            
        % interact with user
        
            % display resume message
            clc
            teTitle('Previous session(s) found\n\n');
            teEcho('The details entered have been used previously. %d resumable session found:\n\n',...
                sum(canResume));
            
            % display session summaries
            sesCounter = 1;
            for t = 1:numTrackers
                if canResume(t)
                    teEcho('<strong>\t%d. %s</strong>\n', sesCounter, smry(t).SessionTime);
                    teEcho('\t   Resumable lists: %s\n', cell2char(smry(t).ValidLists));
                    teEcho('\t   Session duration: %s\n', smry(t).SessionDuration);
                    fprintf('\n')
                    sesCounter = sesCounter + 1;
%                 else
%                     % delete non-resumable tracker
%                     trackers{t} = [];
                end
            end
            % delete non-resumable trackers
            trackers(~canResume) = [];
            
            % input
            teEcho('To RESUME, enter the session number above. To START A NEW SESSION, enter 0 (zero): ');
            resp = enforceinput('> ', 0:sesCounter - 1);
            % if zero is entered, return
            if isequal(resp, 0)
                return
            else
                selTracker = trackers{resp};
            end
            
        % resume selected session
        
            % replace current properties with those of the saved tracker.
            % Cannot replace the whole instance because that also replaces
            % the events, and prevents us messaging the presenter to have
            % it update it's log/lists etc. upon resume
            obj.RandSeed =selTracker.RandSeed;
            obj.prGUID =selTracker.GUID;
            obj.Log =selTracker.Log;
            obj.Lists =selTracker.Lists;
            obj.RegisteredEvents =selTracker.RegisteredEvents;
            
            % check dynamic tracker variables
            if ~isequal(obj.prVariables,selTracker.prVariables)
                error('Variables do not match between previous session and current. Cannot resume.')
            end
            
            % replace dynamic tracker variables
            varNames =selTracker.prVariables(:, 1);
            for v = 1:length(varNames)
                obj.(varNames{v}) =selTracker.(varNames{v});
            end
            
        % attempt to read eye tracking data
        
            % check that there is a Path_EyeTracker property and that it is
            % not empty
            if isprop(selTracker, 'Path_EyeTracker') &&...
                    ~isempty(selTracker.Path_EyeTracker)
                
                % if the path exists, load the data to a temp variable
                if exist(selTracker.Path_EyeTracker, 'file')
                    obj.prPreviousSessionEyeTracking =...
                        load(selTracker.Path_EyeTracker);
                else
                    error('When resuming, and trying to load previous session eye tracking data, the file was not found:\n\n%s',...
                        selTracker.Path_EyeTracker)
                end
                
            end
            
            % flag resuming 
            obj.Resuming = true;
            
            % sent message indicating that a session is resuming. Primarily
            % this will be dealt with by the presenter, which will load
            % it's lists and log from the tracker. 
            notify(obj, 'ResumeSession')
            
        end
        
        function InputValues(obj)
            if isempty(obj.prVariables)
                error('Not variables defined.')
            end
            
            % get variable names
            pnames = obj.prVariables(:, 1);
            
            % loop through and get values
            for p = 1:length(pnames)
                
                % only request a value if one doesn't already exist. This
                % allows for some values (e.g. battery) to be set
                % programtically, whilst variant values (e.g. ID) get
                % requested
                if ~isempty(obj.(pnames{p})), continue, end
                
                % not happy until this variable has been validated
                happy = false;
                while ~happy
                    
                    % get value
                    val = input(sprintf('Enter %s > ', pnames{p}), 's');
                    % check value is not empty and optionally validate
                    if isempty(val)
                        fprintf(2, 'Must enter a value.\n')
                        happy = false;
                        
                    else
                        % check not empty
                        happy = happy || ~isempty(val);
                        
                        % retrieve validation function and options
                        valFun = obj.prVariables{p, 5};
                        options = obj.prVariables{p, 4};
                        
                        % if present, call the validation function for this
                        % variable
                        if ~isempty(valFun)
                            [suc, msg] = feval(valFun, val, obj);
                            % process outputs 
                            if ~suc
                                if ~isempty(msg)
                                    % if a message was returned, display it
                                    fprintf(2, '%s\n', msg);
                                else
                                    % if no message, give a generic error
                                    fprintf(2, 'Invalid value entered for %s.\n',...
                                        pnames{p});
                                end
                                happy = false;
                            end
                            
                        % if present, check input against options list for
                        % this variable
                        elseif ~isempty(options) 
                            
                            % check that value matches the data type of
                            % options
                            validNumeric = isnumeric(val) && isnumeric(options);
                            validChar = ischar(val) && iscellstr(options);
                            if validNumeric || validChar
                                % data type of value and options match,
                                % check to see whether value if a valid
                                % option
                                optionValid = ismember(val, options);
                            else
                                % data types do not match, therefore by
                                % definition the value is not a valid
                                % option
                                optionValid = false;
                            end
                            
                            % decision
                            if ~optionValid
                                
                                % throw warning
                                fprintf(2, 'Invalid value entered for %s.\n',...
                                    pnames{p});
                                fprintf(2, 'Valid options are:\n\n');
                                % display options according to their type
                                % (cellstr needs %s format, numeric needs
                                % %d)
                                if validNumeric
                                    fprintf(2, '\t%d\n', options{:});
                                elseif validChar
                                    fprintf(2, '\t%s\n', options{:});
                                else
                                    error('Error displaying valid options.')
                                end
                                
                            end
                            
                            % store result
                            happy = happy && optionValid;
                            
                        end
                    end
                    if happy, obj.(pnames{p}) = val; end
                end
            end
            % create output folder structure, using the information given
            obj.MakeFilesystemPaths
            % check whether there is an existing dataset (i.e. with
            % metadata matching that which was just input), and offer to
            % resume that session
            obj.CheckResume
        end
        
        function Save(obj, speedMode)
            if nargin == 1
                speedMode = 'normal';
            end
            % can only save a valid tracker
            if obj.Valid 
                % check a path exists in the file system, create it if not
                if ~obj.prFilesystemPathsMade
                    obj.MakeFilesystemPaths
                end
                % copy the instance into a variable so that we can save it.
                % If doing a fast save then serialise the tracker before
                % saving
                if strcmpi(speedMode, 'fast')
                    tracker = getByteStreamFromArray(obj);
                    save(obj.Path_Tracker, 'tracker', '-v6')
                else
                    tracker = obj;
                    save(obj.Path_Tracker, 'tracker', '-v7')
                end
%                 % report save
%                 path_tracker = obj.Path_Tracker;
%                 len = length(path_tracker);
%                 over = len - 70;
%                 if over > 0
%                     s1 = over;
%                     s2 = len;
%                     path_tracker = sprintf('...%s', path_tracker(s1:s2));
%                 end
%                 teEcho('Saved to: %s\n', path_tracker);
%                 ns = 100;
%                 t = zeros(100, 1);
%                 for q = 1:ns
%                     tic
%                     tracker = getByteStreamFromArray(tracker);
%                     save(obj.Path_Tracker, 'tracker', '-v6')
%                     t(q) = toc;
%                 end
%                 d = dir(obj.Path_Tracker);
%                 fs = d.bytes / 1e3;
%                 fprintf('%.3fms, %.3fKB\n', mean(t) * 1000, fs)
            else
                warning('Tracker not valid - save failed.')
            end
        end
        
        function ReplaceLog(obj, val)
        % the .Log property's SetAccess atttribute is private. We want it
        % to stay this way as it should be managed by the tracker or
        % presenter. But sometimes we wish to work on the log array, change
        % something, then replace it. We use this method to explicitly do
        % this, whilst keeping the actual .Log property private
        
            % check that the new value is a log array (cell array of
            % structs)
            if ~iscell(val) || ~all(cellfun(@isstruct, val))
                error('Replacement log array must be a cell array of structs.')
            end
            
            % check that the lengths are the same (may want to remove this
            % if the offline work on the log involvd adding or removing
            % fields. But for data consistency, we'll keep this check for
            % now
            if ~isequal(length(obj.Log), length(val))
                error('Replacement log array must be the same size (%d) as the existing Log.',...
                    length(obj.Log))
            end
            
            % replace
            obj.Log = val;
            
        end
                    
        % get/set       
        function set.Path_Root(obj, val)
            % check path exists
            if ~exist(val, 'dir') 
                % attempt to make path
                [suc, msg] = mkdir(val);
%                 if ~suc
%                     warning('Path %s does not exist. Attempting to create it caused an error:\n\n%s',...
%                         val, msg)
%                 end
            end
            obj.Path_Root = val;
            obj.GeneratePaths
        end
        
        function val = get.ValidationErrors(obj)
            val = obj.prValidationErrors;
        end
        
        function val = get.Valid(obj)
            % check a data path has been passed and exists
            if isempty(obj.Path_Root)
                val = false;
                obj.prValidationErrors = 'Root path not defined.';
                return
            elseif ~exist(obj.Path_Root, 'dir')
                val = false;
                obj.prValidationErrors = 'Root path %s does not exist';
                return
            end
            % check dynamic variables exist
            if isempty(obj.prVariables)
                val = false;
                obj.prValidationErrors = 'No variables defined';
                return
            end
            % check all variables have a value
            propnames = obj.prVariables(:, 1);
            empty = cellfun(@(x) isempty(obj.(x)), propnames);
            if any(empty)
                val = false;
                obj.prValidationErrors = [...
                    sprintf('Invalid field values: '),...
                    sprintf('%s ', propnames{empty})];
            else
                val = true;
                obj.prValidationErrors = [];
            end
        end
        
        function val = get.GUID(obj)
            val = obj.prGUID;
        end
        
        function val = get.SessionStartTimeString(obj)
            if isnan(obj.SessionStartTime)
                val = 'Not valid';
            else
                val = datestr(obj.SessionStartTime, 'yyyymmddTHHMMss');
            end
        end
        
        function val = get.SessionEndTimeString(obj)
            if isnan(obj.SessionEndTime)
                val = 'Not valid';
            else
                val = datestr(obj.SessionEndTime, 'yyyymmddTHHMMss');
            end
        end
        
    end

end

function f = dynSet(~, propname)
        function success = setProp(obj, val)
            % find the validation function for this property
            idx = strcmpi(obj.prVariables(:, 1), propname);
            if ~any(idx)
                error('Not a valid property name.')
            end
            valFun = obj.prVariables{idx, 5};
            % check that the value being assigned is char of numeric -
            % nothing else is supported
            success = ischar(val) || isnumeric(val);
            % if there is a validation function, call it and note
            % success/failue, otherwise just assume success and assign the
            % property value
            if ~isempty(valFun)
                [tmpSuccess, msg] = feval(valFun, val, obj);
                success = success && tmpSuccess;
                if ~tmpSuccess
                    fprintf(2, '%s\n', msg);
                end
            else
                success = success && true;
            end
            if success
                obj.(propname) = val;
                obj.GeneratePaths
            end
        end
    f = @setProp;
end