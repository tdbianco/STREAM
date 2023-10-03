function restingvideos2_defineEvents(events)

    events('FACE_ONSET_EN')    = struct('eeg', 10, 'nirs', 'D', 'task', 'restingvideos2');
    events('FACE_ONSET_NL')    = struct('eeg', 12, 'nirs', 'D', 'task', 'restingvideos2');
    events('FACE_ONSET_SW')    = struct('eeg', 13, 'nirs', 'D', 'task', 'restingvideos2');
    events('FACE_ONSET_PL')    = struct('eeg', 14, 'nirs', 'D', 'task', 'restingvideos2');
    events('FACE_ONSET_GM')    = struct('eeg', 15, 'nirs', 'D', 'task', 'restingvideos2');
    events('FACE_ONSET_IN')    = struct('eeg', 16, 'nirs', 'D', 'task', 'restingvideos2');
    events('FACE_ONSET_ES')    = struct('eeg', 17, 'nirs', 'D', 'task', 'restingvideos2');
    events('FACE_ONSET_FR')    = struct('eeg', 18, 'nirs', 'D', 'task', 'restingvideos2');
    
    events('TOY_ONSET')        = struct('eeg', 11, 'nirs', 'E', 'task', 'restingvideos2');
    
    events('VIDEO_OFFSET')     = struct('eeg', 19, 'nirs', 'F', 'task', 'restingvideos2');

end
