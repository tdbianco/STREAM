function mrk = eegLightSensor2Events(data, thresh, fsample)
% takes a vector of EEG data from one channel, and thresholds it to find
% the on/offset of light sensor activity. Extracts onset and produces event
% markers for each. 
%
% data is a double vector of voltages
%
% thresh is the threshold voltage value in µV, above which activation of
% the light sensor is assumed
%
% mrk is a vector of sample indices corresponding to the start of each
% light sensor activation. Note that this function doesn't deal in
% timestamps - these can optionally be used later on if a time vector is
% available, but since not all EEG provides this we restrict ourselves to
% samples here. 
%
% data are quite noisy when the light sensor is on (one example shows a
% range of ~10µV). Currently not attempting to smooth/denoise this, since
% that is likely to shift the onset, and accurate onset is what we care
% about. 

% RH;
% - 9.3.20; length criterion for LS on added 

% setup

    % check input
    if ~isnumeric(data) || ~isvector(data)
        error('data must be a numeric vector of voltage values.')
    end
    
    % default threshold is 1000µV
    if ~exist('thresh', 'var') || isempty(thresh)
        thresh = 1000;
    end
    
% define the time on for a valid marker
    crit_lightOn_s = 0.100; % time LS needed to be on to be valid: 100ms
    crit_lightOn_samps = crit_lightOn_s * fsample; % number of samples required to be on    
    
% % a) threshold in LS signal 
% 
%     % logical index of all samples during which the light sensor was active
%     idx = data >= thresh;
%     
%     % convert to contiguous structure to find on/offsets
%     ct = findcontig2(idx);
%     
%     % find the markers where the sensor is on for long enough
%     idOn_longEnough = ct(:, 3) >= crit_lightOn_samps;
%     ct(~idOn_longEnough, :) = [];
%     
%     % extract onset
%     mrk = ct(:, 1);

    
    
% b) differences in signal samples
    diff_nextsample = data(2:end) - data(1:end-1);
    idx_on = diff_nextsample >= thresh;
    idx_off = diff_nextsample <= thresh*(-1);
    
    
    % check if the idx_on is valid:
    inds_on = find(idx_on == 1);
    inds_on(2,:) = 0;
    inds_off = find(idx_off == 1);
    for mm = 1:length(inds_on)
        % find LS on events with off events in the 100 ms time window
        samp_on = inds_on(mm);
        delta = samp_on - inds_off;
        idx = crit_lightOn_samps <= delta;
        
        if ~any(idx), continue, end
        
        inds_on(2,mm) = 1;
    end
    % get the valid LS markers
    inds_on_valid = inds_on(1,inds_on(2,:) == 1)';
    % correct sample for taking the differenct
    inds_on_valid = inds_on_valid+1;
    
    mrk = inds_on_valid;
    
    
%     diff_nxt2sample = data(3:end) - data(1:end-2);
%     idx2_on = diff_nxt2sample >= thresh;
%     idx2_off = diff_nxt2sample <= thresh*(-1);
    
%     figure; 
%     subplot(3,1,1); plot(1:1:size(data,2), data); title('Raw LS')
%     subplot(3,1,2); plot(1:1:size(diff_nextsample,2), diff_nextsample); title('Differences with next 1st sample')
%     subplot(3,1,3); plot(1:1:size(diff_nxt2sample,2), diff_nxt2sample); title('Differences with next 2nd sample')
    
    
    
end