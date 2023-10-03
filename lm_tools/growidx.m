function m = growidx(m, extent)

    if ~exist('extent', 'var') || isempty(extent)
        extent = 1;
    end

    if ~isvector(m)
        error('m must be a vector.')
    end
    
    isCol = size(m, 1) > size(m, 2);
    if isCol, m = m'; end
    
    idx = find(m);
    grownIdx = idx;
    for e = 1:extent
        grownIdx = [grownIdx, idx - e, idx + e];
    end
    grownIdx(grownIdx < 1 | grownIdx > length(m)) = [];
    m(grownIdx) = true;
    
    if isCol, m = m'; end
    
end