function tePlotImageStimuliFolder(path_stim)
% loads all images in a folder in a subplot

    % check path
    if ~exist(path_stim, 'dir')
        error('Path not found.')
    end
    
    % attempt to find image files
    d = dir(sprintf('%s%s*.png', path_stim, filesep));
    if isempty(d)
        error('No .png files found.')
    end
    
    % determine number of subplots needed
    nsp = numSubplots(length(d));
    figure('color', 'w')

    for f = 1:length(d)
        
        subplot(nsp(1), nsp(2), f)
        
        % load image and alpha
        [img, ~, alpha] = imread(fullfile(path_stim, d(f).name));
        
        % show image
        im = imshow(img, 'border', 'tight');
        
        % apply alpha
        set(im, 'alphadata', alpha)

%         title(d(f).name, 'Interpreter', 'none')
        
    end

end