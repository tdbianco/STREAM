classdef teExternalData_Enobio < teExternalData
    
    properties (SetAccess = private)
        NumChannels
        NumSamples
        SampleRate
        Duration      
        Valid 
    end
    
    properties (SetAccess = private)
        Type = 'enobio'
    end
    
    methods
        
        function obj = teExternalData_Enobio(path_enobio)
            
            % call superclass constructor to do common initiation
            obj = obj@teExternalData;
            
            % check input args, to ensure that a path has been passed, and
            % that the path exists
            if ~exist('path_enobio', 'var') || isempty(path_enobio)
                error('Must supply a path to Enobio data.')
            elseif ~exist(path_enobio, 'dir')
                error('Path does not exist.')
            else
%                 % store path in subclass
%                 obj.Paths('enobio') = path_enobio;
            end
            
            % look for .easy file, warn and give up if none found or more
            % than one
            file_easy = teFindFile(path_enobio, '*.easy');
            if isempty(file_easy)
                warning('.easy file not found in enobio folder.')
                return
            elseif iscell(file_easy) && length(file_easy) > 1
                warning('Multiple .easy files found.')
                return
            else
                obj.Paths('enobio_easy') = file_easy;
            end
            
            % same for .info file
            file_info = teFindFile(path_enobio, '*.info');
            if isempty(file_info)
                warning('.info file not found in enobio folder.')
                return
            elseif iscell(file_info) && length(file_info) > 1
                warning('Multiple .info files found.')
                return
            else
                obj.Paths('enobio_info') = file_info;
            end            
            
        % attempt to load header
        
            % load
            try
                [obj.NumChannels, obj.SampleRate, ~, numSamples] =...
                    NE_ReadInfoFile(file_info, 0); 
            catch ERR_loadHeader
                warning('Error loading header:\n\n%s',...
                    ERR_loadHeader.message)
                return
            end
            
            % calculate duration
            obj.Duration = numSamples / obj.SampleRate;
            obj.NumSamples = numSamples;
            
            % set valid
            obj.Valid = true;
            
        end
       
    end
    
    
    
end