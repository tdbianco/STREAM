function c = structArray2cellArrayOfStructs(s)
    c = cell(1, numel(s));
    for i = 1:numel(s)
        c{i} = s(i);
    end
end