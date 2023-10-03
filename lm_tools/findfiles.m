function [file_paths, file_names, file_exts] = findfiles(arg)
    [pth, ~, ~] = fileparts(arg);
    d = dir(arg);
    file_paths = cellfun(@(x) fullfile(pth, x), {d.name}, 'uniform', false)';
    [~, file_names, file_exts] = cellfun(@fileparts, file_paths,...
        'uniform', false);
end