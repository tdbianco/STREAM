function tab = teLogExtract(logArray, varargin)

    if ~iscell(logArray) && ~all(cellfun(@(x) isa(x, 'teListItem')))
        error('logArray must be a cell array of teListItems')
    end
    
    if isempty(logArray), tab = table; return, end
    
    % get variable names, and unique signatures
    [fnames, fnames_u, sig, sig_u, sig_i, sig_s, logArray] =...
        teLogGetVariableNames(logArray, varargin{:});    

    % make empty structure of cells, add these to the table
    c = cell(length(logArray), length(fnames_u));    
    % loop through unique field combinations
    for s = 1:length(sig_i)
        % get indices of log items that correspond to the current field
        % combo
        idx = find(sig_s == s);
        % get fieldnames of current combo
        fn = fnames{idx(1)};
        fidx = cellfun(@(x) find(ismember(fnames_u, x)), fn);
        % get values from current combo fields in the log array
        items = cellfun(@(x) struct2cell(x), logArray(idx), 'uniform', false);
        items = horzcat(items{:})';
        % arrange them in c
        c(idx, fidx) = items;
    end
    % put into table
    tab = cell2table(c, 'variablenames', fnames_u);
    % filter out unwanted cols
    if ~isempty(varargin)
        [~, keep] = intersect(fnames_u, varargin);
        tab = tab(:, keep);
    end
    
    % unify data types by column
    for c = 1:size(tab, 2)
        
        col = tab{:, c};
        
        if iscell(col)
            
            empty = cellfun(@isempty, col);
            if all(cellfun(@islogical, col(~empty))) &&...
                    all(cellfun(@isscalar, col(~empty)))
                logcol = false(size(col));
                logcol(~empty) = cell2mat(col(~empty));
                varName = tab.Properties.VariableNames{c};
                tab.(varName) = logcol;
            end
            
        end
        
    end
                
    
%     doSearch = cellfun(@(x) instr(varargin, lower(x)), sig_u)
%     
%     
%     
%     
%     
%     
%     
%     
% 
%     % make empty structure of cells, add these to the table
%     empty = cell(size(c, 1), size(fnames_u, 1));
%     c = [c, empty];
%     % loop through unique field combinations
%     for s = 1:length(sig_i)
%         % get indices of log items that correspond to the current field
%         % combo
%         idx = sig_s == s;
%         % get fieldnames of current combo
%         fn = unique(vertcat(fnames{idx}));
%         % convert field names to indices in c
%         fidx = cellfun(@(x) find(ismember(varNames, x)), fn);
%         % get values from current combo fields in the log array
%         items = cellfun(@(x) struct2cell(x.Data), logArray(idx), 'uniform', false);
%         items = horzcat(items{:})';
%         % arrange them in c
%         c(idx, fidx) = items;
%     end
%     % put into table
%     tab = cell2table(c, 'variablenames', varNames);

end