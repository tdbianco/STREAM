classdef teTrial 
    
    properties 
        EyeTracking
        Gaze
    end
    
    properties (SetAccess = private)
        Date
        Onset
        Offset
        Task
        TrialGUID
        Events
        TrialLogData
    end
    
    properties (Dependent, SetAccess = private)
        Duration
    end
    
    methods
        
        function obj = teTrial(date, onset, offset, task, guid,...
                trialLogData, events)
        
            obj.Date = date;
            obj.Onset = onset;
            obj.Offset = offset;
            obj.Task = task;
            obj.TrialGUID = guid;
            obj.TrialLogData = trialLogData;
            obj.Events = events;
            
        end
        
        % get / set
        function val = get.Duration(obj)
            val = obj.Offset - obj.Onset;
        end
        
    end
    
end