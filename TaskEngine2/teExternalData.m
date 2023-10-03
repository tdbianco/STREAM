classdef teExternalData < handle
    
    properties (SetAccess = protected)
        Paths@teCollection
    end
    
    properties (Abstract, SetAccess = private)
        Type
        Valid
    end
    
    methods
        
        function obj = teExternalData
            obj.Paths = teCollection('char');
        end
        
        function s = struct(obj)
            s = builtin('struct', obj);
            s = rmfield(s, {'Type', 'Paths'});
        end
        
        function data = Load(obj)
            error('Not supported in this class.')
        end
        
    end
    
end
