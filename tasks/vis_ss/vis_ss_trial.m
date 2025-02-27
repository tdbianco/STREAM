function vars = vis_ss_trial(varargin)

%% setup
    
    % get presenter instance, vars struct, and task details
    [pres, vars, task] = teReadyForTrial(varargin{:});
       
% get stimuli for the icon, and set its position/dimension
   
    % retrieve chosen stimulus from the presenter's Stim collection
    stim = pres.Stim(vars.stim);
    
    % check that stimulus could be found
    if isempty(stim)
        error('Could not find icon stimulus: %s', vars.stim)
    end
    
    % size is 15cm (square), and position is centre of screen
    sz = 15;
    rect = teCentreRect([0, 0, sz, sz], [0, 0, pres.DrawingSize]);
    
    % store text version of icon rect in variables (so that it is logged to
    % the data file)
    vars.rect = num2str(rect);
    
    % set screen to dark grey
    pres.BackColour = [020, 020, 020];
    pres.RefreshDisplay;
    
    % set light patch auto off timer to 15ms
    pres.LightPatchAutoOff = .015;
    
% events are labelled with "ICON_ONSET_XHZ", where X is the frequency.
% Using the frequency passed into this function via the vars struct, build
% a label for the current trial

    eventName = sprintf('ICON_ONSET_%dHZ', vars.freq);
    
%% animation

    % if this is the first trial of a block, show a fixation stimulus
    if mod(vars.trial - 1, 6) == 0 || vars.trial == 1
        teFixation(pres);
    end
    
    % num reversals per second (revHz) is different to number of onsets per
    % second (onsetHz). In a "true" reversal task, such as a reversing
    % checkerboard, the probes frequency would be revHz. In a "flicker"
    % task, where we present an image for half the time and a blank screen
    % for the other half, the probe frequency is onsetHz. i.e. the brain
    % does not perceive an image/blank sequence as two stimulations (as it
    % would in a checker reversal task), but one. Therefore we double the
    % frequency in the vars struct, because we want to flicker at onsetHz
    % (since this is not a reversal task). If ever it become a reversal
    % task, set freqMultiplier to 1. 
    freqMultiplier      = 2;
    
    % frequency (in terms of the brain frequency we want to probe) is the
    % number of onsets per second 

    % define variables
    freq                = vars.freq * freqMultiplier;               % stimulation frequency
    duration            = 5.0;                                      % trial duration
    onset               = inf;                                      % trial onset
    revDur              = 1 / freq ;                                % duration of one reversal
    numRev              = ceil(duration / revDur);                  % number of reversals
    revTimes            = nan(numRev, 1);                           % store times of each reversal
    revCounter          = 1;                                        % count reversals
    state               = true;                                     % image state (on/off)
    firstTrialFrame     = true;                                     % flag to mark first frame of trial
    firstRevFrame       = true;                                     % flag to mark first frame of reversal
    frameCounter        = 0;                                        % count frames
    numFramesPerRev     = round(revDur / pres.TargetFrameTime);
    
    % loop until duration is up, trial was skippd, or a request to exit the
    % trial is received
    while teGetSecs - onset < duration &&...
        ~pres.KeyPressed(pres.KB_MOVEON) &&...
        ~pres.ExitTrialNow
    
        % handle light patch
        if firstTrialFrame || (firstRevFrame && state)
            pres.LightPatchOn
        end
    
        % draw (if image is on)
        if state
            pres.DrawStim(stim, rect);
        end
        
        % flip the screen
        flipTime = pres.RefreshDisplay;
        frameCounter = frameCounter + 1;
        
        % if this is the first frame, update the stimulus onset time with
        % the timestamp returned by RefreshDisplay. This is the closest
        % timestamp we have to the time that the stimulus was actually
        % drawn, so we base the duration of the trial on this
        if firstTrialFrame
            
            % store stimulus onset time 
            onset = flipTime;
            
            % send event using onset time
            pres.SendRegisteredEvent(eventName, onset);
            
            % clear first frame flag
            firstTrialFrame = false;
            
        end
        
        % if this is the first frame of a reversal, send a reversal event.
        % This may be an onset (if this is the first frame in which an
        % image is being drawn - i.e. state is true) or an offset (if this
        % is the first frame of the blank period between images - i.e.
        % state is false)
        if firstRevFrame
            
            % store the reversal onset time
            revTimes(revCounter) = flipTime;
            revCounter = revCounter + 1;
            
            % send an event
            switch state
                case true
                    pres.SendRegisteredEvent('FLICKER_ONSET')
                case false
                    pres.SendRegisteredEvent('FLICKER_OFFSET')
            end
            
            % clear the first reversal frame flag
            firstRevFrame = false;
            
        end
        
        % if the number of flips for one cycle of flicker has passed,
        % reverse the state (image on -> off, or off -> on), and reset the
        % frame counter
        if frameCounter == numFramesPerRev 

            state = ~state;
            firstRevFrame = true;
            frameCounter = 0;
            
        end
                
    end

    % clear screen
    offset = pres.RefreshDisplay;
    
    % send trial offset event
    pres.SendRegisteredEvent('ICON_OFFSET', offset);
    
    % record mean and standard deviation of achieved stimulation
    % frequencies
    flipDurs = diff(revTimes);
    fs_actual = 1 ./ flipDurs;
    vars.actual_fs_mu = nanmean(fs_actual);
    vars.acutal_fs_sd = nanstd(fs_actual);
    
    % record skip
    vars.skipped = pres.KeyPressed(pres.KB_MOVEON);
    
    % log variables to vars struct (these will go into the log file)
    vars.duration = duration;
    vars.duration_actual = offset - onset;
    vars.onset = onset;
    vars.offset = offset;
    vars.reversalduration = revDur;
    
end
