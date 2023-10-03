function faceerp_defineEvents(events)

    % fixation icons
    events('FACEERP_FIXATION_ICON')            = struct('eeg', 020, 'task', 'faceerp');
    % faces
    events('FACE_CAUCASIAN_UPRIGHT_ONSET')     = struct('eeg', 021, 'task', 'faceerp');
    events('FACE_CAUCASIAN_INVERTED_ONSET')    = struct('eeg', 022, 'task', 'faceerp');
    events('FACE_ASIAN_UPRIGHT_ONSET')         = struct('eeg', 023, 'task', 'faceerp');
    events('FACE_ASIAN_INVERTED_ONSET')        = struct('eeg', 024, 'task', 'faceerp');
    events('FACE_AFRICAN_UPRIGHT_ONSET')       = struct('eeg', 025, 'task', 'faceerp');
    events('FACE_AFRICAN_INVERTED_ONSET')      = struct('eeg', 026, 'task', 'faceerp');
    % houses
    events('HOUSE_1_UPRIGHT_ONSET')            = struct('eeg', 027, 'task', 'faceerp');
    events('HOUSE_2_UPRIGHT_ONSET')            = struct('eeg', 028, 'task', 'faceerp');
    events('HOUSE_3_UPRIGHT_ONSET')            = struct('eeg', 029, 'task', 'faceerp');
    % blank
    events('FACEERP_BLANK_ONSET')              = struct('eeg', 030, 'task', 'faceerp');

end
