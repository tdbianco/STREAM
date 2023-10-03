function c = seg2cell(seg)

    % get unique IDs
    [id_u, ~, id_s] = unique(seg.ids);
    id_num = length(id_u);
    
    % preallocate output
    c = cell(id_num, 1);
    numTrials = zeros(id_num, 1);
    numRows = cell(id_num, 1);
    
    % loop through IDs and put in trial data
    for i = 1:id_num
        
        % get seg entries for this subject
        segIdx = find(id_s == i);
        
        % get number of trials, and max number of samples for these trials
        numTrials(i) = length(segIdx);
        numRows{i} = cellfun(@length, seg.x(segIdx));
        
        % preallocate output
        c{i} = nan(max(numRows{i}), 2 * numTrials(i));
        
        % loop through and place data in c
        col = 1;
        for t = 1:numTrials(i)
            c{i}(1:numRows{i}(t), col) = seg.x{segIdx(t)};
            c{i}(1:numRows{i}(t), col + 1) = seg.y{segIdx(t)};
            col = col + 2;
        end
        
    end

end