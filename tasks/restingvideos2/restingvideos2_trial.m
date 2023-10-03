function vars = restingvideos2_trial(varargin)
% Presents the social/non-social resting videos ands ends EEG markers.
% This function is essentially a wrapper for video_trial. It queries
% vars.Key for either a) the name of recognised resting video (e.g.
% FACE_EN.mp4), or b) the words 'social' or 'nonsocial'. In this latter
% case, it queries the site variable of the tePresenter's teTracker
% property and attempts to find the appropriate localised video

% lookup table for which video to show at which site

    siteLookup = {...
        'Paris',            'FACE_FR.mp4',      'FACE_ONSET_FR'     ;...
        'Barcelona',        'FACE_RS.mp4',      'FACE_ONSET_ES'     ;...
        'Glasgow',          'FACE_EN.mp4',      'FACE_ONSET_EN'     ;...
        'Madrid',           'FACE_ES.mp4',      'FACE_ONSET_ES'     ;...
        'Edinburgh',        'FACE_EN.mp4',      'FACE_ONSET_EN'     ;...
        'London',           'FACE_EN.mp4',      'FACE_ONSET_EN'     ;...
        'Newcastle',        'FACE_EN.mp4',      'FACE_ONSET_EN'     ;...
        'Cape_Town',        'FACE_EN.mp4',      'FACE_ONSET_EN'     ;...
        'Gambia',           'FACE_GM.mp4',      'FACE_ONSET_GM'     ;...
        'KCL',              'FACE_EN.mp4',      'FACE_ONSET_EN'     ;...
        'Ghent',            'FACE_NL.mp4',      'FACE_ONSET_NL'     ;...
        'Nijmegen',         'FACE_NL.mp4',      'FACE_ONSET_NL'     ;...
        'KI',               'FACE_SW.mp4',      'FACE_ONSET_SW'     ;...
        };

    % check everything is ready for a trial
    [pres, vars] = teReadyForTrial(varargin{:});
    
    % look up event code
    if ~isfield(vars, 'key')
        error('No ''key'' variable was passed - cannot look up stimulus.')
    end
    % set data events - these are used for sending to the tePresenter log
    % (which is how eye tracker events are handled), but not for more
    % restricted formats, e.g. EEG, NIRS. These restricted events are
    % handled in the switch statement below. 
    vars.events.offset                  = 'VIDEO_OFFSET';
    switch vars.key
        
        % lookup by video name - just set the marker 
        case 'FACE_EN.mp4'
            vars.events.onset           = 'FACE_ONSET_EN';
        case 'FACE_NL.mp4'
            vars.events.onset           = 'FACE_ONSET_NL';
        case 'FACE_PL.mov'
            vars.events.onset           = 'FACE_ONSET_PL';
        case 'FACE_SW.mov'
            vars.events.onset           = 'FACE_ONSET_SW';
        case 'FACE_GM.mp4'
            vars.events.onset           = 'FACE_ONSET_GM';
        case 'FACE_IN.mp4'
            vars.events.onset           = 'FACE_ONSET_IN';            
        case 'TOY_EN.mp4'
            vars.events.onset           = 'TOY_ONSET';
            
        % lookup by 'social' or 'nonsocial' and attempt to find the correct
        % video for the current site
        case 'social'
            found = strcmpi(pres.Tracker.Site, siteLookup(:, 1));
            if ~any(found)
                % not found in lookup
                fprintf('Failed to find site ''%s'' in lookup table, defaulting to English.',...
                    pres.Tracker.Site)
                vars.key = 'FACE_EN.mp4';
                vars.events.onset = 'FACE_ONSET_EN';
            else
                % found - rewrite vars.Key with correct movie name and set
                % event
                vars.key = siteLookup{found, 2};
                vars.events.onset = siteLookup{found, 3};
            end
        case 'nonsocial'
            % if non-social there are no localise videos, so setup the toy
            % video
            vars.key = 'TOY_EN.mp4';    % ignore _EN in filename
            vars.events.onset = 'TOY_ONSET';
            
        otherwise
            warndlg(sprintf('Failed to look up event codes for stimulus: %s - will continue but event markers WILL NOT BE SENT!',...
                vars.Key))
    end
    % fixation
    pres.BackColour = [000, 000, 000];
    pres.RefreshDisplay;  
%     teFixation(pres, 'useEyeTracker');
    % pass to video_trial
    vars = video_trial(pres, vars);
    
end

