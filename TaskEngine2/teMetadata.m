classdef teMetadata < teDynamicProps
    
    properties
        Paths@teCollection
    end
    
    properties (Dependent)
        GUID
        Checks@logicalstruct
    end
    
    properties (SetAccess = private)
        Struct
    end
    
    properties (Access = private)
        h_table 
        prStructDirty = false
        prStructCache
        prGUID
        prChecks@logicalstruct
    end
    
    events
        Update
    end
    
    methods
        
        function obj = teMetadata(varargin)
            
            % init collections
            obj.Paths = teCollection('char');
            obj.Checks = logicalstruct;
            
            % if struct has been passed, init from it
            idx_struct = cellfun(@isstruct, varargin);
            if sum(idx_struct) > 1
                error('More than one struct passed. Cannot initialise from multiple structs.')
            elseif sum(idx_struct) == 1
                s = varargin{idx_struct};
                obj.ImportFromStruct(s);
            end
            
        end
        
        function h = uitable(obj, varargin)
            
            % build cell array for table data
            data_cell = buildTableCell(obj);
            
            % make uitable
            h = uitable('data', data_cell,...
                'ColumnName', {'Variable', 'Value'},...
                'FontSize', 12,...
                varargin{:});            

            obj.sizeTableColumns(h)
            obj.h_table = h;
            
        end
        
        function obj = subsasgn(obj, s, varargin)
        % overrides the teDyanmicProps superclass to allow the uitable to
        % be updated, but then calls the superclass method so it can do its
        % think
        
            % workaround if we load an earlier version of teMetadata that
            % has been saved. It didn't have a DynamicPropOrder property,
            % so we need to init this now
            emptyOrder = arrayfun(@(x) isempty(x.DynamicPropOrder), obj);
            if any(emptyOrder)
                idx_emptyOrder = find(emptyOrder);
                for i = 1:length(idx_emptyOrder)
                    obj(i).DynamicPropOrder = teCollection('double');
                end
            end
            
            obj = subsasgn@teDynamicProps(obj, s, varargin{:});
            notify(obj, 'Update')
            obj.prStructDirty = true;
            obj.updateTable;
            
        end
        
        function obj = ImportFromStruct(obj, s)
            
            if ~exist('s', 'var') || ~isstruct(s)
                error('Must pass a struct as an input argument.')
            end
            
            if isempty(s)
                return
            end
            
            % get struct fieldnames
            fnames = fieldnames(s);
            
            % check that no field names in the struct conflict with
            % property names in teMetadata
            mc = metaclass(obj);
            pnames = arrayfun(@(x) x.Name, mc.PropertyList,...
                'UniformOutput', false);
            idx_invalid = ismember(fnames, pnames);
            if any(idx_invalid)
                error('At least one struct fieldname (%s) is a reserved property of the teMetaData class, and cannot be imported from a struct.',...
                    fnames{idx_invalid})
            end
            
            % loop through fieldnames and add properties
            for f = 1:length(fnames)
                % get fieldname and value
                var = fnames{f};
                val = s.(fnames{f});
                % add dynprop
                addprop(obj, var);
                obj.(var) = val;
            end
            
        end
        
        function obj = ImportFromExternalData(obj, ext)
            
            if ~exist('ext', 'var') || ~isa(ext, 'teExternalData')
                error('Must pass a teExternalData instance as an input argument.')
            end
            
            if isempty(ext)
                return
            end    
            
            % add teMetadata property, using the .Type property of the
            % teExternalData (e.g. .eyetracking)
            pname = ext.Type;
%             addprop(obj, pname);
            
            % create a struct to hold the context of the external data
            s = logicalstruct;
            
            % get property names of external data
            extPnames = properties(ext);
            
            % if there is a .Paths property, cat this to the teMetadata
            % .Paths property
            idx_paths = ismember(extPnames, 'Paths');
            if any(idx_paths)
                % cat
                obj.Paths = [obj.Paths, ext.Paths];
                % remove 'Paths' from external data prop names so that we
                % don't try to import it in the next step
                extPnames(idx_paths) = [];
            end
            
            % loop through and add external data properties to struct
            for f = 1:length(extPnames)
                % get fieldname and value
                var = sprintf('%s_%s', ext.Type, extPnames{f});
                val = ext.(extPnames{f});
                % add to struct
                if isscalar(val) && (...
                        ischar(val) || isnumeric(val) || islogical(val))
                    obj.Checks.(var) = val;
                end
            end
% 
%             % store struct in teMetadata property
%             obj.Checks.(pname) = s;
%             

