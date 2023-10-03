function out = delta(m, dim)

    if ~exist('dim', 'var') || isempty(dim)
        dim = 1;
    end
    
    if size(dim, 1) == 1 && size(dim, 2) > 1
        m = m';
        transposed = true;
    else
        transposed = false;
    end
    
    out = [nan; m(2:end, :) - m(1:end - 1, :)];
    
    if transposed, out = out'; end

end