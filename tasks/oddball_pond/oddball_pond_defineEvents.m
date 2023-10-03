function oddball_pond_defineEvents(events)
% stimuli for the oddball task are encoded as distinct trains of s number
% of standards followed by one deviant. The number on the end of each event
% encodes the position of the deviant in a train of standards. 
%
%   TRAIN_ONSET_DEV_05:
%       [S S S S D] four stds followed by a deviant in pos 5 
%
%   TRAIN_ONSET_DEV_10:
%       [S S S S S S S S S D] nine stds followed by a deviant in pos 10 

    events('TRAIN_ONSET_DEV_05')        = struct('eeg', 31, 'task', 'oddball_pond');
    events('TRAIN_ONSET_DEV_06')        = struct('eeg', 32, 'task', 'oddball_pond');
    events('TRAIN_ONSET_DEV_07')        = struct('eeg', 33, 'task', 'oddball_pond');
    events('TRAIN_ONSET_DEV_08')        = struct('eeg', 34, 'task', 'oddball_pond');
    events('TRAIN_ONSET_DEV_09')        = struct('eeg', 35, 'task', 'oddball_pond');
    events('TRAIN_ONSET_DEV_10')        = struct('eeg', 36, 'task', 'oddball_pond');
        
end