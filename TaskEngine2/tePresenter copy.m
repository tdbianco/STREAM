% v0.7 BETA
% to-do 
%   -   error checking on destructor
%   -   fix error on closing window
%   -   listeditor: respond to row type change by altering icon
classdef tePresenter < handle

    properties
        % collections
        Paths@teCollection
        Tasks@teCollection
        Stim@teCollection
        Lists@teListCollection
        Tracker@teTracker
        Keyboards@teCollection
        EventRelays@teCollection
        Events@teEventCollection
        % eye tracker
        EyeTracker
        % screen/window-based
        MonoScreenResolution = [600, 338] 
        % utilities
        ShowTestPattern = false
        % et calibration
        ETCalibStartSize = 8
        ETCalibEndSize = .25
        ETCalibDurWait = 1.2
        ETCalibDurShrink = 1.3
        ETCalibDurMeasure = 2
        ETCalibMoveVelocity = 25
        ETCalibMoveSize = 1;
        ETCalibMinValidAccuracyDeg = 2
        ETCalibMinValidPrecisionDeg = 3
        ETCalibBackgroundColour = [255, 255, 255]
        DrawGazeOnMainWindow = false
        DrawETFaceOnMainWindow = false
        DrawCalibOnMainWindow = false
        DrawGazeOnPreview = true
        DrawAOIsOnPreview = true
        DrawEyeTrackerInfoOnPreview = true
        DrawCalibOnPreview = false
        DrawGazeOffscreenMessage = true
        DrawTimingOnPreview = true
        DrawPreviewOnMainWindow = false
        MapMaximumDisplayHeight = 25;
        DisableKeyboardDuringSession = true
        SilentMode = false
        StampVideoOnSessionStart = true
        % messaging
        ExitTrialNow = false
        PauseRequested = false
        CalibRequested = false
        % trial/list
        CurrentVariables = struct
        HandleTrialErrors = true
        % light patch
        LightPatchEnabled = true
        LightPatchSize = [80, 80]
        LightPatchAutoOff = .2
    end
    
    properties (SetAccess = private)
        % lsl
        LSL_Library
        % pause
        Paused = false
%         % posix timestamps offset
%         PosixTimeOffset
    end
    
    properties (Dependent)
        MonitorNumber
        MonitorSize
        MonoScreenMode
        DrawingSize
        DrawingAspectRatio
        SkipSyncTests
        WindowLimitEnabled 
        WindowLimitSize 
        WindowLimitBorderColour
        PreviewInWindow = false
        PreviewMonitorNumber
        PreviewPositionPreset
        PreviewScale
        PTBWindowPtr
%         CameraInWindow = false
%         CameraMonitorNumber
%         CameraPosition
%         CameraResolutionX
%         CameraResolutionY        
        RecordScreen 
        ScreenRecordingScale
        Animating 
        % drawing
        BackColour = [128, 128, 128]
        EyeTrackerPreviewGazeHistory
        % timing
        TimingData
        % eye tracker
        ETDriftGridSize
    end

    properties (Dependent, SetAccess = private)
        % screen/window-based
        WindowPtr
        PreviewWindowPtr
        WindowOpen
        Resolution
        TargetFPS
        TargetFrameTime
        FPS
        FrameTime
        LightPatchStatus
        % scaling
        CmPerPx
        PxPerCm
        % stim
        TexturesInUse
        MoviesInUse
        % task
        CurrentTask
        CurrentTrial
        CurrentTrialGUID
        % log
        Log 
        % keyboard
        ActiveKeyboard        
    end
    
    properties (Access = private)
        % screen/window-based
        ptr
        prMonitorNumber
        prMonitorSize
        prMonoScreenMode = false
        prSkipSyncTests
        prWindowOpen = false
        prPreviewWindowOpen = false
        prWindowPtr
        prPreviewMonitorNumber
        prPreviewOpen = false
        prPreviewPtr
        prPreviewInWindow    
        prPreviewPosition 
        prPreviewPositionPreset = 'bottomright'
        prPreviewScale = .2
        prDrawPaneOpen = false
%         prCameraWindowOpen = false
%         prCameraMonitorNumber
%         prCameraOpen = false
%         prCameraWindowPtr
%         prCameraInWindow    
%         prCameraResolutionX = 600
%         prCameraResolutionY
%         prCameraPosition = [0, 0]
%         prCameraPositionPreset 
        prCameraDeviceID = 0
        prCameraDevicePtr = nan
        prCameraTexturePtr = nan
        prCameraResolutionX = 360
        prCameraResolutionY
%         prCameraTextureTimestamp = nan
        prOldSyncTest = 0
        prWindowLimitEnabled = false
        prWindowLimitSize = [10, 10]
        prDrawPanePtr
        prWindowLimitOpen = false
        prWindowLimitBorderColour = [000, 000, 000]
        prFrameTime
        prAnimating = false
        prPrevVerbosityFlag
        prPreviewTexture
        prETFaceTexture
        prETGazeTexture
        prETCalibTexture
        prTimingTexture
        prLogoTexture
        % drawing
        prDrawBuffer
        prDrawBufferStim
        prDrawBufferIdx = 1
        prPTBBuffer
        prPTBBufferIdx = 1
        prBackColour = [128, 128, 128]
        prEyeTrackerPreviewGazeHistory = .5
        prEyeTrackerPreviewGazeRadius = 30
        prNextFlipDue = []
        prMoviesCurrentlyPlaying
        prETFaceAngle = 0
        % light patch
        prLightPatchStatus = false
        prLightPatchOnset = nan
        % sound
        prSoundDevicePtr
        prSoundBuffer
        prSoundBufferStim
        prSoundBufferIdx = 1
        % session management
        prSessionStarted = false
        prSessionStartTime = nan;
        prListExecutionTime = nan;
        prListExecutionStartSample 
        % screen capture
        prRecordScreen = false
        prCaptureStarted = false
        prCapturePtr
        prCaptureTexturePtr
        prScreenRecordingScale = .5 
        prCaptureRes
        % scaling
        prScalingValid = false
        prCmPerPx
        prPxPerCm
        % log
        prLog = {}
%         prLogTable
        prLogIdx = 1 
        prLogListener
%         prLogBuffer
%         prLogBufferIdx = 1
        % timing
        prTimingBuffer
        prTimingIdx
        prFrame = 0
        % task
        prCurrentTask 
        prCurrentTrial
        prCurrentTrialGUID
        % list editor
        prEditingList = false
        prListEditorTableVP
        % internal stim
        prTexture_ETFace = nan
        prTexture_ETFaceBoth = nan
        prTexture_ETFaceNone = nan
        prTexture_ETFaceLeft = nan
        prTexture_ETFaceRight = nan
        prTexture_ETFaceOutline = nan
        prAR_ETFace 
        % keyboards
        prKeyboardAssignment@teCollection
        prActiveKeyboard = []
        prKB_empty = true
        prKB_pressed
        prKB_firstPress
        prKB_firstRelease
        prKB_lastPress
        prKB_lastRelease
        prQuitRequestLevel = 0
        % eye tracker
        prETDriftGridSize
        prETDriftPoints
        prETCalibDef = [...         % [x, y, validity]
            0.100,  0.100   ;...
            0.900,  0.100   ;...
            0.100,  0.900   ;...
            0.900,  0.900   ;...
            0.500,  0.500   ];    
        prETCalibStatus
        prCalibDebug
    end
    
    properties (Constant)
        % general
        CONST_VERSION_NO = 0.71
        CONST_VERSION_STR = 'Beta'
        CONST_DEF_BUFFER_SIZE = 1e5;
        CONST_DEF_DRAW_BUFFER_SIZE = 1e3;
        CONST_SUPPORTED_STIM_FORMATS = {'PNG', 'TIF', 'TIFF', 'GIF',...
            'JPG', 'JPEG', 'WAV', 'MP3', 'MOV', 'MP4', 'MPEG4', 'AVI',...
            'MKV', 'M4V'}
        CONST_TIMING_VARIABLES = {'Onset', 'Draw', 'CaptureScreen',...
            'Stimuli', 'Housekeeping', 'KB', 'Eyetracker', 'Preview',...
            'FlipOnset', 'StimOnset', 'FlipOffset', 'FrameTime',...
            'Beampos', 'Missed'};
        % paths
        CONST_PATH_ICONS        =...
            fullfile(fileparts(which('tePresenter')), 'assets', 'icons')
        CONST_PATH_ET           =...
            fullfile(fileparts(which('tePresenter')), 'assets', 'eyetracker')
        CONST_PATH_SPLASH       =...
            fullfile(fileparts(which('tePresenter')), 'assets', 'splash.png')
        CONST_PATH_FIXATIONS    =...
            fullfile(fileparts(which('tePresenter')), 'assets', 'fixation')
        CONST_PATH_ATTENTION    =...
            fullfile(fileparts(which('tePresenter')), 'assets', 'attention')
        
        CONST_ETFACE_PREVIEW_SCALE = 0.3
        CONST_TIMING_PREVIEW_W = 700
        CONST_TIMING_PREVIEW_H = 200
        % colours
        COL_BG                  = [128, 128, 128]
        COL_LABEL_BG            = [030, 000, 080]
        COL_LABEL_FG            = [210, 210, 230] 
        COL_LABEL_HIGHLIGHT     = [250, 210, 040]
        COL_ET_LEFT             = [066, 133, 244]
        COL_ET_RIGHT            = [125, 179, 066]
        COL_ET_AVG              = [213, 008, 000]
        COL_ICON_LIST           = [175, 175, 175]
        COL_ICON_TRIAL          = [001, 155, 229]
        COL_ICON_FUNCTION       = [125, 180, 065]
        COL_ICON_ECK            = [240, 147, 000]
        COL_ICON_NESTEDLIST     = [189, 106, 229]
        COL_AOI_LIGHT           = [245, 145, 110]
        COL_AOI_DARK            = [247, 202, 024]
        COL_TE_PURPLE           = [154, 018, 179]
        COL_TE_DARKPURPLE       = [102, 012, 119]
        % keyboard shortcuts
        KB_ATTGRAB_A            =   'a'         % aud attention getter
        KB_ATTGRAB_V            =   'v'         % vis attention getter
        KB_ATT                  =   'UpArrow'   % participant inattentive
        KB_INATT                =   'DownArrow' % participant inattentive
        KB_PAUSE                =   'p'
        KB_MOVEON               =   'Tab'
        KB_MOVEBACK             =   'ESCAPE'
        KB_QUIT                 =   'q'
        KB_ET_RECALIBRATE       =   'r'
        KB_TASK_BACK             =   '-_'
        KB_TASK_FORWARD          =   '=+'
    end
    
    methods
        
      % constructor
        function obj = tePresenter(varargin)
            
        % display title and version
        
            teTitle('\n\tTask Engine\n\tVersion %s (%s)\n',...
                num2str(obj.CONST_VERSION_NO), obj.CONST_VERSION_STR);
            teLine;
            
            % splash screen
            figSplash = SplashScreen('Task Engine 2', obj.CONST_PATH_SPLASH,...
                'ProgressBar', 'on', 'ProgressRatio', 0);
            
        % init eye tracker - note this won't do anything useful unless it
        % is overwritten with a subclass (such as teEyeTracker_tobii)
        
            obj.EyeTracker = teEyeTracker;
            
%         % calculate offset to convert teGetSecs timestamps to Posix time
%         
%             obj.UpdatePosixOffset;
            
        % init log
        
            % listener
            addlistener(obj.EyeTracker, 'AddLog',...
                @obj.Log_listener);
            % storage
            obj.prLog = cell(obj.CONST_DEF_BUFFER_SIZE, 1);
            
            % startup message
            obj.AddLog('data', 'Task Engine starting up',...
                'source', 'presenter', 'topic', 'housekeeping');
            
            % init collections
            obj.Paths                           = teCollection('char');
            obj.Paths.StoreItemsAsDynamicProperties = true;
            obj.Tasks                           = teCollection('teTask');
            obj.Tasks.ChildProps                = {'Functions'};
            obj.Tasks.ReturnKeyAsNameProp       = true;
            obj.Stim                            = teCollection('teStim');
            obj.Stim.ChildProps                 = { 'Task',...
                                                    'Type',...
                                                    'isMovie',...
                                                    'isSound',...
                                                    'Playing',...
                                                    'NeedsTimestamp'...
                                                   };
            obj.Stim.ReturnKeyAsNameProp        = true;
            obj.Lists                           = teListCollection;
            obj.Keyboards                       = teCollection('struct');
            obj.EventRelays                     = teCollection('teEventRelay');
            obj.Events                          = teEventCollection;
            
            % init standard events
            obj.Events('SYNC')                      = struct('eeg', 247);
            obj.Events('SKIPPED')                   = struct('eeg', 248);
            obj.Events('ATTENTION_GETTER_AUDITORY') = struct('eeg', 249);
            obj.Events('ATTENTION_GETTER_VISUAL')   = struct('eeg', 250);            
            obj.Events('PAUSE_ONSET')               = struct('eeg', 251);
            obj.Events('PAUSE_OFFSET')              = struct('eeg', 252);
            obj.Events('GC_FIXATION_ONSET')         = struct('eeg', 253);
            obj.Events('GC_FIXATION_OFFSET')        = struct('eeg', 254);
            
        % process registry (if one has been passed)
        
            isReg = find(cellfun(@(x) isa(x, 'teRegistry'), varargin));
            if length(isReg) == 1
                % registry found
                reg = varargin{isReg};
                obj.ImportFromRegistry(reg)
            elseif length(isReg) > 1
                error('More than one teRegistry instance was passed to tePresenter. This is not supported.')
            end
            
        % check dependencies 
        
            % check Psychtoolbox is installed
            AssertOpenGL
            
            % check that lmtools is in the path
            if ~exist('Assertlmtools', 'file')
                delete(figSplash)
                error('lmtools package not found in the Matlab path.')
            end
            
            % check that lab streaming layer is in the path
            if ~exist('lsl_loadlib', 'file')
                delete(figSplash)
                error('Lab streaming layer (specifically lsl_loadlib.m) not found in the Matlab path.')
            end
            % load the lsl library
            obj.LSL_Library = lsl_loadlib;
            teEcho('Loaded the Lab Streaming Layer library.\n');
            
            % check that zxing can be found
            try
                path_te = fileparts(which('tePresenter'));
                javaaddpath(fullfile(path_te, 'zxing/core-3.3.3.jar'))
                javaaddpath(fullfile(path_te, 'zxing/javase-3.3.3.jar'))   
                addpath(fullfile(path_te, 'zxing'))
            catch ERR_zxing
                error('Error loading zxing library, error was:\n\n%s',...
                    ERR_zxing.message)
            end
            
        % set up event relays

            myPath = which('tePresenter');
            [myPath, ~, ~] = fileparts(myPath);
            relayPath = fullfile(myPath, 'event_relays');
            addpath(relayPath);
 
        % init PTB graphics
        
            % set verbosity to none
            obj.prPrevVerbosityFlag  = Screen('Preference',...
                'Verbosity', 0);
            % use PTB text plugin
            Screen('Preference','TextRenderer', 1);
            % init draw buffer
            obj.prDrawBuffer = nan(obj.CONST_DEF_DRAW_BUFFER_SIZE, 7);
            obj.prDrawBufferStim = cell(obj.CONST_DEF_DRAW_BUFFER_SIZE, 1);
            obj.prDrawBufferIdx = 1;
            % init PTB buffer
            obj.prPTBBuffer = cell(obj.CONST_DEF_DRAW_BUFFER_SIZE, 1);
            obj.prPTBBufferIdx = 1;
            % load internal stimuli
            isChar = cellfun(@ischar, varargin);
            varargin_char = varargin(isChar);
            if ismember('infant', varargin_char)
                obj.loadInternalStim('infant')
            else
                obj.loadInternalStim('adult')
            end            
            % default monitor number to max screens - ensures laptop screen
            % is not chosen by default if a better alternative is available
            screens = Screen('Screens');
            obj.prMonitorNumber = max(screens);
            if max(screens) == 0
                % only one screen, force mono screen mode
                obj.prMonoScreenMode = true;
                obj.prPreviewInWindow = true;
            end
            % preview window is by default the first screen
            obj.prPreviewMonitorNumber = 0;
            
        % keyboards
            
            obj.InitialiseKeyboards
            
        % timing

            obj.prTimingBuffer = nan(obj.CONST_DEF_BUFFER_SIZE,...
                length(obj.CONST_TIMING_VARIABLES));
            obj.prTimingIdx = 1;
            
        % init tracker
        
            obj.Tracker = teTracker;
            addlistener(obj.Tracker, 'ResumeSession', @obj.LoadFromTracker);
%             % init sounds
%             InitializePsychSound;
%             obj.prSoundDevicePtr =...
%                 PsychPortAudio('Open', [], [], 1, 48000, 2);
            
            % init ET drift measurement grid
            obj.ETDriftGridSize = [12, 12];
            
            obj.AddLog('data', 'Task Engine ready',...
                'source', 'presenter', 'topic', 'housekeeping');   
            
            delete(figSplash)
            
        end
        
        function Shutdown(obj)
            % shutdown message
            teEcho('Task Engine shutting down...\n');
            
            % if shutdown has already been called, the obj (the presenter
            % instance) will be invalid, in which case none of this is
            % necessary
            if isvalid(obj)
            
                % close stim
                try
                    for s = 1:obj.Stim.Count
                        switch lower(obj.Stim(s).Type)
                            case 'image'
                            case 'movie'
                                if obj.Stim(s).Playing
                                    obj.StopStim(obj.Stim(s))
                                end
                                if obj.Stim(s).Prepared
                                    obj.CloseStim(obj.Stim(s))
                                end
        %                             obj.Echo('Closing %s...\n', obj.Stim.Keys{s})
        %                             Screen('CloseMovie', obj.Stim(s).MoviePtr);
        %                             obj.Stim(s).Close
        %                         end
                            case 'sound'
                            otherwise
                                warning('Closing stim type %s not yet implemented.',...
                                    obj.Stim(s).Type)
                        end
                    end
                catch ERR
                    switch ERR.identifier
                        case 'MATLAB:class:InvalidHandle'
                        otherwise
                            rethrow(ERR)
                    end
                end

                % stop animating
                if obj.prAnimating
                    obj.Animating = false;
                end

                % end session
                if obj.prSessionStarted
                    obj.EndSession
                end

                % close screen
                if obj.prWindowOpen
                    obj.CloseWindow
                end

                % delete log listener
                delete(obj.prLogListener)

                % stop eye tracker
                obj.EyeTracker.Disconnect
                delete(obj.EyeTracker)
    %             clear obj.EyeTracker

                % clear collections etc.
                delete(obj.Stim)
                delete(obj.Lists)
                cellfun(@delete, obj.Log)
                delete(obj.Tasks)
                
                % delete lsl library
                obj.LSL_Library = [];

    %             clear obj.Stim
    %             clear obj.Lists
    %             clear obj.Log
    %             clear obj.Tasks



                % restore previous value of PTB sync tests
                if ~isempty(obj.prOldSyncTest)
                    Screen('Preference', 'SkipSyncTests', obj.prOldSyncTest);
                end

                % restore previous verbosity setting
                if ~isempty(obj.prPrevVerbosityFlag)
                    Screen('Preference', 'Verbosity',...
                        obj.prPrevVerbosityFlag);
                end
                
            end
            
            % close any remaining PTB assets
            Screen('CloseAll')
                        
            teEcho('Task Engine shut down.\n');
            
            delete(obj)
            
%             catch ERR
% 
%                 disp(ERR.message)
%                 
%             end
        end
        
        function LoadFromTracker(obj, ~, ~, ~)
        % loads log and lists from the tracker, and replaces log and lists
        % currently in memory
            
            if ~obj.Tracker.Valid
                error('Cannot load list from a tracker in an invalid state.')
            end
            
            % load lists and log from the tracker we're resuming from
            obj.Lists = obj.Tracker.Lists;
            obj.prLog = obj.Tracker.Log;
            obj.prLogIdx = size(obj.prLog, 1) + 1;
            
            % pull eye tracking data from tracker (if available) and pass
            % to the eye tracking class to store it in the buffer
            if ~isempty(obj.Tracker.prPreviousSessionEyeTracking)
                obj.EyeTracker.ReceiveGazeFromResumedSession(...
                    obj.Tracker.prPreviousSessionEyeTracking.eyetracker.Buffer);
            end
            
            % flush buffers to ensure enough log buffer headroom
            obj.FlushBuffer
            
        end
        
        % drawing
        function [flipTime, flipTimeLocal] = RefreshDisplay(obj, varargin)
            if ~obj.prWindowOpen
                error('Window must be open.')
            end
            % check for input flags
            doKeyUodate = ~ismember('noKeyUpdate', varargin);
            % record onset of frame
            tm = nan(1, length(obj.CONST_TIMING_VARIABLES));
            tm(1) = teGetSecs * 1000;
            % check for in-progress async flip
%             obj.AddLog('topic', 'debug', 'data', 'Waiting for previous async flip to end')
            Screen('AsyncFlipEnd', obj.prWindowPtr);
            
            % if light patch has been on for longer than LightPathAutoOff
            % then set it to off
            if obj.LightPatchStatus &&...
                    teGetSecs - obj.prLightPatchOnset > obj.LightPatchAutoOff
                obj.prLightPatchStatus = false;
            end            
            
%             obj.AddLog('topic', 'debug', 'data', 'Finished waiting for previous async flip')
            % draw buffer
            obj.Draw
%             obj.AddLog('topic', 'debug', 'data', 'Called Draw method')
            tm(2) = teGetSecs * 1000;
            
            
            % flip
            Screen('AsyncFlipBegin', obj.prWindowPtr, 0, [], 0);  
%             obj.AddLog('topic', 'debug', 'data', 'Async flip begin on main window')
            Screen('AsyncFlipBegin', obj.prPreviewPtr, 0, [], 0);     
%             obj.AddLog('topic', 'debug', 'data', 'Async flip begin on preview window')                 
            

            
            % capture screen
            if obj.prRecordScreen && obj.prCaptureStarted
                Screen('DrawTexture', obj.prCaptureTexturePtr, obj.ptr,...
                    [0, 0, obj.Resolution], [0, 0, obj.prCaptureRes]);
                Screen('AddFrameToMovie', obj.prCaptureTexturePtr);
            end      
            tm(3) = teGetSecs * 1000;            
            % stimuli
            obj.UpdateStimuli
%             obj.AddLog('topic', 'debug', 'data', 'Updated stimuli')
            tm(4) = teGetSecs * 1000;
            % housekeeping
            obj.DoHousekeeping
%             obj.AddLog('topic', 'debug', 'data', 'Finished housekeeping')
            tm(5) =  teGetSecs * 1000;
            % keyboard
            if doKeyUodate, obj.KeyUpdate, end
%             obj.AddLog('topic', 'debug', 'data', 'Updated keyboard')
            tm(6) =  teGetSecs * 1000;
            % eye tracker
            obj.UpdateEyeTracker
%             obj.AddLog('topic', 'debug', 'data', 'Updated eye tracker')
            tm(7) =  teGetSecs * 1000;
            % draw preview
            obj.UpdatePreview
%             obj.AddLog('topic', 'debug', 'data', 'Updated preview')
            tm(8) =  teGetSecs * 1000;               
            % clear drawing pane
            Screen('FillRect', obj.ptr, obj.prBackColour);    
%             obj.AddLog('topic', 'debug', 'data', 'Cleared drawing pane')
            
            
       
            
            
            
            % wait for flip end
%             obj.AddLog('topic', 'debug', 'data', 'Begin waiting for async flip end (main window)')
            [tm(9), tm(10), tm(11), tm(12), tm(13)] = Screen('AsyncFlipEnd',...
                obj.prWindowPtr);
%             obj.AddLog('topic', 'debug', 'data', 'Finished waiting for async flip to end (main window)')
            % convert flip timestamps to posix
            flipTimeLocal = tm(9);
            tm(9:13) = teGetSecs(tm(9:13));
            flipTime = tm(9);
            % give timestamps to stim in the draw buffer
            if obj.prDrawBufferIdx > 1
                for s = 1:obj.prDrawBufferIdx - 1
                    obj.prDrawBufferStim{s}.DrawnTimestamp = tm(9);
                    % if this was a movie, log a frame time
                    if obj.prDrawBufferStim{s}.isMovie &&...
                            obj.prDrawBufferStim{s}.gotNewFrame
                        
                        movFrameTimeLog.Timestamp   = tm(9);
                        movFrameTimeLog.Source      = obj.prDrawBufferStim{s}.Name;
                        movFrameTimeLog.Topic       = 'movie_frame_time';
                        movFrameTimeLog.MovieTime   =...
                            obj.prDrawBufferStim{s}.CurrentTime;
                        obj.AddLog(movFrameTimeLog);
                        
                    end
                end
                % clear buffer
                obj.prDrawBufferIdx = 1;
            end            
            % if using window limits, draw the window limit drawing pane to
            % the main window
            if obj.prWindowLimitEnabled
                % draw borders
                Screen('FillRect', obj.prWindowPtr,...
                    obj.WindowLimitBorderColour);
            end            
            % store timing
            if obj.prAnimating
                % convert flip timestamps from s to ms
                tm(9:11) = tm(9:11) * 1000;
                % calciulate frametime
                if obj.prTimingIdx > 1
                    lastFlipTime = obj.prTimingBuffer(obj.prTimingIdx - 1, 10);
                    tm(12) = tm(10) - lastFlipTime;
                else
                    tm(12) = nan;
                end
                % store
                obj.prTimingBuffer(obj.prTimingIdx, :) = tm;
                obj.prTimingIdx = obj.prTimingIdx + 1;
                curSize = size(obj.prTimingBuffer, 1);
                if obj.prTimingIdx > curSize
                    newSize = curSize + obj.CONST_DEF_BUFFER_SIZE;
                    obj.prTimingBuffer(newSize, 1) = nan;
                    obj.AddLog(...
                        'source', 'presenter', 'topic', 'buffering', 'data',...
                        sprintf('Buffer Timing increased to %d', newSize));
                end
                obj.prFrame = obj.prFrame + 1;
            end
            
            % wait for preview flip end
%             obj.AddLog('topic', 'debug', 'data', 'Waiting for previous async flip to end (preview)')
            Screen('AsyncFlipEnd', obj.prPreviewPtr);
%             obj.AddLog('topic', 'debug', 'data', 'Finished waiting for previous async flip to end (preview)')
        end
        
        function Draw(obj)
            
            % process draw buffer - here we loop through each of the
            % textures that have been added to the draw buffer since the
            % last refresh. We reshape the data to fit PTB format, then
            % execute one DrawTextures commands, drawing all textures at
            % once
            if obj.prDrawBufferIdx > 1
                buf = obj.prDrawBuffer(1:obj.prDrawBufferIdx - 1, :);
%                 % reshape
%                 texPtr      = buf(:, 1)';
%                 rect        = buf(:, 2:5)';
%                 angle       = buf(:, 6)';
%                 alpha       = buf(:, 7)';
%                 % draw
%                 Screen('DrawTextures', obj.ptr, texPtr, [], rect,...
%                     angle, [], alpha);
%                 
                
                numTextures = obj.prDrawBufferIdx - 1;
                for t = 1:numTextures
                    Screen('DrawTexture', obj.ptr, buf(t, 1), [], buf(t, 2:5), buf(t, 6), [], buf(t, 7));
                end
            end
            
            % process PTB buffer - intended to send PTB commands at draw
            % time, currently not used and untested
            if obj.prPTBBufferIdx > 1
                warning('PTB Buffer is untested!')
                for i = 1:obj.prPTBBufferIdx - 1
                    Screen(obj.prPTBBuffer{i}{:});
                end
            end
            obj.prPTBBufferIdx = 1;
            
            % optionally draw light patch to main window
            if obj.LightPatchStatus
                obj.DrawLightPatch
            end
            
