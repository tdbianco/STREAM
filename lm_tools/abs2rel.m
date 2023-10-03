function rel = abs2rel(abs)

    if ~isAbsPath(abs)
        error('Path is not absolute.')
    end
    rel = strrep(abs, pwd, '');
    
end