function [preLevel, postLevel] = normaliseSound(path_snd, targetDB, path_out)

    if ~exist(path_snd, 'file')
        error('File not found.')
    end
    
    if ~exist('path_out', 'var') || isempty(path_out)
        path_out = path_snd;
    end
    
    if ~exist('targetDB', 'var') || isempty(targetDB)
        targetDB = -23;
    end
    
    % read file, compute loudness
    [x, fs] = audioread(path_snd);
    [preLevel, ~] = integratedLoudness(x, fs);

    % calculate gain adjustment
    gaindB = targetDB - preLevel;
    gain = 10^(gaindB/20);
    xn = x.*gain;
    
    % write output
    audiowrite(path_out, xn, fs);

    % read back in and calculate post level
    [x, fs] = audioread(path_out);
    [postLevel, ~] = integratedLoudness(x, fs);

end