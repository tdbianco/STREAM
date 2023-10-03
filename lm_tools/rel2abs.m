function abs = rel2abs(rel, reference)
    
    if ~exist('reference', 'var') || isempty(reference)
        reference = pwd;
    end
    if isAbsPath(rel)
        error('Path is absolute.')
    end
    abs = fullfile(reference, rel);
    
end