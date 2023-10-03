function vars = faceerp_trial(varargin)

%% setup
    
    % get presenter instance, vars struct, and task details
    [pres, vars, task] = teReadyForTrial(varargin{:});
    
    % select a random icon image
    fixImg          =   pres.Stim.LookupRandom('Key', 'img_faceerp_icon*');
    
    % select face stimulus from vars struct
    faceImg         =   pres.Stim(vars.stimimage);

    % durations
    fixMin          =   .5;
    fixMax          =   .65;
    dur_fixation    =   fixMin + (rand * (fixMax - fixMin));
    dur_face        =   .5;
    blankDurMin     =   .5;
    blankDurMax     =   .650;
    dur_blank       =   blankDurMin + (rand * (blankDurMax - blankDurMin));

    % positions
    [x, y]          =   pres.DrawingCentre;

    fixWidth        =   4;
    fixHeight       =   fixWidth / fixImg.AspectRatio;
    fixRect         =   [x - (fixWidth / 2), y - (fixHeight / 2),...
                        x + (fixWidth / 2), y + (fixHeight / 2)];

    faceWidth       =   13;
    faceHeight      =   faceWidth / faceImg.AspectRatio;
    faceRect        =   [x - (faceWidth / 2), y - (faceHeight / 2),...
                        x + (faceWidth / 2), y + (faceHeight / 2)];

    % set up trial
    pres.BackColour=[120 120 120];
    pres.RefreshDisplay;
    pres.KeyUpdate;
    pres.KeyFlush;

    % determine orientation
    switch lower(vars.orientation)
        case 'inverted'
            faceRot =   180;
        otherwise
            faceRot =   0;
    end
    
% if this is the first trial in a block then show a generic fixation to
% ensure the subject if ready

    if task.TrialNo == 1 ||...
            mod(task.TrialNo - 1, vars.parentlist.NumSamples) == 0
        teEcho('Face ERP Task: press %s when ready to begin.\n',...
            pres.KB_MOVEON);
        teFixation(pres);
    end

% fixation 

    pres.KeyUpdate;
    onset_fix = inf;
    pres.LightPatchOn
    flipTime = nan;
    while teGetSecs - onset_fix < dur_fixation && ~pres.ExitTrialNow

        % draw fixation and flip screen
        pres.DrawStim(fixImg, fixRect);
        flipTime = pres.RefreshDisplay;
        
        % send fixation onset marker 
        if onset_fix == inf
            onset_fix = flipTime;
            pres.SendRegisteredEvent('FACEERP_FIXATION_ICON', onset_fix);
        end
        
    end
    
    % record offfset time
    offset_fix = flipTime;

% face

    onset_face = inf;
    pres.LightPatchOn
    while teGetSecs - onset_face < dur_face && ~pres.ExitTrialNow

        % draw fixation and flip screen
        pres.DrawStim(faceImg, faceRect, faceRot);
        flipTime = pres.RefreshDisplay;
        
        % send fixation onset marker 
        if onset_face == inf
            onset_face = flipTime;
            pres.SendRegisteredEvent(vars.event, onset_face);
        end

    end
    
    % record offset time
    offset_face = flipTime;

% blank
    
    onset_blank = inf;
    pres.LightPatchOn
    while teGetSecs - onset_blank < dur_blank && ~pres.ExitTrialNow

        % refresh 
        flipTime = pres.RefreshDisplay;
        
        % send fixation onset marker 
        if onset_blank == inf
            onset_blank = flipTime;
            pres.SendRegisteredEvent('FACEERP_BLANK_ONSET', onset_blank);
        end

    end
    
    % record offset time
    offset_blank = flipTime;
    
% store vars

    % fixation timing
    vars.onset_fix = onset_fix;
    vars.offset_fix = offset_fix;
    vars.duration_fix = offset_fix - onset_fix;
    vars.delta_fix = vars.duration_fix - dur_fixation;
    
    % face timing
    vars.onset_face = onset_face;
    vars.offset_face = offset_face;
    vars.duration_face = offset_face - onset_face;
    vars.delta_face = vars.duration_face - dur_face;
    
    % blank timing
    vars.onset_blank = onset_blank;
    vars.offset_blank = offset_blank;
    vars.duration_blank = offset_blank - onset_blank;
    vars.delta_blank = vars.duration_blank - dur_blank;
    
end