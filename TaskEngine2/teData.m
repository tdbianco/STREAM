classdef teData < teDynamicProps
    
    properties
        GUID@char
        Valid = false
        RegisteredEvents@teEventCollection
        ExternalData@teCollection
    end
    
    properties (Dependent)
        Log
    end
    
    properties (Dependent, SetAccess = private)
        Tasks
        TaskTrialSummary
        LogTable
        Events
        TrialGUIDs
        TrialGUIDTable
    end
    
    properties (SetAccess = private)
        Path_Session
        Path_Tracker     
        Path_Subject
        DynamicValues
    end
    
    properties (Access = private)
        prTracker
        prLog
        prLogTable
        prWasLoaded = false
    end

    methods
        
        function obj = teData(path_session, varargin)
        % initialise instance with an input argument that is a path to a
        % session folder
        
        % handle input args
        
            % by default, loading one session folder causes a check for
            % multiple sessions in the same subject folder. This can be
            % disabled with the dontCheckMultipleSessions input argument.
            checkMultipleSessions =...
                ~ismember('dontCheckMultipleSessions', varargin);
        
        % init collections
        
            % registered events collection
            obj.RegisteredEvents = teEventCollection;
            
            % external data collection
            obj.ExternalData = teCollection;
            obj.ExternalData.EnforceClass = 'teExternalData';
            obj.ExternalData.ChildProps = {'Paths'};
            
        % check input args and session data to ensure it can be loaded
            
            % check input args
            if ~exist('path_session', 'var') 
                error('You must initialise this instance by passing the path to a session folder.')
            elseif ~exist(path_session, 'file')
                error('Session path not found.')
            end
            
            % do format check on session
            [passed, reason, file_tracker, tracker] = teIsSession(path_session);
            if ~passed
                error('Path [%s] does not refer to a valid Task Engine 2 session. Reason was:\n\n%s',...
                    path_session, reason)
            end
            
        % store main fields from the teTracker into teData properties
        
            % store session path
            obj.Path_Session = path_session; 
            
            % find subject folder and store its path
            parts = strsplit(path_session, filesep);
            obj.Path_Subject = [filesep, fullfile(parts{1:end - 1})];
            
            % store tracker path, and tracker
            obj.Path_Tracker = file_tracker;
            obj.prTracker = tracker;
            
            % store GUID
            obj.GUID = tracker.GUID;
            
            % store log
            obj.prLog = tracker.Log;            
            
        % take dynamic props from tracker and apply them to this class.
        % Dynamic properties are used to store fields that can vary between
        % batteries, e.g. ID, age, site etc.
        
            % get list of dynamic props (variables names) in the tracker
            varNames = tracker.prVariables(:, 1);
            
            % loop through variables and add a dynamic property to this
            % teData instance, then copy the value from the tracker into
            % the instance
            for v = 1:length(varNames)
                % add dynamic prop
                addprop(obj, varNames{v});
                obj.(varNames{v}) = tracker.(varNames{v});
                obj.DynamicProps{end + 1} = varNames{v};
                obj.DynamicValues{end + 1} = tracker.(varNames{v});
            end
    
        % attempt to discover external data in the session folder. If any
        % external data is found, add an instance of the appropriate
        % teExternalData_ subclass to the teData instance as a dynamic
        % prop
        
            % find external data, and return teExternalData instnace(s)
            ext = teDiscoverExternalData(path_session);
            
            % add to object
            obj.ExternalData = [obj.ExternalData, ext];
            
%             % add as dynamic props
%             if ~isempty(ext)
%                 
%                 fnames = fieldnames(ext);
%                 numExt = length(fnames);
%                 for e = 1:numExt
%                     obj.ExternalData(fnames{e}) = ext.(fnames{e});
%                     addprop(obj, fnames{e});
%                     obj.(fnames{e}) = ext.(fnames{e});
%                 end
%                 
%             end
            
        % copy registered events from tracker to teData
        
            % if not reg events in the tracker, use the standard task
            % engine ones
            if isempty(tracker.RegisteredEvents)
                teInitStandardRegisteredEvents(obj.RegisteredEvents);
            else
                obj.RegisteredEvents = tracker.RegisteredEvents;
            end
            
        % look for, and deal with, multiple sessions in the same subject
        % folder
        
            if checkMultipleSessions
                warning('Checking for multiple sessions currently disabled.')
