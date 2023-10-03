function vars = video_trial(varargin)

    % check everything is ready for a trial
    [pres, vars] = teReadyForTrial(varargin{:});
    
    % set up trial
    if isfield(vars, 'backcolour')
        backColour = vars.backcolour;
    else
        backColour = [000, 000, 000];
    end
    pres.BackColour = backColour;
    
    % check that stim is available
    if ~isfield(vars, 'key')
        error('.key field not found in vars structure. This is used to tell this task which stimulus to play.')
    end
    mov = pres.Stim(vars.key);
    if isempty(mov), error('Stimulus %s not found.', vars.key), end
    
    % set volume, rate etc. here - todo
    mov.CurrentTime = 0;
    
    % optionally play fixation - defaults to true
    if ~isfield(vars, 'fixation')
        vars.fixation = true;
    end
    if vars.fixation
        teFixation(pres, 'useEyeTracker');
    end    
    
    % start movie playing
    pres.PlayStim(mov);
    
    % if a duration has been supplied in the vars struct then pull this
    % out, otherwise set it to inf, and the video will play until EOF
    if isfield(vars, 'duration') && ~isempty(vars.duration) &&...
            ~isnan(vars.duration)
        duration = vars.duration;
    else
        duration = inf;
    end
    
    % loop until finished, drawing each frame as we go
    markerSent = false;
    vars.movie_onset = -inf;
    while mov.Playing &&...
            vars.movie_onset - teGetSecs < duration &&...
            ~pres.KeyPressed(pres.KB_MOVEON) &&...
            ~pres.ExitTrialNow
        % draw
        pres.DrawStim(mov);
        flipTime = pres.RefreshDisplay;
        % marker
        if ~markerSent
            % log movie onset time
            vars.movie_onset = flipTime;
            % send events
            if isfield(vars, 'events')
                if isfield(vars.events, 'onset')
                    pres.SendRegisteredEvent(vars.events.onset, flipTime);
                end
            end
            % flag marker as sent
            markerSent = true;
        end
    end
    % stop the movie, and flip the screen (so that the frame is not still
    % visible, and so that we get an accurate timestamp of when the movie
    % was last visible)
    pres.StopStim(mov);
    flipTime = pres.RefreshDisplay;
    
    % send offset event(s)
    vars.movie_offset = flipTime;
    vars.movie_duration = vars.movie_offset - vars.movie_onset;
    if isfield(vars, 'events')
        if isfield(vars.events, 'offset')
            pres.SendRegisteredEvent(vars.events.offset, flipTime);
        end
    end
    
    % record skipped/quit request
    vars.skipped = pres.KeyPressed(pres.KB_MOVEON);
    vars.quit = pres.ExitTrialNow;
    
    % blank screen
    pres.RefreshDisplay;
    
end