%             % process sound buffer
%             if obj.prSoundBufferIdx > 1
%                 warning('Short sound playback is untested!')
%                 for s = 1:obj.prSoundBufferIdx
%                     stim = obj.prSoundBufferStim{s};
%                     PsychPortAudio('FillBuffer', obj.prSoundDevicePtr,...
%                         stim.SoundBufferPtr);
%                     PsychPortAudio('Start', obj.prSoundDevicePtr)
%                 end
%             end
            
            % copy draw pane to main window. All stimuli are now drawn to
            % the main window. The only drawing that happens now is copying
            % Task Engine layers to either the preview, or the main window.
            Screen('DrawTexture', obj.prWindowPtr, obj.ptr)         
            
            % optionally draw preview to main window
            if obj.DrawPreviewOnMainWindow 
                Screen('DrawTexture', obj.prWindowPtr, obj.prPreviewTexture);
            end
            
            % optionally draw et face to main window
            if obj.DrawETFaceOnMainWindow
                Screen('DrawTexture', obj.prWindowPtr, obj.prETFaceTexture);
            end            
            
            % optionally draw calib to main window, and/or preview. Both
            % are optional
            if obj.DrawCalibOnMainWindow
                % draw to main window
                Screen('DrawTexture', obj.prWindowPtr, obj.prETCalibTexture);
            end               

            % optionally draw gaze on main window
            if obj.DrawGazeOnMainWindow
                Screen('DrawTexture', obj.prWindowPtr, obj.prETGazeTexture);
            end            
          
            % tell PTB that no more drawing will happen to the main window
            Screen('DrawingFinished', obj.prWindowPtr);    
            
            % clear overlays
            obj.ClearTexture(obj.prETFaceTexture);
            obj.ClearTexture(obj.prETGazeTexture);          
            obj.ClearTexture(obj.prTimingTexture);  
            
            % copy preview texture from previous frame to preview window
            Screen('DrawTexture', obj.prPreviewPtr, obj.prPreviewTexture)
            
            % set preview texture to have same background colour as main
            % window
            Screen('FillRect', obj.prPreviewTexture, obj.BackColour);
            
        end
        
        function DrawLightPatch(obj)
        % first check that the light patch is enabled. If not, then throw a
        % warning and exit. Otherwise, check whether the light patch is on.
        % If not, exit, otherwise draw it. 
        % To draw it we first find the corner of the screen and work out a
        % rect based on the LightPatchSize property. Then use FillRect to
        % draw a white patch at that location. Note that this function
        % draws to the offscreen window containing the stimuli, so the
        % light patch will appear (albeit one frame behind) on the preview
        % window, too. This is by design, so that an experimenter can check
        % that the patch is being drawn. 
        
            % check enabled and status
            if ~obj.LightPatchEnabled
                return
            end
            
            % determine colour of light patch (white or black) depending
            % upon status
            if obj.LightPatchStatus
                col = [255, 255, 255];
            else
                col = [000, 000, 000];
            end
            
        % calculate rect for drawing
        
            % get screen dimensions
            w = obj.Resolution(1);
            h = obj.Resolution(2);
            
            % get patch size
            pw = obj.LightPatchSize(1);
            ph = obj.LightPatchSize(2);
            
            % make rect
            rect = [0, h - ph, pw, h];
            
        % draw
        
            Screen('FillRect', obj.ptr, col, rect)
            
        end
        
        function UpdateStimuli(obj)
        % perform any updates for currently playing stimuli
        
            % update frames for playing movies. First we get a logical
            % vector representing which movie stimuli are currently
            % playing. We then loop through and update all relevant
            % stimuli.
            needsFrame = find(cell2mat(obj.Stim.Playing) &...
                cell2mat(obj.Stim.isMovie));
            for s = 1:length(needsFrame)
                obj.UpdateMovieStimulus(obj.Stim.Items(needsFrame(s)));
            end
            
            % update time index for sounds
            needsTimeIndex = find(cell2mat(obj.Stim.Playing) &...
                cell2mat(obj.Stim.isSound));
            for s = 1:length(needsTimeIndex)
                obj.UpdateSoundStimulus(obj.Stim.Items(needsTimeIndex(s)));
            end
            
        end
        
        function UpdateMovieStimulus(obj, stim)
            % provides updates to any movie stimulus. We call PTB to get a
            % new frame from gstreamer. If that frame was valid, we delete
            % texture holding the previous frame, and update the teStim
            % instance with: 1) the texture pointer of the current frame;
            % 2) the current movie time; and 3) the LastTouched property. 
            %
            % If the returned texture pointer is -1, this indicates EOF and
            % the teStim is stopped.
            if ~isa(stim, 'teStim')
                error('''stim'' must be a teStim instance.')
            end
            
            % get frame
            [texPtr, movTime] =...
                Screen('GetMovieImage', obj.prWindowPtr,...
                stim.MoviePtr, 0);            
            
            % check that a frame was returned
            if texPtr == 0
            % no frame returned, because we're checking faster than the
            % video's framerate
                stim.gotNewFrame = false;
                
            elseif texPtr > 0
            % new frame returned
            
                % delete last texture (if present)
                if ~isnan(stim.TexturePtr) && stim.TexturePtr > 0
                    Screen('Close', stim.TexturePtr);
                end                        
                % save new texture ptr to stim object
                stim.TexturePtr = texPtr;
                stim.CurrentTime = movTime;
                % tell stim that it got a new frame
                stim.gotNewFrame = true;
                % update last touched time
                stim.LastTouched = teGetSecs;
                
            elseif texPtr == -1
            % EOF
                
                % movie finished
                obj.StopStim(stim)
                stim.gotNewFrame = false;
                
            end
        end
        
        function UpdateSoundStimulus(~, stim)
        % updates currently playing sound stimulus. Gets the current time
        % position from PTB and sets the teStim's prCurrentTime property
        
            % check stim type
            if ~isa(stim, 'teStim')
                error('''stim'' must be a teStim instance.')
            end
            if ~stim.isSound
                error('''stim'' must have a type of ''sound''.')
            end
            
            % get time from ptb
            stim.CurrentTime = Screen('GetMovieTimeIndex', stim.SoundPtr);
            
        end
            
        function DoHousekeeping(obj)
            % if ShowTestPattern is enabled, draw it now
            if obj.ShowTestPattern
                obj.DrawTestPattern
            end
        end
        
        function UpdateEyeTracker(obj)
            % here we perform all update tasks related to the eye tracker.
            % The first of these is to get the most recent gaze data from
            % the teEyeTracker class by calling it's Update method. We then
            % use the data in the teEyeTracker to draw gaze, AOIs, and the
            % et face textures. 
            
            % if eye tracker is not in a valid state, return. This mostly
            % happens in non-ET paradigms
            if ~obj.EyeTracker.Valid, return, end
            
            % get gaze data, update AOIs
            obj.EyeTracker.Update

            % now use the latest gaze to draw eye tracking information to
            % a texture (a task enging layer). 
            % AOIs
            obj.DrawAOIs
            % gaze and ET face
            obj.DrawGaze 
        end
        
        function DrawAOIs(obj)
            % extract AOI data and draw it to the ETGazeTexture. First pull
            % the AOI coords from the teEyeTracker instance, reshape,
            % select colours and draw to the texture. AOIs are drawn as an
            % outline, which is gradually filled in from the bottom to
            % represent the proportion looking time to that AOI. Finally
            % each AOI is labelled with its name and the proportion
            % looking time. This final text pass is slow, so may need to be
            % removed in case of timing difficulties. 
            
            % skip if: 
            %   1) DrawAOIsOnPreview flag is false
            %   2) There is no gaze data
            %   3) No AOIs are defined
            if ~obj.DrawAOIsOnPreview || ~obj.EyeTracker.HasGaze ||...
                    obj.EyeTracker.AOIs.Count == 0
                return
            end
            
            % get AOI data
            aoi_tab         = obj.EyeTracker.AOITable;
            numAOIs         = size(aoi_tab, 1);
            aoi_name        = obj.EyeTracker.AOIs.Keys;
            aoi_rect        = aoi_tab(:, 2:5);
            aoi_prop        = aoi_tab(:, 6);
            aoi_rect_px     = obj.ScaleRect(aoi_rect, 'rel2px');
            
            % fill rect to visualise proportion looking time
            aoi_h           = (aoi_rect_px(:, 4) - aoi_rect_px(:, 2)) .*...
                            (1 - aoi_prop);
            aoi_mult        = [...
                            aoi_rect_px(:, 1),...
                            aoi_rect_px(:, 2) + aoi_h,...
                            aoi_rect_px(:, 3),...
                            aoi_rect_px(:, 4)];
                        
            % get colours
            col_lt          = obj.COL_AOI_LIGHT;
            col_dk          = obj.COL_AOI_DARK;
            
            % reshape for PTB
            aoi_frame       = aoi_rect_px';
            aoi_fill        = aoi_mult';
            
            % draw AOIs
            Screen('FrameRect', obj.prETGazeTexture,... % outine
                [col_dk, 225], aoi_frame, 5)
            Screen('FillRect', obj.prETGazeTexture,...  % fill
                [col_lt, 100], aoi_fill)
            
            % label AOIs. Skip this if an async flip is in operation, as
            % Screen('DrawText') can throw errors otherwise
%             if Screen('AsyncFlipCheckEnd', obj.prWindowPtr) ~= 0                
                for a = 1:numAOIs
                    % prepare AOI name and proportion of gaze
                    aoi_str = sprintf('%s [%.2f]', aoi_name{a}, aoi_prop(a));
%                     % draw text
                    Screen('DrawText', obj.prETGazeTexture, aoi_str,...
                        aoi_rect_px(a, 1) + 8, aoi_rect_px(a, 2) + 8, col_dk);
                end
%             end
        end
        
        function DrawGaze(obj)
            res = obj.Resolution;
            % draw gaze
            t2 = teGetSecs;
            t1 = t2 - obj.prEyeTrackerPreviewGazeHistory;
            gaze = obj.EyeTracker.GetGaze(t1, t2);
            if isempty(gaze), return, end
            numSamps = size(gaze, 1);
            % alpha increment 
            alphaInc = 255 / numSamps;
            % compute alpha values
            a_range = (0:alphaInc:255)';
            if length(a_range) > numSamps
                a_range = a_range(1:numSamps);
            end                    
            % get eye validity
            val_l = gaze(:, 4);
            val_r = gaze(:, 19);
            val = val_l | val_r; 
            % convert POG to px
            if any(val)
                % if any eyes are valid
                gx_l = gaze(:, 2);
                gy_l = gaze(:, 3);
                gx_r = gaze(:, 17);
                gy_r = gaze(:, 18);
                % determine if gaze is offscreen
                gazeOffscreen_l = all(gx_l < 0 | gx_l > 1 |...
                    gy_l < 0 | gy_l > 1);
                gazeOffscreen_r = all(gx_r < 0 | gx_r > 1 |...
                    gy_r < 0 | gy_r > 1);
                gazeOffscreen = gazeOffscreen_l && gazeOffscreen_r;
                % scale gaze to pixels
                gx_l = round(gx_l * res(1));
                gy_l = round(gy_l * res(2));
                gx_r = round(gx_r * res(1));
                gy_r = round(gy_r * res(2));                
                % average by taking available eyes, or mean of
                % both if both visible
                gx_a = nan(numSamps, 1);
                gy_a = nan(numSamps, 1);
                gx_a(val) =...
                    round(nanmean([gx_l(val), gx_r(val)], 2));
                gy_a(val) =...
                    round(nanmean([gy_l(val), gy_r(val)], 2));;
                % dot radius
                radius = obj.prEyeTrackerPreviewGazeRadius;
                % make non valid samples invisible by setting
                % their alpha value to 0 (their position is
                % NaN)
                a_range(~val_l & ~val_r) = 0;
                % reshape dots into row vector for PTB
                dots = [gx_l', gx_r', gx_a'; gy_l', gy_r', gy_a'];
                % colour dots according to eye, setting alpha
                % to fade out over time
                col = [...
                    repmat(obj.COL_ET_LEFT, numSamps, 1), a_range;...
                    repmat(obj.COL_ET_RIGHT, numSamps, 1), a_range;...
                    repmat(obj.COL_ET_AVG, numSamps, 1), a_range];                               
                % draw
                Screen('DrawDots', obj.prETGazeTexture, dots, radius,...
                    col', [], 1);   
            end
            
        % if both eyes are missing, or if both eyes are off-screen,
        % then optionally display a message about this. 
        
            % gazeOffscreen was calculated earlier, assuming there was some
            % gaze data. Update it now with a logical OR, so that we
            % present the message if there is no gaze data, or if the gaze
            % is offscreen
            gazeOffscreen = ~any(val) || gazeOffscreen;
            if gazeOffscreen && obj.DrawGazeOffscreenMessage
                
                msg = 'NOT LOOKING';
                
                % find centre of texture
                cx = obj.Resolution(1) / 2;
                cy = obj.Resolution(2) / 2;
                
                % set font size
                oldFontSize = Screen('TextSize', obj.prETGazeTexture, 64);
                
                % get bounds of text box
                tb = Screen('TextBounds', obj.prETGazeTexture, msg, 0, 0);
                
                % centre text box in texture
                tb = teCentreRect(tb, [0, 0, obj.Resolution]);
                
                % draw red background
                Screen('FillRect', obj.prETGazeTexture, [200, 000, 000, 180]);
                
                % draw text, shadow first, then overlay
                Screen('DrawText', obj.prETGazeTexture, msg, tb(1) + 1, tb(2) + 1,...
                    [000, 000, 000, 255], [000, 000, 000, 000]);
                Screen('DrawText', obj.prETGazeTexture, msg, tb(1), tb(2),...
                    obj.COL_LABEL_FG, [000, 000, 000, 000]);
                
                % draw frame, again with a shadow
                rect_frame = tb + [-20, -20, 20, 20];
                Screen('FrameRect', obj.prETGazeTexture,...
                    [000, 000, 000], rect_frame + 1, 3);
                Screen('FrameRect', obj.prETGazeTexture,...
                    obj.COL_LABEL_FG, rect_frame, 3);
                
                % restore font size
                Screen('TextSize', obj.prETGazeTexture, oldFontSize);
                
            end
            
            % draw et face
            % get x, y, z pos of each eye
            x1 = nanmean(gaze(:, 13));
            y1 = nanmean(gaze(:, 14));
            x2 = nanmean(gaze(:, 28));
            y2 = nanmean(gaze(:, 29));
            z1 = nanmean(gaze(:, 15));
            z2 = nanmean(gaze(:, 30));                        
            % average x, y, to get centre of eyes
            x = 1 - nanmean([x1, x2]);
            y = nanmean([y1, y2]);                        
            % average eyes on z axis, relative to centre of
            % track box 
            z  = 0.5 + nanmean([z1, z2]);
            % calculate angle vectors for head angle against 90
            % degree plane
            v1 = [x2 - x1, y2 - y1];
            v2 = [1, 0];
            % compute angle
            angle = 180 + atan2d(det([v1;v2]),dot(v1,v2));
            % process validity
            if ~val_l(end) && ~val_r(end)
                % no eyes
                angle = obj.prETFaceAngle;
                f_tex_win = obj.prTexture_ETFaceNone;
            elseif ~val_l(end) && val_r(end)
                % right eye
                angle = obj.prETFaceAngle;
                f_tex_win = obj.prTexture_ETFaceRight;
            elseif val_l(end) && ~val_r(end)
                % left eye
                angle = obj.prETFaceAngle;
                f_tex_win = obj.prTexture_ETFaceLeft;
            else
                f_tex_win = obj.prTexture_ETFaceBoth;
            end 
            obj.prETFaceAngle = angle;
            % make rect for main window. This will be half
            % the height of the screen, scaled by aspect ratio
            rect_main = [0, 0, obj.ScalePoint(obj.DrawingSize, 'cm2px')];
            w_main = rect_main(3);
            h_main = rect_main(4);
            % window: get centre of face, using eye pos
            x_px_win = x * w_main;
            y_px_win = y * h_main;                        
            % define size of face
            f_h_px_win = h_main / 2;                        
            f_w_px_win = (h_main / 2) * obj.prAR_ETFace;
            % make rect
            f_rect_win = round([...
                x_px_win - ((f_w_px_win / z) / 2),...
                y_px_win - ((f_h_px_win / z) / 2)+ (f_h_px_win / 9),...
                x_px_win + ((f_w_px_win / z) / 2),...
                y_px_win + ((f_h_px_win / z) / 2)+ (f_h_px_win / 9)]);
            % set alpha according to mean validity
            f_alpha_win = mean(val_l | val_r);
            % calculate position of outline representing ideal
            % position in centre of track box
            x_ol = 0.5; 
            y_ol = 0.5;
            z_ol = 1;
            % window: get centre of face, using eye pos
            x_px_win_ol = x_ol * w_main;
            y_px_win_ol = y_ol * h_main;                            
            % make rect
            f_rect_win_ol = round([...
                x_px_win_ol - ((f_w_px_win / z_ol) / 2),...
                y_px_win_ol - ((f_h_px_win / z_ol) / 2)+ (f_h_px_win / 9),...
                x_px_win_ol + ((f_w_px_win / z_ol) / 2),...
                y_px_win_ol + ((f_h_px_win / z_ol) / 2)+ (f_h_px_win / 9)]);                                                                   
            % draw et face
            Screen('DrawTexture', obj.prETFaceTexture, f_tex_win,...
                [], f_rect_win, angle, [], f_alpha_win);
            % draw et face outline
            Screen('DrawTexture', obj.prETFaceTexture,...
                obj.prTexture_ETFaceOutline, [], f_rect_win_ol);
        end
        
        function UpdatePreview(obj)  
            
            % copy to preview
            Screen('DrawTexture', obj.prPreviewTexture, obj.ptr); 
            
            % optionally draw calibration to preview
            if obj.DrawCalibOnPreview  
                Screen('DrawTexture', obj.prPreviewTexture,...
                    obj.prETCalibTexture);
            end
            
            % draw gaze on preview
            Screen('DrawTexture', obj.prPreviewTexture, obj.prETGazeTexture)       
            
            % draw face to preview
            res = obj.Resolution;
            rect_et = [0, res(2) * .6, res(1) * .4, res(2)];
            Screen('DrawTexture', obj.prPreviewTexture,...
                obj.prETFaceTexture, [], rect_et);                
                      
            % draw timing
%             col_bg = obj.COL_LABEL_BG;
            col_fg = obj.COL_LABEL_FG;
            % timing - draw frame and label first
            if obj.DrawTimingOnPreview && obj.prTimingIdx ~= 1
                % get width and height
                w_timing = obj.CONST_TIMING_PREVIEW_W;
                h_timing = obj.CONST_TIMING_PREVIEW_H;
                yax_w_tg = 0;
                % rect for graph
                rect_tg = [0, 0, w_timing - yax_w_tg, h_timing];
                Screen('FrameRect', obj.prTimingTexture, [0, 0, 0],...
                    rect_tg + 3, 3)
                Screen('FrameRect', obj.prTimingTexture, col_fg,...
                    rect_tg, 3)

                % draw timing graph
                numFramesBack = 120;                 
                % get number of frames
                f2 = obj.prFrame - 1;
                f1 = obj.prFrame - numFramesBack;
                % correct if out of bounds
                if f2 < 1, f2 = 1; end              
                if f1 < 1, f1 = 1; end
                numFramesNeeded = f2 - f1 + 1;
                % define ft range
                fps_range = [120, 60, 30, 15];
                ft_range = 1000 ./ fps_range;
                % get data
                ft = obj.prTimingBuffer(f1:f2, 12)';
                x = (0:numFramesNeeded - 1) / numFramesNeeded;
                % scale data to graph
                gw = w_timing - yax_w_tg;
                gh = h_timing;
                x = round(x * gw);
                prop = (ft / max(ft_range));
                y = round(prop * gh);
                % colour dots by proportion of target frame time out
                tar_ft = obj.TargetFrameTime * 1000;
                delta = ft - tar_ft;
                delta(delta < 0) = 0;
                colProp = 1 - (delta / tar_ft);
                colProp(colProp > 1) = 1;
                cols = [repmat(200, 1, numFramesNeeded); colProp * 200; colProp * 200];             
                % draw target line
                targY = gh * (tar_ft / max(ft_range));
                Screen('DrawLine', obj.prTimingTexture, [0, 255, 0], 0, targY,...
                    gw, targY, 3);
                str = sprintf('%.1fms', tar_ft);
                Screen('DrawText', obj.prTimingTexture, str,...
                    gw, targY, col_fg);
                % draw
                Screen('DrawDots', obj.prTimingTexture, [x; y], 5, cols);   
                % draw texture to preview
                rect_timingTex = [res(1) - w_timing, res(2) - h_timing,...
                    res(1), res(2)];
                Screen('DrawTexture', obj.prPreviewTexture,...
                    obj.prTimingTexture, [], rect_timingTex)
            end
        end
                    
        function DrawBackColour(obj)
            % check window open
            if ~obj.prWindowOpen
                error('Window must be open.')
            end
            % draw
            Screen('FillRect', obj.ptr, obj.prBackColour);
            Screen('FillRect', obj.prWindowPtr, obj.prBackColour);
        end       
        
        function DrawStim(obj, stimName, rect, angle, alpha, immediate)
            
            % check input args
            if nargin == 1 || isempty(stimName)
                % no stim supplied
                error('Must supply a stimulus name.')
            elseif isa(stimName, 'teStim')
                % object was passed
                stim = stimName;
            elseif ischar(stimName)
                % name was passed - look up stim
                stim = obj.Stim(stimName);
                if isempty(stim)
                    error('Stimulus name %d not found.', stimName)
                end                
            else
                % incorrect argument type
                error('Stimulus name must be char.')
            end
            
            % if not rect supplied, default to full screen and set flag to
            % adjust for screen aspect ratio (later on)
            if nargin <= 2 || isempty(rect)
                rect = [0, 0, obj.DrawingSize];
                adjustForAR = true;
            else
                adjustForAR = false;
            end
            
            % default angle = 0 (no rotation)
            if nargin <= 3 || isempty(angle) || isnan(angle)
                angle = 0;
            end
            
            % default alpha = totaly opqaue
            if nargin <= 4 || isempty(alpha)
                alpha = 255;
            end
            
            % default is to send to draw buffer, but for some layering
            % operations (e.g. text over images), we may want to control
            % the order of drawing more precisely, in which case the
            % immediate input arg bypasses the stim buffer and draws
            % immediately
            if nargin <= 5 || isempty(immediate)
                immediate = false;
            end
            
            % check window open
            if ~obj.WindowOpen
                error('Window not open.')
            end
            
            % check type of stim
            if ~stim.isMovie && ~stim.isImage
                error('Only IMAGE or MOVIE stimuli can be drawn.')
            end
            
            % check if prepared
            if ~stim.isPrepared
%                 fprintf('Prepared stim %s\n', stim.Filename);
                obj.PrepareStim(stim);
            end
            
            % check for valid texture ptr
            if stim.TexturePtr < 1 || isnan(stim.TexturePtr)
                error('Tried to draw an invalid texture!')
            end
            
            % adjust for aspect ratio if drawing fullscreen
            if adjustForAR
                
                % get aspect ratio of stim and screen                
                ar_stim = stim.AspectRatio;
                ar_screen = obj.DrawingAspectRatio;
                
                % set width and height to both needed
                w = [];
                h = [];
                
                % clamp either width or height based upon comparison of
                % screen and stim aspect ratios. If the stim aspect ratio
                % is greater than the screen (i.e. it is wider) then we
                % clamp the width, otherwise (i.e. is it narrower) then we
                % clamp the height
                if ar_stim > ar_screen
                    % clamp width
                    w = obj.DrawingSize(1);
                    
                elseif ar_stim < ar_screen
                    % clamp height
                    h = obj.DrawingSize(2);
                    
                elseif ar_stim == ar_screen
                    % aspect ratio of stim matches exactly the aspect ratio
                    % of the screen, so set the width and height to that of
                    % the screen
                    w = obj.DrawingSize(1);
                    h = obj.DrawingSize(2);
                end
                
                % now look for missing width or height. If found, use the
                % stim aspect ratio to calculate the appropriate value,
                % based upon the dimension that is present
                if isempty(w) && ~isempty(h)
                    % height is clamped, calculate width
                    w = h * ar_stim;
                    
                elseif isempty(h) && ~isempty(w)
                    % width is clamped, calculate height
                    h = w / ar_stim;
                    
                elseif isempty(w) && isempty(h)
                    % both width and height are empty. This shouldn't
                    % happen so throw and error
                    error('Both dimensions (width AND height) missing whilst trying to size against aspect ratio.')
                end
                    
                % build a rect from the width and height, then centre it
                % within the drawing pane (essentially putting black
                % borders around it)
                rect_stim = [0, 0, w, h];
                rect_screen = [0, 0, obj.DrawingSize];
                rect = teCentreRect(rect_stim, rect_screen);
                    
            end
            
            % convert rect from cm to px
            rectPx = obj.ScaleRect(rect, 'cm2px');
            
            % draw
            if immediate
                % draw now
                Screen('DrawTexture', obj.ptr, stim.TexturePtr,...
                    [], rectPx, angle, [], alpha);
            else 
                % add to draw buffer
                obj.prDrawBufferStim{obj.prDrawBufferIdx} = stim;
                obj.prDrawBuffer(obj.prDrawBufferIdx, :) =...
                    [stim.TexturePtr, rectPx, angle, alpha];
                obj.prDrawBufferIdx = obj.prDrawBufferIdx + 1;
            end
        end
        
        function BufferPTB(obj, varargin)
            obj.prPTBBuffer(obj.prPTBBufferIdx) = {varargin};
            obj.prPTBBufferIdx = obj.prPTBBufferIdx + 1;
        end
        
        function ClearTexture(~, texPtr)
            Screen('BlendFunction', texPtr, GL_ONE, GL_ZERO);
            Screen('FillRect', texPtr, [0, 0, 0, 0])
            Screen('BlendFunction', texPtr, GL_SRC_ALPHA,...
                GL_ONE_MINUS_SRC_ALPHA);
        end
        
        function Pause(obj)
        % loop until pause is cancelled, drawing the ET face. If
        % recalibration is requested during a pause, then the presenter is
        % first unpaused, and then calibration happens - so as not to
        % return the user to a paused state after calibration.
            
            % echo, set paused flag, set et face draw flag
            teTitle('PAUSED: Press p to continue...'); teLine;
            obj.Paused = true;
            obj.DrawETFaceOnMainWindow = true;
            
            % loop until unpaused, or an exit or recalib request is made
            while obj.PauseRequested && ~obj.ExitTrialNow &&...
                    ~obj.CalibRequested
                obj.RefreshDisplay;
            end
            
            % turn off et face, unset paused flag
            obj.DrawETFaceOnMainWindow = false;
            obj.Paused = false;
            
            % handle recalib request after pausing
            if obj.CalibRequested
                obj.ETGetEyesAndCalibrate;
                obj.PauseRequested = false;
            end
            
        end
        
        function StampForVideo(obj)
        % stamps a video with time and session information. This is done in
        % three ways: 
        % 
        % 1) each corner of the screen is coloured red, green,
        % blue and white - these markers are used offline to detect the
        % sync point; 
        %
        % 2) draw a QR code to the screen with session
        % information, this is used to identify a video by automatic
        % offline processing; 
        %
        % 3) write session information as text to the screen, this is used
        % for manual idenfitication
        %
        % This is drawn for five seconds, so that offline processing only
        % needs to check every five seconds, then work back to the onset of
        % the corner markers. The timestamp in the QR code and the text
        % will refer to the onset of these markers. 
        
            teEcho('\nStamping video with GUID [%s]...', obj.Tracker.GUID);
        
        % get screen dimensions
            
            w = obj.Resolution(1);
            h = obj.Resolution(2);
        
        % define corner marker rects and colours
            
            % corner marker width/height
            w_mrk = 70;
            % rects
            rect_mrk(1:4, 1:4) = [...
                0,          0,          w_mrk,      w_mrk       ;...    % top left
                w - w_mrk,  0,          w,          w_mrk       ;...    % top right
                0,          h - w_mrk,  w_mrk,      h           ;...    % bottom left
                w - w_mrk,  h - w_mrk,  w,          h           ];      % bottom right
            % colours
            col_mrk(1:4, 1:3) = [...
                255, 000, 000   ;...
                000, 255, 000   ;...
                000, 000, 255   ;...
                255, 255, 255];
            
        % fade screen from black to white
            
            % define keyframes for luminance
            kf = teKeyFrame2;
            kf.Data = [ 0,  000 ;...
                        1,  255 ];
            kf.Duration = 1;
            kf.TimeFormat = 'normalised';
            
            % loop
            onset = teGetSecs;
            while teGetSecs - onset < kf.Duration
                lum = kf.GetValue(teGetSecs - onset);
                Screen('FillRect', obj.prWindowPtr, [lum, lum, lum]);
                Screen('Flip', obj.prWindowPtr);
            end
            
        % calculate future timestamp of when the QR code will be presented.
        % This will be used to schedule the key screen flip. Set it for
        % one second from now (to allow time to make the QR code etc.)
        
            onsetTime = teGetSecs + 1;
            gsOnsetTime = GetSecs + 1;
            
        % prepare details - interrogate the teTracker's private prVariables
        % property. This lists all variables that have been defined in the
        % tracker (this can vary session-to-session). Form here, build a
        % struct with the variable values in them. 
        
            % get tracker vars
            trackerVars = obj.Tracker.prVariables;
            % extract var names
            varNames = trackerVars(:, 1);
            % extract values
            varVals = cellfun(@(x) obj.Tracker.(x), varNames, 'uniform',...
                false);
            % add GUID
            varNames{end + 1} = 'GUID';
            varVals{end + 1} = obj.Tracker.GUID;
            % add datestamp
            varNames{end + 1} = 'Date_Time';
            varVals{end + 1} = datetimeStr;
            % add timestamp
            varNames{end + 1} = 'Task_Engine_Timestamp';
            varVals{end + 1} = sprintf('%.4f', onsetTime);
            
        % make QR code. Do this by serialising the session details struct
        % (which makes uint8) and converting to char. 
        
            % cell array to hold GUID and timestamp
            c{1} = obj.Tracker.GUID;
            c{2} = onsetTime;
            % make char
            msg = sprintf('%s#%.8f', c{:});
            % make QR
            qr = encode_qr(msg, [300, 300]) .* 255;
            % make texture
            tex_qr = Screen('MakeTexture', obj.prWindowPtr, qr);
            % compute dimensions
            cx = w / 2;
            cy = h / 2;
            % find width or height, whichever is shorter
            screenExt = min([w, h]);
            qr_w = round(screenExt * .5);
            rect_qr = [...
                cx - (qr_w / 2),...
                rect_mrk(1, 4),...
                cx + (qr_w / 2),...
                rect_mrk(1, 4) + qr_w];
            
        % format session summary for display. 
        
            % summarise in cell array
            smryCell = cellfun(@(vars, vals)...
                sprintf('%s: %s\n', vars, vals),...
                varNames, varVals, 'uniform', false);
            % convert to string
            smryStr = horzcat(smryCell{:});
            % get text bounds
            textLines = cellfun(@(vars, vals) sprintf('%s%s', vars, vals),...
                varNames, varVals, 'uniform', false);
            bounds = cellfun(@(x) Screen('TextBounds', obj.prWindowPtr, x),...
                textLines, 'uniform', false);
            bounds = vertcat(bounds{:});
            tw = max(bounds(:, 3) - bounds(:, 1));
            % find space to write summary under qr code
            y1 = rect_qr(4);
            y2 = rect_mrk(4, 2);
            rect_str = [...
                cx - (tw / 2),...
                y1,...
                cx + (tw / 2),...
                y2];
            
        % draw
        
            % black background
            Screen('FillRect', obj.prWindowPtr, [000, 000, 000]);
            % corner markers
            Screen('FillRect', obj.prWindowPtr, col_mrk', rect_mrk');
            % qr
            Screen('DrawTexture', obj.prWindowPtr, tex_qr, [], rect_qr, [], 0);
            % text
            old_fontSize = Screen('TextSize', obj.prWindowPtr, 26);
            old_fontName = Screen('TextFont', obj.prWindowPtr, 'menlo');
            DrawFormattedText(obj.prWindowPtr, smryStr, rect_str(1), 'center',...
                [255, 255, 255], [], [], [], [], [], rect_str);
            Screen('TextSize', obj.prWindowPtr, old_fontSize);
            Screen('TextFont', obj.prWindowPtr, old_fontName);
            % refresh
            [~, flipTime] = Screen('Flip', obj.prWindowPtr, gsOnsetTime);
            % send marker
            obj.SendRegisteredEvent('SYNC', teGetSecs(flipTime));
            
        % hold for 5s
            
            WaitSecs(5);
            teEcho('done.\n');
            
            % blank screen
            obj.RefreshDisplay;
            
        end
            
        % scaling
        function scaled = ScaleValue(obj, vals, operation)
            % scale a single value 
            if ~isnumeric(vals) || ~isvector(vals)
                error('Coords value must be numeric and scalar or vector.')
            end
            % for operations that require knowledge of monitor size, throw
            % an error if that info has not been set
            if ~obj.prScalingValid && instr(operation, 'cm') &&...
                    ~instr(operation, 'inches')
                error('Cannot scale using cm without setting MonitorSize.')
            end
            numVals = length(vals);
            scaled = zeros(size(vals));
            for v = 1:numVals
                switch operation
                    case 'inches2cm'
                        scaled(v) = vals(v) * 2.54;
                    case 'cm2inches'
                        scaled(v) = vals(v) / 2.54;
                    case 'cm2pxx'
                        scaled(v) = round(vals(v) * obj.prPxPerCm(1));
                    case 'cm2pxy'
                        scaled(v) = round(vals(v) * obj.prPxPerCm(2));  
                    case 'cm2relx'
                        scaled(v) = vals(v) / obj.DrawingSize(1);
                    case 'cm2rely'
                        scaled(v) = vals(v) / obj.DrawingSize(2);                    
                    case 'rel2cmx'
                        scaled(v) = vals(v) * obj.DrawingSize(1);
                    case 'rel2cmy'
                        scaled(v) = vals(v) * obj.DrawingSize(2);                    
                    case 'px2relx'
                        scaled(v) = vals(v) / obj.Resolution(1);
                    case 'px2rely'
                        scaled(v) = vals(v) / obj.Resolution(2);                    
                    case 'rel2pxx'
                        scaled(v) = round(vals(v) * obj.Resolution(1));
                    case 'rel2pxy'
                        scaled(v) = round(vals(v) * obj.Resolution(2));
                    case 'px2cmx'
                        scaled(v) = vals(v) * obj.prCmPerPx(1);
                    case 'px2cmy'
                        scaled(v) = vals(v) * obj.prCmPerPx(2);  
                    otherwise 
                        msg{1} = 'Unknown operation. Supported operations are:';
                        msg{2} = 'inches2cm, cm2inches, cm2pxx, cm2pxy, cm2relx, cm2rely';
                        msg{3} = 'rel2cmx, rel2cmy, px2relx, px2rely, rel2pxx, rel2pxy, px2cmx, px2cmy';
                        error('%s\n', msg{:})
                end
            end
        end
        
        function scaled = ScalePoint(obj, point, operation)
            % scale a point (x, y coord)
            if ~isnumeric(point) || size(point, 2) ~= 2
                error('point value must be a numeric vector with two elements.')
            end
            % multiple rects can be supplied as rows
            num = size(point, 1);
            scaled = zeros(size(point));
            for p = 1:num
                switch lower(operation)
                    case 'inches2cm'
                        scaled(p, 1) = obj.ScaleValue(point(p, 1), 'inches2cm');
                        scaled(p, 2) = obj.ScaleValue(point(p, 2), 'inches2cm');
                    case 'cm2inches'
                        scaled(p, 1) = obj.ScaleValue(point(p, 1), 'cm2inches');
                        scaled(p, 2) = obj.ScaleValue(point(p, 2), 'cm2inches');
                    case 'cm2px'
                        scaled(p, 1) = obj.ScaleValue(point(p, 1), 'cm2pxx');
                        scaled(p, 2) = obj.ScaleValue(point(p, 2), 'cm2pxy');                    
                    case 'cm2rel'
                        scaled(p, 1) = obj.ScaleValue(point(p, 1), 'cm2relx');
                        scaled(p, 2) = obj.ScaleValue(point(p, 2), 'cm2rely');                    
                    case 'rel2cm'
                        scaled(p, 1) = obj.ScaleValue(point(p, 1), 'rel2cmx');
                        scaled(p, 2) = obj.ScaleValue(point(p, 2), 'rel2cmy');                    
                    case 'px2rel'
                        scaled(p, 1) = obj.ScaleValue(point(p, 1), 'px2relx');
                        scaled(p, 2) = obj.ScaleValue(point(p, 2), 'px2rely');                    
                    case 'rel2px'
                        scaled(p, 1) = obj.ScaleValue(point(p, 1), 'rel2pxx');
                        scaled(p, 2) = obj.ScaleValue(point(p, 2), 'rel2pxy');                    
                    case 'px2cm'
                        scaled(p, 1) = obj.ScaleValue(point(p, 1), 'px2cmx');
                        scaled(p, 2) = obj.ScaleValue(point(p, 2), 'px2cmy');                    
                    otherwise 
                        msg{1} = 'Unknown operation. Supported operations are:';
                        msg{2} = 'inches2cm, cm2inches, cm2px, cm2rel, rel2cm, px2rel, rel2px, px2cm';
                        error('%s\n', msg{:})
                end 
            end
        end
        
        function scaled = ScaleRect(obj, rect, operation)            
            % scale a rect (x1, y1, x2, y2)
            
            % check for rect vector that has been transposed (col
            % vector)
            if isvector(rect) && size(rect, 1) == 4
                rect = rect';
            end            
            % check arg
            if ~isnumeric(rect) ||size(rect, 2) ~= 4
                error('rect value must be a numeric matrix of size [n, 4].')
            end
            % multiple rects can be supplied as rows
            num = size(rect, 1);
            scaled = zeros(size(rect));
            for r = 1:num
                switch lower(operation)
                    case 'inches2cm'
                        scaled(r, [1, 2]) = obj.ScalePoint(rect(r, [1, 2]), 'inches2cm');
                        scaled(r, [3, 4]) = obj.ScalePoint(rect(r, [3, 4]), 'inches2cm');
                    case 'cm2inches'
                        scaled(r, [1, 2]) = obj.ScalePoint(rect(r, [1, 2]), 'cm2inches');
                        scaled(r, [3, 4]) = obj.ScalePoint(rect(r, [3, 4]), 'cm2inches');
                    case 'cm2px'
                        scaled(r, [1, 2]) = obj.ScalePoint(rect(r, [1, 2]), 'cm2px');
                        scaled(r, [3, 4]) = obj.ScalePoint(rect(r, [3, 4]), 'cm2px');                   
                    case 'cm2rel'
                        scaled(r, [1, 2]) = obj.ScalePoint(rect(r, [1, 2]), 'cm2rel');
                        scaled(r, [3, 4]) = obj.ScalePoint(rect(r, [3, 4]), 'cm2rel');               
                    case 'rel2cm'
                        scaled(r, [1, 2]) = obj.ScalePoint(rect(r, [1, 2]), 'rel2cm');
                        scaled(r, [3, 4]) = obj.ScalePoint(rect(r, [3, 4]), 'rel2cm');                  
                    case 'px2rel'
                        scaled(r, [1, 2]) = obj.ScalePoint(rect(r, [1, 2]), 'px2rel');
                        scaled(r, [3, 4]) = obj.ScalePoint(rect(r, [3, 4]), 'px2rel');                    
                    case 'rel2px'
                        scaled(r, [1, 2]) = obj.ScalePoint(rect(r, [1, 2]), 'rel2px');
                        scaled(r, [3, 4]) = obj.ScalePoint(rect(r, [3, 4]), 'rel2px');                  
                    case 'px2cm'
                        scaled(r, [1, 2]) = obj.ScalePoint(rect(r, [1, 2]), 'px2cm');
                        scaled(r, [3, 4]) = obj.ScalePoint(rect(r, [3, 4]), 'px2cm');                  
                    otherwise 
                        msg{1} = 'Unknown operation. Supported operations are:';
                        msg{2} = 'inches2cm, cm2inches, cm2px, cm2rel, rel2cm, px2rel, rel2px, px2cm';
                        error('%s\n', msg{:})
                end   
            end
        end
        
        function rect = CentreRect(~, rect)
            x = (fixedRect(2) + fixedRect(4) - rect(2) - rect(4)) / 2;
            y = (fixedRect(1) + fixedRect(3) - rect(1) - rect(3)) / 2;
            rect(2) = rect(2) + y;
            rect(4) = rect(4) + y;
            rect(1) = rect(1) + x;
            rect(3) = rect(3) + x;
        end
        
        function val = MagnifyRect(~, rect, scalingFactor)
            % find centre
            x = (rect(1) + rect(3)) / 2;
            y = (rect(2) + rect(4)) / 2;
            % subtract centre
            rectTmp = [rect(1) - x, rect(2) - y, rect(3) - x, rect(4) - y];
            % scale
            rectTmp = rectTmp * scalingFactor;
            % add centre back again
            val = [rectTmp(1) + x, rectTmp(2) + y, rectTmp(3) + x,...
                rectTmp(4) + y];
        end
        
        function [x, y] = DrawingCentre(obj)
            % if DrawingSize property is empty, this is probably because
            % the monitor size hasn't been set, or the window is not open,
            % or both. In this case return x and y as empty and throw a
            % warning
            if isempty(obj.DrawingSize)
                x = [];
                y = [];
                warning('DrawingCentre property is not available until MonitorSize has been set.')
                return
            end
            x = obj.DrawingSize(1) / 2;
            y = obj.DrawingSize(2) / 2;
        end
            
        function UpdateScaling(obj)
            % if screen is not open, or monitor size has not been set, we 
            % can't calculate scaling params, so note this and return
            if ~obj.WindowOpen || isempty(obj.prMonitorSize)
                obj.prScalingValid = false;
                return
            end
            % get resolution 
            res = Screen('Rect', obj.prWindowPtr);
            res = res([3, 4]);
            % calculate params
            obj.prCmPerPx = obj.MonitorSize ./ res;
            obj.prPxPerCm = res ./ obj.MonitorSize;
            obj.prScalingValid = true;
        end
        
        function SetMonitorDiagonal(obj, diagCm, xRatio, yRatio, units)
            % calculate monitor width and height from diagonal and aspect
            % ratio
            
            % do unit conversion if necessary
            if ~exist('units', 'var') || isempty(units)
                units = 'cm';
            end
            if strcmpi(units, 'inches')
                diagCm = obj.ScaleValue(diagCm, 'inches2cm');
            elseif ~strcmpi(units, 'cm')
                error('Units must be cm or inches.')
            end
                
            % calculate
            h = (diagCm * yRatio) / sqrt((xRatio ^ 2) + (yRatio ^ 2));
            w = (xRatio / yRatio) * h;
            obj.prMonitorSize = [w, h];
            obj.UpdateScaling
        end
        
        % screen/window
        function OpenWindow(obj)
            % check screen is not already open
            if obj.prWindowOpen
                error('Window already open.')
            end
            % check that a monitor size has been set
            if isempty(obj.prMonitorSize)
                error('Cannot open a window until the MonitorSize property has been set.')
            end
            obj.Echo('Opening window...\n')
            % open main window
            bgCol = obj.COL_TE_PURPLE;     
            switch obj.MonoScreenMode
                case false
                    % open fullscreen 
                    obj.prWindowPtr = Screen('OpenWindow',...
                        obj.prMonitorNumber, bgCol);
                case true
                    % open with panelfitter mode, to present a smaller
                    % preview window when only one monitor is being used
                    fullScreenRect = Screen('Rect', obj.prMonitorNumber);
                    obj.prWindowPtr = PsychImaging('OpenWindow',...
                        obj.prMonitorNumber, bgCol,...
                        [0, 0, obj.MonoScreenResolution], [],...
                        [], [], [], [], [], fullScreenRect);
                    % set preview monitor number to same screen as main
                    % window
                    obj.prPreviewMonitorNumber = obj.prMonitorNumber;                    
            end
            % enable support for fast offscreen windows (for quick context
            % shifting between textures)
            PsychImaging('PrepareConfiguration');
            PsychImaging('AddTask', 'General', 'UseFastOffscreenWindows');       
            % flag window as open
            obj.prWindowOpen = true;
            % turn on alpha blending 
            Screen('BlendFunction', obj.prWindowPtr, GL_SRC_ALPHA,...
                GL_ONE_MINUS_SRC_ALPHA);  
            % open offscreen window
            obj.OpenDrawPane
            % open preview
            obj.OpenPreview   
            % open textures for overlays
            res = [0, 0, obj.Resolution];
            tw = obj.CONST_TIMING_PREVIEW_W;
            th = obj.CONST_TIMING_PREVIEW_H;
            obj.prTimingTexture = Screen('OpenOffscreenWindow',...
                obj.prWindowPtr, [0, 0, 0, 0], [0, 0, tw, th]);
            obj.prPreviewTexture = Screen('OpenOffscreenWindow',...
                obj.prWindowPtr, [0, 0, 0, 0], res);
            obj.prETFaceTexture = Screen('OpenOffscreenWindow',...
                obj.prWindowPtr, [0, 0, 0, 0], res);
            obj.prETGazeTexture = Screen('OpenOffscreenWindow',...
                obj.prWindowPtr, [0, 0, 0, 0], res);
            obj.prETCalibTexture = Screen('OpenOffscreenWindow',...
                obj.prWindowPtr, [0, 0, 0, 0], res);  
            obj.prLogoTexture = Screen('OpenOffscreenWindow',...
                obj.prWindowPtr, obj.COL_TE_PURPLE, res);              
            % enable alpha blending for texture and set font
            Screen('BlendFunction', obj.prTimingTexture, GL_SRC_ALPHA,...
                GL_ONE_MINUS_SRC_ALPHA);         
            Screen('TextFont', obj.prTimingTexture, 'Menlo');
            Screen('BlendFunction', obj.prPreviewTexture, GL_SRC_ALPHA,...
                GL_ONE_MINUS_SRC_ALPHA);   
            Screen('BlendFunction', obj.prETFaceTexture, GL_SRC_ALPHA,...
                GL_ONE_MINUS_SRC_ALPHA);   
            Screen('BlendFunction', obj.prETGazeTexture, GL_SRC_ALPHA,...
                GL_ONE_MINUS_SRC_ALPHA);   
            Screen('BlendFunction', obj.prETCalibTexture, GL_SRC_ALPHA,...
                GL_ONE_MINUS_SRC_ALPHA);       
            Screen('BlendFunction', obj.prLogoTexture, GL_SRC_ALPHA,...
                GL_ONE_MINUS_SRC_ALPHA); 
            % show splash screen on main window
            imgSplash = imread(obj.CONST_PATH_SPLASH);
            texSplash = Screen('MakeTexture', obj.prWindowPtr, imgSplash);
            Screen('DrawTexture', obj.prLogoTexture, texSplash);
            Screen('DrawTexture', obj.prWindowPtr, obj.prLogoTexture);
            Screen('DrawTexture', obj.prPreviewPtr, obj.prLogoTexture);
            % flip
            Screen('Flip', obj.prWindowPtr);   
            Screen('Flip', obj.prPreviewPtr);             
            % init calibration texture
            obj.initCalibTexture
            obj.DrawCalibrationResults
            % set CPU priority
            topPriorityLevel = MaxPriority(obj.prWindowPtr);
            Priority(topPriorityLevel);
            % set default font
            Screen('TextFont', obj.ptr, 'Menlo');
            % tell the eye tracker class the window ptr, so that it can get
            % mouse coords if the eye tracker type is set to mouse
            if strcmpi(obj.EyeTracker.TrackerType, 'mouse')
                obj.EyeTracker.MouseWindowPtr = obj.prWindowPtr;
            end
            % prepare internal stim
            obj.prepareInternalStim;
            % set the background colour and draw it
            obj.DrawBackColour
            obj.RefreshDisplay;
            obj.Echo('Task Engine window ready.\n')
        end
        
        function CloseWindow(obj)
            % check window is open
            if ~obj.prWindowOpen
                error('Window not open.')
            end
            % can't close window when a session is active
            if obj.prSessionStarted
                error('Cannot close window whilst session is active.')
            end
            % if draw pane is open, close it
            if obj.prDrawPanePtr
                obj.CloseDrawPane
            end
            % if preview open, close it
            if obj.prPreviewWindowOpen 
                obj.ClosePreview
            end
%             % close main window
%             Screen('Close', obj.prWindowPtr)
%             Screen('CloseAll')
            obj.prWindowOpen = false;
%             obj.prPreviewWindowOpen = false;
           
%             Screen('FinalizeMovie', obj.prCapturePtr);
        end
        
        function ReopenWindow(obj)
            
            % check window is open
            if ~obj.prWindowOpen
                error('Window not open.')
            end
            
            obj.CloseDrawPane
            obj.CloseWindow
            obj.OpenWindow
            obj.OpenDrawPane
            obj.RefreshDisplay
            
        end
        
        function OpenDrawPane(obj)
            % open offscreen window for drawing to. if window limits are
            % enabled, scale this accordingly
            obj.UpdateScaling
            if obj.prWindowLimitEnabled
                res = [0, 0, round(obj.WindowLimitSize .* obj.prPxPerCm)];
            else
                res = [];                   % default to fullscreen
            end
            % open offscreen window
            obj.ptr = Screen('OpenOffscreenWindow',...
                obj.prWindowPtr, obj.prBackColour, res);
            obj.prDrawPaneOpen = true;
            % turn on alpha blending 
            Screen('BlendFunction', obj.ptr, GL_SRC_ALPHA,...
                GL_ONE_MINUS_SRC_ALPHA);             
            % re-prepare any already-prepared stim
            for s = 1:obj.Stim.Count
                stim = obj.Stim.Items{s};
                if stim.Prepared
                    obj.PrepareStim(stim);
                end
            end
        end
        
        function CloseDrawPane(obj)
            % check window is open
            if ~obj.prDrawPaneOpen
                error('Draw pane not open.')
            end
            % can't close  when a session is active
            if obj.prSessionStarted
                error('Cannot close draw pane whilst session is active.')
            end            
            % close offscreen window
            Screen('Close', obj.prDrawPanePtr);
            obj.prDrawPaneOpen = false;
            % erase drawing pointer 
            obj.ptr = [];
        end
        
        function ReopenDrawPane(obj)
            obj.CloseDrawPane
            obj.OpenDrawPane
            obj.ReopenPreview
        end
        
        function OpenPreview(obj)
            % check window is open
            if obj.prPreviewWindowOpen
                error('Preview window already open.')
            end
            % prepare preview in window setting
            if obj.prPreviewInWindow 
                windowOption = kPsychGUIWindow; 
            else
                windowOption = [];
            end         
            % get preview position from preset
            obj.prPreviewPosition = obj.WindowPositionFromPreset(...
                obj.prPreviewPositionPreset, obj.prPreviewScale);
            % open
            obj.prPreviewPtr = Screen('OpenWindow', obj.prPreviewMonitorNumber,...
                obj.BackColour, obj.prPreviewPosition, [], 2, 0, [],...
                [], windowOption, [0, 0, obj.Resolution]);    
            % turn on alpha blending 
            Screen('BlendFunction', obj.prPreviewPtr, GL_SRC_ALPHA,...
                GL_ONE_MINUS_SRC_ALPHA); 
            % draw BG colour
            Screen('FillRect', obj.ptr, obj.prBackColour);
            obj.prPreviewWindowOpen = true;
        end
        
        function ClosePreview(obj)
            % check window is open
            if ~obj.prPreviewWindowOpen
                error('Preview window not open.')
            end
            % can't close  when a session is active
            if obj.prSessionStarted
                error('Cannot close draw pane whilst session is active.')
            end           
            try
                % close preview window
                Screen('Close', obj.prPreviewPtr)
                obj.prPreviewWindowOpen = false;
            catch ERR
                warning(ERR.identifier,...
                    'Error whilst closing preview window:\n%s',...
                    ERR.message)
            end
        end
        
        function ReopenPreview(obj)
            obj.ReopenWindow
        end
        
        % stim
        function LoadStim(obj, file, name, task)
            
            % if file is empty, it probably means that an incorrect key was
            % used to refer to a path in a collection - so throw an error
            if isempty(file)
                error('Path not found.')
            end
            
            % if a task has been specified, then tag the stimuli that we
            % load with a reference to that task. 
            if ~exist('task', 'var') || isempty(task)
                task = [];
                taskPath = [];
            else
                % ensure task exists
                if ~ismember(task, obj.Tasks.Keys)
                    error('Specified task ''%s'' does not exist.', task)
                end
                % get task path, to allow specifying filenames that are
                % relative to the task folder
                taskPath = obj.Tasks(task).Path;
            end
            
            % if the path is relative (to either task or pwd) then convert
            % to absolute path. We want to store absolute paths, but
            % relative paths make for cleaner code in scripts
            if ~isAbsPath(file)
                % first try relative to pwd
                file = rel2abs(file);
                if ~exist(file, 'dir') && ~exist(file, 'file')
                    % now try relative to task
                    file = rel2abs(file, taskPath);
                end
            end
            
            % determine file or folder
            isFolder = exist(file, 'dir');
            isFile = ~isFolder && exist(file, 'file');
            % check path exists
            if ~isFile && ~isFolder
                error('Path ''%s'' not found.', file)
            end
            
            % search for files
            d = dir(file);
            if isempty(d)
                error('No files found matching the pattern: %s',...
                    file)         
            end
            % check that files match supported types, remove if not
            [~, ~, ext] = cellfun(@fileparts, {d.name}, 'uniform', false);
            ext = cellfun(@(x) upper(x(2:end)), ext, 'uniform', false);
            supported = cellfun(@(x)...
                ismember(x, obj.CONST_SUPPORTED_STIM_FORMATS), ext);
            d(~supported) = [];
            % if not files match, throw an error
            if isempty(d), error('No supported file types found.'), end
            numFiles = length(d);
            
            % each stim has a name. This can be specified when loaded, or
            % we can set it from the filename
            if ~exist('name', 'var') || isempty(name);              
                generateName = true;
            else
                % ensure that name is char
                if ~ischar(name) || ~isvector(name) 
                    error('''name'' must be char.')
                end
                generateName = false;
            end
            
            % if more than one file being added, flag to append suffix to
            % name (e.g. 'stim001')
            suffixName = numFiles > 1;
            
            % loop through files and add
            for f = 1:numFiles
                % build path
                if isFolder
                    fileToAdd = fullfile(file, d(f).name);
                else
                    fileToAdd = file;
                end
                % if needed, generate a unique name
                if generateName
                    nameToAdd = d(f).name;
                elseif suffixName
                    nameToAdd = sprintf('%s%.3d', name, f);
                else
                    nameToAdd = name;
                end
                % add stimulus to collection
                obj.Stim.AddItem(teStim(fileToAdd, task), nameToAdd);
            end
            
        end    
        
        function PrepareStim(obj, stim)
            if ischar(stim)
                stim = obj.Stim(stim);
            end
            % check whether multiple stim were returned
            if ~iscell(stim) 
                % take single stim and put into cell array
                allStim = {stim};
            else
                % put multiple stim into cell array
                allStim = stim;
            end
            numToPrepare = length(allStim);
            for s = 1:numToPrepare
                stim = allStim{s};
                if ~isa(stim, 'teStim')
                    error('stim argument must be a stimulus name or teStim instance.')
                end
                if ~stim.Loaded
                    error('Stim not loaded.')
                end
                if ~obj.WindowOpen
                    error('Window not open.')
                end
                switch stim.Type
                    case 'IMAGE'
                        % make texture
                        texPtr = Screen('MakeTexture', obj.prWindowPtr,...
                            stim.ImageData);
                        % update flags
                        stim.SetPrepared(texPtr);
                    case 'MOVIE'
                        % open movie in PTB
                        movPtr = Screen('OpenMovie', obj.prWindowPtr,...
                            stim.Filename);
                        stim.SetPrepared(movPtr);
                        % get first frame
                        Screen('SetMovieTimeIndex', stim.MoviePtr, 0);
                        stim.TexturePtr = Screen('GetMovieImage', obj.prWindowPtr,...
                            stim.MoviePtr);
                        if stim.TexturePtr == -1
                            error('Could not get first frame from movie')
                        end
                    case 'SOUND'         
                        % open movie in PTB
                        sndPtr = Screen('OpenMovie', obj.prWindowPtr,...
                            stim.Filename);
                        stim.SetPrepared(sndPtr);
                        % get first frame
                        Screen('SetMovieTimeIndex', stim.SoundPtr, 0);
                    case 'SHORTSOUND'
                        stim.SoundBufferPtr = PsychPortAudio('CreateBuffer',...
                            obj.prSoundDevicePtr, stim.SoundData);
                        stim.SetPrepared(sndPtr);                        
                    otherwise
                        error('Not yet implemented!')
                end
                % update last touched time
                stim.LastTouched = teGetSecs;  
                % log
                obj.AddLog('source', 'presenter', 'topic',...
                    'stim', 'data', sprintf('Prepared %s', stim.Filename)) 
            end
        end
        
        function PlayStim(obj, stim)
            % todo - allow multiple stim
            if ischar(stim)
                stim = obj.Stim(stim);
            end
            if ~isa(stim, 'teStim')
                error('stim argument must be a stimulus name or teStim instance.')
            end
            if ~stim.Loaded
                error('Stim not loaded.')
            end
            if ~stim.Prepared
                obj.PrepareStim(stim)
                if ~stim.Prepared
                    error('Stim not prepared - tried to prepare but failed.')
                end
            end
            if ~obj.WindowOpen
                error('Window not open.')
            end
            % set volume, if in silent mode then set volume to 0
            if obj.SilentMode
                vol = 0;
            else
                vol = stim.Volume;
            end            
            % start playing, according to stim type
            switch stim.Type
                case 'IMAGE'
                    error('Cannot play an image.')
                case 'MOVIE'
                    % set PTB movie time to match stim current time
                    Screen('SetMovieTimeIndex', stim.MoviePtr,...
                        stim.prCurrentTime);
                    % get a new frame (since the time has changed)
                    obj.UpdateMovieStimulus(stim)
                    % start playing
                    Screen('PlayMovie', stim.MoviePtr, stim.PlaybackRate,...
                        double(stim.Loop), vol);
                    stim.SetPlaying
                    % set flag in collection for fast lookup of currently
                    % playing movies by the presenter. Note that if the
                    % teStim was passed directly to this method, it may not
                    % exist in the stim collection, in which case we can't
                    % do this. 
                    idx = obj.Stim.LookupIndex(stim);
                    if ~isempty(idx)
                        obj.Stim.Playing{idx} = true;
                    end
                    % update last touched time
                    stim.LastTouched = teGetSecs;
                    
                case 'SOUND'
                    % start playing
                    Screen('SetMovieTimeIndex', stim.SoundPtr,...
                        stim.prCurrentTime);
                    Screen('PlayMovie', stim.SoundPtr, stim.PlaybackRate,...
                        double(stim.Loop), vol);
                    stim.SetPlaying     
                    % set flag in collection for fast lookup of currently
                    % playing sounds by the presenter
                    idx = obj.Stim.LookupIndex(stim);
                    obj.Stim.Playing{idx} = true;      
                    
                case 'SHORTSOUND'
                    % either play sound now, or add to buffer to play at
                    % next refresh
                    if strcmpi(stim.SoundMode, 'immediate')
                        % fill device buffer from stim buffer
                        PsychPortAudio('FillBuffer', obj.prSoundDevicePtr,...
                            stim.SoundBufferPtr);  
                        % play
                        PsychPortAudio('Start', obj.prSoundDevicePtr);
                        stim.SetPlaying
                    else
                        % add to sound buffer
                        obj.prSoundBuffer(obj.prSoundBufferIdx) =...
                            stim.Sound;
                        obj.prSoundBufferStim(obj.prSoundBufferIdx) =...
                            stim;
                        obj.prSoundBufferIdx = obj.SoundBufferIdx + 1;
                    end
                    
            end
            % log
            obj.AddLog('source', 'presenter', 'topic',...
                'stim', 'data', sprintf('Started %s', stim.Filename))                  
        end
        
        function StopStim(obj, stim)
            % check input arg, look up stim if char
            if ischar(stim)
                stim = obj.Stim(stim);
                if isempty(stim)
                    error('Stim not found.')
                end
            end            
            % check stim
            if ~isa(stim, 'teStim')
                error('stim argument must be a stimulus name or teStim instance.')
            end            
            switch stim.Type
                case {'MOVIE', 'SOUND'}
                    if ~stim.Playing
                        warning('Stim %s not playing.', stim.Name)
                        return
                    end
                    % stop movie in PTB
                    if stim.isMovie
                        ptrToStop = stim.MoviePtr;
                    elseif stim.isSound
                        ptrToStop = stim.SoundPtr;
                    end
                    Screen('PlayMovie', ptrToStop, 0);
                    stim.SetStopped
                    % set flag in collection for fast lookup of currently
                    % playing movies by the presenter
                    idx = obj.Stim.LookupIndex(stim);
                    obj.Stim.Playing{idx} = false;       
                    % if not looping, set time back to zero
                    if ~stim.Loop
                        stim.CurrentTime = 0;
                        Screen('SetMovieTimeIndex', ptrToStop, stim.CurrentTime);
                    end
                    % update last touched time
                    stim.LastTouched = teGetSecs;                        
                otherwise
                    error('Not yet implemented!')
                    % TODO - implement for sounds
            end
            % log
            obj.AddLog('source', 'presenter', 'topic',...
                'stim', 'data', sprintf('Stopped %s', stim.Filename))                  
            
        end
        
        function CloseStim(obj, stim)
            % check input arg, look up stim if char
            if ischar(stim)
                stim = obj.Stim(stim);
                if isempty(stim)
                    error('Stim not found.')
                end
            end            
            % check stim
            if ~isa(stim, 'teStim')
                error('stim argument must be a stimulus name or teStim instance.')
            end            
            switch stim.Type
                case {'MOVIE', 'SOUND'}
                    if stim.Playing, obj.StopStim(stim); end
                    % clear frame texture
                    if stim.TexturePtr > 0
                        Screen('Close', stim.TexturePtr)
                        stim.TexturePtr = nan;
                    end
                    % close movie
                    if stim.Prepared 
                        if stim.isMovie
                            ptrToClose = stim.MoviePtr;
                        elseif stim.isSound
                            ptrToClose = stim.SoundPtr;
                        end
                        Screen('CloseMovie', ptrToClose)
                        stim.MoviePtr = nan;
                        stim.SetClosed;
                    end
                    % update last touched time
                    stim.LastTouched = teGetSecs;         
                case 'IMAGE'
                otherwise
                    error('Not yet implemented!')
                    % TODO - implement for sounds
            end      
            % log
            obj.AddLog('source', 'presenter', 'topic',...
                'stim', 'data', sprintf('Closed %s', stim.Filename))                  
        end
            
        function ClearStim(obj)
            obj.Stim.Clear
        end
        
        function PlayAuditoryAttentionGetter(obj)
        % selects a random auditory attention getter and plays it
        
            % play
            snd = obj.Stim.LookupRandom('Key', 'snd_att_get*');
            obj.PlayStim(snd);
            % send event
            obj.SendRegisteredEvent('ATTENTION_GETTER_AUDITORY');
            
        end
        
        function PlayVisualAttentionGetter(obj)
        % plays a visual attention getter - for now this is a fixation
        
            % if eye tracker is valid, make this a gaze contingent
            % fixation, otherwise the experimenter will have to press Tab
            % when the subject is looking
            if obj.EyeTracker.Valid
                teFixation(obj, 'useEyeTracker');
            else 
                teFixation(obj);
            end
            obj.KeyFlush;
            obj.KeyUpdate;
            
        end 
        
        function LightPatchOn(obj)
        % first check that the light patch is enabled. If not, throw a
        % warning and exit. Otherwise, check whether the light patch is
        % already on. If it is, then reset it's auto off timer to the
        % current time. Otherwise, switch it on and log the current time to
        % enable auto off in future
        
            % check enabled
            if ~obj.LightPatchEnabled
                warniing('Light patch not enabled, set LightPatchEnabled to true before calling this method.')
                return
            end
            
            % check status
            if obj.LightPatchStatus
                % already on, reset timer
                obj.prLightPatchOnset = teGetSecs;
                
            else 
                % off, switch on and log time
                obj.prLightPatchOnset = teGetSecs;
                obj.prLightPatchStatus = true;
                
            end
            
        end
            
        % eye tracker
        function ETGetEyesAndCalibrate(obj)
            % don't run if using mouse
            if strcmpi(obj.EyeTracker.TrackerType, 'mouse') ||...
                    strcmpi(obj.EyeTracker.TrackerType, 'keyboard')
                return
            end
            teTitle('Get eyes and calibrate:\n\n');
            obj.DrawCalibOnPreview = true;
            obj.KeyFlush        
            % get eyes
            state = 1;
            while state ~= 3
                switch state
                    case 1
                        
                        % get eyes
                        teEcho('Centre participant in trackbox, press %s to move on to calibration\n',...
                            obj.KB_MOVEON);
                        obj.ETGetEyes
                        if obj.KeyPressed(obj.KB_MOVEON)
                            % move on to calibration
                            state = 2;
                            obj.KeyFlush
                        elseif obj.KeyPressed(obj.KB_MOVEBACK)
                            break
                        end
                        
                    case 2
                        
                        % calibrate                      
                        teEcho('Calibrating, press %s to accept and move on, %s to go back to get eyes\n',...
                            obj.KB_MOVEON, obj.KB_MOVEBACK);                        
                        calibAccepted = obj.ETCalibrate;
                        if obj.KeyPressed(obj.KB_MOVEBACK)
                            % move back
                            state = 1;
                            obj.KeyFlush
                        elseif obj.KeyPressed(obj.KB_MOVEON) || calibAccepted
                            % move on
                            state = 3;
                            obj.KeyFlush
                        end
                        
                end
            end
            teEcho('Exiting calibration.');
            teLine
            obj.DrawCalibOnPreview = false;
            obj.CalibRequested = false;
        end
        
        function ETGetEyes(obj)
            if ~obj.EyeTracker.Valid
                error('Eye tracker not valid.')
            end
            if strcmpi(obj.EyeTracker.TrackerType, 'mouse')
                warning('Cannot get eyes when TrackerType is set to ''mouse''')
                return
            end
            % draw et face
            obj.DrawETFaceOnMainWindow = true;
            % prepare movie
            stim = obj.Stim('et_video');
            obj.PrepareStim(stim)
            obj.PlayStim(stim)
            % loop until move on key is pressed
            obj.KeyFlush
            while ~obj.KeyPressed(obj.KB_MOVEON) &&...
                    ~obj.KeyPressed(obj.KB_MOVEBACK)
                obj.DrawStim(stim)
                obj.RefreshDisplay;
            end
            obj.StopStim(stim)
            obj.DrawETFaceOnMainWindow = false;
        end
        
        function calibAccepted = ETCalibrate(obj)
            if ~obj.EyeTracker.Valid
                error('Eye tracker not in valid state.')
            end
            % enter calibration mode
            obj.EyeTracker.BeginCalibration;
            obj.DrawCalibOnPreview = true;
            obj.BackColour = obj.ETCalibBackgroundColour;
            obj.RefreshDisplay;
            calibOnset = teGetSecs;
            % if calib status is empty (no calib run yet), fill it from
            % calib def (which details the coords of each point) and with
            % empty validity information
            if isempty(obj.prETCalibStatus)
                calibDef = obj.prETCalibDef;
                valid = false(size(calibDef, 1), 1);
                measured = false(size(calibDef, 1), 1);
                obj.prETCalibStatus = array2table([...
                        calibDef,...
                        valid,...
                        measured],...
                    'variablenames', {...
                        'PointX',...
                        'PointY',...
                        'Valid',...
                        'Measured'});
            end
            % get calib status
            cs = obj.prETCalibStatus;
            numPoints = size(cs, 1);
            % reset measured flags
            cs.Measured = false(numPoints, 1);
            % loop until all valid, or key pressed to move on/back
            obj.KeyFlush;
            moveOn = false;
            moveBack = false;
            finished = false;
            firstPoint = true;
            calibAccepted = false;
            obj.prCalibDebug = [];
            while ~finished && ~moveOn && ~moveBack
                
                % if all points are valid, query whether to wipe calib and 
                % start again, or to accept
                if all(cs.Valid)
                    % get image for participant to look at
                    img = obj.Stim.LookupRandom('Keys', 'et_image');
                    obj.DrawStim(img);
                    obj.RefreshDisplay;
                    teEcho('All calibration points are valid. Do you want to accept this calibration (y) or discard it and start again (n)? >');
                    ListenChar
                    resp = input('', 's');
                    if obj.DisableKeyboardDuringSession && obj.prSessionStarted
                        ListenChar(2);
                    end
                    if ~isempty(resp) && ischar(resp) &&...
                            instr(lower(resp), 'n')
                        % wipe and start again
                        cs.Valid = false(numPoints, 1);
                        cs.Measured = false(numPoints, 1);
                        obj.EyeTracker.ClearCalibPoints
                    else
                        calibAccepted = true;
                        break
                    end
                end
                
                % find a point to calibrate, get x, y, coords
                needCalib = find(~cs.Valid & ~cs.Measured);
                numNeeded = length(needCalib);
                currentPointIdx = needCalib(randi(numNeeded));
                x = cs.PointX(currentPointIdx);
                y = cs.PointY(currentPointIdx);
                % prepare point for calibration
                if firstPoint
                    % this is the first point, create a calib point
                    % structure and initialise it with the first x, y coord
                    cpoint = obj.ETCreateCalibPoint(x, y,...
                        obj.ETCalibStartSize);
                    firstPoint = false;
                else
                    % this is not the first point. Move the existing calib
                    % point structure to the location of the current point
                    cpoint = obj.ETMoveCalibPoint(cpoint, x, y);
                    % look up a random sound and play it
                    snd = obj.Stim.LookupRandom('Key', 'fix_snd*');
                    snd.CurrentTime = 0;
                    obj.PlayStim(snd);                    
                    % grow to full size
                    cpoint = obj.ETSizeCalibPoint(cpoint,...
                        obj.ETCalibStartSize, .35);                
                end
                % rotate and shrink
                cpoint = obj.ETRotateCalibPoint(cpoint, obj.ETCalibDurWait);
                cpoint = obj.ETSizeCalibPoint(cpoint, obj.ETCalibEndSize,...
                    obj.ETCalibDurShrink);
                % measure
                obj.EyeTracker.CalibratePoint(x, y)    
                cs.Measured(currentPointIdx) = true;
                
                % try to catch errors where the point has gone offscreen
                if cpoint.x > 1 || cpoint.x < 0 ||...
                        cpoint.y > 1 || cpoint.y < 0
                    warning('Calib point off screen!')
                end
                
                % check keyboard
                moveOn = obj.KeyPressed(obj.KB_MOVEON);
                moveBack = obj.KeyPressed(obj.KB_MOVEBACK);
                
%                 fprintf('%.2f %.2f\n', cpoint.x, cpoint.y);
                
                % if all points are measured, compute calibration
                if all(cs.Measured) || moveOn
                    % compute calibration and summarise
                    obj.EyeTracker.ComputeCalibration;
                    cs = obj.ETSummariseCalibration(cs, calibOnset, teGetSecs);
                    obj.DrawCalibrationResults
                    obj.RefreshDisplay('noKeyUpdate');
                    % set any non-valid to be measured again
                    notVal = ~cs.Valid;
                    numNotVal = sum(notVal);
                    cs.Measured(notVal) = false(numNotVal, 1);
                    if any(notVal)
                        teEcho('Some points not valid, retrying - press %s to move on, or %s to move back.\n',...
                            obj.KB_MOVEON, obj.KB_MOVEBACK);
                    end
                end

            end
            % update status 
            obj.prETCalibStatus = cs;
%             % update tracker
%             obj.Tracker.EyeTrackerCalibration = obj.EyeTracker.Calibration;
            % exit calibration mode
            obj.EyeTracker.EndCalibration
            obj.DrawCalibOnPreview = false;
            % flush buffer to save everything to disk
            obj.FlushBuffer
        end
        
        function calibDef = ETSummariseCalibration(obj, calibDef, from, to)
        % take a calibration definition, calibDef, reads the calibration
        % summary from the eye tracker, reads gaze data between from and to
        % (the duration of the calib sequence) and computes summary
        % statistics for each calib point. Essentially, this is where we
        % convert the eye tracker's calibration summary to accuracy and
        % precision statistics
        
            numPoints = size(calibDef, 1);
            
            % if not calibrated, return
            if ~obj.EyeTracker.Calibrated
                return
            end
            
            % get data
            tab = obj.EyeTracker.Calibration.Table;
            
            % calculate median distance from screen during calibration
            gaze = obj.EyeTracker.GetGaze(from, to);
            dist = gaze(:, [12, 27]);
            medDist = nanmedian(dist(:)) / 10;
            
            % replace invalid values with nans
            val_l = tab.LeftValidity;
            val_r = tab.RightValidity;
            tab(~val_l, [3, 4, 9, 10, 13]) = array2table(nan(sum(~val_l), 5));
            tab(~val_r, [5, 6, 11, 12, 14]) = array2table(nan(sum(~val_r), 5));
            
        % convert offsets to degrees
        
            tab_deg = tab;    
            
            % convert cm to deg
            [tab_deg.LeftOffsetX, tab_deg.LeftOffsetY] = norm2deg(...
                tab_deg.LeftOffsetX, tab_deg.LeftOffsetY,...
                obj.DrawingSize(1), obj.DrawingSize(2), medDist);
            [tab_deg.RightOffsetX, tab_deg.RightOffsetY] = norm2deg(...
                tab_deg.RightOffsetX, tab_deg.RightOffsetY,...
                obj.DrawingSize(1), obj.DrawingSize(2), medDist);  
            
            % convert x, y offsets to euclidean offset distances
            tab_deg.LeftOffset = sqrt((tab_deg.LeftOffsetX .^ 2) +...
                (tab_deg.LeftOffsetY .^ 2));
            tab_deg.RightOffset = sqrt((tab_deg.RightOffsetX .^ 2) +...
                (tab_deg.RightOffsetY .^ 2));           
            
        % summaries are calculated for each calib point. Extract unique
        % calib points from the calib summary table
        
            % make keys for points
            pt_key = arrayfun(@(x, y) sprintf('%.1f_%.1f', x, y),...
                tab_deg.PointX, tab_deg.PointY, 'uniform', false);
            [pt_u, pt_i, pt_s] = unique(pt_key);
            smry = table;
            smry.Key = pt_u;
            smry.PointX = tab_deg.PointX(pt_i);
            smry.PointY = tab_deg.PointY(pt_i);
            
        % calculate summary statistics for each point
            
            % calculate number of gaze samples used for each point
            smry.NumSamples = accumarray(pt_s, ones(size(pt_s)), [], @sum);
            
            % calculate absolute accuracy for each point, separately on x,
            % y axes for each eye
            smry.LeftX  = accumarray(pt_s, tab.LeftX,   [], @nanmean);
            smry.LeftY  = accumarray(pt_s, tab.LeftY,   [], @nanmean);
            smry.RightX = accumarray(pt_s, tab.RightX,  [], @nanmean);
            smry.RightY = accumarray(pt_s, tab.RightY,  [], @nanmean);
            
            % calculate accuracy/precision - normalised coords, for x axis
            smry.LeftAccuracyX_norm =...
                accumarray(pt_s, tab.LeftOffsetX, [], @nanmean);
            smry.LeftPrecisionX_norm =...
                accumarray(pt_s, tab.LeftOffsetX, [], @nanrms);            
            smry.RightAccuracyX_norm =...
                accumarray(pt_s, tab.RightOffsetX, [], @nanmean);
            smry.RightPrecisionX_norm =...
                accumarray(pt_s, tab.RightOffsetX, [], @nanrms);             
            
            % calculate accuracy/precision - normalised coords, for y axis
            smry.LeftAccuracyY_norm =...
                accumarray(pt_s, tab.LeftOffsetY, [], @nanmean);
            smry.LeftPrecisionY_norm =...
                accumarray(pt_s, tab.LeftOffsetY, [], @nanrms);            
            smry.RightAccuracyY_norm =...
                accumarray(pt_s, tab.RightOffsetY, [], @nanmean);
            smry.RightPrecisionY_norm =...
                accumarray(pt_s, tab.RightOffsetY, [], @nanrms);                    
            
            % calculate accuracy/precision - normalised coords, averaged
            % across x and y
            smry.LeftAccuracy_norm =...
                accumarray(pt_s, tab.LeftOffset, [], @nanmean);
            smry.LeftPrecision_norm =...
                accumarray(pt_s, tab.LeftOffset, [], @nanrms);            
            smry.RightAccuracy_norm =...
                accumarray(pt_s, tab.RightOffset, [], @nanmean);
            smry.RightPrecision_norm =...
                accumarray(pt_s, tab.RightOffset, [], @nanrms);              
            
            % calculate accuracy/precision - degrees, averaged across x and
            % y
            smry.LeftAccuracy_deg =...
                accumarray(pt_s, tab_deg.LeftOffset, [], @nanmean);
            smry.LeftPrecision_deg =...
                accumarray(pt_s, tab_deg.LeftOffset, [], @nanrms);            
            smry.RightAccuracy_deg =...
                accumarray(pt_s, tab_deg.RightOffset, [], @nanmean);
            smry.RightPrecision_deg =...
                accumarray(pt_s, tab_deg.RightOffset, [], @nanrms);     
            
            % validity for each point
            minAcc = obj.ETCalibMinValidAccuracyDeg;
            minPrec = obj.ETCalibMinValidPrecisionDeg;
            pt_val_l =...
                smry.LeftAccuracy_deg <= minAcc &...
                smry.LeftPrecision_deg <= minPrec;
            pt_val_r = ...
                smry.RightAccuracy_deg <= minAcc &...
                smry.RightPrecision_deg <= minPrec;
            smry.Valid = pt_val_l | pt_val_r;
            
            % store in eye tracker
            obj.EyeTracker.Calibration.Summary = smry;
            
        % update calib def validity based on results
        
            for p = 1:numPoints
                
                % find point in summary
                xd = abs(smry.PointX - calibDef.PointX(p));
                yd = abs(smry.PointY - calibDef.PointY(p));
                nearest = find(xd < .001 & yd < .001);
                
                if isempty(nearest)
                    % no calib data for this point, mark as invalid
                    calibDef.Valid(p) = false;
                else
                    % mark validity based on summary validity
                    calibDef.Valid(p) = smry.Valid(nearest);
                end
                
            end
            
        end
        
        function ETMeasureDrift(obj, numPoints)
%             if ~obj.EyeTracker.Valid
%                 error('Eye tracker not valid.')
%             end
%             if ~obj.WindowOpen
%                 error('Window not open.')
%             end
            % default numner of points if missing
            if nargin == 1
                numPoints = 5;
            end
            
            % init vars
            vel = 3;
            sz = .5;
            col_dot = [0, 0, 0];
            col_bg = [255, 255, 255];
            obj.BackColour = col_bg;
            res = obj.Resolution;
            dur_norm = 4;
            
            % select points to measure
            drift = obj.prETDriftPoints;
            [~, so] = sort(drift(:, 3), 'descend');
            drift = drift(so, :);
            % do we have enough points to satisfy numPoints?
            if numPoints <= size(drift, 1)
                % yes - select top n points by priority
                sel = 1:numPoints;
            else
                % no - first select all points in priority order, then a
                % random selection to make up numbers
                sel = 1:size(drift, 1);
                % calculate how many more we need
                stillNeeded = numPoints - size(drift, 1);
                sel = [sel, randi(size(drift, 1), 1, stillNeeded)];
            end
            drift = drift(sel, :);
            % randomise order of points
            so = randperm(size(drift, 1));
            drift = drift(so, :);
            % get x, y coords
            pos_norm = drift(:, 1:2);
%             pos_px = obj.ScalePoint(pos_norm, 'rel2px');
            xg = pos_norm(:, 1);
            yg = pos_norm(:, 2);
            % calculate inter-point distances
            dists = sqrt((diff(pos_norm(:, 1)) .^ 2) +...
                (diff(pos_norm(:, 2)) .^ 2));
            % convert distances to durations
            durs = cumsum([0; dists * dur_norm]);
            % keyframes
            kf_x                = teKeyFrame;
            kf_x.TimeMode       = 'absolute';
            kf_x.Duration       = durs(end);
            kf_x.AddTimeValue   (durs, xg);
            kf_y                = teKeyFrame;
            kf_y.TimeMode       = 'absolute';
            kf_y.Duration       = durs(end);
            kf_y.AddTimeValue   (durs, yg);
            onset               = teGetSecs;
            kf_x.StartTime      = onset;
            kf_y.StartTime      = onset;
            % animate
            while ~kf_x.Finished
                % draw
                cx = kf_x.Value;
                cy = kf_y.Value;
                curPos = obj.ScalePoint([cx, cy], 'rel2px');
                Screen('DrawDots', obj.ptr, curPos, 16, col_dot, [], 2);
                obj.EyeTracker.MeasureDrift(cx, cy)
                obj.RefreshDisplay;                
            end
            % update priorities
            
            
            
%             % draw
%             for p = 2:numPoints
%                 % get start/end coords
%                 x1 = xg(p - 1);
%                 y1 = yg(p - 1);
%                 x2 = xg(p);
%                 y2 = yg(p);
%                 % keyframe
%                 kf = teKeyFrame;
%                 kf.AddTimeValue
%                 
%                 
%                 
%                 
%                 % init current x, y and vel
%                 cx = x1;
%                 cy = y1;
%                 xvel = vel * ((x2 - x1) / res(1));
%                 yvel = vel * ((y2 - y1) / res(2));
%                 % loop until at destination
%                 dist = sqrt(((cx - x2) .^ 2) + ((cy - y1) .^ 2));
%                 while dist > .2
%                     % update
%                     xvel = vel * ((x2 - x1) / res(1));
%                     yvel = vel * ((y2 - y1) / res(2));                    
%                     cx = cx + xvel;
%                     cy = cy + yvel;
%                     rect = teRectFromDims(cx, cy, sz, sz);
%                     dist = sqrt(((cx - x2) .^ 2) + ((cy - y1) .^ 2));
%                     % draw
%                     Screen('DrawDots', obj.ptr, [cx, cy], 16, col_dot, [], 2);
%                     obj.RefreshDisplay;
%                 end
%             end
        end
        
        function point = ETCreateCalibPoint(obj, x, y, size)
            point.x = x;
            point.y = y;
            point.size = size;
            point.rot = 0;
            point.rotChangePerS = 250;
            point.stim = obj.Stim.LookupRandom('key', 'et_calib_spiral*');
        end
        
        function point = ETRotateCalibPoint(obj, point, dur)
            % convert x, y to cm
            xy_cm = obj.ScalePoint([point.x, point.y], 'rel2cm');
            x = xy_cm(1); y = xy_cm(2);            
            % calculate rotation needed for this duration
            rotNeeded = point.rotChangePerS * dur;
            % keyframe
            kf = teKeyFrame;
            kf.Duration = dur;
            kf.AddTimeValue(0, point.rot);
            kf.AddTimeValue(1, point.rot + rotNeeded);
            % animate
            anim_onset = teGetSecs;
            kf.StartTime = anim_onset;
            while ~kf.Finished && ~obj.KeyPressed(obj.KB_MOVEBACK) &&...
                    ~obj.KeyPressed(obj.KB_MOVEON)
                % make rect
                sz = point.size;
                rect = [x - sz, y - sz, x + sz, y + sz];
                point.rot = kf.Value;
                % draw
                obj.DrawStim(point.stim, rect, point.rot)
                obj.RefreshDisplay;
            end          
        end
        
        function point = ETSizeCalibPoint(obj, point, toSize, dur)
            % convert x, y to cm
            xy_cm = obj.ScalePoint([point.x, point.y], 'rel2cm');
            x = xy_cm(1); y = xy_cm(2);     
            % size keyframes
            kf_size = teKeyFrame2;
            kf_size.TimeFormat = 'normalised';
            kf_size.Data = [...
                0.0,    point.size         ;...
                0.8,    toSize * 1.1       ;...
                1.0,    toSize             ];
            kf_size.Duration = dur;
            % calculate rotation needed for this duration
            rotNeeded = point.rotChangePerS * dur;
            % rotate keyframe
            kf_rot = teKeyFrame2;
            kf_rot.TimeFormat = 'normalised';
            kf_rot.Duration = dur;
            kf_rot.Data = [...
                0.0,    point.rot                   ;...
                1.0,    point.rot + rotNeeded       ];
            % animate
            anim_onset = teGetSecs;
            while teGetSecs - anim_onset < dur &&...
                    ~obj.KeyPressed(obj.KB_MOVEBACK) &&...
                    ~obj.KeyPressed(obj.KB_MOVEON)
                
                elap = (teGetSecs - anim_onset) / dur;
                % make rect
                sz = kf_size.GetValue(elap);
                rect = [x - sz, y - sz, x + sz, y + sz];
                point.rot = kf_rot.GetValue(elap);
                % draw
                obj.DrawStim(point.stim, rect, point.rot)
                obj.RefreshDisplay;
            end     
            % update point with current size
            point.size = toSize;
        end
        
        function point = ETMoveCalibPoint(obj, point, toX, toY)
            % defaults
            sz = point.size;
            vel = obj.ETCalibMoveVelocity;
            % convert x, y to cm
            fromX = point.x;
            fromY = point.y;
            xy_cm = obj.ScalePoint([fromX, fromY], 'rel2cm');
            fromX = xy_cm(1); fromY = xy_cm(2);
            xy_cm = obj.ScalePoint([toX, toY], 'rel2cm');
            toX_cm = xy_cm(1); toY_cm = xy_cm(2);            
            % calculate duration from distance and velocity
            dis = sqrt(((toX_cm - fromX) ^ 2) + ((toY_cm - fromY) ^ 2));
            dur = dis / vel;
            % keyframe x, y
            kf_x = teKeyFrame2;
            kf_x.Data = [0, fromX; 1, toX_cm];
            kf_x.TimeFormat = 'normalised';
            kf_x.Duration = dur;
            
            kf_y = teKeyFrame2;
            kf_y.Data = [0, fromY; 1, toY_cm];
            kf_y.TimeFormat = 'normalised';
            kf_y.Duration = dur;
            
            % calculate rotation needed for this duration
            rotNeeded = point.rotChangePerS * dur;            
            % rotate keyframe
            kf_rot = teKeyFrame2;
            kf_rot.TimeFormat = 'normalised';
            kf_rot.Data = [0, point.rot; 1, point.rot + rotNeeded];
            kf_rot.Duration = dur;
             
            % animate
            anim_onset = teGetSecs;
            while teGetSecs - anim_onset < dur &&...
                    ~obj.KeyPressed(obj.KB_MOVEBACK) &&...
                    ~obj.KeyPressed(obj.KB_MOVEON)
                % make rect
                elap = (teGetSecs - anim_onset) / dur;
                x = kf_x.GetValue(elap);
                y = kf_y.GetValue(elap);
                rect = [x - sz, y - sz, x + sz, y + sz];
                % draw
                obj.DrawStim(point.stim, rect, point.rot)
                obj.RefreshDisplay;
            end 
            point.x = toX;
            point.y = toY;
        end
        
        function DrawCalibrationResults(obj)
            if ~obj.WindowOpen
                error('Window not open.')
            end
            % set up colours
            col_pt          = obj.COL_LABEL_FG;
            col_val_l       = [obj.COL_ET_LEFT, 255];
            col_val_r       = [obj.COL_ET_RIGHT, 255];
%             col_inval_l     = [obj.COL_ET_LEFT, 128];
%             col_inval_r     = [obj.COL_ET_RIGHT, 128];  
            col_inval_l     = [220, 000, 000, 128];
            col_inval_r     = [220, 000, 000, 128];
            sz_pt           = 30;
            sz_g            = 7;            

            % clear texture
            obj.ClearTexture(obj.prETCalibTexture);
            % draw semi-transparent background to dark existing stim
            Screen('FillRect', obj.prETCalibTexture, [0, 0, 0, 200]);            

            % different contents depending on whether the calibration was
            % successful or not
%             if obj.EyeTracker.Calibrating
%                 DrawFormattedText(obj.prETCalibTexture,...
%                     'Calibrating...', 'center', 'center', col_pt);                    
            if obj.EyeTracker.Calibrated 
                % get calibration results table
                tab = obj.EyeTracker.Calibration.Table;
                numGaze = size(tab, 1);
                
                % calib points
                pt_x_all = tab.PointX;
                pt_y_all = tab.PointY;
                pt_x_all = obj.ScaleValue(pt_x_all, 'rel2pxx');
                pt_y_all = obj.ScaleValue(pt_y_all, 'rel2pxy');
                pt_pos = obj.ScalePoint(obj.EyeTracker.Calibration.Points,...
                    'rel2px');
                pt_x = pt_pos(:, 1);
                pt_y = pt_pos(:, 2);
                % convert x, y to rect for drawing by PTB
                numPoints = length(pt_x);
                pt_rect = zeros(4, numPoints);
                for pt = 1:numPoints
                    pt_rect(:, pt) =...
                        teRectFromDims(pt_x(pt), pt_y(pt), sz_pt, sz_pt)';
                end                
                % draw points
                Screen('FillOval', obj.prETCalibTexture, col_pt, pt_rect, 3);
                
                % gaze points
                g_l = obj.ScalePoint([tab.LeftX, tab.LeftY], 'rel2px')';
                g_r = obj.ScalePoint([tab.RightX, tab.RightY], 'rel2px')';
                % colours - left 
                val_l = tab.LeftValidity;
                numLeftInval = sum(~val_l);
                g_col_l = repmat(col_val_l', 1, numGaze);
                g_col_l(:, ~val_l) = repmat(col_inval_l', 1, numLeftInval);
                % colours - right
                val_r = tab.RightValidity;
                numRightInval = sum(~val_r);
                g_col_r = repmat(col_val_r', 1, numGaze);
                g_col_r(:, ~val_r) = repmat(col_inval_r', 1, numRightInval);
                % combine points and colours for drawing
                g = [g_l, g_r];
                g_col = [g_col_l, g_col_r];
                % draw gaze 
                Screen('DrawDots', obj.prETCalibTexture, g, sz_g, g_col,...
                    [], 2);
                
                % coords for lines connecting points to gaze samples
                quiv_x = reshape([pt_x_all', pt_x_all'; g(1, :)], 1, []);
                quiv_y = reshape([pt_y_all', pt_y_all'; g(2, :)], 1, []);
                quiv_coords = [quiv_x; quiv_y];
                % draw quiver
                g_col(4, :) = 30;
                Screen('DrawLines', obj.prETCalibTexture, quiv_coords,...
                    2, [g_col, g_col]);
                
                % draw accuracy and precision
                alx     = obj.EyeTracker.Calibration.Summary.LeftX;                 % accuracy left x
                aly     = obj.EyeTracker.Calibration.Summary.LeftY;                 % accuracy lefy y
                arx     = obj.EyeTracker.Calibration.Summary.RightX;                % accuracy right x
                ary     = obj.EyeTracker.Calibration.Summary.RightY;                % accuracy right y
                prec_ln = obj.EyeTracker.Calibration.Summary.LeftPrecision_norm;    % precision left
                prec_rn = obj.EyeTracker.Calibration.Summary.RightPrecision_norm;   % precision right
                prec_lxn= obj.EyeTracker.Calibration.Summary.LeftPrecisionX_norm;   % precision left x
                prec_lyn= obj.EyeTracker.Calibration.Summary.LeftPrecisionY_norm;   % precision left y
                prec_rxn= obj.EyeTracker.Calibration.Summary.RightPrecisionX_norm;  % precision right x                 
                prec_ryn= obj.EyeTracker.Calibration.Summary.RightPrecisionY_norm;  % precision right y                 
                
                % rescale to pixels
                apos_l  = obj.ScalePoint([alx, aly], 'rel2px');
                apos_r  = obj.ScalePoint([arx, ary], 'rel2px');
                aw_l    = obj.ScalePoint([prec_lxn, prec_lyn], 'rel2px');
                aw_r    = obj.ScalePoint([prec_rxn, prec_ryn], 'rel2px');
                
                % make rects
                arect_l = arrayfun(@(x, y, w, h) teRectFromDims(...
                    x, y, w, h), apos_l(:, 1), apos_l(:, 2), aw_l(:, 1), aw_l(:, 2),...
                    'uniform', false);
                arect_r = arrayfun(@(x, y, w, h) teRectFromDims(...
                    x, y, w, h), apos_r(:, 1), apos_r(:, 2), aw_r(:, 1), aw_r(:, 2),...
                    'uniform', false);  
                
                % draw left and right accuracy
                Screen('FrameOval', obj.prETCalibTexture, col_val_l,...
                    vertcat(arect_l{:})', 3);
                Screen('FrameOval', obj.prETCalibTexture, col_val_r,...
                    vertcat(arect_r{:})', 3);     
                
                % print accuracy and precision
                val     = obj.EyeTracker.Calibration.Summary.Valid;
                % get vars
                acc_l   = obj.EyeTracker.Calibration.Summary.LeftAccuracy_deg;
                prec_l  = obj.EyeTracker.Calibration.Summary.LeftPrecision_deg;
                acc_r   = obj.EyeTracker.Calibration.Summary.RightAccuracy_deg;
                prec_r  = obj.EyeTracker.Calibration.Summary.RightPrecision_deg;
                % compute text position
                tx      = obj.EyeTracker.Calibration.Summary.PointX;
                ty      = obj.EyeTracker.Calibration.Summary.PointY + .05;
                tw      = obj.ScaleValue(.2, 'rel2pxx');
                th      = obj.ScaleValue(.2, 'rel2pxy');
                tpos    = obj.ScalePoint([tx, ty], 'rel2px');
                trect   = arrayfun(@(x, y) teRectFromDims(x, y, tw, th),...
                    tpos(:, 1), tpos(:, 2), 'uniform', false);
                % colour by validity
                tcol    = repmat({col_pt}, numel(val), 1);
                tcol(~val) = repmat({[220, 000, 000]}, sum(~val), 1);
                % make string
                tdeg    = char(176);
                tstr    = arrayfun(@(acc_l, prec_l, acc_r, prec_r)...
                    sprintf('Left: %.2f%s (%.2f%s)\nRight: %.2f%s (%.2f%s)',...
                    acc_l, tdeg, prec_l, tdeg, acc_r, tdeg, prec_r, tdeg),...
                    acc_l, prec_l, acc_r, prec_r, 'uniform', false);
                % draw shadow
                cellfun(@(str, rect) DrawFormattedText(obj.prETCalibTexture,...
                    str, 'center', 'center', [000, 000, 000], [], [], [], [], [],...
                    rect + 1), tstr, trect);                
                % draw text
                cellfun(@(str, rect, col) DrawFormattedText(obj.prETCalibTexture,...
                    str, 'center', 'center', col, [], [], [], [], [],...
                    rect), tstr, trect, tcol);           
            else
                    DrawFormattedText(obj.prETCalibTexture,...
                    'No valid calibration', 'center', 'center', col_pt);
            end
        end
        
        % keyboards
        function InitialiseKeyboards(obj)
            % clear collection
            obj.Keyboards = teCollection('struct');
            obj.prKeyboardAssignment = teCollection('double');
            obj.prActiveKeyboard = [];
            % get all keyboard data
            [kIdx, kName, kInfo] = GetKeyboardIndices;
            if isempty(kIdx)
                error('No keyboards found.')
            end
            % loop through and store
            for k = 1:length(kIdx)
                % if keyboard name is blank, use a generic name. It seems
                % that PTB sometimes doesn't return a name
                if isempty(kName{k})
                    kName{k} = sprintf('Keyboard_%02d', k);
                end
                % if no keyboard name, exclude it
                if ~isempty(kName{k})
                    kInfo{k}.idx = kIdx(k);
                    obj.Keyboards(kName{k}) = kInfo{k};
                end
            end
            teEcho('Found %d keyboards.\n', obj.Keyboards.Count);
            % assign the first keyboard that was found to be the default,
            % operator, and participant keyboard. This is a good default
            % for getting things up and running, regardless of the number
            % of attached keyboards. 
            obj.AssignKeyboard('default', obj.Keyboards.Keys{1});
            obj.AssignKeyboard('operator', obj.Keyboards.Keys{1});
            obj.AssignKeyboard('participant', obj.Keyboards.Keys{1});
            obj.SwitchKeyboard('default');
        end
        
        function AssignKeyboard(obj, assignedName, keyboardName)
            % if no keyboards known, try initialising, otherwise throw an
            % error
            if obj.Keyboards.Count == 0
                obj.InitialiseKeyboards
                if obj.Keyboards.Count == 0
                    error('No keyboards found.')
                end
            end
            if exist('keyboardName', 'var') && ~isempty(keyboardName)
                % if a keyboard name was supplied, look this up 
                kb = obj.Keyboards(keyboardName);
                if isempty(kb)
                    % specified keyboard name not found. If there is
                    % exactly one keyboard that has been found, then warn
                    % and default to that keyboard. Otherwise, throw an
                    % error. 
                    if obj.Keyboards.Count == 1
                        obj.AssignKeyboard(assignedName, obj.Keyboards.Keys{1})
                        warning('No keyboard with name ''%s'' was found, default keyboard %s used instead.',...
                            keyboardName, obj.Keyboards.Keys{1})
                        return
                    else
                        error('No keyboard with name ''%s'' was found.', keyboardName)
                    end
                else
                    % get keyboard device idx
                    dev = kb.idx;
                end
            else
                % no keyboard name was supplied, so the user must press a
                % key to identify a keyboard to assign
                teEcho('Found %d keyboards.\n\nRepeatedly press the Tab key on the keyboard you wish to designate as\nthe %s keyboard\n\n',...
                    obj.Keyboards.Count, assignedName);
                % repeatedly loop through keyboards until a keypress is
                % detected
                ListenChar(2)
                pressed = false;
                while ~pressed
                    for k = 1:obj.Keyboards.Count
                        % create a queue for the current keyboard
                        dev = obj.Keyboards(k).idx;
                        KbQueueCreate(dev);
                        KbQueueStart(dev);
                        WaitSecs(0.1);
                        pressed = KbQueueCheck(dev);
                        KbQueueStop(dev)
                        if pressed, break, end
                    end
                end
                ListenChar
                keyboardName = obj.Keyboards.Keys{k};
            end
            % store assignment
            kba = obj.prKeyboardAssignment(assignedName);
            if isempty(kba)
                % add a new entry
                obj.prKeyboardAssignment(assignedName) = dev;
            else
                % update existing entry
                kba = dev;
            end
            % if only one keyboard, switch to it
            if length(obj.prKeyboardAssignment) == 1
                obj.SwitchKeyboard(assignedName)
            end
            % reports
            teEcho('Assigned the keyboard named ''%s'' to be the ''%s'' keyboard.\n',...
                keyboardName, assignedName);
        end
        
        function SwitchKeyboard(obj, assignedName)
            % search for an assigned keyboard 
            dev = obj.prKeyboardAssignment(assignedName);
            if isempty(dev)
                error('No keyboard with assigned name %s found.',...
                    assignedName)
            else
                % start listening
                KbQueueCreate(dev);
                KbQueueStart(dev);
                obj.prActiveKeyboard = dev;
                teEcho('Switched to the %s keyboard\n', assignedName);
            end 
        end
        
        function KeyFlush(obj)
            if isempty(obj.prActiveKeyboard)
                error('No active keyboard has been set.')
            else
                KbQueueFlush(obj.prActiveKeyboard);
                obj.prKB_empty = true;
            end
        end

        function KeyUpdate(obj)
        % query the keyboard queue, and get any key press events since the
        % last check. In general, this wil be checked on each screen
        % refresh. When a key is pressed, a timestamp is returned
        % indiciating the onset time. 
        %
        % Once the buffer queried, check for particular special keys that
        % perform useful actions (such as 'r' to recalib). These checks
        % only happen when a session has started, so as to avoid
        % registering keypress events during debugging etc.
        
            % if no active keyborad defined, give up. This shouldn't happen
            % as the presenter shouldn't get this far without an active
            % keyboard, but better to check 
            if isempty(obj.prActiveKeyboard)
                return
            end
            
            % query keyboard queue, store resulst and timestamps in private
            % variables
            [obj.prKB_pressed, obj.prKB_firstPress,...
                obj.prKB_firstRelease, obj.prKB_lastPress,...
                obj.prKB_lastRelease] = KbQueueCheck(obj.prActiveKeyboard);
            % set keyboard empty flag to false
            obj.prKB_empty = false;
            
        % check for special keys, and process accordingly...
        
            % if session is not started yet, give up
            if ~obj.prSessionStarted, return, end
            
            % quit request - by default this is 'q' and needs to be pressed
            % twice, so as to avoid accidental keypresses
            if obj.KeyPressed(obj.KB_QUIT)
                
                % update the quit request level:
                %   0 = do nothing
                %   1 = present message indicating that another keypress
                %       will end the session
                %   2 = actually quit
                obj.prQuitRequestLevel = obj.prQuitRequestLevel + 1;
                
                % process quit request level
                switch obj.prQuitRequestLevel
                    
                    case 1
                        % present message
                        teTitle(sprintf('Quit Requested. Press %s a second time to confirm',...
                           obj.KB_QUIT));
                        teLine;
                        % send event
                        obj.AddLog(...
                            'source',   'presenter',...
                            'topic',    'housekeeping',...
                            'data',     'FIRST_QUIT_REQUEST')                          
                        
                    case 2
                        % actually quit
                        teTitle('Quitting, waiting for tasks to finish...');
                        teLine;
                        % set exit trial now flag, which all tasks should
                        % respect. this will cause any loops to exit. If
                        % tasks don't respect this flag then we have to
                        % wait until the end of the current trial before a
                        % quite will happen
                        obj.ExitTrialNow = true;
                        % send event
                        obj.AddLog(...
                            'source',   'presenter',...
                            'topic',    'housekeeping',...
                            'data',     'SECOND_QUIT_REQUEST')                           
                end
                
            end
            
            % check for pause request    
            if obj.KeyPressed(obj.KB_PAUSE)
                ov = obj.PauseRequested;
                obj.PauseRequested = ~obj.PauseRequested;
                if obj.PauseRequested && ~ov
                    teTitle('Pause requested, waiting for trial to end...'); teLine
                elseif ~obj.PauseRequested && ov
                    teEcho('Pause request cancelled\n');
                end
            end
            
            % check for calib request    
            if obj.KeyPressed(obj.KB_ET_RECALIBRATE)
                ov = obj.CalibRequested;
                obj.CalibRequested = ~obj.CalibRequested;
                if obj.CalibRequested && ~ov && ~obj.Paused
                    teTitle('Recalibration requested, waiting for trial to end...'); teLine
                elseif ~obj.CalibRequested && ov
                    teEcho('Recalibration request cancelled\n');
                end
            end
            
            % check for attention grabber
            if obj.KeyPressed(obj.KB_ATTGRAB_A)
                obj.PlayAuditoryAttentionGetter
            end
            if obj.KeyPressed(obj.KB_ATTGRAB_V)
                obj.PlayVisualAttentionGetter
            end
            
        end
        
        function [pressed, when, duration] = KeyPressed(obj, keyName)
            if nargin == 1
                keyName = [];
            end
            [pressed, when, duration] =...
                obj.KeyQuery(keyName, 'prKB_lastPress');
        end
        
        function [released, when, duration] = KeyReleased(obj, keyName)
            if nargin == 1
                keyName = [];
            end            
            [released, when, duration] =...
                obj.KeyQuery(keyName, 'prKB_lastRelease');
        end
        
        function [pressed, when, duration] = KeyQuery(obj, keyName, event)
            if isempty(obj.prActiveKeyboard)
                error('No active keyboard has been set.')
            end
            % if the key buffer is empty, return
            if obj.prKB_empty
                pressed = false;
                when = [];
                duration = [];
                return
            end
            % if passed with no arg, return whether any key was pressed
            if isempty(keyName) && obj.prKB_pressed
                pressed = true;
                % return most recent timestamp of a keypress
                valPress = obj.(event) > 0;
                when = min(obj.(event)(valPress));
            elseif ~isempty(keyName) && obj.prKB_pressed
                keyIdx = KbName(keyName);
                pressed = obj.(event)(keyIdx) ~= 0;
                when = obj.(event)(keyIdx);
            else
                pressed = false;
                when = [];
            end
            duration = teGetSecs - when;
        end
        
        % lists
        function [comp, map, taskKey, trialCounter] =...
                CompileList(obj, val, level, trialCounter)
            % convert a list to a compiled list of task instructions, and
            % an overview hierarchical map. This method can recurse, so the
            % outputs are optionally passed as inputs. 
            
            % check/retrieve list
            list = obj.AssertList(val);
            % if not passed, init output vars
            comp = {};
            map = {};
            taskKey = {};
            if ~exist('level', 'var') || isempty(level)
                level = 1;
            end
            if ~exist('trialCounter', 'var') || isempty(trialCounter)
                trialCounter = 0;
            end
            % calculate list sampling - needed in case a block list is
            % called multple times, in which case we want the randomisation
            % to be different each time it is called
            list.CalculateSampling;
            % loop through
            samples = list.SampleTable;
            numSamp = size(samples, 1);
            for l = 1:numSamp
                % compile current list item
                [tmpComp, tmpMap, tmpTaskKeys, level, trialCounter] =...
                    obj.CompileListItem(list, samples(l, :), level,...
                    trialCounter);
%                 % empty storage vars
%                 tmpComp = {};
%                 tmpMap = {};
%                 tmpTaskKeys = {};  
                % append
                comp        = [comp; tmpComp];
                map         = [map; tmpMap];
                taskKey     = [taskKey; tmpTaskKeys];
            end
            
            % if this is the end of the first level (i.e. no more
            % recursion - compilation is complete) then store the
            % results in the list            
            if level == 1
                list.prComp = comp;
                list.prMap = obj.MakeMapChar(map);
                list.prMapList = map;
                list.prTaskKey = taskKey;
                list.IsCompiled = true;                
            end
        end
        
        function [comp, map, taskKey, level, trialCounter] = ...
                CompileListItem(obj, list, sample, level, trialCounter)
            % process list item based on type
            switch lower(sample.Type{1})
                case {'trial', 'function', 'eck'}
                    % check task exists
                    if ~isempty(sample.Task)
                        % get task key
                        taskKey{1} = sample.Task;
                        % check if it has been registered with the presenter
                        if isempty(obj.Tasks(taskKey{1}))
                            error('Task [%s] not found in %s.',...
                                sample.Task, list.Name)
                        end
                    end
                    % check function exists
                    if exist(sample.Target{1}, 'file') ~= 2
                        error('Function [%s] not found in %s.',...
                            sample.Target{1}, list.Name)
                    end
                    % encapsulate data in struct
                    comp{1} = table2struct(sample);
                    % store current list
                    comp{1}.ParentList = list;
                    % write map entry
                    trialCounter = trialCounter + 1;
                    task      = sample.Task{1};
                    if isempty(task)
                        task = '';
                        target = sample.Target{1};
                    else
                        task = sample.Task{1};
                        target = sprintf('(%s)', sample.Target{1});
                    end
                    map{1, 1} = sample.Type{1};
                    map{1, 2} = sprintf('%s %s', task, target);
                    map{1, 3} = level;
                    map{1, 4} = trialCounter;

                case 'nestedlist'
                    % check list exists
                    if isempty(obj.Lists(sample.Target{1}))
                        error('List [%s] not found in %s at %d.',...
                            sample.Target{1}, list.Name, l)
                    end
                    % recurse - first look up target list, then set
                    % start sample and num sample according to values
                    % in current list
                    nestedList = obj.Lists(sample.Target{1});
                    if ~isempty(sample.NumSamples(1)) &&...
                            ~isnan(sample.NumSamples(1))
                        nestedList.prNumSamples = sample.NumSamples(1);
                    end
                    if ~isempty(sample.StartSample(1)) &&...
                            ~isnan(sample.StartSample(1))
                        nestedList.prStartSample = sample.StartSample(1);
                    end
                    % call compile method recursively
                    [comp, map, taskKey, trialCounter] =...
                        obj.CompileList(nestedList, level + 1,...
                        trialCounter);
                    % add parent vars
                    parentComp = table2struct(sample); 
                    parentComp = rmfield(parentComp, {'Type', 'Target',...
                        'Task', 'StartSample', 'NumSamples', 'Key'});
                    if ~isempty(parentComp)
                        comp  = cellfun(@(x) catstruct(x, parentComp),...
                            comp, 'uniform', false);
                    end
                    % insert list name as header into map
                    map = [{sample.Type{1}, sample.Target{1},...
                        level}, nan; map];
            end
        end
        
        function map_char = MakeMapChar(obj, map, pos)
            if ~exist('pos', 'var') 
                pos = nan;
            end

            % define symbol codes
            open_triangle = char(9655);
            closed_triangle = char(9654);
            down_triangle = char(9661);
%             closed_end_triangle = char(9664);
            tl_corner = char(9487);
            tr_corner = char(9491);
            bl_corner = char(9495);
            br_corner = char(9499);
            horiz = char(9473);
            % convert map to text
            map_char = '';
            tc = 0;
            for m = 1:size(map, 1)
                
                if ~strcmpi(map{m, 1}, 'nestedlist')
                    tc = tc + 1;
                end
                
                % tabs
                tab_char = '';
                for tab = 1:map{m, 3}
                    tab_char = [tab_char, sprintf('   ')];
                end
                bar_char = sprintf('%s', 9475);

                % define separator - if it matches the current pos then use
                % a closed triangle
                    if map{m, 4} == pos
%                     msgbox(sprintf('%d_%d',m,pos))
                    % at position
                    sep = closed_triangle;
                    sep_end = bar_char;
                    item_name = upper(map{m, 2});
%                     item_name = map{m, 2};
                    horiz_item = repmat(horiz, 1, length(item_name) + length(sep) + 4);
                    pos_pre = [tab_char, tl_corner, horiz_item, tr_corner, newline];
                    pos_post = [tab_char, bl_corner, horiz_item, br_corner, newline];
                else
                    % not at position
                    sep = open_triangle;
                    sep_end = '';
                    item_name = map{m, 2};
                    pos_pre = '';
                    pos_post = '';
                end
                
                  % target and type
                if strcmpi(map{m, 1}, 'nestedlist')
                    sep = down_triangle;
%                 else
%                     tc = tc + 1;
                end
                
                % item
                item_char = sprintf(' %s %s ', sep, item_name, sep_end);
                map_char = [map_char, pos_pre, tab_char, bar_char, item_char, newline, pos_post];
            end 
            
        end
        
        function ExecuteList(obj, val, startSample, numSamples)
            % check window is open
            if ~obj.WindowOpen
                error('Window not open.')
            end
            % check session has started
            if ~obj.prSessionStarted
                error('Cannot execute a list until a session has started.')
            end
            
            %% set up list / compile
            
            % check/retrieve list
            list = obj.AssertList(val);
            
            % does list neeed compiling?
            if ~list.IsCompiled
                % compile
                [comp, map] = obj.CompileList(val);
                % start at first listitem
                if nargin >= 3
                    startItem = startSample;
                else
                    startItem = 1;
                end
                % log
                obj.AddLog(...
                    'source',   list.Name,...
                    'topic',    'list_management',...
                    'data',     'compiled_list')                
            else
                % retrieve compiled vars from list
                comp = list.prComp;
                map = list.prMap;                                                                                                                                                           
                % start at most recent listitem (can be overridden by input
                % arg)
                if nargin >= 3
                    startItem = startSample;
                else
                    startItem = list.prCompIdx;
                end
                % log
                obj.AddLog(...
                    'source',   list.Name,...
                    'topic',    'list_management',...
                    'data',     'retrieved_compiled_vars')                  
            end
            
            % determine number of samples (default whole list, but can be
            % overridden with numSamples input arg)
            if nargin >= 4
                endItem = startItem + numSamples - 1;
                % bounds correct
                if endItem > size(comp, 1)
                    endItem = size(comp, 1);
                end
            elseif nargin <= 4
                % default
                endItem = size(comp, 1);
            end
            obj.AddLog(...
                'source',   list.Name,...
                'topic',    'list_management',...
                'data',     'list_onset')
            
            % default empty task instance
            thisTask = [];
            
            %% execute
            
            % store execution time
            obj.prListExecutionTime = teGetSecs;
            obj.prListExecutionStartSample = startItem;
            
            % clear AOIs
            obj.EyeTracker.AOIs.Clear;
            
            % loop and execute
            obj.prCurrentTask = [];
            i = startItem;
            while i <= endItem
                
                % if the .Enabled flag is not set, then skip this trial
                if ~comp{i}.Enabled
                    i = i + 1;
                    continue
                end
                
                % draw map to command window
                obj.DrawMapToCommandWindow(list.prMapList, i)      
                
                % set current trial GUID
                obj.prCurrentTrialGUID = GetGUID;
                
            % here we begin executing an list item. This may be a trial (or
            % ECK trial), or a nested list. First, we set a flag for
            % whether it is one of the two forms of trial
                
                % flag for item type
                isTrial = strcmpi(comp{i}.Type, 'trial');
                isECK = strcmpi(comp{i}.Type, 'ECK');    
                    
            % determine whether this list item represents a change in task
            % from the previous item. First get the current task, then get
            % the next task, and compare to determine whether a change has
            % occurred
             
                % check/change current task
                curTask = comp{i}.Task;
                
                % retrieve task intance
                thisTask = obj.Tasks(curTask);
                    
                % check next task
                if i < endItem
                    nextTask = comp{i + 1}.Task;
                else
                    nextTask = [];
                end
                
                % determine whether this is the last task in the list
                finalTaskInList = i == endItem - 1;
                
                % determine whether the task is changing 
                taskIsChanging = ~isempty(curTask) &&...
                    ~isequal(obj.prCurrentTask, curTask);
                
                % determine whether to process a task change
                processTaskChange = taskIsChanging || finalTaskInList;

                % increment task trial number 
                if isTrial
                    thisTask.TrialNo = thisTask.TrialNo + 1;
                end
                
            % if the task has changed, then store this in the prCurrentTask
            % property, and manage stimuli. This involves unloading all
            % stimuli from the previous task, and loading stimuli from the
            % current task
                
                if processTaskChange 
                                        
                    % record previous task
                    oldTask = obj.prCurrentTask;
                    
                    % get the indices of stimuli belonging to both the old
                    % task, and the new task
                    oldStimIdx = strcmpi(obj.Stim.Task, oldTask);
                    newStimIdx = strcmpi(obj.Stim.Task, curTask);
                    
                    % if there was a previous task, send an offset event
                    % for it, and then close any stimuli associated with it
                    if ~isempty(oldTask)
                        
                        % send task offset event
                        obj.AddLog(...
                            'source',   oldTask,...
                            'topic',    'task_change',...
                            'data',     'task_offset')      
                        
                        % close stimuli
                        if any(oldStimIdx)
                            % loop through stim
                            for s = 1:obj.Stim.Count
                                if oldStimIdx(s) 
                                    obj.CloseStim(obj.Stim(s));
                                end
                            end
                        end                        
                        
                    end
                    
                    % if there is a current task, open and prepare it's
                    % stimuli
                    if any(newStimIdx)
                        % loop through stim
                        for s = 1:obj.Stim.Count
                            if newStimIdx(s) && ~obj.Stim(s).isPrepared
                                obj.PrepareStim(obj.Stim(s));
                            end
                        end
                    end
                    
                    % set new task
                    obj.prCurrentTask = curTask;
                    
                    % log task onset
                    obj.AddLog(...
                        'source',   curTask,...
                        'topic',    'task_change',...
                        'data',     'task_onset')
                    
                end       
                
            % determine whether the next task will be different to the
            % current one. This allows a task to perform housekeeping/clean
            % up etc. 
                
                thisTask.NextTaskWillChange = ~isempty(nextTask) &&...
                    ~isempty(curTask) && ~isequal(curTask, nextTask);
                
            % is this is a trial (as opposed to a list) send a trial onset 
            % log item
                
                obj.AddLog(...
                    'source',   curTask,...
                    'topic',    'trial_change',...
                    'data',     'trial_onset')                
                
            % perform some updates before executing the current item
                
                % update keyboard
                obj.KeyFlush
                obj.KeyUpdate
                
                % update eye tracker
                if obj.EyeTracker.Valid
                    obj.EyeTracker.Update;
                end
                
                % start animating
                if isTrial || isECK
                    obj.Animating = true;
                end
                
            % make a copy of tracker variables (ID etc.) in the variables
            % structure for this item. This ensures a) that this
            % information is available to the trial/list code, and b) that
            % these variables get logged in the trial log data
                
                % gather additional vars for execution
                trackerVars = obj.Tracker.prVariables(:, 1);
                for v = 1:length(trackerVars)
                    comp{i}.(trackerVars{v}) = obj.Tracker.(trackerVars{v});
                end
                
                
            % prepare vars struct. Before a trial is called, this will
            % contain the variables pulled from the compiled list (and so
            % is essentially the 'comp' variable of the list). Store this
            % in the presenter, so that it is available to other methods,
            % for example, this allows the SendEvent method to write
            % timestamps for each event to the struct, without the calling
            % trial function having to pass the struct around manually
                
                vars = hstruct(comp{i});
                vars.TrialGUID = obj.CurrentTrialGUID;
                obj.CurrentVariables = vars;
                
            % execute the target function. If the list item is of type
            % 'eck' then first set some variables for backwards
            % compatibility, and rejig the output log data to put it into
            % te2 format. 
            % note that if the HandleTrialErrors property is true then the
            % target will be executed within a try/catch block, so that
            % errors in trial code don't stop the whole session. This can
            % be switched off, usually for debugging purposes, in which
            % case the session will stop on an error. 
            
                onset = teGetSecs;
                switch lower(comp{i}.Type)
                    case 'eck'
                        
                        % copy NumSamples field to NumTrials for backward
                        % compatiblity
                        vars.NumTrials = vars.NumSamples;
                        
                        % make legacy variables on ECK format
                        varTrack = obj.Tracker;
                        varLog = obj.Log;
                        varVars = struct2cell(vars)';
                        varVarNames = fieldnames(vars)';
                        curSample = i;
                        
                        % execute, with optional try/catch block for error
                        % handling
                        if obj.HandleTrialErrors
                            try
                                vars = feval(vars.Target, obj,...
                                    varTrack, varLog, varVars, varVarNames,...
                                    curSample);
                            catch trialERR
                                obj.WarnOfTrialError(trialERR, vars)
                            end
                            
                        else
                            % execute without any error handling
                            vars = feval(vars.Target, obj,...
                                varTrack, varLog, varVars, varVarNames,...
                                curSample);       
                            
                        end
                        
                        % process output as ECK, convert to struct
                        hdr = fixTableVariableNames(vars.Headings);
                        vars = cell2struct(vars.Data, hdr, 2);
                        
                    otherwise
                        % excute, te2-style, with optional error handling
                        if obj.HandleTrialErrors
                            try
                                vars = feval(vars.Target, obj, vars, thisTask);
                            catch trialERR
                                obj.WarnOfTrialError(trialERR, vars)
                            end
                            
                        else
                            % execute without error 
                            vars = feval(vars.Target, obj, vars, thisTask);
                        end
                        
                end
                offset = teGetSecs;
                
                % stop animating
                if isTrial || isECK 
                    obj.Animating = false;
                end      
                
            % run eye tracker data quality report (if eye tracker is
            % valid). This will append proportion/time looking to the
            % log output
            
                % get number of log items to append
                numItems = numel(vars);
                    
                if obj.EyeTracker.Valid
                    dq = obj.EyeTracker.GetQCMetrics(onset, offset);
                    % if returns empty, there is no data
                    if isempty(dq)
                        dq.looking_prop = nan;
                        dq.looking_time = nan;
                    end
                    % loop through all items and add looking prop and time
                    for it = 1:numItems
                        vars(it).et_looking_prop = dq.looking_prop;
                        vars(it).et_looking_time = dq.looking_time;
                    end
                end

                % append log items returned by each trial to the
                % presenter's log array. General variables (such as the
                % presenter's trial on/offset timestamps and task version)
                % are added to the output before they are appended. This
                % ensures consistentcy of how trials are marked up,
                % regardless of what data the trial code itself stores.                 
                if isTrial || isECK
                    
                    % for each log item, append a timestamp, source and
                    % topic
                    for it = 1:numItems
                        vars(it).Timestamp = onset;
                        vars(it).Source = curTask;
                        vars(it).Topic = 'trial_log_data';
                        % append task version if available - todo this may
                        % need error checking if a task is not current
                        % active 
                        vars(it).TaskVersion = thisTask.VersionString;                        
                    end
                    
                    % if this is a trial, append the presenter's trial
                    % on/offset timestamps. These are rough markers which
                    % can be used for segmentation of a session into trials
                    if isTrial
                        % append trial on/offset
                        for it = 1:numItems
                            vars(it).Presenter_TrialOnset = onset;
                            vars(it).Presenter_TrialOffset = offset;
                        end
                    end

                    % add all items to log
                    obj.AddLog(vars);
                end
                
                % clear the current variables property, as the contents
                % now refers to the previous trial
                obj.CurrentVariables = struct;
                
                % do some updating (including flushing buffers and saving
                % to disk) UNLESS the task has marked this as unwanted (in
                % which case it will happen on the next change to a task
                % that HAS NOT marked this as unwanted)
                if thisTask.FlushBuffersOnTrialEnd
                    % update keyboard
                    obj.KeyFlush
                    obj.KeyUpdate
                    % flush buffer
                    obj.FlushBuffer
                end
                
            % is this is a trial (as opposed to a list), send a trial
            % offset event
                
                obj.AddLog(...
                    'source',   curTask,...
                    'topic',    'trial_change',...
                    'data',     'trial_offset')     
                
                % store current list index in list object
                list.prCompIdx = i;
                
                % if exit command sent, exit loop
                if obj.ExitTrialNow
                    obj.EndSession
                    break
                end
                
                % process pause
                if obj.PauseRequested, obj.Pause, end
                
                % process recalib 
                if obj.CalibRequested, obj.ETGetEyesAndCalibrate, end
                
                % perform trial end action
                switch lower(thisTask.TrialEndAction)
                    case 'continue'
                        % continue through the list - ?his is the default
                        % action 
                        i = i + 1;
                    case 'repeat'
                        % repeat the current trial - no action needed, we
                        % just don't increment the loop variable and leave
                        % the loop to run again
                    case 'resamplefromlist'
                        error('Not yet implemented')
%                         % choose another (random) sample from the current
%                         % list and add it to the compiled list, in position
%                         % to be executed on the next loop iteration. 
%                         % get list sample
%                         [~, newSample] =...
%                             thisTask.ParentList.SampleFromList([], 1);
%                         % compile
%                         level = comp{i}.level;
%                         trialCounter = thisTask.TrialNo;
%                         [tmpComp, tmpMap] = pres.CompileListItem(...
%                             [], [], [], 
%                         % insert into compiled list
%                         
%                         
%                         i = i + 1;
                end
            end
            
            %% clean up
            
            % clear trial GUID
            obj.prCurrentTrialGUID = [];
            
            % clear current task
            if ~isempty(obj.prCurrentTask)
                % close task stimuli
                oldStimIdx = strcmpi(obj.Stim.Task, obj.prCurrentTask);
                if any(oldStimIdx)
                    % loop through stim, open/close according to task
                    for s = 1:obj.Stim.Count
                        if oldStimIdx(s), obj.CloseStim(obj.Stim(s)); end
                    end
                end
                % log task change
                obj.AddLog(...
                    'source',   obj.prCurrentTask,...
                    'topic',    'task_change',...
                    'data',     'task_offset')    
                obj.prCurrentTask = [];
            end      
            
            % reset exit trial now command
            if obj.ExitTrialNow
                obj.ExitTrialNow = false;
                obj.prQuitRequestLevel = 0;
            end
            
            % clear AOIs
            obj.EyeTracker.AOIs.Clear;
            
            % log list finished
            obj.AddLog(...
                'source',   list.Name,...
                'topic',    'list_management',...
                'data',     'list_offset')
        end
        
        function DrawMapToCommandWindow(obj, map, pos)
        % draw the map of the current compiled list to the command
        % window. This gives the user an indication of where in the
        % list they are. 
        
            % select a portion of the map according to position
            s1 = pos;
            s2 = pos + obj.MapMaximumDisplayHeight - 1;
            % get indices of map rows
            mapIdx = cell2mat(map(:, 4));
            % check that positions are in bounds
            if s2 > max(mapIdx)
                rowsRem = 0;
                s2 = max(mapIdx);
            else
                rowsRem = max(mapIdx) - s2;
            end
            % get indices of map rows
            ms1 = find(mapIdx == s1, 1);
            ms2 = find(mapIdx == s2, 1);
            % chop map
            map = map(ms1:ms2, :);                
            % convert to char
            map_char = obj.MakeMapChar(map, pos);            
            % display
            clc
            % if not at the first position, display number of trials
            % already executed
            if pos ~= 1
                fprintf('\t+%d...\n', pos)
            end
            disp(map_char)
            % if more trials to come, display the number
            if rowsRem > 0
                fprintf('\t+%d...\n', rowsRem)
            end
            % calculate time elapsed and remaining
            elap_secs = teGetSecs - obj.prListExecutionTime;
            elap_str = datestr(elap_secs / 86400, 'HH:MM:SS');
            elap_num = pos - obj.prListExecutionStartSample;
            if elap_num > 0
                perTrial_secs = elap_secs / elap_num;
                rem_num = max(mapIdx) - pos + 1;
                rem_secs = perTrial_secs * rem_num;
                rem_str = datestr(rem_secs / 86400, 'HH:MM:SS');
                fprintf('\n\n[%d of %d] | Elapsed: %s | Remaining: %s\n',...
                    pos, max(mapIdx), elap_str, rem_str)
            end
        end

        function SaveList(obj, val, path)
            if obj.Lists.Count == 0
                error('No lists defined.')
            end            
            % look up list
            list = obj.Lists(val);
            if isempty(list)
                error('List %s not found.', val);
            end
            try
                save(path, 'list')
            catch ERR
                error('Error saving list. Error was:\n\n%s', ERR.message)
            end
        end
        
        function SaveAllLists(obj, path)
            if obj.Lists.Count == 0
                error('No lists defined.')
            end
            lists = obj.Lists;
            try
                save(path, 'lists')
            catch ERR
                error('Error saving lists. Error was:\n\n%s', ERR.message)
            end
        end
        
        function LoadLists(obj, path)
            if ~exist(path, 'file') 
                error('File %s not found.', path);
            end
            try
                tmp = load(path);
            catch ERR
                error('Error loading lists. Error was:\n\n%s', ERR.message)
            end
            if ~isfield(tmp, 'lists') || ~isa(tmp.lists, 'teListCollection')
                error('Invalid file type - no lists found.')
            end
            if tmp.lists.Count == 0
                error('No lists in loaded collection.')
            end
            % check for unique keys
            if obj.Lists.Count > 0
                keys_current = obj.Lists.Keys;
                keys_loading = tmp.lists.Keys;
                inCurrent = cellfun(@(x) ismember(x, keys_current),...
                    keys_current);
                if any(inCurrent)
                    fprintf(2, '\t%s\n', keys_loading{inCurrent});
                    error('The above list keys already exist in the tePresenter list collection.')
                end
            end
            for l = 1:tmp.lists.Count
                key = tmp.lists.Keys{l};
                obj.Lists.AddItem(tmp.lists.Items(l), key);
            end
            teEcho('Loaded %d lists.\n', tmp.lists.Count);            
        end
        
        function ResetAllLists(obj)
            for l = 1:obj.Lists.Count
                obj.Lists(l).Reset;
            end
        end
        
        function WarnOfTrialError(obj, ERR, vars)
        % this method handles errors thrown within trial code, and is
        % called from ExecuteList. The intention is to allow the session to
        % continue when an error occurs, to warn the user, and to log it
        
            % ensure all struct fields are lowercase
            vars = structFieldsToLowercase(vars);
            
            % warn user
            teLine
            fprintf(2, '<strong>Task Engine caught an error in %s.</strong> The target function was not executed. The error was:\n\n%s',...
                vars.target, ERR.message)
            teLine
            
            % log to vars structure
            vars.ErrorMessage = ERR.message;
            vars.ErrorIdentifier = ERR.identifier;
            vars.ErrorFile = ERR.stack(1).file;
            vars.ErrorLine = ERR.stack(1).line;
            
            % log
            obj.AddLog(...
                'source',       vars.target,...
                'topic',        'trial_error',...
                'errorid',      ERR.identifier,...
                'errormessage', ERR.message,...
                'errorfile',    ERR.stack(1).file,...
                'errorline',    ERR.stack(1).line);
            
        end
        
        % event marking
        function when = SendEvent(obj, event, when, type)
        % process event sending. The actual sending happens in event
        % relays, so this method gets everything into shape and then passes
        % the event data to one or multple event relays. 
        %
        % the particular event relay can be specified using the 'type'
        % argument. If this is blank then the event will be passed to all
        % registered event relay. Note that some relays cannot handle
        % certain events (e.g. an EEG relay that handles only numeric
        % values from 0-255 can't handle a text label) - in this case they
        % will silently ignore the event. 
        %
        % 'when' is the timestamp at which the event happened. If this is
        % not passed then the current time is used. 'when' gets returned
        % from this method to the calling function. 
        %
        % in addition to sending the event, this method can optionally be
        % passed a 'vars' struct - the variable data that is sent to each
        % task by the presenter, and then used to form a log file. Passing
        % a 'vars' struct to this method means that temporal events (e.g.
        % 'TRIAL_ONSET') will be added to the log data as a variable name
        % and a timestamp. This means that sending, e.g. a trial onset as
        % an event will also log that event label and the timestamp into
        % the log file. 
        
        % if no event relays have been set up, an event can't be sent.
        % Display a warniing and return
            if isempty(obj.EventRelays)
                warning('No event relays defined - event will not be sent.')
                return
            end
        
        % check input args
        
            % check for timestamp, if not passed, use current time
            if nargin <= 2 || isempty(when)
                when = teGetSecs;
            end
            
            % check for type, if not passed, make empty
            if nargin <= 3 
                type = [];
            end
            
            % check input args
            if isempty(event)
                error('Cannot send an empty event.')
            end
            if ~isnumeric(when) || ~isscalar(when) || when < 0
                error('When (timestamp) argument must be a positive numeric scalar.')
            end
            
        % if a relay type has not been specified then send to all
        % relays. If it has been passed, then check that the
        % appropriate relay exists and send it to that
            
            if isempty(type)
                % no relay specified - send to all
                
                % check that at least one event relay haw been registered
                if isempty(obj.EventRelays)
                    warning('Attempted to send an event but no event relays have been registered. EVENT NOT SENT!')
                end
                % pass to all relays
                cellfun(@(x) x.SendEvent(event, when, obj.prCurrentTask),...
                    obj.EventRelays.Items);
                
            else
                % relay specified - send to that relay
                
                % check format of type (must be char)
                if ~ischar(type)
                    error('''type'' argument must be char (name of event relay).')
                end
                % look up event relay
                er = obj.EventRelays(type);
                % if no event relay is registered, then send to command
                % window with a warning indicating that the event was not
                % sent
                if isempty(er)
                    cprintf('*green',   '\n[');
                    cprintf('*green',   '%.4f', when);
                    cprintf('*green',   '] ');
                    cprintf('red',      'Event relay %s not registered - EVENT NOT SENT\n', type)
                    return
                end
                % pass to requested relay
                er.SendEvent(event, when, obj.prCurrentTask);
                
            end 
            
        % update vars struct
        
            % if current variables structure is empty, don't add. We only
            % want this to happen during trials, in which case some
            % variables will exist
            if ~isempty(obj.CurrentVariables)
        
                % if current event is not a valid field name for the vars
                % struct, attempt to make it. First check for numeric and
                % convert to char
                if isnumeric(event)
                    event = num2str(event);
                end

                % we only add chars (text labels, essentially) to the current
                % variables (vars) struct. If the event is char, then check it
                % is a valid matlab variable name, and if not try to fix it. If
                % that doesn't work, then skip adding it by setting even to
                % empty.
                if ischar(event)

                    % check it is a valid variable name, if not, attempt to fix
                    % it
                    if ~isvarname(event)
                        try
                            event = matlab.lang.makeValidName(event);
                        catch ERR
                            event = [];
                        end
                    end

                    % if the event is not empty (i.e. is valid), add it to current
                    % variables. 
                    if ~isempty(event)
                        obj.CurrentVariables.(event) = when;
                    end
                    
                end
                
            end
            
        end
        
        function SendRegisteredEvent(obj, key, when)
        % send an event that has previously been registered with the
        % presenter in the 'Events' property. This allows one event to have
        % data for different types of receiving hardware/software. For
        % example, an event can have a .eeg field, with a value that will
        % only be passed to event relays named 'eeg'. Any relays not
        % specified with a value (such as .eeg) will get the collection key
        % (effectively a text label describing the event) passed to them.
        %
        %   event       can be a text key for lookup in the collection, or
        %               a struct containing event info
        %   
        % All other input arguments are idential to the SendEvent method
        
        % check input args
        
            % check for timestamp, if not passed, use current time
            if nargin <= 2 || isempty(when)
                when = teGetSecs;
            end
            % check input args
            if isempty(key)
                error('Cannot send an empty event.')
            end
            if ~isnumeric(when) || ~isscalar(when) || when < 0
                error('When (timestamp) argument must be a positive numeric scalar.')
            end
            
            % determine event type
            if ischar(key)
                % look up event in collection
                event = obj.Events(key);
                % check it exists
                if isempty(event)
                    error('Event ''%s'' not found in collection.',...
                        key)
                end
            else
                error('''key'' must be a char containing the key to an element in the Events collection.')
            end

            
        % loop through all registered event relays, and attempt to match
        % the relay name to any event types. If found, send the appropriate
        % value to that relay. If not found, send the event label to the
        % relay. 
        
            % warn if no event relays
            if isempty(obj.EventRelays)
                warning('No event relays defined, marker will not be sent.')
            end
            % get all event types from event
            types = fieldnames(event);
            % remove 'task' field (since this is not an event type)
            types(strcmpi(types, 'task')) = [];
            % loop through relays
            for r = 1:obj.EventRelays.Count
                % get relay details
                relay_name = obj.EventRelays.Keys{r};
                relay = obj.EventRelays.Items{r};
                % attempt to match event type to relays
%                 match = find(ismember(relay_name, types));
                match = find(strcmp(types, relay_name));
                if isempty(match)
                    % not matched - pass label to relay
                    eventToSend = key;
                else
                    % matched - pass appropriate value to relay
                    eventToSend = event.(types{match});
                end
                % send event
                relay.SendEvent(eventToSend, when, event.task);
            end
            
        end
        
        % session management
        function StartSession(obj)
        % This is a place for important things to happen at the start of a
        % session. For example, starting the screen recording, timestamping
        % the video, starting the EEG recording, etc. 
        % A list cannot be executed until a session has started, which
        % ensures that all of the housekeeping here is complete before
        % tasks are run
            
        % general checks
        
            % check window open
            if ~obj.prWindowOpen
                error('Window not open.')
            end
            
            % check session not started
            if obj.prSessionStarted 
                error('Session already started.')
            end
            
            % check tracker is valid
            if ~obj.Tracker.Valid
                error('Tracker is not in a valid state.')
            end
            
            % can't start a session if editing a list
            if obj.prEditingList
                error('Cannot start a session whilst editing a list.')
            end
            
            % flush keyboard
            obj.KeyFlush
            obj.KeyUpdate
            
            % save tracker
            obj.Tracker.Save
            
            % start diary
            diary(obj.Tracker.Path_Diary)
            
            % message all event relays informing them that the session has
            % started. This allows, for example, NetStation to start an EEG
            % recording when the session starts
            if ~isempty(obj.EventRelays)
                cellfun(@(x) x.StartSession, obj.EventRelays.Items);
            end
            
            % start screen recording
            if obj.prRecordScreen
                obj.StartScreenRecording
            end
            
            % if stamping video, do it now
            if obj.StampVideoOnSessionStart
                % await user to confirm video is recording
                teTitle(sprintf('Press %s once screen recording has started...',...
                    obj.KB_MOVEON));
                % flush keyboard
                obj.KeyFlush
                obj.KeyUpdate
                % await keypress
                while ~obj.KeyPressed(obj.KB_MOVEON)
                    obj.KeyUpdate
                end              
                % start stamping
                obj.StampForVideo
                teLine;
            end
            
            % optionally disable keyboard
            if obj.DisableKeyboardDuringSession
                ListenChar(2);
            end
            
            % get teGetSecs and Posix time for reference
            [getSecsBase, posixBase] = GetSecs('AllClocks');
            
            % log relevant info (such as time, screen dimensions etc.)
            obj.prSessionStarted = true;
            obj.prSessionStartTime = getSecsBase;
            obj.Tracker.SessionStartTime = now;
            obj.AddLog(...
                'source', 'presenter',...
                'topic', 'session',...
                'data', 'session_onset',...
                'getsecstime', getSecsBase,...
                'posixtime', posixBase,...
                'windowlimitsenabled', obj.WindowLimitEnabled,...
                'windowlimits_w', obj.WindowLimitSize(1),...
                'windowlimits_h', obj.WindowLimitSize(2),...
                'drawingsize_w', obj.DrawingSize(1),...
                'drawingsize_h', obj.DrawingSize(2),...
                'resolution_w', obj.Resolution(1),...
                'resolution_h', obj.Resolution(2),...
                'monitorsize_w', obj.MonitorSize(1),...
                'monitorsize_h', obj.MonitorSize(2));
        end
        
        function EndSession(obj)
        % tidy up after a session. Largely this does the opposite of what
        % StartSession does
        
            if ~obj.prSessionStarted
%                 warning('Session not yet started.')
                return
            end
            
            % flush buffers
            obj.FlushBuffer 
            
            % end screen recording
            if obj.prCaptureStarted
                obj.StopScreenRecording;
                % finalise
                obj.Echo('Finalizing screen recording...')
                Screen('FinalizeMovie', obj.prCapturePtr);
                obj.Echo('done.\n')
            end
            
            % if stamping video, do it now
            if obj.StampVideoOnSessionStart           
                % start stamping
                obj.StampForVideo
                teTitle('Stop video recording now'); teLine
            end        
            
            % message all event relays informing them that the session has
            % ended
            if ~isempty(obj.EventRelays)
                cellfun(@(x) x.EndSession, obj.EventRelays.Items);
            end
            
            % re-enable keyboard
            ListenChar;
            obj.Tracker.SessionEndTime = now;
            obj.prSessionStarted = false;
            if obj.EyeTracker.Valid
                obj.EyeTracker.Save(obj.Tracker.Path_EyeTracker)
            end
            
            % get teGetSecs and Posix time for reference
            [getSecsBase, posixBase] = GetSecs('AllClocks'); 
            
            % log session end
            obj.AddLog(...
                'source', 'presenter',...
                'topic', 'session',...
                'data', 'session_offset',...
                'getsecstime', getSecsBase,...
                'posixtime', posixBase)
            
            % calculate session duration
            sesDur = obj.Tracker.SessionEndTime - obj.Tracker.SessionStartTime;
            % echo
            teTitle('Session ended.\n\n');
            teEcho('\tStart time:\t\t\t%s\n', obj.Tracker.SessionStartTimeString);
            teEcho('\tEnd time:\t\t\t%s\n', obj.Tracker.SessionEndTimeString);
            teEcho('\tSession duration:\t\t%s\n', datestr(sesDur, 'HH:MM:SS'));
            teLine
            
            % stop diary
            diary off
            obj.Tracker.Save
        end
        
        function FlushBuffer(obj)
           
            % update eye tracker buffers
            if obj.EyeTracker.Valid
                % update eye tracker to get freshest gaze data
                obj.EyeTracker.Update
                % increase size of eye tracker buffer
                obj.EyeTracker.FlushBuffer
                % eye tracker AOIs
                for a = 1:obj.EyeTracker.AOIs.Count
                    newSize = obj.EyeTracker.AOIs(a).CONST_DEF_BUFFER_SIZE +...
                        obj.EyeTracker.AOIs(a).prIdx;
                    obj.EyeTracker.AOIs(a).prBuffer(newSize) = nan;
                    obj.AddLog(...
                        'source', 'presenter', 'topic', 'buffering', 'data',...
                        sprintf('Buffer AOI %s increased to %d',...
                        obj.EyeTracker.AOIs.Keys{a}, newSize));                    
                end
            end
            
            % update tracker
            obj.Tracker.Log = obj.Log;
            obj.Tracker.Lists = obj.Lists;
            obj.Tracker.LastUpdate = now;
            obj.Tracker.RegisteredEvents = obj.Events;
            
            % flush event relays
            for er = 1:obj.EventRelays.Count
                relay = obj.EventRelays.Items(er);
                relay.Flush
            end
            
            % save using the fast method - note this will save a serialised
            % copy of the teTracker instance, for about a 10x speed
            % advantage. When the session is ended, this will be
            % overwritten with a non-serialised version
            obj.Tracker.Save('fast')
            if obj.EyeTracker.Valid
                obj.EyeTracker.Save(obj.Tracker.Path_EyeTracker, 'fast');
            end
            
        end
        
%         function [nowPosix, nowGS] = UpdatePosixOffset(obj)
%         % timestamps are stored in posix format, but in raw form they come
%         % from PTB's teGetSecs function which returns in a time format
%         % with a zero point when the computer was switched on. To enable
%         % converting teGetSecs timestamps to Posix, we need a conversion
%         % factor. This method calculate this and stores it in the
%         % presenter. 
%         
%             % get current time in both teGetSecs and Posix formats
%             [nowGS, nowPosix, ~] = teGetSecs('AllClocks');
% 
%             % calculate the offset between the two
%             obj.PosixTimeOffset = nowPosix - nowGS;
%             
%             % give the posix time conversion offset to the eye tracker
%             obj.EyeTracker.PosixTimeOffset = obj.PosixTimeOffset;
%         end
        
        % log
        function AddLog(obj, varargin)
            % if varargin is a list of fieldname/value pairs, create a
            % struct from it
            if ~all(cellfun(@isstruct, varargin))
                % build struct
                try
                    % Matlab's struct function interprets fields that are
                    % cell arrays as needing to be converted to a struct
                    % array, with each element of the cell being a field
                    % value on a seperate element of the struct array. To
                    % avoid this, we need to encapsulate the cell in a
                    % nested cell. Detect and do this now.
                    argIsCell = cellfun(@iscell, varargin);
                    argLens = cellfun(@length, varargin);
                    needsFixing = argIsCell & argLens > 1;
                    if any(needsFixing) 
                        warning('dealing witih cell log item - may cause problems.')
                        varargin(needsFixing) = cellfun(@(x) {x},...
                            varargin(needsFixing), 'uniform', false);
                    end
                    % build a struct from the input args, and put it into a
                    % cell array (since this function can support cell
                    % arrays of structs - i.e. multiple log items - the
                    % rest of the code expects a cell).
                    s = {struct(varargin{:})};
                catch ERR
                    error('Invalid log item definition.')
                end
            else
                % if this is a struct array (which happens when ECK tasks
                % log multiple rows of data on a trial - te2 then converts
                % these row to elements of a struct array) convert to a
                % cell array of struct scalars (as would be the case if a
                % comma separated list was passed to this method)
                if numel(varargin{1}) > 1
                    varargin  = structArray2cellArrayOfStructs(varargin{1});
                end                 
                % store struct(s)
                s = varargin;
            end
            % make struct fields lowercase
            s = cellfun(@structFieldsToLowercase, s, 'uniform', false);
            % check each log item has the proper fields
            numItems = length(s);
            for i = 1:numItems
                % if missing, add date, timestamp and trial guid
                if ~isfield(s{i}, 'date'),      s{i}.date       = now;                      end
                if ~isfield(s{i}, 'timestamp'), s{i}.timestamp  = teGetSecs;                  end
                if ~isfield(s{i}, 'trialguid'), s{i}.trialguid  = obj.CurrentTrialGUID;     end
                % source and topic are required 
%                 if ~isfield(s{i}, 'source') || ~isfield(s{i}, 'topic')
%                     error('Log items must contain a ''source'' and ''topic'' field.')
%                 end
                % if no source field, query the function stack to get the
                % name of the originating function
                if ~isfield(s{i}, 'source')
                    dbs = dbstack;
                    s{i}.source = dbs(2).name;
                end
                % topic field required
                if ~isfield(s{i}, 'topic')
                    error('Log items must contain a ''topic'' field.')
                end
%                 % convert teGetSecs format time to posix form
%                 s{i}.timestamp = s{i}.timestamp + obj.PosixTimeOffset;
            end
            % order fields so general vars are at the start
            genVars = {'date', 'timestamp', 'topic', 'source'};
            s = cellfun(@(x) orderfieldssparse(x, genVars), s, 'uniform', false);
            % store in buffer
            for i = 1:numItems
                obj.prLog(obj.prLogIdx:obj.prLogIdx) = s(i);
                obj.prLogIdx = obj.prLogIdx + 1;  
                obj.BufferIncrement('prLog', 'prLogIdx');
            end
        end
        
        function Log_listener(obj, ~, eventdata)
            % this listener allows other functions and classes to send a
            % log via the presenter. Simply pass this to the AddLog method.
            obj.AddLog(eventdata.LogItem{:})
        end        
        
        % screen recording
        function StartScreenRecording(obj, filename)
            % check window open
            if ~obj.prWindowOpen
                error('Window not open.')
            end
            % check not recording already
            if obj.prCaptureStarted
                error('Already recording screen.')
            end
            % check filename - if not provided, try to use filename from
            % tracker
            if ~exist('filename', 'var') || isempty(filename)
                if ~obj.Tracker.Valid
                    error('Tracker not valid - cannot get filename for screen recording.')
                else
                    filename = obj.Tracker.Path_ScreenRecording;
                end
            end
            % determine size of capture 
            res = Screen('Rect', obj.ptr);
            w = round(res(3) * obj.ScreenRecordingScale);
            h = round(res(4) * obj.ScreenRecordingScale);
            obj.prCaptureRes = [w, h];
            % open offscreen window for recording to
            obj.prCaptureTexturePtr = Screen('OpenOffscreenWindow',...
                obj.prWindowPtr, [], [0, 0, w, h]);
            % start capture
            filename = sprintf('"%s"', filename);
            obj.prCapturePtr = Screen('CreateMovie', obj.prWindowPtr,...
                filename, w, h, obj.TargetFPS,...
                ':CodecType=x264enc');
%                 ':CodecType=vp8enc');
%                 ':CodecType=x264enc Videoquality=1');
%                                 ':CodecType=huffyuv');

%                 ':CodecType=ffenc_ljpeg');
            obj.prCaptureStarted = true;
            obj.AddLog('source', 'presenter', 'topic',...
                'screen_recording', 'data', 'Screen recording started')
        end
        
        function StopScreenRecording(obj)
            if ~obj.prCaptureStarted
                error('Capture not started.')
            end
            obj.prCaptureStarted = false;
            obj.AddLog('source', 'presenter', 'topic',...
                'screen_recording', 'data', 'Screen recording ended')
        end
        
        function OpenCamera(obj)
            if ~obj.prWindowOpen
                error('Window not open.')
            end
            if obj.prCameraOpen
                error('Camera already open.')
            end
            if isempty(obj.prCameraDeviceID) || isnan(obj.prCameraDeviceID)
                error('Camera device ID not valid.')
            end
            teEcho('Opening webcam...\n');
            obj.prCameraPtr = Screen('OpenVideoCapture',...
                obj.prWindowPtr, obj.prWebcamCaptureDeviceID, [], 1);
            teEcho('Starting webcam capture...\n');
            Screen('StartVideoCapture', obj.prWebcamCapturePtr, obj.CaptureFPS, 1);
            obj.prCameraOpen = true;
        end
        
        % get/set
                
        % screen/window
        function set.MonitorNumber(obj, val)
            % check that the requested monitor number is valid
            if ~isnumeric(val)
                error('Monitor number must be numeric.')
            elseif val < 0
                error('Monitor number must be positive.')
            end
            attached = Screen('Screens');
            if val > max(attached)
                error('Requested monitor number is greater than the number of attached monitors (%d)',...
                    max(attached))
            end
            obj.prMonitorNumber = val;
%             % if working on one screen, set MonoScreenMode to true, which
%             % will scale the display of the window to a smaller region so
%             % that Matlab is not occluded 
%             if obj.prMonitorNumber == 0 && ~obj.MonoScreenMode
%                 obj.MonoScreenMode = true;
%             end
            % if a screen is already open, re-open
            if obj.prWindowOpen
                obj.ReopenWindow;
            end        
        end
        
        function val = get.MonitorNumber(obj)
            val = obj.prMonitorNumber;
        end
        
        function val = get.Resolution(obj)
            if obj.WindowOpen
                res = Screen('Rect', obj.ptr);
                val = res([3, 4]);
            else
                val = [nan, nan];
            end
        end
        
        function set.SkipSyncTests(obj, val)
            if val
                obj.prOldSyncTest =...
                    Screen('Preference', 'SkipSyncTests', 1);
                Screen('Preference','VisualDebugLevel', 0);
            else
                Screen('Preference', 'SkipSyncTests', 0);
                obj.prOldSyncTest = 0;
            end
            if obj.prWindowOpen 
                obj.ReopenWindow
            end
            obj.prSkipSyncTests = val;
        end
        
        function val = get.SkipSyncTests(obj)
            val = obj.prSkipSyncTests;
        end
        
        function val = get.WindowPtr(obj)
            val = obj.ptr;
        end
        
        function val = get.WindowOpen(obj)
            val = obj.prWindowOpen;
        end
        
        function set.MonitorSize(obj, val)
            if ~isvector(val) || length(val) ~= 2
                error('Monitor size must be a two-element col vector.')
            elseif any(val < 1)
                error('Minimum monitor size is [1cm, 1cm].')
            end
            obj.prMonitorSize = val;
            obj.UpdateScaling
            % if window limit open, reopen to get new size
            if obj.prWindowLimitEnabled
                obj.ReopenDrawPane
            end
        end
        
        function val = get.MonitorSize(obj)
            val = obj.prMonitorSize;
        end
        
        function val = get.DrawingSize(obj)
            switch obj.WindowLimitEnabled
                case false
                    val = obj.prMonitorSize;
                case true
                    val = obj.WindowLimitSize;
            end
        end
        
        function val = get.DrawingAspectRatio(obj)
            val = obj.DrawingSize(1) / obj.DrawingSize(2);
        end
        
        function set.MonoScreenMode(obj, val)
            if val ~= obj.prMonoScreenMode
                % if only one screen attached, mono screen mode is forced
                if max(Screen('Screens')) == 0 && ~val
                    error('Only one screen attached, can only run in mono screen mode.')
                end
                % if setting mono screen mode, preview must be in window
                if ~obj.prPreviewInWindow && val
                    obj.prPreviewInWindow = true;
                    obj.ReopenPreview;
                end
                obj.prMonoScreenMode = val;
                if obj.prWindowOpen
                    obj.ReopenWindow;
                end
            end
        end
        
        function val = get.MonoScreenMode(obj)
            val = obj.prMonoScreenMode;
        end
        
        function set.WindowLimitEnabled(obj, val)
            % check that monitor sizes have been defined
            if isempty(obj.MonitorSize)
                error('Monitor size must be set before window limits can be applied.')
            end
            % check if value has changed
            changed = val ~= obj.prWindowLimitEnabled;
            obj.prWindowLimitEnabled = val;
            if changed && obj.WindowOpen, obj.ReopenDrawPane, end
        end
        
        function val = get.WindowLimitEnabled(obj)
            val = obj.prWindowLimitEnabled;
        end
        
        function set.WindowLimitSize(obj, val)
            if ~isvector(val) || length(val) ~= 2
                error('Window limit size must be a two-element col vector.')
            elseif isempty(obj.MonitorSize)
                % monitor size must be set before window limits can be
                % applied, since window limits aren't allowed to go beyond
                % the screen size (and we cannot check this until the
                % screen size has been set)
                error('MonitorSize must be set before WindowLimitSize can be set.')
            elseif any(val < 1)
                error('Minimum window limits are [1cm, 1cm].')
            elseif val(1) > obj.MonitorSize(1)
                error('Window limits must be narrower than monitor width.')
            elseif val(2) > obj.MonitorSize(2)
                error('Window limits must be narrower than monitor height.')
            end
            changed = isequal(val, obj.prWindowLimitSize);
            obj.prWindowLimitSize = val;
            if changed && obj.WindowOpen, obj.ReopenDrawPane, end
        end
        
        function val = get.WindowLimitSize(obj)
            val = obj.prWindowLimitSize; 
        end

        function set.WindowLimitBorderColour(obj, val)
            obj.AssertColType(val)
            obj.WindowLimitBorderColour = val;
        end
        
        function val = get.WindowLimitBorderColour(obj)
            val = obj.prWindowLimitBorderColour;
        end
        
        function set.PreviewInWindow(obj, val)
            % check input arg
            if ~islogical(val)
                error('PreviewInWindow property must be logical.')
            end
%             % during MonoScreenMode, PreviewInWindow must be true,
%             % otherwise mono screen and preview would overlap
%             if obj.MonoScreenMode && ~val
%                 warning('During MonoScreenMode, PreviewInWindow must be true.')
%                 obj.prPreviewInWindow = true;
%                 return
%             end
            changed = obj.prPreviewInWindow ~= val;
            obj.prPreviewInWindow = val;
            if changed, obj.ReopenPreview; end
        end
        
        function val = get.PreviewInWindow(obj)
            val = obj.prPreviewInWindow;
        end
        
        function set.PreviewMonitorNumber(obj, val)
            % check that the requested monitor number is valid
            if ~isnumeric(val)
                error('Monitor number must be numeric.')
            elseif val < 0
                error('Monitor number must be positive.')
            end
            attached = Screen('Screens');
            if val > max(attached)
                error('Requested monitor number is greater than the number of attached monitors (%d)',...
                    max(attached))
            end
            % if we are not in mono screen mode, preview cannot be on same
            % monitor as main window
            if ~obj.prMonoScreenMode && val == obj.prMonitorNumber
                error('Preview cannot be on same monitor as main window, unless in MonoScreenMode.')
            end
            changed = val ~= obj.prPreviewMonitorNumber;
            obj.prPreviewMonitorNumber = val;
            if changed, obj.ReopenPreview, end
        end
        
        function val = get.PreviewMonitorNumber(obj)
            val = obj.prPreviewMonitorNumber;
        end
        
        function set.PreviewScale(obj, val)
            if ~isnumeric(val) || ~isscalar(val) || val < .05 ||...
                    val > 1
                error('PreviewScale must be between 0.05 and 1.')
            end
            obj.prPreviewScale = val;
            obj.SetPreviewPositionFromPreset(obj.prPreviewPositionPreset);
        end
        
        function val = get.PreviewScale(obj)
            val = obj.prPreviewScale;
        end
        
        function set.PreviewPositionPreset(obj, val)
            if ~isequal(val, obj.prPreviewPositionPreset)
                obj.prPreviewPositionPreset = val;
                if obj.WindowOpen
                    obj.ReopenPreview
                end
            end
        end
        
        function val = get.PreviewPositionPreset(obj)
            val = obj.prPreviewPositionPreset;
        end
        
        function val = get.TargetFrameTime(obj)
            if ~obj.prWindowOpen
                val = nan;
            else
                val = Screen('GetFlipInterval', obj.prWindowPtr);
            end
        end
        
        function val = get.TargetFPS(obj)
            val = round(1 / obj.TargetFrameTime);
        end
        
        function val = get.FrameTime(obj)
            if ~obj.prWindowOpen
                val = nan;
            else
                val = obj.prFrameTime;
            end
        end        
        
        function val = get.FPS(obj)
            val = 1 / obj.TargetFrameTime;
        end
        
        function set.Animating(obj, val)
            if ~islogical(val)
                error('Animating property must be logical.')
            else
                if val
%                     obj.Echo('Animation started.\n')
%                     for i = 1:100
%                         obj.RefreshDisplay
%                     end
                else
%                     obj.Echo('Animation stopped.\n')
                end
                obj.prAnimating = val;
            end
        end
        
        function val = get.Animating(obj)
            val = obj.prAnimating;
            if val, pres.FlushBuffers; end
        end
        
        function val = get.TimingData(obj)
            if obj.prTimingIdx == 1
                val = [];
            else
                dat = obj.prTimingBuffer(1:obj.prTimingIdx - 1, :);
               dat(:, 2:10) = dat(:, 2:10) - dat(:, 1);
                val = array2table(dat, 'variablenames',...
                    obj.CONST_TIMING_VARIABLES);
            end
%             % return timing data, but only up to current frame (to avoid
%             % loads of blank entries that have been preallocated in the
%             % private property, but not yet filled with data)
%             fnames = fieldnames(obj.prTiming);
%             for f = 1:length(fnames)
%                 val.(fnames{f}) =...
%                     obj.prTiming.(fnames{f})(:, 1:obj.prFrame);
%             end
        end
        
        function val = get.PTBWindowPtr(obj)
            val = obj.prWindowPtr;
        end
               
        % log
        function val = get.Log(obj)
            val = obj.prLog(1:obj.prLogIdx - 1);
        end
                
        % capture
        function val = get.RecordScreen(obj)
            val = obj.prRecordScreen;
        end
        
        function set.RecordScreen(obj, val)
            if ~islogical(val)
                error('RecordScreen property must be logical.')
            end
%             if ~obj.prRecordScreen && val
%                 % start recording
%                 obj.StartScreenRecording
%             elseif obj.prRecordScreen && ~val
%                 % stop recording
%                 obj.StopScreenRecording
%             end
            obj.prRecordScreen = val;
        end
        
        function val = get.ScreenRecordingScale(obj)
            val = obj.prScreenRecordingScale;
        end
        
        function set.ScreenRecordingScale(obj, val)
            if obj.prCaptureStarted
                error('Cannot change ScreenRecordingScale when a recording is active.')
            end
            if val < .1 || val > 2
                error('ScreenRecordingScale must be between 0.1 and 2.0.')
            end
            obj.prScreenRecordingScale = val;
        end
        
        % drawing
        function set.BackColour(obj, val)
            % check backcolour format
            val = obj.AssertColType(val);
            obj.prBackColour = val;
            if obj.prWindowOpen
                obj.DrawBackColour
            end
        end
        
        function val = get.BackColour(obj)
            val = obj.prBackColour;
        end
        
        function set.EyeTrackerPreviewGazeHistory(obj, val)
            if ~isnumeric(val) || ~isscalar(val) || val < 0 
                error('EyeTrackerPreviewGazeHistory must be a positive numeric scalar.')
            end
            obj.prEyeTrackerPreviewGazeHistory = val;
        end
        
        function val = get.EyeTrackerPreviewGazeHistory(obj)
            val = obj.prEyeTrackerPreviewGazeHistory;
        end
        
        % scaling
        function val = get.CmPerPx(obj)
            if obj.prScalingValid
                val = obj.prCmPerPx;
            else
                val = [nan, nan];
            end
        end
        
        function val = get.PxPerCm(obj)
            if obj.prScalingValid
                val = obj.prPxPerCm;
            else
                val = [nan, nan];
            end
        end
        
        % stim
        function val = get.TexturesInUse(obj)
            val = 0;
            for s = 1:obj.Stim.Count
                if obj.Stim(s).TexturePtr > 0
                    val = val + 1;
                end
            end
        end
        
        function val = get.MoviesInUse(obj)
            val = 0;
            for s = 1:obj.Stim.Count
                if obj.Stim(s).MoviePtr >= 0
                    val = val + 1;
                end
                if obj.Stim(s).Prepared && obj.Stim(s).MoviePtr < 0
                    error('State/ptr mismatch - debug')
                end
            end
        end
        
        function set.SilentMode(obj, val)
            if ~islogical(val) || ~isscalar(val)
                error('SilentMode must be true or false.')
            end
            obj.SilentMode = val;
            if val, warning('Silent mode is on.'); end
        end
        
        % tasks
        function val = get.CurrentTask(obj)
            % look up current task by index
            idx = obj.prCurrentTask;
            if ~isempty(idx)
                val = obj.Tasks{idx}.Name;
            else
                val = 'None';
            end
        end
        
        function val = get.CurrentTrial(obj)
            % look up current trial, if there is one
            val = obj.prCurrentTrial;
            if isempty(val) || isnan(val)
                val = 'None';
            end
        end  
        
        function val = get.CurrentTrialGUID(obj)
            % look up current trial, if there is one
            val = obj.prCurrentTrialGUID;
            if isnan(val)
                val = [];
            end
        end 
        
        % et
        function set.EyeTracker(obj, val)
            obj.EyeTracker = val;
            % tell the eye tracker class the window ptr, so that it can get
            % mouse coords if the eye tracker type is set to mouse
            if strcmpi(obj.EyeTracker.TrackerType, 'mouse')
                obj.EyeTracker.MouseWindowPtr = obj.prWindowPtr;
            end
%             % give the posix time conversion offset to the eye tracker
%             obj.EyeTracker.PosixTimeOffset = obj.PosixTimeOffset;
        end
        
        function set.ETCalibStartSize(obj, val)
            if ~isscalar(val) || ~isnumeric(val) || val < 0
                error('ETCalibStartSize must be a positive numeric scalar.')
            end            
            obj.ETCalibStartSize = val;
        end
        
        function set.ETCalibEndSize(obj, val)
            if ~isscalar(val) || ~isnumeric(val) || val < 0
                error('ETCalibEndSize must be a positive numeric scalar.')
            end         
            obj.ETCalibEndSize = val;
        end
        
        function set.ETCalibDurWait(obj, val)
            if ~isscalar(val) || ~isnumeric(val) || val < 0
                error('ETCalibDurWait must be a positive numeric scalar.')
            end      
            obj.ETCalibDurWait = val;
        end
        
        function set.ETCalibDurShrink(obj, val)
            if ~isscalar(val) || ~isnumeric(val) || val < 0
                error('ETCalibDurShrink must be a positive numeric scalar.')
            end   
            obj.ETCalibDurShrink = val;
        end
        
        function set.ETCalibDurMeasure(obj, val)
            if ~isscalar(val) || ~isnumeric(val) || val < 0
                error('ETCalibDurMeasure must be a positive numeric scalar.')
            end   
            obj.ETCalibDurMeasure = val;
        end
        
        function set.ETCalibMoveVelocity(obj, val)
            if ~isscalar(val) || ~isnumeric(val) || val < 0
                error('ETCalibMoveVelocity must be a positive numeric scalar.')
            end   
            obj.ETCalibMoveVelocity = val;
        end
        
        function val = get.ETDriftGridSize(obj)
            val = obj.prETDriftGridSize;
        end
        
        function set.ETDriftGridSize(obj, val)
            % check the input and create drift measurement points in the
            % eye tracker class
            if ~isnumeric(val) || ~isvector(val) || length(val) ~= 2
                error('ETDriftGridSize must be a positive numeric vector of length 2.')
            end
            obj.prETDriftGridSize = val;
            % make grid
            xgs = 1 / (val(1) - 1);
            ygs = 1 / (val(2) - 1);
            [xg, yg] = meshgrid(0:xgs:1, 0:ygs:1);
            % convert to vector of [x, y] coords
            xg = reshape(xg, [], 1);
            yg = reshape(yg, [], 1);
            % drift points have an [x, y] coord and a priorty from 0-1,
            % indicating how urgent it is to measure this point. Initially
            % the corners and centre of the screen are the highest
            % priority, with other points having their priority set as a
            % function of distance from the centre/corners
            pr = zeros(size(xg));
            % find coords nearest to the corners/centre
            highPriorityCoords = [...
                0.10, 0.10  ;...
                0.90, 0.10  ;...
                0.50, 0.50  ;...
                0.10, 0.90  ;...
                0.90, 0.90  ];
            numCoords = size(highPriorityCoords, 1);
            % loop through coords and find nearest
            maxPriority = false(size(pr));
            for c = 1:numCoords
                cx = highPriorityCoords(c, 1);
                cy = highPriorityCoords(c, 2);
                dist = sqrt(((xg - cx) .^ 2) + ((yg - cy) .^ 2));
                nearest = find(dist == min(dist), 1);
                % flag nearest to set max priority later
                maxPriority(nearest) = true;
                % set priority of all others as function of distance
                dist = dist / max(dist);
                pr = mean([pr, dist], 2);
            end
            % now set highest priority, using flag set in previous loop
            pr(maxPriority) = 1;
            % store
            obj.prETDriftPoints = [xg, yg, pr];
        end
        
        % keyboard
        function val = get.ActiveKeyboard(obj)
            val = obj.prActiveKeyboard;
        end
        
        % light patch
        function val = get.LightPatchStatus(obj)
        % if light patch is enabled, read private property to get status
        % (which is true/false = on/off). Otherwise return false
        
            val = obj.LightPatchEnabled && obj.prLightPatchStatus;
            
        end
        
        function set.LightPatchEnabled(obj, val)
            if ~islogical(val) || ~isscalar(val)
                error('''LightPatchEnabled'' must be a logical scalar (true/false).')
            end
            obj.LightPatchEnabled = val;
        end

        % buffering
        function BufferIncrement(obj, propName, idxName)
            % get size and cursor pos of buffer
            curSize = size(obj.(propName), 1);
            curIdx = obj.(idxName);
            % if size is too small...
            changed = curIdx >= curSize;
            if changed
                % calculate new size
                curSize = curSize + obj.CONST_DEF_BUFFER_SIZE;
                % increase
                obj.(propName){curSize} = [];
                % log
                obj.AddLog('source', 'presenter',...
                    'topic', 'buffering', 'data',...
                    sprintf('Buffer %s increased to %d', propName, curSize))
            end
        end
        
        % utilities
        function Echo(obj, varargin)
            msg = teEcho(varargin{:});
            obj.AddLog('data', msg, 'source', 'presenter',...
                'topic', 'echo');            
        end
        
        function ListEditor(obj, listName)
            
            % if a list name was supplied, load it
            if exist('listName', 'var') && ~isempty(listName) 
                list = obj.Lists(listName);
                if isempty(list)
                    error('List ''%s'' not found.', listName);
                else
                    displayList
                end
            else
                list = [];
                listName = [];
            end
            
            % a few semi-local vars - may make these private properties in
            % future 
            isNumArray = [];
            tbl_selRow = [];
            tbl_selCol = [];
                        
            %% define controls
            
            % control positions/sizes
            % positions 
            res                 =   get(0, 'ScreenSize');
            pos_fig             =   [0.12, 0.12, 0.75, 0.75];
            pos_figPx           =   round(pos_fig .* repmat(res(3:4), 1, 2));
            pos_pnlCol          =   [0000, 0000, 0250, pos_figPx(4)];
            pos_pnlColW         =   0250 / pos_figPx(3);
            pos_pnlList         =   [pos_pnlColW, 0, 1 - pos_pnlColW, 1];
            pos_pnlListControls =   [0.97, 0.00, 0.03, 1.00];
            pos_pnlListControlsPx = round(pos_pnlListControls .* repmat(pos_figPx(3:4), 1, 2));
            btnTop              =   pos_pnlListControlsPx(4);
            btnSize             =   48;
            pos_btnAddRow       =   [0001, btnTop - (btnSize * 1) - 1, btnSize, btnSize];
            pos_btnDelRow       =   [0001, btnTop - (btnSize * 2) - 1, btnSize, btnSize];
            pos_btnCloneRow     =   [0001, btnTop - (btnSize * 3) - 1, btnSize, btnSize];
            pos_btnAddCol       =   [0001, btnTop - (btnSize * 4) - 1, btnSize, btnSize];
            pos_btnDelCol       =   [0001, btnTop - (btnSize * 5) - 1, btnSize, btnSize];
            pos_btnMoveUp       =   [0001, btnTop - (btnSize * 6) - 1, btnSize, btnSize];
            pos_btnMoveDown     =   [0001, btnTop - (btnSize * 7) - 1, btnSize, btnSize];            
            pos_tbl             =   [0.00, 0.00, 0.97, 1.00];
            pos_lstColl         =   [0.00, 0.50, 1.00, 0.48];
            pos_lblColl         =   [0.00, 0.98, 1.00, 0.02];
            pos_pnlInspect      =   [0.00, 0.00, 1.00, 0.50];
            pos_lblListName     =   [0.02, 0.95, 0.98, 0.05];
            pos_lblCount        =   [0.02, 0.91, 0.98, 0.04];
            pos_lblStart        =   [0.02, 0.87, 0.49, 0.04];
            pos_lblNum          =   [0.02, 0.83, 0.49, 0.04];            
            pos_txtStart        =   [0.49, 0.87, 0.49, 0.04];
            pos_txtNum          =   [0.49, 0.83, 0.49, 0.04];
            pos_lblOrder        =   [0.02, 0.79, 0.49, 0.04];
            pos_popOrder        =   [0.49, 0.79, 0.49, 0.04];    
            
            % make figure
            fig = figure(...
                'name',                 'List Editor',...
                'menubar',              'none',...
                'toolbar',              'none',...
                'resize',               'off',...
                'units',                'normalized',...
                'numbertitle',          'off',...
                'position',             pos_fig);       
            
            % load other icons
            ico_addRow      = loadIcon('ico_addRow.png');
            ico_delRow      = loadIcon('ico_deleteRow.png');
            ico_CloneRow    = loadIcon('ico_cloneRow.png');
            ico_addCol      = loadIcon('ico_addColumn.png');
            ico_delCol      = loadIcon('ico_deleteColumn.png');
            ico_moveUp      = loadIcon('ico_moveUp.png');
            ico_moveDown    = loadIcon('ico_moveDown.png');
            
            function img = loadIcon(file)
                col_bg  = get(fig, 'Color');
                file    = fullfile(obj.CONST_PATH_ICONS, file);
                img     = imread(file, 'BackgroundColor', col_bg);
                img     = imresize(img, [btnSize - 8, btnSize - 8]);
            end
                        
            % make controls
            pnlColl = uipanel(...
                'parent',               fig,...
                'bordertype',           'none',...
                'units',                'pixels',...
                'position',             pos_pnlCol);
            
            pnlList = uipanel(...
                'parent',               fig,...
                'bordertype',           'none',...
                'units',                'normalized',...
                'position',             pos_pnlList);    
            
            pnlListControls = uipanel(...
                'parent',               pnlList,...
                'bordertype',           'none',...
                'units',                'normalized',...
                'position',             pos_pnlListControls);  
            set(pnlListControls, 'units', 'pixels')
            
            btnAddRow = uicontrol(...
                'parent',               pnlListControls,...
                'style',                'pushbutton',...
                'tooltipstring',        'Add Row',...
                'position',             pos_btnAddRow,...
                'callback',             @btnAddRow_Click,...
                'cdata',                ico_addRow);
            
            btnDelRow = uicontrol(...
                'parent',               pnlListControls,...
                'style',                'pushbutton',...
                'tooltipstring',        'Delete Row',...
                'position',             pos_btnDelRow,...
                'callback',             @btnDelRow_Click,...
                'cdata',                ico_delRow);
            
            btnCloneRow = uicontrol(...
                'parent',               pnlListControls,...
                'style',                'pushbutton',...
                'tooltipstring',        'Clone Row',...
                'position',             pos_btnCloneRow,...
                'callback',             @btnCloneRow_Click,...
                'cdata',                ico_CloneRow);
            
            btnAddCol = uicontrol(...
                'parent',               pnlListControls,...
                'style',                'pushbutton',...
                'tooltipstring',        'Add Column',...
                'position',             pos_btnAddCol,...
                'callback',             @btnAddCol_Click,...
                'cdata',                ico_addCol);
            
            btnDelCol = uicontrol(...
                'parent',               pnlListControls,...
                'style',                'pushbutton',...
                'tooltipstring',        'Delete Row',...
                'position',             pos_btnDelCol,...
                'callback',             @btnDelCol_Click,...
                'cdata',                ico_delCol);         
            
            btnMoveUp = uicontrol(...
                'parent',               pnlListControls,...
                'style',                'pushbutton',...
                'tooltipstring',        'Move Row Up',...
                'position',             pos_btnMoveUp,...
                'callback',             @btnMoveUp_Click,...
                'cdata',                ico_moveUp);  
            
            btnMoveDown = uicontrol(...
                'parent',               pnlListControls,...
                'style',                'pushbutton',...
                'tooltipstring',        'Move Row Down',...
                'position',             pos_btnMoveDown,...
                'callback',             @btnMoveDown_Click,...
                'cdata',                ico_moveDown);              
            
            choice_TrialType = {'Trial', 'Function', 'NestedList', 'ECK'};
%             if obj.Tasks.Count == 0
%                 choice_Task = 'char';
%             else
%                 choice_Task = horzcat(obj.Tasks.Functions{:});
%             end
            tbl_colFormat = {...
                [],...               
                'logical',...
                choice_TrialType,... 
                'char',...                                        
                'char',...
                'numeric',...
                'numeric',...
                'char'};
            tbl = uitable(...
                'Data',                 {},...
                'CellSelectionCallback',@tbl_Select,... 
                'CellEditCallback',     @tbl_Edit,...
                'Parent',               pnlList,...
                'Units',                'Normalized',...
                'ColumnName',           {},...
                'ColumnFormat',         tbl_colFormat,...
                'ColumnEditable',       true,...
                'RowName',              [],...
                'RowStriping',          'off',...
                'FontName',             'menlo',...
                'Position',             pos_tbl); 
            
            % get underlying java table object, get its viewport, and store
            % to allow setting selection row later on
            jtbl = findjobj(tbl);
            obj.prListEditorTableVP = jtbl.getViewport.getView;
            
            % flag to disable selection callback when programmatically
            % setting selection
            disableSel = false;
            
            lstColl = uicontrol(...
                'style',                'listbox',...
                'parent',               pnlColl,...
                'units',                'normalized',...
                'position',             pos_lstColl,...
                'FontName',             'menlo',...
                'FontSize',             12,...
                'callback',             @lstColl_Click,...
                'string',               obj.Lists.Keys);
            
            lblColl = uicontrol(...
                'style',                'text',...
                'parent',               pnlColl,...
                'units',                'normalized',...
                'position',             pos_lblColl,...
                'FontSize',             12,...
                'String',               'Loaded lists');
            
            pnlInspect = uipanel(...
                'parent',               pnlColl,...
                'bordertype',           'none',...
                'units',                'normalized',...
                'position',             pos_pnlInspect);
            
            lblListName = uicontrol(...
                'style',                'text',...
                'parent',               pnlInspect,...
                'units',                'normalized',...
                'position',             pos_lblListName,...
                'FontSize',             16,...
                'FontWeight',           'bold',...
                'foregroundcolor',      [0.30, 0.30, 0.30],...
                'horizontalalignment',  'left',...
                'String',               'No list selected');
            
            lblCount  = uicontrol(...
                'style',                'text',...
                'parent',               pnlInspect,...
                'units',                'normalized',...
                'position',             pos_lblCount,...
                'FontSize',             12,...
                'FontWeight',           'bold',...
                'horizontalalignment',  'left',...
                'String',               'Count: NaN');
            
            lblNum  = uicontrol(...
                'style',                'text',...
                'parent',               pnlInspect,...
                'units',                'normalized',...
                'position',             pos_lblNum,...
                'FontSize',             12,...
                'FontWeight',           'bold',...
                'horizontalalignment',  'left',...
                'String',               'Number of Samples');            
            
            txtNum  = uicontrol(...
                'style',                'edit',...
                'parent',               pnlInspect,...
                'units',                'normalized',...
                'position',             pos_txtNum,...
                'FontSize',             12,...
                'FontWeight',           'bold',...
                'horizontalalignment',  'left',...
                'callback',             @txtNum_Edit,...
                'String',               'NaN');       
            
            lblStart = uicontrol(...
                'style',                'text',...
                'parent',               pnlInspect,...
                'units',                'normalized',...
                'position',             pos_lblStart,...
                'FontSize',             12,...
                'FontWeight',           'bold',...
                'horizontalalignment',  'left',...
                'String',               'Start Sample');            
            
            txtStart  = uicontrol(...
                'style',                'edit',...
                'parent',               pnlInspect,...
                'units',                'normalized',...
                'position',             pos_txtStart,...
                'FontSize',             12,...
                'FontWeight',           'bold',...
                'horizontalalignment',  'left',...
                'callback',             @txtStart_Edit,...
                'String',               'NaN');                
            
            lblOrder = uicontrol(...
                'style',                'text',...
                'parent',               pnlInspect,...
                'units',                'normalized',...
                'position',             pos_lblOrder,...
                'FontSize',             12,...
                'FontWeight',           'bold',...
                'horizontalalignment',  'left',...
                'String',               'Order Type');   
            
            popOrder = uicontrol(...
                'style',                'popupmenu',...
                'parent',               pnlInspect,...
                'units',                'normalized',...
                'position',             pos_popOrder,...
                'FontSize',             12,...
                'FontWeight',           'bold',...
                'horizontalalignment',  'left',...
                'String',               {'Sequential', 'Random'});              
            
            function loadList(newListName)
                if ~strcmpi(listName, newListName)
                    listName = newListName;
                    list = obj.Lists(listName);
                    displayList
                end                
            end
            
            function displayList
                % record previous selection
                oldRowSel = tbl_selRow;
                oldColSel = tbl_selCol;
                % update
                if ~isempty(list)
                    % get data
                    data = table2cell(list.Table);
                    % insert col for icon
                    data = [cell(size(data, 1), 1), data];
                    
                    % format type with colour icons
                    for r = 1:size(data, 1)
                        % format type icon
                        switch lower(data{r, 3})
                            case 'list'
                                hexCol = rgb2hex(obj.COL_ICON_LIST);
                            case 'trial'
                                hexCol = rgb2hex(obj.COL_ICON_TRIAL);
                            case 'function'
                                hexCol = rgb2hex(obj.COL_ICON_FUNCTION);
                            case 'nestedlist'
                                hexCol = rgb2hex(obj.COL_ICON_NESTEDLIST);
                            case 'eck'
                                hexCol = rgb2hex(obj.COL_ICON_ECK);
                        end
                        % apply colour
                        data{r, 1} = [...
                            '<html><table border=0><TR><TC><TD width=10 bgcolor=#',...
                            hexCol, '></TD></TC><TC><TD>', data{r, 1},...
                            '</TD></TC></TR></table></html>'];
                    end
                    
                    % check for vectors/matrices/logicals within the table
                    isNumArray = cellfun(@(x) isnumeric(x) &&...
                        ~isequal(size(x), [1, 1]), data);
                    isLogicalArray = cellfun(@(x) islogical(x) &&...
                        ~isequal(size(x), [1, 1]), data);                    
                    isNumOrLogical = isNumArray | isLogicalArray;
                    numArray2TableCell = @(x) strrep(num2str(x), '  ', ',');
                    data(isNumOrLogical) = cellfun(numArray2TableCell, data(isNumOrLogical),...
                        'uniform', false);
                    
                    tbl.Data = data;
                    tbl.ColumnName =...
                        [' ', list.Table.Properties.VariableNames];
                    
                    % sort out column headers
                    uitableAutoColumnHeaders(tbl, 1.5)
                    
                    % set icon column width
                    tbl.ColumnWidth{1} = 26;
                    
                    % set selected row
                    if ~isempty(oldRowSel)
                        setListSelection(oldRowSel);
                    end
                    tbl_selRow = oldRowSel;
                    
                    % inspector
                    lblListName.String  = list.Name;
                    lblCount.String     = sprintf('Count: %d', list.Count);
                    txtNum.String       = list.NumSamples;
                    txtStart.String         = list.StartSample;
                    popOrder.String     = {'Sequential', 'Random'};
                    switch lower(list.OrderType)
                        case 'sequential'
                            popOrder.Value = 1;
                        case 'random'
                            popOrder.Value = 2;
                        otherwise
                            popOrder.String = list.OrderType;
                    end
%                     % try to restore selection
%                     if oldRowSel <= list.Count
%                     end
                end
            end   
            
            function setListSelection(row)
                disableSel = true;
                jtbl = findjobj(tbl);
                v = jtbl.getViewport.getView;
                v.changeSelection(row - 1, 0, false, false);
                v.changeSelection(row - 1, 6, false, true);                
                disableSel = false;
            end
                
            %% callbacks
            
            function tbl_Select(h, eventData)
%                 if ~disableSel
                    % get indices
                    if isempty(eventData.Indices)
                        tbl_selRow = [];
                        tbl_selCol = [];
                    else
                        tbl_selRow = eventData.Indices(1);
                        tbl_selCol = eventData.Indices(2);
                    end
                    fprintf('%d\n', tbl_selRow)
%                     setListSelection(tbl_selRow)
%                 end
            end
            
            function tbl_Edit(h, eventData)
                % update internal table
                var = tbl.ColumnName{tbl_selCol};
                % determine data type of destination cell
                dest = list.Table.(var)(tbl_selRow);
                data = tbl.Data(tbl_selRow, tbl_selCol);
                
                % if data is either numeric or logical, then the uitable
                % will have put it into a cell array. This prevents us from
                % storing it back in the teList, so we extract it from the
                % cell array
                destIsNumericOrLogical = isnumeric(dest) || islogical(dest);
                dataIsNumericOrLogical = isnumeric(data{1}) || islogical(data{1});
                if destIsNumericOrLogical && iscell(data) && dataIsNumericOrLogical
                    data = data{1};
                end

                % store
                try
                    list.(var)(tbl_selRow) = data;
                catch ERR
                    switch ERR.message
                        case 'Cannot set StartSample when type is not NestedList or ECK.'
                            tbl.Data(tbl_selRow, tbl_selCol) = {nan};
                            errordlg(ERR.message)
                        otherwise
                            errordlg(ERR.message)
                    end
                end
                list.IsCompiled = false;
            end
            
            function lstColl_Click(h, eventData)
                if isempty(h.Value), return, end
                loadList(obj.Lists(h.Value).Name);
            end

            function btnAddRow_Click(h, eventdata)
                list.AddRow(1, tbl_selRow + 1)
                displayList
            end
            
            function btnDelRow_Click(h, eventdata)
                if isempty(tbl_selRow)
                    errordlg('No row selected', 'Delete Row');
                    return
                end
                try
%                     oldNode = findSelectedTreeNode;
%                     parNode = findTreeNode({'teList', list.Name});
                    list.DeleteRow(tbl_selRow)
                catch ERR
                    rethrow ERR
                end  
                displayList
%                 newSelNode = parNode.getPreviousNode;
%                 parNode.remove(oldNode)
%                 treeModel.reload
%                 tvLists.setSelectedNode(newSelNode);
%                 tvLists.expand(parNode)
            end
            
            function btnCloneRow_Click(h, eventdata)
                if isempty(tbl_selRow)
                    errordlg('No row selected', 'Delete Row');
                    return
                end                  
                answer = inputdlg(...
                    'Number of clones to make', 'Clone Rows', 1, {'1'});
                if isempty(answer)
                    % cancel was clicked
                    return
                else
                    % extract numeric content from string answer
                    num = str2double(answer);
                    % check valid input
                    if isnan(num) || ~isnumeric(num) || ~isscalar(num) 
                        % not numeric
                        errordlg('Value must be numeric.')
                        return
                    elseif num < 1 || num > 100
                        errordlg('Value must be between 1 and 100.')
                        return
                    end
                    list.CloneRow(tbl_selRow, num)
                end
                displayList
            end

            function btnAddCol_Click(h, eventdata)
                var = inputdlg('Enter new variable name', 'Add Variable');
                if ~isempty(var)
%                     try
                        list.AddVariable(var{1})
%                     catch ERR
%                         rethrow ERR
%                     end
                end
                displayList
            end
            
            function btnDelCol_Click(h, eventdata)
                if isempty(tbl_selCol)
                    errordlg('No column selected', 'Delete Column');
                    return
                end
                try
                    list.DeleteVariable(tbl_selCol)
                catch ERR
                    rethrow ERR
                end            
                displayList
            end         
            
            function btnMoveUp_Click(s, eventData)
                if isempty(tbl_selRow)
                    errordlg('No row selected', 'Move Row Up');
                    return
                end
                list.MoveRowUp(tbl_selRow)
                tbl_selRow = tbl_selRow - 1;
                displayList
            end
            
            function btnMoveDown_Click(s, eventData)
                if isempty(tbl_selRow)
                    errordlg('No row selected', 'Move Row Down');
                    return
                end                
                list.MoveRowDown(tbl_selRow)
                tbl_selRow = tbl_selRow + 1;
                displayList
            end
        end
        
        function DrawTestPattern(obj)
            % draws a test pattern of circles and lines. useful for
            % checking that monitor size scaling and window limits are
            % working
            
            col_bg = obj.COL_LABEL_BG;
            col_fg = obj.COL_LABEL_FG;
            
            % background 
            Screen('FillRect', obj.ptr, col_bg);
            
            % get centre of screen, and smallest dimension (width or
            % height)
            [cx, cy] = obj.DrawingCentre;
            sdim = floor(min([cx, cy]));
            
            % draw ruler lines in 1cm sections. all of this drawing will be
            % in done in cm, then converted to px
            xr = [cx - floor(cx), cy, cx + floor(cx), cy];
            yr = [cx, cy - floor(cy), cx, cy + floor(cy)];
            xr = obj.ScaleRect(xr, 'cm2px');
            yr = obj.ScaleRect(yr, 'cm2px');
            Screen('DrawLine', obj.ptr, col_fg, xr(1), xr(2), xr(3), xr(4));
            Screen('DrawLine', obj.ptr, col_fg, yr(1), yr(2), yr(3), yr(4));
            
            % draw circles in 2cm radii
            radii = 2:2:sdim;
            crect = [cx - radii; cy - radii; cx + radii; cy + radii];
            crect = obj.ScaleRect(crect', 'cm2px')';
            Screen('FrameOval', obj.ptr, col_fg, crect);
            
            % draw ticks at 1cm intervals
            ticks = -sdim + 1:2:sdim - 1;
            xtp = [...
                sort(repmat(cx - ticks, 1, 2));...
                repmat([cy - .3, cy + .3], 1, length(ticks));...
                ];
            ytp = [...
                repmat([cx - .3, cx + .3], 1, length(ticks));...
                sort(repmat(cy - ticks, 1, 2));...
                ];            
            xtp = obj.ScalePoint(xtp', 'cm2px')';
            ytp = obj.ScalePoint(ytp', 'cm2px')';
            Screen('DrawLines', obj.ptr, [xtp, ytp], [], col_fg);
            
%             % draw labels at 1cm intervals along smallest dim
%             xlp = [cx - ticks', repmat(cy + .5, length(ticks), 1)];
%             xlp = obj.ScalePoint(xlp, 'cm2px');
%             for l = 1:length(xlp)
%                 lab = num2str(ticks(end - l + 1));
%                 x = xlp(l, 1);
%                 y = xlp(l, 2);
%                 tb = Screen('TextBounds', obj.ptr, lab, x, y);
%                 x = x - ((tb(3) - tb(1)) / 2);
%                 Screen('DrawText', obj.ptr, lab, x, y, col_fg);
%             end
        end
        
        function PlotTiming(obj)
            % make figure
            figure(...
                'name',         'Task Engine Presenter Timing Summary',...
                'menubar',      'none',...
                'numbertitle',  'off',...
                'toolbar',      'none',...
                'units',        'normalized',...
                'position',     [0.25, 0.25, 0.50, 0.50]);
            % get timing data
            tab = obj.TimingData;   
            % get max frametime
            ft_max = ceil(max(tab.FrameTime));
            % get missed frame idx
            missed = tab.Missed >= 0;
            % get late frames
            late = tab.FrameTime - (obj.TargetFrameTime * 1000) > 1;
            % scatter/hist subplots
            x = tab.Onset - tab.Onset(1);
            numMetrics = 9;
            metric = 2;
            spCounter = 1;
            for i = 1:numMetrics
                subplot(5, numMetrics, spCounter)
                spCounter = spCounter + 1;
                scatter(x, tab{:, metric}, 5);
                hold on
                scatter(x(late), tab{late, metric}, 5, 'm')
                scatter(x(missed), tab{missed, metric}, 5, 'r')
                line([x(1), x(end)], repmat(obj.TargetFrameTime * 1000, 1, 2),...
                    'color', 'g')
                ylim([0, ft_max])
                title(tab.Properties.VariableNames{metric})
                metric = metric + 1;
            end
            metric = 2;
            for i = 1:numMetrics
                subplot(5, numMetrics, spCounter)
                spCounter = spCounter + 1;
                histogram(tab{:, metric}, 20)
                xlim([0, ft_max])
                hold on
                yl = ylim;
                line(repmat(obj.TargetFrameTime * 1000, 1, 2), [yl(1), yl(end)],...
                    'color', 'g')
                metric = metric + 1;
            end
            
            % frame time
            subplot(5, numMetrics, spCounter:spCounter - 1 + numMetrics * 3)
            hold on
            set(gca, 'ColorOrder', distinguishable_colors(numMetrics));
            plot(x, tab{:, 2:2 + numMetrics - 1}, 'linewidth', 2)
            area(x, tab.FrameTime, 'facealpha', .1, 'edgecolor', 'm',...
                'facecolor', 'b', 'LineStyle', '--')
            line([x(1), x(end)], repmat(obj.TargetFrameTime * 1000, 1, 2),...
                'color', 'g', 'linewidth', 2)
            bar(x, missed * ft_max, 'facecolor', 'r', 'linestyle', 'none',...
                'facealpha', .2)
            bar(x, late * ft_max, 'facecolor', 'm', 'linestyle', 'none',...
                'facealpha', .2)
            legend([obj.CONST_TIMING_VARIABLES(2:2 + numMetrics - 1),...
                'FrameTime', 'Target', 'Missed', 'Late'], 'location', 'best')

%             % remove FlipData array (since we don't plot this)
%             tab = rmfield(tab, 'FlipData');
%             % get timing variables, calculate number of needed subplots
%             fnames = fieldnames(tab);
%             num = length(fnames) * 2;
%             numSP = numSubplots(num);
%             % time vector for all frames
%             t = tab.FrameL - tab.FrameL(2);
%             % get indices of missed flip deadline
%             missed = obj.prTiming.Missed;
%             % scatter plots
%             for p = 1:num / 2
%                 subplot(numSP(1), numSP(2), p)
%                 scatter(t, tab.(fnames{p}), [], '.')
%                 hold on
%                 scatter(t(missed), tab.(fnames{p})(missed), 100, 'r.')
% %                 ylim([0, obj.TargetFrameTime * 2])
%                 title(fnames{p})
%             end
%             % histograms
%             for p = 1:num / 2
%                 subplot(numSP(1), numSP(2), (num / 2) + p)
%                 histogram(tab.(fnames{p}))
%                 xlim([0, obj.TargetFrameTime * 2])
%                 title(fnames{p})
%             end
        end
        
        function ClearTiming(obj)
            obj.prTimingIdx = 1;
        end
        
        function SetPreviewPositionFromPreset(obj, val)
            % set the preview window position to a useful preset - e.g. top
            % left
            newVal = obj.WindowPositionFromPreset(val, obj.prPreviewScale);
            if ~isequal(newVal, obj.prPreviewPosition)
                obj.prPreviewPosition = newVal;
                if obj.WindowOpen
                    obj.ReopenPreview
                end
            end
        end
        
        function ImportFromRegistry(obj, reg)
            % import tasks
            if ~isempty(reg.Tasks)
                for t = 1:reg.Tasks.Count
                    obj.Tasks.AddItem(reg.Tasks(t), reg.Tasks.Keys{t});
                end
                teEcho('Imported %d tasks from registry.\n',...
                    reg.Tasks.Count);
            end
            % import paths
            if ~isempty(reg.Paths)
                for p = 1:reg.Paths.Count
                    obj.Paths.AddItem(reg.Paths(p), reg.Paths.Keys{p});
                end
                teEcho('Imported %d paths from registry.\n',...
                    reg.Paths.Count);
            end
            % import lists
            if isprop(reg, 'Lists') && ~isempty(reg.Lists)
                for p = 1:reg.Lists.Count
                    obj.Lists.AddItem(reg.Lists(p), reg.Lists.Keys{p});
                end
                teEcho('Imported %d lists from registry.\n',...
                    reg.Lists.Count);
            end
        end
        
        function DrawStimThumbnails(obj)
            if ~obj.WindowOpen
                error('Window not open')
            end
            % check that there are some image/movie stimuli to draw
            if isempty(obj.Stim)
                return
            else
                isImg = cellfun(@(x) x.isImage, obj.Stim.Items);
                isMov = cellfun(@(x) x.isMovie, obj.Stim.Items);
                if ~any(isImg) && ~any(isMov)
                    return
                end
            end
            toDraw = isImg | isMov;
            numThumbs = sum(toDraw);
            % calculate positions
            tb = numSubplots(numThumbs);
            w = obj.DrawingSize(1) / tb(1);
            h = obj.DrawingSize(2) / tb(2);
            x = 0:w:obj.DrawingSize(1) - w;
            y = 0:h:obj.DrawingSize(2) - h;
            border = .2;
            % draw 
            obj.BackColour = [000, 000, 000];
            oldTextSize = Screen('TextSize', obj.ptr, 12);
            row = 1;
            col = 1;
            for s = 1:obj.Stim.Count
                if toDraw(s)
                    % make rect in cm
                    rect = [x(col) + border, y(row) + border,...
                        x(col) + w - border, y(row) + h - border];
                    rect_px = obj.ScaleRect(rect, 'cm2px');
                    % draw thumbnail
                    obj.DrawStim(obj.Stim(s), rect, [], [], true)
                    % draw border
                    Screen('FrameRect', obj.ptr, obj.COL_TE_DARKPURPLE,...
                        rect_px, 3);
                    % draw text
                    txt = obj.Stim.Keys{s};
                    tx = rect_px(1);
                    ty = rect_px(2);
                    Screen('DrawText', obj.ptr, txt, tx, ty,...
                        obj.COL_LABEL_FG, obj.COL_LABEL_BG);                    
                    % process row, col
                    col = col + 1;
                    if col > tb(1)
                        col = 1;
                        row = row + 1;
                    end
                end
            end
            obj.RefreshDisplay;
            Screen('TextSize', obj.ptr, oldTextSize);
        end
        
        function val = WindowPositionFromPreset(obj,...
                preset, scale)
            if nargin <= 1
                error('Must provide both a preset and a scale.')
            end
            if ~isnumeric(scale) || ~isscalar(scale) || scale < .05 ||...
                    scale > 1
                error('scale must be between .05 and 1.')
            end
            % get screen size and calculate screen ar
            res_drawingWindow = Screen('Rect', obj.MonitorNumber);
            res_previewWindow = Screen('Rect', obj.PreviewMonitorNumber);
            % calculate width and height
            w = round(res_drawingWindow(3) * scale);
            h = round(res_drawingWindow(4) * scale);
            % find x1, y1 from preset
            switch lower(preset)
                case 'topleft'
                    x1 = 0;
                    y1 = 0;
                case 'topright'
                    x1 = res_previewWindow(3) - w;
                    y1 = 0;
                case 'bottomleft'
                    x1 = 0;
                    y1 = res_previewWindow(4) - h;
                case 'bottomright'
                    x1 = res_previewWindow(3) - w;
                    y1 = res_previewWindow(4) - h;
                otherwise
                    error('Invalid preset. Valid presets are: topleft, topright, bottomleft, bottomright.')
            end
            % set x2, y2 using width and height
            x2 = x1 + w;
            y2 = y1 + h;
            val = [x1, y1, x2, y2];
        end

        function AssertValueType(~, val)
            if ~isnumeric(val)
                error('Coordinates must be numeric.')
            end            
            if ~isscalar(val)
                error('Coords argument must be a scalar value.')
            end
        end
        
        function AssertRectType(~, val)
            warning('This is slow!')
            if ~isnumeric(val)
                error('Coordinates must be numeric.')
            end            
            if size(val, 2) ~= 4
                error('Coords argument must be a four-element vector.')
            end
        end

        function AssertPointType(~, val)
            warning('This is slow!')
            if ~isnumeric(val)
                error('Coordinates must be numeric.')
            end            
            if size(val, 2) ~= 2
                error('Coords argument must be a two-elements wide.')
            end
        end
        
        function val = AssertColType(~, val)
%             warning('This is slow!')
            val = teAssertColourType(val);
        end
        
        function list = AssertList(obj, val)
            % val can be a list name (char) or a teList instnace -
            % determine which
            if ischar(val)
                list = obj.Lists(val);
                if isempty(list)
                    error('List named %s not found.', val)
                end
            elseif isa(val, 'teList')
                list = val;
            else
                error('Must specify a list name or teList object.')
            end
        end
        
        function SelfTest(obj)
            % paths
            if ~exist(obj.CONST_PATH_ET, 'dir');
                error('''eyetracker'' folder not found: %s.',...
                    obj.CONST_PATH_ET)
            end
            if ~exist(obj.CONST_PATH_ICONS, 'dir');
                error('''icons'' folder not found: %s.',...
                    obj.CONST_PATH_ICONS)
            end
            % classes
            reqClasses = {...
                'teEyeTracker',...
                'teCollection',...
                'teList',...
                'teListCollection',...
                'teLogEventData',...
                'teLogItem',...
                'teStim',...
                'teTask',...
                'teTracker'};
            classesFound = cellfun(@(x) exist(x, 'class') == 8, reqClasses);
            if ~all(classesFound)
                fprintf('Missing TaskEngine2 classes:\n\n')
                fprintf('\t%s\n', reqClasses{~classesFound})
                error('Missing classes - check TaskEngine2 installation.')
            end
        end

        % hidden set/get methods for backward compatibility with ECK
        function val = get.WindowWidthCm(obj)
            val = obj.DrawingSize(1);
        end
        
        function val = get.WindowHeightCm(obj)
            val = obj.DrawingSize(2);
        end
        
        function val = get.WindowWidthLimitCm(obj)
            val = obj.DrawingSize(1);
        end
        
        function val = get.WindowHeightLimitCm(obj)
            val = obj.DrawingSize(2);
        end        
                
    end 
    
    % hidden props and methods for backward compatibilty with ECK and
    % interal tools for Task Engine
    properties (Hidden)
    end
    
    properties (Hidden, Dependent, SetAccess = private)
        WindowWidthLimitCm
        WindowHeightLimitCm
        WindowWidthCm
        WindowHeightCm
    end
    
    methods (Hidden)

        function loadInternalStim(obj, type)
            
            teEcho('Loading internal stimuli...\n');
            
        % check input args and set up paths
        
            if ~exist('type', 'var') || isempty(type)
                type = 'adult';
            end
            path_et = fullfile(obj.CONST_PATH_ET, type);
            path_fixation = fullfile(obj.CONST_PATH_FIXATIONS, type);
            
        % fixation stimuli and attention getters
        
            obj.LoadStim(path_fixation);      
            obj.LoadStim(obj.CONST_PATH_ATTENTION);      

        % eye tracking
        
            % et face
            obj.Stim('et_face_both') = teStim(fullfile(path_et,...
                'et_face_both.png')); 
            obj.Stim('et_face_none') = teStim(fullfile(path_et,...
                'et_face_none.png'));                     
            obj.Stim('et_face_left') = teStim(fullfile(path_et,...
                'et_face_left.png'));                     
            obj.Stim('et_face_right') = teStim(fullfile(path_et,...
                'et_face_right.png'));  
            obj.Stim('et_face_outline') = teStim(fullfile(path_et,...
                'et_face_outline.png'));                        
            % calib point images
            [file_calib, file_names] = findfiles(...
                fullfile([obj.CONST_PATH_ET, filesep,...
                'et_calib_spiral*.png']));
            for f = 1:length(file_calib)
                obj.Stim(file_names{f}) = teStim(file_calib{f});
            end
            % �et eyes video
            et_video = teStim(...
                fullfile(path_et, 'et_calib_vid.mp4'));
            et_video.Volume = .6;
            et_video.Loop = true;
            obj.Stim('et_video') = et_video;
            % post-calib images
            obj.Stim('et_image_00001') = teStim(fullfile(path_et,...
                'et_calib_img_00001.png'));
            obj.Stim('et_image_00002') = teStim(fullfile(path_et,...
                'et_calib_img_00002.png'));
            obj.Stim('et_image_00003') = teStim(fullfile(path_et,...
                'et_calib_img_00003.png'));
            obj.Stim('et_image_00004') = teStim(fullfile(path_et,...
                'et_calib_img_00004.png'));
            obj.Stim('et_image_00005') = teStim(fullfile(path_et,...
                'et_calib_img_00005.png'));
            
        end
        
        function prepareInternalStim(obj)
            teEcho('Preparing internal stimuli...\n');
            % et face            
            obj.PrepareStim('et_face_both');
            obj.PrepareStim('et_face_none');
            obj.PrepareStim('et_face_left');
            obj.PrepareStim('et_face_right');
            obj.PrepareStim('et_face_outline');
            obj.prTexture_ETFaceBoth = obj.Stim('et_face_both').TexturePtr;
            obj.prTexture_ETFaceNone = obj.Stim('et_face_none').TexturePtr;
            obj.prTexture_ETFaceLeft = obj.Stim('et_face_left').TexturePtr;
            obj.prTexture_ETFaceRight = obj.Stim('et_face_right').TexturePtr;
            obj.prTexture_ETFaceOutline = obj.Stim('et_face_outline').TexturePtr;
            obj.prAR_ETFace = obj.Stim('et_face_both').AspectRatio;
            % et calib 
            obj.PrepareStim('et_calib_spiral*')            
        end
        
        function initCalibTexture(obj)
            res = obj.Resolution;
            obj.ClearTexture(obj.prETCalibTexture)
            % draw semi-transparent background to dark existing stim
            Screen('FillRect', obj.prETCalibTexture, [0, 0, 0, 200]);
        end

        % ECK compatiblity 
        function frames = AnimToFrames(~, anim, numFrames)
            
            frames=zeros(1,floor(numFrames));
            
            for curStep=1:size(anim,1)-1
                
                % work out the first frame that corresponds to the point in
                % time referred to in the current step of the anim block
                stepStartFrame      =   floor((anim(curStep,1)*(numFrames-1))+1);
                stepStartValue      =   anim(curStep,2);
                
                % if the next step is actually the end of the anim
                if curStep+1>size(anim,1)                
                    stepEndFrame    =   stepStartFrame; 
                    stepEndValue    =   stepStartValue;
                else                   
                    stepEndFrame    =   floor(anim(curStep+1,1)*(numFrames-1))+1;                    
                    stepEndValue    =   anim(curStep+1,2);
                end
                
                curStepFrames       =   stepEndFrame-stepStartFrame;
                curStepFrameChange  =   (stepEndValue - stepStartValue) / ...
                                        curStepFrames;
                
                if curStepFrameChange==0
                    
                    frames(stepStartFrame:stepEndFrame)=...
                        repmat(stepStartValue,1,curStepFrames+1);
                    
                else
                    
                    frames(stepStartFrame:stepEndFrame)=...
                        [stepStartValue : curStepFrameChange : stepEndValue];
                
                end
                
            end
            
        end
        
        function val = LookupObjectFromName(obj, ~, name)
            val = obj.Stim(name);
        end
        
        function val = Images(obj)
            % sneaky backward compatibility: this property is no longer
            % meaningful in te2, because all stim are stored in the Stim
            % collection, regardless of type. ECK scripts will call this
            % and pass it to ECKLookupObject and ECKLookupRandomObject.
            % These functions have been rewritten to call Stim.Lookup and
            % Stim.LookupRandom. These calls require the presenter object,
            % not the Images or Sounds collection. So when Images is
            % called, we just return the whole presenter, and the rewritten
            % ECKLookupX will use this to interrogate the Stim collection
            % and return what the ECK script was expecting. See also Sounds
            % and Movie (below)
            val = obj;
        end
        
        function val = Sounds(obj)
            val = obj;
        end
        
        function val = Movies(obj)
            val = obj;
        end
        
        function val = RescaleCmToProp(obj, val)
            % legacy ECK
            if isscalar(val)
                val = obj.ScaleValue(val, 'cm2rel');
            elseif isvector(val) && length(val) == 2
                val = obj.ScalePoint(val, 'cm2rel');
            elseif isvector(val) && length(val) == 4
                val = obj.ScaleRect(val, 'cm2rel');
            end
        end
        
        function val = FlipInterval(obj, val)
            val = obj.TargetFrameTime;
        end
        
        function val = QuitRequested(obj, val)
            if nargin == 2
                error('Setting this backwards compat property is not supported.')
            end
            val = obj.ExitTrialNow;
        end
        
        function val = ImmediateRequest(obj, val)
            if nargin == 2
                error('Setting this backwards compat property is not supported.')
            end
            val = obj.ExitTrialNow;
        end
        
        function DrawImage(obj, varargin)
%             obj.DrawStim(varargin{:})
        end
        
        function val = ScreenOpen(obj)
            val = obj.WindowOpen;
        end
        
        function EEGSendEvent(obj, event, when)
            % this assumes that there is an event realy called 'eeg' that
            % can be used for EEG markers
            obj.SendEvent(event, when, 'eeg');
        end
        
    end

end

    
    
   %         % destructor
%         function delete(obj)
%             obj.ShutDown
%         end
%             
% %             try
%             
%             % shutdown message
%             cprintf('*cyan', 'Task Engine shutting down...\n')
%             
% %             % close stim
% %             for s = 1:obj.Stim.Count
% %                 switch lower(obj.Stim(s).Type)
% %                     case 'image'
% %                     case 'movie'
% %                         if obj.Stim(s).Playing
% %                             obj.StopStim(obj.Stim(s))
% %                         end
% % %                         if obj.Stim(s).Prepared
% % %                             obj.Echo('Closing %s...\n', obj.Stim.Keys{s})
% % %                             Screen('CloseMovie', obj.Stim(s).MoviePtr);
% % % %                             obj.Stim(s).Close
% % %                         end
% %                     case 'sound'
% %                     otherwise
% %                         warning('Closing stim type %s not yet implemented.',...
% %                             obj.Stim(s).Type)
% %                 end
% %             end
%                         
%             % stop animating
%             if obj.prAnimating
%                 obj.Animating = false;
%             end
%             
%             % end session
%             if obj.prSessionStarted
%                 obj.EndSession
%             end
%             
%             % stop eye tracker
%             obj.EyeTracker.Disconnect
%             delete(obj.EyeTracker)
% %             clear obj.EyeTracker
%             
%             % clear collections etc.
%             delete(obj.Stim)
%             delete(obj.Lists)
%             delete(obj.Log)
%             delete(obj.Tasks)
%             
% %             clear obj.Stim
% %             clear obj.Lists
% %             clear obj.Log
% %             clear obj.Tasks
%             
%             % close screen
%             if obj.prWindowOpen
%                 obj.CloseWindow
%             end
%             
%             % restore previous value of PTB sync tests
%             if ~isempty(obj.prOldSyncTest)
%                 Screen('Preference', 'SkipSyncTests', obj.prOldSyncTest);
%             end
%             
%             % restore previous verbosity setting
%             if ~isempty(obj.prPrevVerbosityFlag)
%                 Screen('Preference', 'Verbosity',...
%                     obj.prPrevVerbosityFlag);
%             end
%             
%             % close any remaining PTB assets
%             Screen('CloseAll')
%             
%             cprintf('*cyan', 'Task Engine shut down.\n')
%             
% %             catch ERR
% % 
% %                 disp(ERR.message)
% %                 
% %             end
%             
%         end



%         function OpenCamera(obj)
%             % check window is open
%             if obj.prCameraWindowOpen
%                 error('Camera window already open.')
%             end
%             % prepare Camera in window setting
%             if obj.prCameraInWindow 
%                 windowOption = kPsychGUIWindow; 
%             else
%                 windowOption = [];
%             end         
%             % if a Camera positon preset has been specified, convert this
%             % to x, y vals now
%             if ~isempty(obj.prCameraPositionPreset)
%                 [x, y] = obj.CameraPositionFromPreset(...
%                     obj.prCameraPositionPreset);
%                 obj.CameraPosition = [x, y];
%             end
%             % calculate resolution. width is specified in
%             % CameraResolutionX, use this to maintain the same aspect
%             % ratio as the drawing pane
%             x = obj.CameraPosition(1);
%             y = obj.CameraPosition(2);
%             res = [x, y, x + obj.CameraResolutionX,...
%                 y + round(obj.CameraResolutionX / obj.DrawingAspectRatio)];
%             % open
%             obj.prCameraWindowPtr = Screen('OpenWindow', obj.prCameraMonitorNumber,...
%                 obj.prBackColour, res, [], 2, 0, [],...
%                 [], windowOption, [0, 0, obj.Resolution]);    
%             % turn on alpha blending 
%             Screen('BlendFunction', obj.prCameraWindowPtr, GL_SRC_ALPHA,...
%                 GL_ONE_MINUS_SRC_ALPHA); 
%             % draw BG colour
%             Screen('FillRect', obj.ptr, obj.prBackColour);
%             obj.prCameraWindowOpen = true;
%         end
%         
%         function CloseCamera(obj)
%             % check window is open
%             if ~obj.prCameraWindowOpen
%                 error('Camera window not open.')
%             end
%             % close Camera window
%             Screen('Close', obj.prCameraWindowPtr)
%             obj.prCameraWindowOpen = false;
%         end
%         
%         function ReopenCamera(obj)
%             obj.CloseCamera
%             obj.OpenCamera
%         end


        
%         function PreviewCameras(obj)
%             if ~obj.WindowOpen
%                 error('Window must be open.')
%             end            
%             % get capture devices
%             dev = Screen('VideoCaptureDevices');
%             if isempty(dev)
%                 error('No cameras found.')
%             end
%             numSP = numSubplots(length(dev));
%             figure
% %             for d = 1:length(dev)
% %                 obj.Echo('\t|Checking device %d of %d...\n', d, length(dev))
% %                 subplot(numSP(1), numSP(2), d)
%                 % open device
% %                 devPtr = Screen('OpenVideoCapture', obj.prWindowPtr,...
% %                     dev(d).DeviceIndex, [], [], [], [], [], 8);
%                 devPtr = Screen('OpenVideoCapture', obj.prWindowPtr,...
%                     [], [], [], [], [], [], 8);
% 
%                 Screen('StartVideoCapture', devPtr, 30, 1);
%                 % get image
%                 [~, ~, ~, img] = Screen('GetCapturedImage',...
%                     obj.prWindowPtr, devPtr);
%                 imagesc(img)
%                 title(sprintf('Device %d (%s)', d, dev(d).DevicePlugin))
% %             end
%         end
        
            
            
        
%         function [x1, y1, x2, y2] = CameraPositionFromPreset(obj, val)
%             % set the preview window position to a useful preset - e.g. top
%             % left
%             [x1, y1, x2, y2] = obj.WindowPositionFromPreset(val,...
%                 obj.prPreviewScale);
%             obj.prCameraPositionPreset = val;
%         end