function sync = teSyncVideo(path_in)

    % add axing to java path (for processing QR codes)
    path_te = teFindRootFolder;
    path_zxing = fullfile(path_te, 'zxing');
    if ~exist(path_zxing, 'dir')
        error('Could not find zxing path at %s.', path_zxing)
    else
        javaaddpath(fullfile(path_zxing, 'core-3.3.3.jar'))
        javaaddpath(fullfile(path_zxing, 'javase-3.3.3.jar'))
    end

    % check input arg
    isDir = exist(path_in, 'dir');
    isFile = exist(path_in, 'file');
    if ~isDir && ~isFile
        error('Path ''%s'' is neither a file nor a folder.', path_in);
    end
    
    % define valid video formats
    valFormats = {'avi', 'mp4', 'm4v', 'mov'};

    % if path_in is a folder, search it
    if isDir
        % get all files
        d = dir(path_in);
        % make full file paths
        allFiles = cellfun(@(filename) fullfile(path_in, filename),...
            {d.name}, 'uniform', false)';
        % get extensions
        [~, ~, ext] = cellfun(@fileparts, allFiles, 'uniform', false);
        % strip dot
        ext = cellfun(@(x) strrep(x, '.', ''), ext, 'uniform', false);
        % find files with valid extensions
        idx_valExt = ismember(ext, valFormats);
        % filter
        allFiles(~idx_valExt) = [];
        
    elseif isFile
        % just place the file into a cell array, so that it can be
        % processed in the same way as a list of files
        allFiles{1} = path_in;
        
    end
    
    % check there are some files
    numFiles = length(allFiles);
    if numFiles == 0
        error('No files with valid extensions found.')
    end
    
    % process
    sync = cell(numFiles, 1);
    for f = 1:numFiles
        
        % sync one video
        sync{f} = syncOneVideo(allFiles{f});
        
    end
    
    % if one single file, remove from cell array
    if numFiles == 1
        sync = sync{1};
    end
        
end

function sync = syncOneVideo(file_in)

    teEcho(sprintf('Processing [%s]\n', file_in));

% get video info. this is so that we can open a window that has the correct
% aspect ratio. Not important for processsing, but looks nicer. 

    % get video info
    try
        inf = mmfileinfo(file_in);
    catch ERR_vid
        error('Erroring getting video metadata. Error was:\n\n%s',...
            ERR_vid.message)
    end
    % get width, height
    w = inf.Video.Width;
    h = inf.Video.Height;    
    if isempty(w) || isempty(h)
        ar = 16 / 9;
    else
        ar = w / h;
    end

% set up PTB window

    % max width of window is 500px, scale height according to video aspect
    % ratio
    sw = 500;
    sh = round(sw / ar);
    rect_screen = [0, 0, sw, sh];
   
    % skip PTB sync tests, and set verbosity to minimum
    old_skipSyncTests = Screen('Preference', 'SkipSyncTests', 2);
    old_verbosity = Screen('Preference', 'Verbosity', 0);
    
    % open PTB window
    screenNum = max(Screen('Screens'));
    w = Screen('OpenWindow', screenNum, [], rect_screen);
    Screen('TextFont', w, 'Arial');
    
    % set font for drawing timecode
    old_fontName = Screen('TextFont', w, 'menlo');
    old_fontSize = Screen('TextSize', w, 24);    
    
% set up PTB video
    
    % open video 
    try
        [m, dur, fps] = Screen('OpenMovie', w, file_in);
    catch ERR_PTB_vid
        error('Erroring loading video. Error was:\n\n%s',...
            ERR_PTB_vid.message)
    end   
    
    % get inter-frame-interval
    ifi = 1 / fps;
    
    % define duration of stamp - default is 5s
    dur_stamp = 5;
    
    % define sampling period
    sampPer = (dur_stamp - (2 * ifi));
    
% define the search strategy for finding the edge markers. These are most
% likely to be at the start or the end of the video. So first search the
% the beginning 10% of frames, then the final 10%, then the remaining
% middle 80%

%     first10             = 0:sampPer:dur * .10;
%     last10              = dur - (dur * .10):sampPer:dur;
%     middle80            = (dur * .10) + sampPer:sampPer:dur - (dur * .10);
%     initSearchSpace     = [first10, last10, middle80];
%     numFrames           = length(initSearchSpace);
%     
%     first10             = 0:sampPer:dur * .10;
%     last10              = dur - (dur * .10):sampPer:dur;
    
