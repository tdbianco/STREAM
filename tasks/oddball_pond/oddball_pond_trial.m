function vars = oddball_pond_trial(varargin)
% Presents the POND auditory oddball task. Unlike most tasks, all trials
% are run in one big loop within this function. Doing otherwise would
% introduce overhead in starting each trial, leading to variable latency
% between stimuli. Therefore Task Engine sees this function as one very
% long trial.
% Stimuli are encoded as trains of stds, followed by a dev. The ISI is 1s,
% and a silent 1s ISI is encoded on the end of each train. This means they
% can be presented back-to-back without worrying about tracking time
% between stimuli. 
% In total there are 390 stds and 60 devs. There are 6 different trains,
% each with a different number of stds. This breaks down as:
%
%   [S S S S D]             - 4 stds, 1 dev
%   [S S S S S D]           - 5 stds, 1 dev
%   ...
%   [S S S S S S S S S D]   - 9 stds, 1 dev
%
% Each train is presented 10 times, which means that we present (6 * 10 =
% 60) devs, and ([4, 5, 6, 7, 8, 9] * 10) stds = 390. Total number of
% sounds is 450. 
% A video is played silently on screen whilst this tasks runs.

    [pres, vars, ~] = teReadyForTrial(varargin{:});

    % clear screen
    pres.BackColour = [0, 0, 0];
    pres.RefreshDisplay;
    
    % look up chosen video 
    mov = pres.Stim.LookupRandom('Keys', 'auditory_video*');
    mov.Volume = 0;
    pres.PlayStim(mov);
    pres.DrawStim(mov);

    % load sound data into memory. Each sound is stored in a separate
    % variable. There are six sounds, each a train of stds with the dev in
    % a different position, from 5 to 10. For example, d6 means dev in
    % position 6, which means there are 5 stds in the train followed by one
    % dev [S S S S S D]. We read the sampling rate into fs on loading the
    % first stimulus - we don't bother doing this for subsequent stimuli.
    snd_dev             = cell(6, 1);
    [snd_dev{1}, fs]    = audioread([pres.Paths.oddball_pond_stim, filesep, 'T1.wav']);
    snd_dev{2}          = audioread([pres.Paths.oddball_pond_stim, filesep, 'T2.wav']);
    snd_dev{3}          = audioread([pres.Paths.oddball_pond_stim, filesep, 'T3.wav']);
    snd_dev{4}          = audioread([pres.Paths.oddball_pond_stim, filesep, 'T4.wav']);
    snd_dev{5}          = audioread([pres.Paths.oddball_pond_stim, filesep, 'T5.wav']);
    snd_dev{6}          = audioread([pres.Paths.oddball_pond_stim, filesep, 'T6.wav']);
    
    % load order of trials
    if ~exist('oddball_pond_order.mat', 'file')
        error('Cannot find ''oddball_pond_order.mat''.')
    end
    tmp = load('oddball_pond_order.mat');
    ord = tmp.oddball_pond_order;
    
    % open buffer 
    sndPtr = PsychPortAudio('Open', [], [], 3, fs, 2);

    pres.KeyUpdate
    fprintf('\n\n<strong>POND Oddball task ready, press %s to begin.\n</strong>',...
        pres.KB_MOVEON);
    while ~pres.KeyPressed(pres.KB_MOVEON)
        pres.KeyUpdate
        WaitSecs(.001);
    end

% init vars
    
    onset_task = teGetSecs;             % task onset
    tr = 1;                             % trial counter 
    numTrials = length(ord);            % num trials
%     numTrials = 3;   
    onset_train = nan(numTrials, 1);    % train onsets
    offset_train = nan(numTrials, 1);   % scheduled train offsets
    dur_train = nan(numTrials, 1);      % train duration
    offset_actual = nan(numTrials, 1);  % actual train offsets
    delta_train = nan(numTrials, 1);    % actual/sched offset delta
    devPos = nan(numTrials, 1);         % dev position in train
    mrk = cell(numTrials, 1);           % event markers
    soundData = table;
    trainData = table;
    
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
             
        % fill buffer with sound, using the index stored in the ord
        % variable for the current trial (tr)
        PsychPortAudio('FillBuffer', sndPtr, snd_dev{ord(tr)}');

        % play sound
        onset_train(tr) = PsychPortAudio('Start', sndPtr, 1, [], 1);
        
        % convert onset time to posix
        onset_train(tr) = teGetSecs(onset_train(tr));
        
        % calculate sound duration
        dur_train(tr) = length(snd_dev{ord(tr)}) / fs;
        offset_train(tr) = onset_train(tr) + dur_train(tr);
        
    % send marker
        
        % calculate deviant position
        devPos(tr) = ord(tr) + 4;
    
        % construct marker string
        mrk{tr} = sprintf('TRAIN_ONSET_DEV_%02d', devPos(tr));

        % send marker
        pres.SendRegisteredEvent(mrk{tr}, onset_train(tr));
        
    % loop for train duration

        while teGetSecs < offset_train(tr)
            pres.DrawStim(mov);
            flipTime = pres.RefreshDisplay;
        end
        
        offset_actual(tr) = flipTime;
        delta_train(tr) = offset_actual(tr) - offset_train(tr);
        
        tr = tr + 1;
        
    end

    % Close the audio device:
    PsychPortAudio('Close', sndPtr);

    % make train data
    trainData = [...
        (1:numTrials)',...
        onset_train,...
        offset_train,...
        dur_train,...
        delta_train,...
        devPos,...
        ];

    % repeat train data 4x, then sort
    trainData = array2table(trainData, 'VariableNames', {...
        'train_number',...
        'onset_train',...
        'offset_train',...
        'duration_train',...
        'delta_train',...
        'deviant_position',...
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