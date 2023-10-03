function [ logOut ]=restingvideos_block(pres,track,log,vars,varNames,curSample)

% fold variable names and values into a struct for ease of
% access/readability
design=cell2struct(vars,varNames,2);
design.BlockNo=curSample;

switch track.Site
    case {'UU', 'T2UU', 'RUNMC', 'T2RUNMC'}
        faceVideo = 'FACE_NL.MP4';
        faceCode = '12';
    case 'KI'
        faceVideo = 'FACE_SW.MOV';
        faceCode = '13';
    case 'UOW'
        faceVideo = 'FACE_PL.MOV';
        faceCode = '14';
    otherwise
        faceVideo='FACE_EN.MP4';
        faceCode = '10';
end

% DESIGN
trials=ECKList;
trials.Name='resting videos trial list';
trials.Presenter=pres;
trials.Tracker=track;   
trials.Log=log;
trials.Table={...
    'Nested',   'Function',             'Video',        'MaxDuration',  'StimWidth','StimEEGCode',  'StimNIRSOnsetCode',    'StimNIRSOffsetCode';...
    1           'restingvideos_trial',  faceVideo,      70,             55,         faceCode,       'D',                    'F'                 ;...
    1           'restingvideos_trial',  'TOY_EN.MP4',   70,             55,         '11',           'E',                    'G'                 ;...
    1           'restingvideos_trial',  faceVideo,      70,             55,         faceCode,       'D',                    'F'                 ;...
    1           'restingvideos_trial',  'TOY_EN.MP4',   70,             55,         '11',           'E',                    'G'                 };

trials.NumSamples=design.NumTrials;
trials.StartSample=design.StartTrial;
trials.Order='SEQUENTIAL';

% pres.EEGSendEvent(num2str(design.BlockNo),GetSecs);
WaitSecs(.5);
trials.Start();
logOut=[];
end