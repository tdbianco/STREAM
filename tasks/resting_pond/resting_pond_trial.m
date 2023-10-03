function vars = resting_pond_trial(varargin)
% Presents one trial of the POND resting state paradigm. This is according
% to the SOP operationalised as either an abstract video or a fixation
% cross. For ease of use, the function will take the string value from
% vars.Key as either 'abstract' (video) or 'fixation' (image)
%
% The experimenter is expected to wait until the EEG has settled, then
% press a key to mark the onset of a period of clean data. If the
% participant becomes unsettled and the data quality deteriorates, the
% experimnter will press a key to mark the offset of the clean period. 
%
% This continues until 2m of clean EEG has been collected. The function
% shows a running timer. If, after 5 mins of stimulation, the 2m clean data
% criterion has not been reached, the trial will end

    % check everything is ready for a trial
    [pres, vars] = teReadyForTrial(varargin{:});
    
    % define keys
    kb_clean_onset = 'UpArrow';
    kb_clean_offset = 'DownArrow';
    
    % set timing criteria
    crit_clean = 2 * 60;
    crit_timeout = 5 * 60;
    
    % look up stimulus
    switch lower(vars.Key)
        
        case 'abstract'
            stim        = pres.Stim('vid_resting_pond.mp4');
            mrk_onset   = 'RESTING_ONSET_VIDEO';
            mrk_offset  = 'RESTING_OFFSET_VIDEO';
            
        case 'fixation'
            stim        = pres.Stim('img_resting_pond.png');
            mrk_onset   = 'RESTING_ONSET_FIXATION';
            mrk_offset  = 'RESTING_OFFSET_FIXATION';
            
        otherwise
            error('vars.Key must be ''abstract'' or ''fixation''.')
    end
    if isempty(stim), error('Stimulus %s not found.', vars.Key), end

    % display message
    teTitle
    teEcho('RESTING STATE INSTRUCTIONS:\n\n');
    teEcho('We aim to collect %d minutes of clean EEG data per trial.\n', crit_clean / 60);
    teEcho('There may be more than one trial. Once you have acknowledged\n');
    teEcho('this message by pressing %s the trial will start.\n\n', pres.KB_MOVEON);
    teEcho('\t-Indicate the START of a period of clean data by pressing %s\n', kb_clean_onset);
    teEcho('\t-Indicate the END of a period of clean data by pressing %s\n\n', kb_clean_offset);
    teEcho('Press %s to begin\n', pres.KB_MOVEON);
    teLine
    while ~pres.KeyPressed(pres.KB_MOVEON)
        pres.KeyUpdate
        WaitSecs(.001);
    end

    % set up trial
    if isfield(vars, 'backcolour')
        backColour = vars.backcolour;
    else
        backColour = [000, 000, 000];
    end
    pres.BackColour = backColour;
    
    % if we are presenting a movie, set its start time and start playing
    if stim.isMovie
        stim.CurrentTime = 0;
        pres.PlayStim(stim);
    end
        
    % zero timer and set attention/clean state
    tm = 0;
    tm_display = 0;
    clean = false;
    
    % loop until finished, drawing each frame as we go
    markerSent = false;
    vars.onset = -inf;
    flipTime = teGetSecs;
    pres.KeyUpdate
    while vars.onset - teGetSecs < crit_timeout &&...
            tm < crit_clean &&...
            ~pres.KeyPressed(pres.KB_MOVEON) &&...
            ~pres.ExitTrialNow
        
        % draw
        pres.DrawStim(stim);
        prevFlipTime = flipTime;
        flipTime = pres.RefreshDisplay;
        
        % onset marker
        if ~markerSent
            
            % log movie onset time
            vars.onset = flipTime;
            
            % send event
            pres.SendRegisteredEvent(mrk_onset, flipTime)
         
            % flag marker as sent
            markerSent = true;
        end
        
        % poll keyboard for changes in attentive/clean data state
        if pres.KeyPressed(kb_clean_onset) && ~clean
            clean = true;
            pres.SendRegisteredEvent('RESTING_ONSET_GOOD');
            teEcho('\tClean period STARTED\n');
            
        elseif pres.KeyPressed(kb_clean_offset) && clean
            clean = false;
            pres.SendRegisteredEvent('RESTING_OFFSET_GOOD');
            teEcho('\tClean period ENDED\n');
            
        end
        
        % update timer
        if clean
            tm = tm + (flipTime - prevFlipTime);
        end
        
        % update display timer
        tm_display = tm_display + (flipTime - prevFlipTime);
        
        % display timer every second
        if tm_display > 1
            teEcho('Accumulated clean time: %.1fs / %.1fs\n',...
                tm, crit_clean);
            tm_display = 0;
        end
    end
    
    % stop the movie, and flip the screen (so that the frame is not still
    % visible, and so that we get an accurate timestamp of when the movie
    % was last visible)
    if stim.isMovie
        pres.StopStim(stim);
    end
    flipTime = pres.RefreshDisplay;
    
    % send offset event(s)
    vars.offset = flipTime;
    vars.duration = vars.offset - vars.onset;
    pres.SendRegisteredEvent(mrk_offset, flipTime);
    
    % record skipped/quit request
    vars.skipped = pres.KeyPressed(pres.KB_MOVEON);
    vars.quit = pres.ExitTrialNow;
    vars.timed_out = vars.duration >= crit_timeout;
    vars.dur_clean = tm;
    vars.crit_clean = tm >= crit_clean;
    
    % blank screen
    pres.RefreshDisplay;
    
    % report outcome
    if vars.crit_clean
        teEcho('Sufficient clean data acquired. Press %s to move to next trial\n',...
            pres.KB_MOVEON);
        pres.KeyUpdate;
        while ~pres.KeyPressed(pres.KB_MOVEON)
            pres.KeyUpdate;
            WaitSecs(.001);
        end
        pres.KeyUpdate
    elseif vars.timed_out
        teEcho('Times out after %d seconds. Press %s to move to next trial\n',...
            crit_timeout, pres.KB_MOVEON);
        pres.KeyUpdate;
        while ~pres.KeyPressed(pres.KB_MOVEON)
            pres.KeyUpdate;
            WaitSecs(.001);
        end
        pres.KeyUpdate
    end
end

