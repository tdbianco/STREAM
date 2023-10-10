%% Clean EEG data

% This script cleans the EEG data (fieldtrip format).

% For each session folder:

% 1) Find the fieldtrip data 
% 2) Preprocess the data for the different conditions
% 3) Save the data in the session fieldtrip folder

% 4) Save the path to the clean data in the table
% 5) Save the number of clean trial per condition in the table

% Calls to functions from Fieldtrip, 
% and Task Engine and eeg-tools created by Luke Mason
% and other functions specific to this paradigm:
%   - BrTUK_01a_Preprocess_Allcond which calls to:
%       - BrTUK_trialfun_braintoolsUKtrt_FastERP
%       - BrTUK_01aa_NumberTrials_ERPs
%       - BrTUK_01ab_preproc_cleandata

% by Rianne Haartsen: jan-feb 21

%% Load the table with info

clear variables

% Set up local paths to scripts
%add LM code TaskEngine2
    addpath(genpath('/Users/teresa/Documents/MATLAB/STREAM/TaskEngine2'))
    addpath(genpath('/Users/teresa/Documents/MATLAB/STREAM/lm_tools'));
    addpath(genpath('/Users/teresa/Documents/MATLAB/STREAM/ettools-main'));
    addpath(genpath('/Users/teresa/Documents/MATLAB/STREAM/eegtools'));
    addpath(genpath('/Users/teresa/Documents/MATLAB/STREAM/tasks')); 
% braintools UK specific analysis scripts    
    addpath('/Users/teresa/Documents/MATLAB/STREAM');
    addpath('/Users/teresa/Documents/MATLAB/EEG_QC/BrT_Arb_scripts')
%add fieldtrip path and set to defaults
    addpath('/Users/teresa/Documents/MATLAB/fieldtrip-20180925'); 
    ft_defaults
    
    
%% Set up table to keep track of different thresholds

% Variables: ID+session, EEGft_path, CleanData_path, 
% Nfaceup, Ncheckers

% create a table with variable for tracking

PPTfolder = dir('/Users/teresa/Documents/MATLAB/data/stream');
    Nrows = numel(PPTfolder)-7;
    stream_ClnEEG = table('Size',[Nrows 5], ...
        'VariableNames',{'IDses','EEGft_path','CleanData_path','Nfaceup','Ncheckers'},...
        'VariableTypes',{'cell','cell','cell','cell','cell'});

    save('/Users/teresa/Documents/MATLAB/data/stream/0_stream_Trt/stream_Cleandata_tracker.mat','stream_ClnEEG');

    
%% Clean and preprocess all datasets

% load '/Users/teresa/Documents/MATLAB/data/stream/0_stream_Trt/stream_Cleandata_tracker.mat'
% load '/Users/teresa/Documents/MATLAB/data/stream/0_stream_Trt/stream_IDs_tracking_wETint.mat'
    
% Cleaning parameters:
    Tmin = -150; % minimum value for minmax threshold AR
    Tmax = 150; % maximum value for minmax threshold AR
    Trange = []; % range value for range threshold AR, or empty 
    BPfilter = [.1, 40]; % range for band pass filter
    Baseline_timewindow =  [-0.1, 0]; % time for baseline correction in sec, or empty

for ss = 1:height(stream_ClnEEG)

    fprintf('Currently nr %i out of %i\n',ss,height(stream_ClnEEG))
    Subj = PPTfolder(7+ss).name; %ppt code
    disp(Subj)
    
    % 1) Find the fieldtrip data    
        FTdata = stream_IDs_tracking_wETint.tEEG_path{ss}{1,1}; % EEG data file 
        
    % 2) Preprocess the data for the different conditions
        % save parameters in structure for bookkeeping
        FastERP_info.Subj = Subj;
        FastERP_info.BPfilter = BPfilter;
        FastERP_info.AR_Thresholds = [Tmin, Tmax];
        FastERP_info.AR_Range = Trange; 
        FastERP_info.Baseline_timewindow = Baseline_timewindow;
        
        % function to clean the data
        [EEGdata_Faces_Obj, EEGdata_Checkers, FastERP_info] = BrtUK_01a_Preprocess_Allcond(FTdata, FastERP_info);
 
    % 3) Save the data in the session fieldtrip folder
        Session_path = extractBefore(FTdata,'fieldtrip');
        Cleandata_path = strcat(Session_path,'fieldtrip/', Subj, '_CleanData.mat');
        save(Cleandata_path, 'EEGdata_Faces_Obj','EEGdata_Checkers', 'FastERP_info')

    % 4) Add the path to the clean data into the table
        stream_ClnEEG.CleanData_path{ss} = Cleandata_path;
  
    % 5) Add the number of clean trial per condition into the table
    
        stream_ClnEEG.IDses(ss) = {Subj};
        stream_ClnEEG.EEGft_path(ss) = {FTdata};
        stream_ClnEEG.Nfaceup(ss) = {FastERP_info.N_trials.FaceUp.Nclean};
        %stream_ClnEEG.Nfaceinv(ss) = {FastERP_info.N_trials.FaceInv.Nclean};
        %stream_ClnEEG.Nobjup(ss) = {FastERP_info.N_trials.ObjUp.Nclean};
        %stream_ClnEEG.Nobjinv(ss) = {FastERP_info.N_trials.ObjInv.Nclean};
        stream_ClnEEG.Ncheckers(ss) = {FastERP_info.N_trials.Checkers.Nclean}; 
        
        save('/Users/teresa/Documents/MATLAB/data/stream/0_stream_Trt/stream_Cleandata_tracker.mat','stream_ClnEEG');
        
        clear EEGdata_Faces_Obj EEGdata_Checkers FastERP_info 
        clear FTdata Cleandata_path Session_path Subj

end
