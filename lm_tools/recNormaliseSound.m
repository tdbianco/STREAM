function recNormaliseSound(path_in)

    % get files
    files = recdir(path_in);
    % filter for audio
    audioFormats = {'.WAV', '.MP3', '.M4A'};
    [~, ~, ext] = cellfun(@fileparts, files, 'uniform', false);
    validFormat = ismember(lower(ext), lower(audioFormats));
    files(~validFormat) = [];
    % normalise
    [pre, post] = cellfun(@(x) normaliseSound(x, -30), files, 'uniform', false);
    
end