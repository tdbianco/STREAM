classdef logicalstruct 
    
    properties (Access = private)
        data = struct
    end
    
    methods
        
        function obj = logicalstruct(varargin)
            % create lstruct from either struct or fieldname/value string
            % pairs
            if numel(varargin) == 1 && isstruct(varargin{1})
                obj.data = varargin{1};
            elseif iscellstr(varargin)
                obj.data = struct(varargin{:});
%             else
%                 error('Initialise this class with either a struct or fieldname/value string pairs.')
            end
        end
        
        function obj = subsasgn(obj, s, varargin)
            if length(s) == 1 && strcmpi(s.type, '.')
                obj.data.(s.subs) = varargin{:};
            else
                obj.data = builtin('subsasgn', obj.data, s, varargin{:});
            end
        end
        
        function varargout = subsref(obj, s)
            if length(s) == 1 && strcmpi(s.type, '.') 
                if isempty(obj.data) || ismember(s.subs, fieldnames(obj.data))
                    % field exists, get value
                    val = builtin('subsref', obj.data, s);
%                     if islogical(val)
%                         % value is logical, return it
                        varargout = {val};
%                     else
%                         % value is not logical, but field does exist,
%                         % return true
%                         varargout = {true};
%                     end
                    %                     varargout = {builtin('subsref', obj.data, s)};
                else
                    % field does not exist, return false
                    varargout = {false};
                end
            end
        end
        
        function disp(obj)
            if isempty(obj.data)
                fprintf('<strong>  logicalstruct</strong> with no fields.\n\n')
            else
                fprintf('<strong>  logicalstruct</strong> with fields:\n\n')
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
        
        function val = struct2table(obj)
            val = struct2table(struct(obj));
        end
        
        function properties(obj)
            builtin('properties', obj.data)
        end           
                
    end
    
end
