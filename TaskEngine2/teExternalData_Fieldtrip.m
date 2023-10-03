classdef teExternalData_Fieldtrip < teExternalData
    
    properties (SetAccess = private)
        SampleRate
        Valid 
    end
    
    properties (SetAccess = private)
        Type = 'fieldtrip'
    end
    
    methods
        
        function obj = teExternalData_Fieldtrip(path_ft)
            
            % call superclass constructor to do common initiation
            obj = obj@teExternalData;
            
            % check input args, to ensure that a path has been passed, and
            % that the path exists
            if ~exist('path_ft', 'var') || isempty(path_ft)
                error('Must supply a path to Enobio data.')
            elseif ~exist(path_ft, 'dir')
                error('Path does not exist.')
            end
            
            % look for fieldtrip file
            file_ft = teFindFile(path_ft, '*fieldtrip*');
            if isempty(file_ft)
                warning('Fieldtrip file not found in fieldtrip folder.')
                return
            elseif iscell(file_ft) && length(file_ft) > 1
                warning('Multiple fieldtrip files found.')
                return
            else
                obj.Paths('fieldtrip') = file_ft;
            end
    
        % attempt to load header
        
            % load
            tmp = load(file_ft);
            
            % calculate duration
            obj.SampleRate = tmp.ft_data.fsample;
            
            % set valid
            obj.Valid = true;
            
        end
        
        function data = Load(obj)
            
            path_ft = obj.Paths('fieldtrip');
            if isempty(path_ft) 
                error('No fieldtrip path defined.')
            elseif ~exist(path_ft, 'file')
                error('File not found: %s', path_ft)
            else
                tmp = load(path_ft);
                data = tmp.ft_data;
                teEcho('Loaded fieldtrip data from: %s\n', path_ft);
            end
            
        end
       
    end
    
    
    
end