%                 obj.HandleMultipleSessions
            end

        end
        
        function HandleMultipleSessions(obj)
        % find multiple sessions in the current subject folder    
            
        % find subfolders in the subject folder
        
            d = dir(obj.Path_Subject);
            
            % only folders
            d(~[d.isdir]) = [];
            
            % remove . and .. crap
            idx_crap = ismember({d.name}, {'.', '..'});
            d(idx_crap) = [];
            
        % make full absolute paths
            
            path_folders = cellfun(@(path, name) fullfile(path, name),...
                {d.folder}, {d.name}, 'UniformOutput', false);
            
        % filter for session folders
        
            idx_ses = cellfun(@teIsSession, path_folders);
            path_ses = path_folders(idx_ses);
            
        % remove currently-loaded session from session folders
        
            idx_current = strcmpi(obj.Path_Session, path_ses);
            path_ses(idx_current) = [];
            
        % make teData instance for each multiple session
        
            mData = cellfun(@(pth) teData(pth, 'dontCheckMultipleSessions'),...
                path_ses, 'UniformOutput', false);
            
        % filter out non-matching GUIDs from sessions
        
            mGUIDs = cellfun(@(x) x.GUID, mData, 'UniformOutput', false);
            idx_guidMatch = isequal(obj.GUID, mGUIDs);
            path_ses(~idx_guidMatch) = [];
            mData(~idx_guidMatch) = [];
            numSes = length(mData);
            
        end
        
        % get / set
        function val = get.Log(obj)
            val = obj.prLog;
        end
        
        function set.Log(obj, val)
            obj.prLog = val;
        end
        
        function val = get.LogTable(obj)
            % if no log data, return empty
            if isempty(obj.Log), val = []; return, end
            % check if cached
            if isempty(obj.prLogTable)
                % make table
                obj.prLogTable = teLogExtract(obj.Log);
            end
            % return value
            val = obj.prLogTable;
        end
        
        function val = get.Tasks(obj)
            % get log table
            tab = obj.LogTable;
            % find empties
            empty = cellfun(@isempty, tab.task);
            tab(empty, :) = [];
            % return unique task labels
            val = unique(tab.task);            
        end
        
        function val = get.TaskTrialSummary(obj)
            % get log table
            tab = obj.LogTable;
            % filter for trial data
            tab = teLogFilter(tab, 'topic', 'trial_log_data');
            % find empties
            empty = cellfun(@isempty, tab.task);
            tab(empty, :) = [];
            % get task subscripts
            [task_u, task_i, task_s] = unique(tab.task);
            % count trials
            num = accumarray(task_s, ones(size(tab, 1), 1), [], @sum);
            % make table
            val = array2table(num, 'rownames', task_u, 'VariableNames',...
                {'Number'});
        end
        
        function val = get.Events(obj)
            % get just events
            val = teLogFilter(obj.LogTable, 'source', 'teEventRelay_Log');
        end
        
        function val = get.TrialGUIDTable(obj)
        % returns a table of trial GUIDs, with associated task name, trial
        % number and subscripts to further interrogate the log
        
            % get working copy of trial log table. We do this so that we
            % can filter out rows with missing trial GUIDs but still query
            % it for, e.g., task name
            tab = teLogFilter(obj.Log, 'data', 'trial_onset');
        
            % get trial GUIDs in a vector
            tguid = tab.trialguid;
            
            % remove empty
            empty = cellfun(@isempty, tguid);
            tab(empty, :) = [];
            
            % find unique
            [tguid_u, tguid_i, tguid_s] = unique(tab.trialguid);        
            
            val = table;
            val.trialguid = tguid_u;
            val.timestamp = tab.timestamp;
            val.task = tab.source;
            val.trialno = cell2mat(tab.trialno);
        
        end
        
        function val = get.TrialGUIDs(obj)
        % produces a unique list of trial GUIDs. Some log entries will have
        % a blank trial GUID so we remove those first. 
        
            tab = obj.TrialGUIDTable;
            val = tab.trialguid;
            
        end
       
    end
    
end