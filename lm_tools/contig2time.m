function [ctt, ct] = contig2time(ct, time)
    if isempty(ct), ctt = []; return, end
    % take just onsets/offsets (not duration)
    ctt = ct(:, 1:2);
    % we measure onset of sample n to onset of sample n + 1 so add 1 to
    % offest samples
    ctt(:, 2) = ctt(:, 2) + 1;
    % adding one to sample may make an index that exceeds the bounds of
    % time. Make a fake timestamp on the end, which serves as an offset for
    % the final sample (for the purposes of calculating durations) and uses
    % the median inter-sample delta to get a duration
    misd = median(diff(time));
    time(end + 1) = time(end) + misd;
    % check samples are in bounds
    if any(ctt(:) > length(time))
        warning('Samples out of bounds - will ignore samples outside range of time vector.')
        outIdx = any(ctt > length(time), 2);
        ctt(outIdx, :) = [];
        ct(outIdx, :) = [];
    end
    % look up time
    ctt(:, 1) = time(ctt(:, 1));
    ctt(:, 2) = time(ctt(:, 2));
    % calculate durations
    ctt(:, 3) = ctt(:, 2) - ctt(:, 1);
end
    