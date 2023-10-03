function aud_ss_defineEvents(events)
% defines registered events for the auditory steady state task. Two
% frequencies are presented in 500ms trains, 10Hz and 40Hz. 

    events('TRAIN_ONSET_10HZ')    = struct('eeg', 040, 'task', 'aud_ss');
    events('TRAIN_ONSET_40HZ')    = struct('eeg', 041, 'task', 'aud_ss');
    
end
