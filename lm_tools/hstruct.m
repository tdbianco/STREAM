classdef hstruct < handle
    
    properties (Access = private)
        data
    end
    
    methods
        
        function obj = hstruct(varargin)
            obj.data = struct(varargin{:});
        end
        
        function obj = subsasgn(obj, s, varargin)
            if length(s) == 1 && strcmpi(s.type, '.')
                obj.data.(s.subs) = varargin{:};
            else
                obj.data = builtin('subsasgn', obj.data, s, varargin{:});
            end
        end
        
        function varargout = subsref(obj, s)
            varargout = {builtin('subsref', obj.data, s)};
        end
        
        function disp(obj)
            if isempty(obj.data)
                fprintf('<strong>  hstruct</strong> with no fields.\n\n')
            else
                fprintf('<strong>  hstruct</strong> with fields:\n\n')
            end
            builtin('disp', obj.data)
        end
        
        function obj = rmfield(obj, varargin)
            obj.data = rmfield(obj.data, varargin{:});
        end
        
        function val = fieldnames(obj)
            val = builtin('fieldnames', obj.data);
        end
        
        function val = isfield(obj, varargin)
            val = builtin('isfield', obj.data, varargin{:});
        end      
        
        function val = getfield(obj, varargin)
            val = getfield(obj.data, varargin{:});
        end           
        
        function setfield(obj, varargin)
            obj.data = setfield(obj.data, varargin{:});
        end   
        
        function val = orderfields(obj, varargin)
            obj.data = orderfields(obj.data, varargin{:});
            val = obj.data;
        end   
        
        function val = struct(obj)
            val = obj.data;
        end
        
        function val = struct2cell(obj)
            val = struct2cell(struct(obj));
        end
        
        function properties(obj)
            builtin('properties', obj.data)
        end           
                
    end
    
end
