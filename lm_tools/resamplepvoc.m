function data = resamplepvoc(data, currentFs, desiredFs)
    % resample
    data = resample(data, currentFs, desiredFs);
    % calculate speed/pitch change
    change = desiredFs / currentFs;
    % time-shift
    data = pvoc(data, change);
end