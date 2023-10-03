function hex = rgb2hex(rgb)

    hex = cell2mat(arrayfun(@(x) dec2hex(x, 2), rgb, 'uniform', 0));
        
end