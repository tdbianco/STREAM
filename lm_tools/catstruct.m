function s = catstruct(s1, s2)

    if length(s1) ~= length(s2)
        error('Cannot merge structs with unequal number of elements.')
    end
    
    f1 = fieldnames(s1);
    f2 = fieldnames(s2);
    numElements = length(s1);
    
    for i = 1:numElements
        for f = 1:length(f1)
            s(i).(f1{f}) = s1(i).(f1{f});
        end
        for f = 1:length(f2)
            s(i).(f2{f}) = s2(i).(f2{f});
        end
    end
    
end