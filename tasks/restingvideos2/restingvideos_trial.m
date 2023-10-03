function [ logOut ] = restingvideos_trial( pres,track,log,vars,varNames,curSample )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
funVersion = '001';
varNames = ['Version', varNames];
vars = [funVersion, vars];

% convert variables into a struct, for ease of access
design=cell2struct(vars,varNames,2);
design.TrialNo=curSample;

skipEnabled=false;

% check if the presenter is in the correct state
if isempty(pres)
    error('Empty presenter object passed.')
end

if ~pres.ScreenOpen
    error('The passed presenter object does not have an open screen. Use ECKPresenter.InitialiseDisplay first.')
end

% sync EEG
pres.EEGSync

pres.KeyFlush;
pres.KeyUpdate;

% set up trial
trialOnsetTime=GetSecs;
pres.BackColour=[0 0 0];
stimWidthCm=design.StimWidth;

% look up stimulus movies
mov=pres.LookupObjectFromName(pres.Movies,design.Video);
        
% set height, scale width according to aspect ratio of image
stimRectCm=pres.CentreImageRectCm(mov,stimWidthCm,[]);

pres.EEGSendEvent(design.StimEEGCode,GetSecs);

if pres.NIRSConnected
    WaitSecs(.1);
    pres.NIRSSendEvent(design.StimNIRSOnsetCode);
end

if strcmpi(pres.EyeTracker.State, 'TRACKING')
    pres.EyeTracker.SendEvent({'RESTINGVIDEOS_ONSET', design.Video});
end

% play the movie
movieOnsetTime=GetSecs;
mov.Play(pres.WindowPtr);

% loop until the movie is over
while strcmpi(mov.State,'PLAYING') &&...
        (GetSecs-movieOnsetTime)<design.MaxDuration && ...
        ~pres.KeyPressed(pres.KB_MOVEON) &&...
        ~track.SkipEnabled && ~pres.ImmediateRequest
    
    curFrame=mov.Frame;
    pres.DrawImageFullscreen(curFrame);
    pres.RefreshDisplay();
       
    if ~strcmpi(track.SkipToFunction, 'restingvideos_block')
        track.SkipEnabled=pres.SkipToFunctionRequested;
        pres.SkipToFunctionRequested=false;
    end

end

skipped = pres.KeyPressed(pres.KB_MOVEON);

mov.Stop

if pres.NIRSConnected
    WaitSecs(.1);
    pres.NIRSSendEvent(design.StimNIRSOffsetCode);
end

if strcmpi(pres.EyeTracker.State, 'TRACKING')
    pres.EyeTracker.SendEvent('RESTINGVIDEOS_OFFSET');
end

% ECKFlushEyeTracker(pres);
   
trialOffsetTime=GetSecs;

logOut.Data=horzcat({...
    num2str(trialOnsetTime),...
    num2str(movieOnsetTime),...
    num2str(trialOffsetTime)...
    pres.SkipToFunctionRequested,...
    'singing_markers',...    
    skipped,...
    },vars);

logOut.Headings=horzcat({...
    'TrialOnsetTime',...
    'MovieOnsetTime',...
    'TrialOffsetTime',...
    'SKIPENABLED',...
    'SKIPTOFUNCTION',...    
    'TrialSkipped',...
    }, varNames);
end

