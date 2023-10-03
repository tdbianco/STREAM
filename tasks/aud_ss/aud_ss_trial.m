function vars = aud_ss_trial(varargin)
% Presents the auditory steady state (aud_ss) task. 500ms trains of clicks
% are sent, at frequencies of 10Hz or 40Hz. ISI is random 1000-1500ms. 
% 100 trials are sent in total, with a 1:1 ratio of each frequency, in a
% pseudorandom order. 
% A video is played during this task, selected at startup in the same way
% as for the oddball task. 

% set up trial, clear screen, look up movie (this was selected at startup,
% and is the same as used for the oddball task)

    [pres, vars, ~] = teReadyForTrial(varargin{:});

    % clear screen
    pres.BackColour = [0, 0, 0];
    pres.RefreshDisplay;
    
    % look up chosen video 
    mov = pres.Stim.LookupRandom('Keys', 'auditory_video*');
    mov.Volume = 0;
    pres.PlayStim(mov);
    pres.DrawStim(mov);
    
% define number of trials, durations etc. The edge of each clip is tapered
% and the duration of this taper is set up here
    
    dur_click = 0.015;                              % duration of one click
    dur_clickEdge = 0.001;                          % duration of tapered click edge
    dur_trainISI = 1.000;                              % duration of one train
    
% load the precalculated order and isi for all trials
    
    % check file exists
    if ~exist('aud_ss_order.mat', 'file')
        error('Cannot find ''aud_ss_order.mat''.')
    end
    
    % load and assign
    tmp = load('aud_ss_order.mat');
    ord = tmp.aud_ss_order;
    ISI = tmp.aud_ss_isi;

% create sound stimuli. One 1.5ms click is generated. Empty 500ms trains of
% sound data are generated. The number of clicks per train is calculated
% for each frequency, then we simply repeat the click that number of times

    % sampling rate is 44.1Khz
    fs = 44100;
    
    % calculate number of samples for click length
    samps_click = round(fs * dur_click);
    
    % calculate rise/fall duration in samples of click edges
    samps_clickEdge = round(fs * dur_clickEdge);

    % calculate number of samples for each 500ms train
    samps_train = round(fs * dur_trainISI);
    
    % calculate number of clicks needed for each freq
    numClicks_10 = 10 * dur_trainISI;
    numClicks_40 = 40 * dur_trainISI;
    
    % generate click for one channel
    click = 0.5 - rand(1, samps_click);
    
    % make click rise/fall
    clickEdge_step = 1 / (samps_clickEdge - 1);
    clickEdge_left = 0:clickEdge_step:1;
    clickEdge_right = 1:-clickEdge_step:0;
    click(1:samps_clickEdge) = click(1:samps_clickEdge) .* clickEdge_left;
    click(end - samps_clickEdge + 1:end) =...
        click(end - samps_clickEdge + 1:end) .* clickEdge_right;
    
    % make stereo by repeating the mono channel
    click = repmat(click, 2, 1);
    
    % calculate inter-click-interval in samples for each freq
    ici_10 = round(samps_train / numClicks_10);
    ici_40 = round(samps_train / numClicks_40);
    
    % generate sample indices for position of click within train for each
    % frequency
    s1_10 = 1:ici_10:samps_train;
    s2_10 = s1_10 + samps_click - 1;
    s1_40 = 1:ici_40:samps_train;
    s2_40 = s1_40 + samps_click - 1;
    
    % generate empty matrices to hold trains for each freq
    snd_10 = zeros(2, samps_train);
    snd_40 = zeros(2, samps_train);
    
    % insert clicks at the appropriate sample indices
    for c = 1:numClicks_10
        snd_10(:, s1_10(c):s2_10(c)) = click;
    end
    for c = 1:numClicks_40
        snd_40(:, s1_40(c):s2_40(c)) = click;
    end

