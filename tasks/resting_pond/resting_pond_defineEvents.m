function resting_pond_defineEvents(events)

    events('RESTING_ONSET_VIDEO')       = struct('eeg', 001, 'task', 'resting_pond');
    events('RESTING_OFFSET_VIDEO')      = struct('eeg', 002, 'task', 'resting_pond');
    events('RESTING_ONSET_FIXATION')    = struct('eeg', 003, 'task', 'resting_pond');
    events('RESTING_OFFSET_FIXATION')   = struct('eeg', 004, 'task', 'resting_pond');
    events('RESTING_ONSET_GOOD')        = struct('eeg', 005, 'task', 'resting_pond');
    events('RESTING_OFFSET_GOOD')       = struct('eeg', 006, 'task', 'resting_pond');

end
