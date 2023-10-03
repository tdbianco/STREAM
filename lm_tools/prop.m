function p = prop(m, dim)
    if nargin == 1
        dim = 1;
    end
    p = sum(m, dim) / size(m, dim);
end