%     search_f1(:, 1)     = 0.00:0.05:0.95;
%     search_f2(:, 1)     = 0.05:0.05:1.00;
%     numSearch           = length(search_f1);
%     initSearchSpace     = [];
%     for se = 1:numSearch
%         if mod(se, 2) ~= 0
%             idx = se;
%         else
%             idx = numSearch - se + 1;
%         end
%         initSearchSpace = [initSearchSpace, search_f1(idx) * dur:sampPer:dur * search_f2(idx)];
%     end

    initSearchSpace = 0:sampPer:dur;
    numFrames = length(initSearchSpace);
    
    % flag vector to record which frames had a marker present (these will
    % form the basis of a more fine-grained search for the exact on/offset
    % of the edge markers in the next stage
    markerPresent       = false(size(initSearchSpace));
    
% now loop through the search space and look for markers

    for f = 1:numFrames
        
        % get time of current search frame
        t = initSearchSpace(f);
        
        % look for marker
        markerPresent(f) = findEdgeMarkers(getFrame(t));
        if markerPresent(f)
            fprintf('Possible corner markers found at %.2fs\n', t);
        end
        
    end
    
% for all frames with markers present, define a new search space. Now we
% want to know the precise frame at which the marker onset occured, so we
% step through frame-by-frame. 
% the markers are stamped on the video for (default) 5s. Based on the
% previous step, we don't know whether the frame we found with a marker
% present as in the middle of this 5s, as the start, the end etc. Rather
% than checking all frames, we sample by splitting that 5s into two and
% searching there. If the marker is still found, we need to go back (so we
% now split 2.5s into two), if it is not found, we need to go forward (so
% we split 2.5s in a forward direction). This checks the least possible
% number of frames, making for the fastest possible search. 

    % get number of markers present
    numMarkers = sum(markerPresent);
    
    % get frame indices of markers
    idx_frame = find(markerPresent);
    
    % get timestamps of those frames
    t_known = initSearchSpace(idx_frame);
    
    % storage for time onsets
    foundTimes = nan(1, numMarkers);
    GUIDs = cell(1, numMarkers);
    timestamps = nan(1, numMarkers);
    
    for mrk = 1:numMarkers
        
        step = dur_stamp / 2;
        direction = -1;
        t_search = t_known(mrk);
        while abs(step) > (ifi / 2) 
            
            t_search = t_search + (direction * step);
            if t_search < 0
                t_search = 0;
            end
            markersFound = findEdgeMarkers(getFrame(t_search));
            if ~markersFound

                % marker not present - halve search space and try again
                step = step / 2;
                direction = 1;
                
            elseif markersFound && t_search ~= 0
                
                % marker present - search with same step but go backwards
                direction = -1;
                
            elseif markersFound && t_search == 0
                
                % marker preent and time at zero - we can stop now
                break
                
            end
            
        end
        
        % search ends on the frame before the onset, so add one frame to
        % the current search time and store it
        foundTimes(mrk) = t_search + ifi;
        
        % decode QR
        msg = decode_qr(imresize(getFrame(foundTimes(mrk)), 2));
        
        % split QR message
        c = strsplit(msg, '#');
        GUIDs{mrk} = c{1};
        timestamps(mrk) = str2double(c{2});     
        
    end

    % close movie
    Screen('CloseAll')

    % restore PTB sync skip and verbosity setting
    Screen('Preference', 'SkipSyncTests', old_skipSyncTests);
    Screen('Preference', 'Verbosity', old_verbosity);
    
    % report results
    sync.numMarkers = numMarkers;
    sync.teTime = timestamps;
    sync.videoTime = foundTimes;
    sync.GUID = GUIDs;
    sync.file_in = file_in;
    
    % calculate frame numbers, frame time, and te timstamps (per frame)
    numTotalFrames = dur * fps;
    sync.frames = ceil(dur * fps);
    sync.frameTimes = 0:ifi:dur;
    
    % sort times
    if numMarkers >= 1
        sync.teTime = sort(sync.teTime);
        sync.videoTime = sort(sync.videoTime);
    end
    
    % intercept 
    if numMarkers == 1
        % intercept only
        a = sync.teTime(1) - sync.videoTime(1);
        sync.timestamps = sync.frameTimes + a;
        sync.intercept = a;
        sync.video2te = str2func(sprintf('@(x) x + %.12f', a));
        sync.te2video = str2func(sprintf('@(x) x - %.12f', a));
    end
    
    if numMarkers > 1
        % intercept
        a = sync.teTime(1) - sync.videoTime(1);
        % slope
        b = (sync.teTime - a) / sync.videoTime;
        sync.timestamps = a + (sync.frameTimes * b);
        sync.intercept = a;
        sync.b1 = b;
        sync.video2te = str2func(sprintf('@(x) %.12f + (x * %.12f)', a, b));
        sync.te2video = str2func(sprintf('@(x) (x - %.12f) / %.12f', a, b));
    end
    
    if numMarkers == 0
        sync = struct;
        sync.GUID = 'NOT_FOUND';
    end
    
    % write sync struct
    [path_in, fil, ext] = fileparts(file_in);
    file_out = fullfile(path_in, sprintf('%s%s#%s#.sync.mat',...
        fil, ext, sync.GUID));
    save(file_out, 'sync')    
    
    % echo results
    if numMarkers > 0
        str = sprintf('Found %d stamp(s)', numMarkers);
    else
        str = 'No stamps found.';
    end
    teTitle(str); teTitle;
    
    function img = getFrame(t)

        % set movie time
        Screen('SetMovieTimeIndex', m, t);

        % get a frame, convert to image matrix
        tex = Screen('GetMovieImage', w, m);
        if tex ~= -1
            img = Screen('GetImage', tex);
        else
            % no more frames (eof or sof), so return blank image
            img = zeros(h, w, 3);
        end

        % draw to screen
        Screen('DrawTexture', w, tex, [], rect_screen);
        Screen('Close', tex);
        
        % draw timecode
        elap = datestr(t / 86400, 'HH:MM:SS.fff');
        tot = datestr(dur / 86400, 'HH:MM:SS.fff');
        str = sprintf('%s / %s', elap, tot);
        DrawFormattedText(w, str, 'center', 30, [255, 000, 255]);
        
        % flip
        Screen('Flip', w, [], [], 1);
        
    end
    
end

function found = findEdgeMarkers(img)

% define corner markers - these are fairly large on the original screen,
% but since the video may be downscaled by an unknown amount, we will, take
% a relatively small patch at each corner and read the mode colour value

    % corner marker width/height
    w_mrk = 30;
    % gap from edge
    gap = 10;
    % image width, height
    w = size(img, 2) - gap;
    h = size(img, 1) - gap;    
    % rects
    rect_mrk(1:4, 1:4) = [...
        gap,        gap,        w_mrk,      w_mrk       ;...    % top left
        w - w_mrk,  gap,        w,          w_mrk       ;...    % top right
        gap,        h - w_mrk,  w_mrk,      h           ;...    % bottom left
        w - w_mrk,  h - w_mrk,  w,          h           ];      % bottom right
    % colours
    col_mrk(1:4, 1:3) = [...
        255, 000, 000   ;...
        000, 255, 000   ;...
        000, 000, 255   ;...
        255, 255, 255];
    % tolerance when searching for marker
    tol = 60;
    
% loop through each rect and look for markers in image

    numCorners = size(rect_mrk, 1);
    cornerFound = false(numCorners, 1);
    for c = 1:numCorners
        % get patch of image inside rect
        patch = img(rect_mrk(c, 2):rect_mrk(c, 4), rect_mrk(c, 1):rect_mrk(c, 3), :);
        % find mode for each colour channels
        md_r = mode(mode(patch(:, :, 1)));
        md_g = mode(mode(patch(:, :, 2)));
        md_b = mode(mode(patch(:, :, 3)));
        md_rgb = double([md_r, md_g, md_b]);
        % compare to marker colours
        cornerFound(c) = all(abs(md_rgb - col_mrk(c, :)) <= tol);
%         % if not found, don't look at other corners
%         if ~found, break, end
    end
    
    % we define found as at least two corner markers present
    found = sum(cornerFound) >= 3;

end