% open the sound device and present a message to the experimenter saying we
% are ready to start
    
    sndPtr = PsychPortAudio('Open', [], [], 3, fs, 2);

    pres.KeyUpdate
    fprintf('\n\n<strong>Auditory Steady State task ready, press %s to begin.\n</strong>',...
        pres.KB_MOVEON);
    while ~pres.KeyPressed(pres.KB_MOVEON)
        pres.KeyUpdate
        WaitSecs(.001);
    end

% init vars
    
    onset_task = teGetSecs;             % task onset
    tr = 1;                             % trial counter 
    numTrials = length(ord);            % num trials
    onset_train = nan(numTrials, 1);    % train onsets
    offset_ISI = nan(numTrials, 1);     % scheduled ISI offsets
    dur_trainISI = nan(numTrials, 1);   % train + ISI duration
    offset_actual = nan(numTrials, 1);  % actual train + ISI offsets
    delta_ISI = nan(numTrials, 1);      % actual/sched offset delta
    soundData = table;
    
    % loop through trains
    while tr <= numTrials && ~pres.ExitTrialNow

    % calculate elapsed time, and format into a string for display.
    % This allows the experimenter to get an idea of how far through
    % the task they are
    
        elap_sec = teGetSecs - onset_task;
        elap_str = datestr(elap_sec / 86400, 'HH:MM:SS');
        trPerSec = elap_sec / tr;
        tr_rem = numTrials - tr;
        rem_sec = tr_rem * trPerSec;
        if tr < 5
            rem_str = '<calculating>';
        else
            rem_str = datestr(rem_sec / 86400, 'HH:MM:SS');
        end
        fprintf('Trial %3d of %3d | Elapsed: %s | Remaining: %s\n',...
            tr, numTrials, elap_str, rem_str);
        
    % play train
             
        % fill buffer with sound, using the index stored in ord to select
        % the appropriate frequency
        switch ord(tr)
            case 1
                % 10Hz
                sndToPlay = snd_10;
                mrk = 'TRAIN_ONSET_10HZ';
            case 2
                % 40Hz
                sndToPlay = snd_40;
                mrk = 'TRAIN_ONSET_40HZ';
            otherwise
                % catch errors if ord is not 1 or 2
                error('Expected order to be 1 or 2, was %d', ord(tr))
        end
        PsychPortAudio('FillBuffer', sndPtr, sndToPlay);
        
        % play sound
        onset_train(tr) = PsychPortAudio('Start', sndPtr, 1, [], 1);
        
        % convert onset time to posix
        onset_train(tr) = teGetSecs(onset_train(tr));
        
        % calculate sound duration
        dur_trainISI(tr) = (length(sndToPlay) / fs) + ISI(tr);
        offset_ISI(tr) = onset_train(tr) + dur_trainISI(tr);
        
    % send marker
        
        pres.SendRegisteredEvent(mrk, onset_train(tr));
        
    % loop for train duration

        while teGetSecs < offset_ISI(tr)
            pres.DrawStim(mov);
            flipTime = pres.RefreshDisplay;
        end
        
        offset_actual(tr) = flipTime;
        delta_ISI(tr) = offset_actual(tr) - offset_ISI(tr);
        
        tr = tr + 1;
        
    end

    % Close the audio device:
    PsychPortAudio('Close', sndPtr);

    % make train data
    trainData = [...
        (1:numTrials)',...
        onset_train,...
        offset_ISI,...
        dur_trainISI,...
        delta_ISI,...
        ];

    % repeat train data 4x, then sort
    trainData = array2table(trainData, 'VariableNames', {...
        'train_number',...
        'onset_train',...
        'offset_trainISI',...
        'duration_trainISI',...
        'delta_trainISI',...
        });

    % repeat vars that apply to all trials
    tab_vars = cell2table(struct2cell(vars)', 'VariableNames',...
        fieldnames(vars));
    varData = repmat(tab_vars, numTrials, 1);
    
    % combine tables and convert back to struct
    combData = [varData, trainData, soundData];
    vars = table2struct(combData);
    
    pres.StopStim(mov);

end