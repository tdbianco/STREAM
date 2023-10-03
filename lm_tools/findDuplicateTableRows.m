function [hasDup, dupIdx] = findDuplicateTableRows(t)

    % serialise
    ser = cell(size(t, 1), 1);
    for row = 1:size(t, 1)
        ser{row} = getByteStreamFromArray(t(row, :));
    end
    % convert to char
    ch = cellfun(@char, ser, 'uniform', false);
    % find dups
    [u, i, ~] = unique(ch);
    hasDup = size(u, 1) < size(ch, 1);
    dupIdx = setdiff(1:size(ch, 1), i);

end