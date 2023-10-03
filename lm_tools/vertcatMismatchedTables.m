function joinedTable = vertcatMismatchedTables(varargin)

    % check input args
    if nargin < 2
        error('Must pass at least two tables as input arguments.')
    end
    if ~all(cellfun(@istable, varargin))
        error('All inputs must be tables.')
    end
    if any(cellfun(@isempty, varargin))
        error('No tables can be empty.')
    end
    
    tab = varargin;
    numTabs = length(tab);
    
    % convert any non-cell columns to cell
    for t = 1:numTabs
        numCols = size(tab{t}, 2);
        for c = 1:numCols
            if ~iscell(tab{t}{1, c})
                tab{t}(:, c) = num2cell(tab{t}{:, c});
            end
        end
    end
    
    var_names = cellfun(@(x) x.Properties.VariableNames, tab, 'uniform', false);
    var_sig = cellfun(@(x) horzcat(x{:}), var_names, 'uniform', false);
    var_names = unique(horzcat(var_names{:}));
    
    % combine into a table sig for each table
%     tab_sig = cellfun(@(x) horzcat(x{:}), var_sig, 'uniform', false);
    [tab_u, tab_i, tab_s] = unique(var_sig);

    % make sub-table for each unique variable signature
    numSubTabs = length(tab_u);
    subTab = cell(numSubTabs, 1);
    for st = 1:numSubTabs
        subTab{st} = vertcat(tab{tab_s == st});
    end
    
    % harmonise variables
    for t = 1:numSubTabs
        % harmonise
        colMissing = setdiff(var_names, subTab{t}.Properties.VariableNames);
        subTab{t} = [subTab{t}, array2table(nan(height(subTab{t}), numel(colMissing)),...
            'VariableNames', colMissing)];
        % check for cell mismatch
        for colname = colMissing
            % find variables that are cells in any table
            varIsCell = cellfun(@(x) iscell(x.(colname{1})) && ismember(colname{1}, x.Properties.VariableNames), subTab);
            % if any were, convert NaN to cell
            if any(varIsCell)
                subTab{t}.(colname{1}) = cell(height(subTab{t}), 1);
            end
        end        
    end
    joinedTable = vertcat(subTab{:});    
    
%     
%     % sort sub-tabs by number of cars
%     subTabNumVars = cellfun(@(x) size(x, 2), subTab);
%     [~, so] = sort(subTabNumVars, 'descend');
%     subTab = subTab(so);    
%     
%     
%     
%     
% 
% 
%     % harmonise variables
%     for t = 1:numTabs
%         % harmonise
%         colMissing = setdiff(var_names, tab{t}.Properties.VariableNames);
%         tab{t} = [tab{t}, array2table(nan(height(tab{t}), numel(colMissing)),...
%             'VariableNames', colMissing)];
% %         % check for cell mismatch
% %         for colname = colMissing
% %             % find variables that are cells in any table
% %             varIsCell = cellfun(@(x) iscell(x.(colname{1})) && ismember(colname{1}, x.Properties.VariableNames), tab);
% %             % if any were, convert NaN to cell
% %             if any(varIsCell)
% %                 tab{i}.(colname{1}) = cell(height(tab{i}), 1);
% %             end
% %         end
%     end
%     
%     joinedTable = vertcat(tab{:});
%     
%     
%     
%     
%     
%     
%     colIsCell = cell(size(tab));
%     var_sig = cell(size(tab));
%     var_names = cell(size(tab));
%     for t = 1:numTabs
%         % record which column is cell
%         numCols = size(tab{t}, 2);
%         colIsCell{t} = false(1, numCols);
%         var_names{t} = tab{t}.Properties.VariableNames;
%         for c = 1:numCols
%             colIsCell{t}(c) = iscell(tab{t}{1, c});
%             var_sig{t}{c} = sprintf('%s_%d', var_names{t}{c}, colIsCell{t}(c));
%         end
%     end    
%     
%     
%     
%     
%     
%     
%     
%     
%     
%     
%     
%     
%     
%     
%     tab = varargin;
%     numTabs = length(tab);
%     
%     % make signature for each column of each table, comprised of
%     % NAME_isCell
%     colIsCell = cell(size(tab));
%     var_sig = cell(size(tab));
%     var_names = cell(size(tab));
%     for t = 1:numTabs
%         % record which column is cell
%         numCols = size(tab{t}, 2);
%         colIsCell{t} = false(1, numCols);
%         var_names{t} = tab{t}.Properties.VariableNames;
%         for c = 1:numCols
%             colIsCell{t}(c) = iscell(tab{t}{1, c});
%             var_sig{t}{c} = sprintf('%s_%d', var_names{t}{c}, colIsCell{t}(c));
%         end
%     end

%     
%     
%     
% %     
%     % move through tables and add variables that exist to main table
%     joinedTable = subTab{1};
%     for i = 2:numSubTab
%         % find vars in output table not in subtab
%         vars_missing = setdiff(vars_out, vars_in);
%         numRows = size(subTab{i}, 1);
%         % determine whether these columns are cell or numeric
%         for v = 1:length(vars_missing)
%             curVar = vars_missing{v};
%             if iscell(joinedTable.(curVar)(1))
%                 subTab{i}.(curVar) = cell(numRows, 1);
%             else
%                 subTab{i}.(curVar) = nan(numRows, 1);
%             end
%         end
%     end
%                 
%  
%     
%     
%     % get unique variables
%     var_names = unique(horzcat(var_names{:}));
    

    
end