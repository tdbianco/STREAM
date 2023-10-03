classdef teExternalData_EyeTracking < teExternalData
    
    properties 
        Buffer
    end
    
    properties (SetAccess = private)
        TargetSampleRate
        Notepad
        TrackerType
        Calibration
    end
    
    properties (Dependent, SetAccess = private)
        Duration
        Valid
    end
    
    properties (SetAccess = private)
        Type = 'eyetracking'
    end
    
    methods
        
        function obj = teExternalData_EyeTracking(path)
            
            % check input args, to ensure that a path has been passed, and
            % that the path exists
            if ~exist('path', 'var') || isempty(path)
                error('Must supply a path to eye tracking data.')
            elseif ~exist(path, 'dir')
                error('Path does not exist.')
            end
            
            % try to find eyetracking .mat file
            file = teFindFile(path, 'eyetracking*');
            if isempty(file)
                error('No eye tracking file found in %s.', path)
            elseif iscell(file) && length(file) > 1
                error('Multiple files matched the pattern ''eyetracking*'' in path:\n%s',...
                    path)
            end
            
            % attempt to load
            try
                tmp = load(file);
            catch ERR_load
                error('Error occurred when reading eye tracking data. Error was:\n\n%s',...
                    ERR_load.message)
            end
            
            % check for serialised eye tracker, and convert if necessary
            if isa(tmp.eyetracker, 'uint8')
                tmp.eyetracker = getArrayFromByteStream(tmp.eyetracker);
            end
            
            % store
            obj.Paths('eyetracking') = file;
            obj.Buffer = tmp.eyetracker.Buffer;
            obj.TargetSampleRate = tmp.eyetracker.SampleRate;
            obj.Notepad = tmp.eyetracker.Notepad;
            obj.TrackerType = tmp.eyetracker.TrackerType;
            obj.Calibration = tmp.eyetracker.Calibration;
            
        end
        
        % get/set
        function val = get.Duration(obj)
            if ~obj.Valid
                val = [];
            else
                val = obj.Buffer(end, 1) - obj.Buffer(1, 1);
            end
        end
        
        function val = get.Valid(obj)
            val = ~isempty(obj.Buffer);
        end
        
    end
    
end