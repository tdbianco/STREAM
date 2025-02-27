function codes = teRegisteredEvents2Codes(regEvents, labels, type)

    % type, e.g. 'eeg' or 'nirs' - defaults to eeg
    if ~exist('type', 'var') || isempty(type)
        type = 'eeg';
        warning('No type specified, defaulting to ''eeg''')
    end
    
    % get sumamry of reg events
    smry = regEvents.Summary;
    
    % find type
    col_type = strcmpi(type, smry.Properties.VariableNames);
    if ~any(col_type)
        error('Event type ''%s'' not found in registered events.', type)
    elseif sum(col_type) > 1
        error('Event type ''%s'' found %d times in registered events.',...
            type, sum(col_type));
    end

    % get master list of eeg codes 
    masterLabels = smry{:, 1};
    
    % get indices of each event label in the master list of events
    idx = cellfun(@(x) find(strcmpi(masterLabels, x), 1), labels,...
        'UniformOutput', false);
    
    % events not found in the master list are currently empty elements in
    % the cell array idx. Make an index of these missing events, then
    % remove the missing elements
    missing = cellfun(@isempty, idx);
    idx(missing) = num2cell(nan(sum(missing), 1));
    idx = cell2mat(idx);
    
    % now use the index to lookup codes for each event
    codes = nan(size(missing));
    codes(~missing) = cell2mat(smry{idx(~missing), col_type});

end