function vars = teFixation(pres, varargin)

%     [pres, vars, ~] = teReadyForTrial(varargin{:});
    
    % parse input args
    if ~iscellstr(varargin)
        error('All input arguments must be char.')
    end
    varargin = lower(varargin);
    useET = ismember('useeyetracker', varargin);
    
    % update keyboard
    pres.KeyUpdate
    
    % get stim
    fix_img = pres.Stim.LookupRandom('Keys', 'fix_img');
    fix_snd = pres.Stim.LookupRandom('Keys', 'fix_snd');    
    
    % set size/pos
    [x, y] = pres.DrawingCentre;
    size_min = 3;
    size_max = 5;
    rect = teRectFromDims(x, y, size_min, size_min);
    
    % AOI
    if useET
        aoi_rect_cm = teRectFromDims(x, y, size_max, size_max);
        aoi_rect_rel = pres.ScaleRect(aoi_rect_cm, 'cm2rel');
        aoi = teAOI(aoi_rect_rel, .050);
        pres.EyeTracker.AOIs('fixation') = aoi;
    end
    
    % keyframes
    kf = teKeyFrame;
    kf.Duration = 0.66;
    kf.Loop = true;
    kf.AddTimeValue(0.00, size_min);
    kf.AddTimeValue(0.50, size_max);
    kf.AddTimeValue(1.00, size_min);
    
    % animation loop
    flipTime = nan;
    firstFrame = true;
    hasGaze = false;
    pres.PlayStim(fix_snd);
    while ~hasGaze && ~pres.KeyPressed(pres.KB_MOVEON) &&...
            ~pres.ExitTrialNow
        
        % draw
        pres.DrawStim(fix_img, rect)
        flipTime = pres.RefreshDisplay;
        
        % update time if first frame
        if firstFrame
            % send event
            pres.SendRegisteredEvent('GC_FIXATION_ONSET', flipTime);
            % set key frame start time
            kf.StartTime = flipTime;
            % set first frame flag to false
            firstFrame = false;
        end
        
        % update size
        newSize = kf.Value;
        rect = teRectFromDims(x, y, newSize, newSize);                                                                                                  
        
        % check gaze
        if useET
            hasGaze = aoi.Hit;
        end
        
    end
    
    % if the fixation has been skipped, the time of the last flip
    % (flipTime) may be missing. In that case, set it to the current time
    % (since no stimuli have been displayed, this is the best estimate of
    % when the fixation ended - even though it never really began)
    if isnan(flipTime), flipTime = teGetSecs; end
    
    % send markers
    pres.SendRegisteredEvent('GC_FIXATION_OFFSET', flipTime);
    
    % delete AOI
    if useET
        pres.EyeTracker.AOIs.RemoveItem('fixation');
    end
    
    % flush keyboard
    pres.KeyFlush
    pres.KeyUpdate
    
end
        
        
  