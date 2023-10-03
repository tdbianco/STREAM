function vis_ss_defineEvents(events)
% defines registered events for the visual steady state task. Registered
% events combine a meaningful text label (e.g. 'ICON_ONSET_1HZ') with a
% numeric EEG code (e.g. 101). 
% 'events' is a teEventCollection instance. Since these instances are
% handle classes, the variable is not passed back out as an input argument.

    % ICON_ONSET refers to the onset of a period of stimulation at a
    % certain frequency. So ICON_ONSET_1HZ refers to a n-second long period
    % of stimulation at a frequency of 1Hz. ICON_OFFSET is the offset event
    % that is sent at the end of this period of stimulation. 
    events('ICON_ONSET_1HZ')    = struct('eeg', 101, 'task', 'vis_ss');
    events('ICON_ONSET_3HZ')    = struct('eeg', 102, 'task', 'vis_ss');
    events('ICON_ONSET_6HZ')    = struct('eeg', 103, 'task', 'vis_ss');
    events('ICON_ONSET_10HZ')   = struct('eeg', 104, 'task', 'vis_ss');
    events('ICON_ONSET_15HZ')   = struct('eeg', 105, 'task', 'vis_ss');
    events('ICON_OFFSET')       = struct('eeg', 110, 'task', 'vis_ss');
    
    % FLICKER_ONSET refers to one visual presentation of the stimulus. This
    % is the component part of each flicker. For example, for a 10Hz trial,
    % FLICKER_ONSET will appear every 0.2ms (at 0, 0.2, 0.4 etc.) and
    % FLICKER OFFSET every 0.2ms (at 0.1, 0.3, 0.5 etc.)
    events('FLICKER_ONSET')     = struct('eeg', 111, 'task', 'vis_ss');
    events('FLICKER_OFFSET')    = struct('eeg', 112, 'task', 'vis_ss');
    
end