%                 
%             % check that no field names in the struct conflict with
%             % property names in teMetadata
%             mc = metaclass(obj);
%             pnames = arrayfun(@(x) x.Name, mc.PropertyList,...
%                 'UniformOutput', false);
%             idx_invalid = ismember(extPnames, pnames);
%             if any(idx_invalid)
%                 error('At least one teExternalData property (%s) is a reserved property of the teMetaData class, and cannot be imported from a struct.',...
%                     extPnames{idx_invalid})
%             end
%             
%             % loop through fieldnames and add properties
%             for f = 1:length(extPnames)
%                 % get fieldname and value
%                 var = extPnames{f};
%                 val = ext.(extPnames{f});
%                 % add dynprop
%                 addprop(obj, var);
%                 obj.(var) = val;
%             end
            
        end

        % get / set
        function val = get.Struct(obj)
            
            % use cached struct if available and data hasn't changed
            if ~isempty(obj.prStructCache) && ~obj.prStructDirty
                val = obj.prStructCache;
                return
            end
            
            % create struct, set GUID to be first field, and record field
            % order
            val = struct;
            val.GUID = obj.GUID;
            fOrd = 1;
            fieldCounter = 2;

        % non-struct dynamic props
            
            % pull dynamic props from teData instance
            numProps = length(obj.DynamicProps);
            for p = 1:numProps
                
                propName = obj.DynamicProps{p};
                propVal = obj.(propName);
                
                % only dynamic props that are not structs at this point-
                % struct props will get flattened in a later step
                if ~isstruct(propVal)
                    
                    val.(propName) = propVal;
                
                    % record field order from teMetadata (will apply it to
                    % struct later)
                    fo = obj.DynamicPropOrder(propName) + 1;
                    if ~isempty(fo)
                        fOrd(fieldCounter) = fo;
                    else
                        fOrd(fieldCounter) = inf;
                    end
                    fieldCounter = fieldCounter + 1;
                    
                end
                
            end
            
            % sort field order to get monotonic order and sort struct
            % fields
            [~, so] = sort(fOrd, 'ascend');
            val = orderfields(val, so);
            
            % pull checks
            if ~isempty(obj.Checks)
                val = catstruct(val, struct(obj.Checks));
            end
            
            % loop through and get all struct properties. Flatten these
            % into the struct
            for p = 1:numProps
                
                propName = obj.DynamicProps{p};
                propVal = obj.(propName);
                
                % if a field is itself a struct, we flatten it into the
                % struct we are creating. so obj.struct.field1 becomes
                % obj.struct_field1. 
                if isstruct(propVal)
                    fn = fieldnames(propVal);
                    numFields = length(fn);
                    for f = 1:numFields
                        % built struct_field format name
                        flatName = sprintf('%s_%s', propName, fn{f});
                        % assign in flattened struct
                        val.(flatName) = obj.(propName).(fn{f});
                    end
                end
                
            end
            
            % pull paths
            if ~isempty(obj.Paths)
                keys = obj.Paths.Keys;
                items = obj.Paths.Items;
                s_paths = cell2struct(items, keys, 2);
                val = catstruct(val, s_paths);
            end
            
            obj.prStructCache = val;
            obj.prStructDirty = false;

        end
        
        function val = get.GUID(obj)
            val = obj.prGUID;
        end
        
        function set.GUID(obj, val)
            obj.prGUID = val;
            notify(obj, 'Update')
            obj.prStructDirty = true;
            obj.updateTable;
        end
        
        function val = get.Checks(obj)
            val = obj.prChecks;
        end
        
        function set.Checks(obj, val)
            obj.prChecks = val;
            notify(obj, 'Update')
            obj.prStructDirty = true;
            obj.updateTable;
        end
        
    end
    
    methods (Hidden)
        
        function ResetCache(obj)
            obj.prStructDirty = true;
        end
        
    end
    
    methods (Access = {?teAnalysisDatabase})
        
        function [data_cell, cols] = buildTableCell(obj)
        % format data into a cell array, to pass to table. Loop through
        % all props and pull the values of numerical, char or logical
        % props
            
            s = obj.Struct;
            fn = fieldnames(obj.Struct);
            data_cell = [fn, struct2cell(obj.Struct)];
            validType = cellfun(@isnumeric, data_cell(:, 2)) |...
                cellfun(@ischar, data_cell(:, 2)) |...
                cellfun(@islogical, data_cell(:, 2));
            data_cell(~validType, :) = [];
            cols = colourHeaders(data_cell(:, 1));
            data_cell(:, 1) = uitableColourCell(data_cell(:, 1), cols);
%             props = sort(properties(obj));
%             checks = fieldnames(obj.Checks);
%             numProps = length(props);
%             numChecks = length(checks);
% 
%             % prepare cell output
%             data_cell = cell(numProps + numChecks, 2);
%             data_cell(1:numProps, 1) = props;
%             
%             for p = 1:length(props)
%                 
%                 % get value
%                 val = obj.(props{p});
%                 
%                 if ischar(val) || islogical(val) || isnumeric(val)
%                     data_cell{p, 2} = val;
%                 else
%                     data_cell{p, 2} = 'Cannot display';
%                 end
%                 
%             end
%             
%             % add checks
%             for c = 1:numChecks
% 
%                 data_cell{p + c, 1} = sprintf('check_%s', checks{c});
%                 data_cell{p + c, 2} = obj.Checks.(checks{c});
%                 
%             end

        end
        
        function updateTable(obj)
            
            if length(obj) ~= 1 || isempty(obj.h_table) || ~isvalid(obj.h_table)
                return
            end
            
            % build cell array for table data
            data_cell = buildTableCell(obj);
            obj.h_table.Data = data_cell;
            obj.sizeTableColumns(obj.h_table);
            
        end
        
        function sizeTableColumns(~, h)
            
            uitableAutoColumnHeaders(h)
            h.Units = 'pixels';
            valColWidth = h.Position(3) - h.ColumnWidth{1};
            if valColWidth < 0, valColWidth = 100; end
            h.Units = 'normalized';
            h.ColumnWidth{2} = valColWidth;
            h.RowName = [];
            
        end
        
        function clearTable(obj)
            
            if length(obj) ~= 1 || isempty(obj.h_table) || ~isvalid(obj.h_table)
                return
            end
            
            delete(obj.h_table);
            obj.h_table = [];
            
        end

    end
    
end