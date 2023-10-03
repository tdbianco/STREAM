function c = cellstr2num(c)
    
    % anonymous function to find whether a string contains a number
    hasNumber = @(x) any(arrayfun(@(x) ~isnan(str2double(x)), x));
    
    % index for string with numbers in them
    ch = cellfun(@ischar, c) & cellfun(@(x) hasNumber(x), c);
    if ~all(ch), warning('No all elements contained a number.'), end
    
    % extract numbers
    c(ch) = cellfun(@(x) regexp(x, '\d*', 'match'), c(ch));

end