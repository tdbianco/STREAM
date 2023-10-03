function bin = etBinariseAOIMask(mask, def)

    numAOIs = size(def, 1);
    w = size(mask, 2);
    h = size(mask, 1);
    bin = false(h, w, numAOIs);
    tol = 10;
    
    mask = double(mask);
    mask_r = mask(:, :, 1);
    mask_g = mask(:, :, 2);
    mask_b = mask(:, :, 3);
        
    for a = 1:numAOIs

        % determine number of colours in this AOI
        numCols = size(def{a, 2}, 2);
        for c = 1:numCols

            % pull RGB values from the def
            def_r = double(def{a, 2}{c}(1));
            def_g = double(def{a, 2}{c}(2));
            def_b = double(def{a, 2}{c}(3));

            % compare against AOI pixel values
            idx = ...
                abs(mask_r - def_r) < tol &...
                abs(mask_g - def_g) < tol &...
                abs(mask_b - def_b) < tol;
            
            bin(:, :, a) = bin(:, :, a) | idx;
            
        end

    end    

end