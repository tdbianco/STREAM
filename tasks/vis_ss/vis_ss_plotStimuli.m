d = dir('/Users/luke/Documents/MATLAB/tasks/vis_ss/stimuli/*.png');
nsp = numSubplots(length(d));
figure('color', 'w')

for f = 1:length(d)
    subplot(nsp(1), nsp(2), f)
    [img, ~, alpha] = imread(sprintf('/Users/luke/Documents/MATLAB/tasks/vis_ss/stimuli/%s', d(f).name));
    im = imshow(img, 'border', 'tight');
    set(im, 'alphadata', alpha)
    
    title(d(f).name, 'Interpreter', 'none')
end