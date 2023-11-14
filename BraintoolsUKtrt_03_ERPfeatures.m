%% % Braintools UK project test-retest data: Extracting ERP component features

% This script reads in all the clean data, then randomly draws different
% numbers of trials from the data, and extracts the relevant EEG features.

% For checkerboards:
% 1) Specify parameters
%   - N trials: 10 - 20 - 30 - 40 - 50 - all available
% 2) Randomly draw N trials and calculate ERP avg
% 3) Get key EEG features: P1 latency and amplitude, DTW stimulus, DTW P1 window
% 4) Check the validity of the ERP avg and P1 peak
% 5) Save the data and values

% For faces; 
% 1) Specify parameters
%   - N trials: 10 - 20 - 30 - 40 - 50 - 60 - 70 - 80 - 90 - 100 - all available
% 2) Randomly draw N trials and calculate ERP avg
% 3) Get key EEG features: N290 latency and amplitude, P400 mean ampl, 
% DTW stimulus, DTW N290 window, DTW P400 window
% 4) Check the validity of the ERP avg and N290 peak
% 5) Save the data and values


% Calls to functions from Fieldtrip, 
% and other functions specific to this paradigm:
%   - BrtUKtrt_03a_randomNs_indivERPs
%   - BrtUKtrt_03b_AllERPfeatures
%   - BrtUKtrt_03c_PeakValid

% by Rianne Haartsen and Emily J.H. Jones: jan-feb 21

%%

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


%% Checkerboards
% Loop through participants for test data    
    % load old and new trackers
    load /Users/teresa/Documents/MATLAB/data/stream/0_stream_Trt/stream_Cleandata_tracker.mat
% 	load /XXXXX/BrtUK_Checkers_features.mat


    % Define the different numbers of trials to average across
        Nrantrls = [10, 20, 30, 40, 50, 0]; % 0 = all trials available

% create a table with variable for tracking
% Variables: ID+session, CleanData_path, ERPs_path, Nrantrls, 
% ERPtime, ERPavg, P1lat, P1pamp, DTWdir_stim, DTWdir_P1time
% 
%     Nrows = height(BrtUK_Checkers_features);
    PPTfolder = dir('/Users/teresa/Documents/MATLAB/data/stream');
    Nrows = numel(PPTfolder)-7;
    stream_Checkers_features = table('Size',[Nrows 11], ...
        'VariableNames',{'IDses','CleanData_path','ERPs_path','Nrantrls','ERPtime','ERPavg','P1lat','P1pamp',...
        'DTWdir_stim','DTWdir_P1time','P1_valid'},...
        'VariableTypes',{'cell','cell','cell','cell','cell','cell','cell', 'cell','cell','cell','cell'});
%     manually enter and adjust the IDs

    save('/Users/teresa/Documents/MATLAB/data/stream/0_stream_Trt/stream_Checkers_features.mat','stream_Checkers_features');
    
    % load the grand average for the dtw
    load('/Users/teresa/Documents/MATLAB/data/stream/0_stream_Trt/stream_GrandAverages.mat', 'Gavg_CheckAll')
    Ref_gavg = Gavg_CheckAll.avg;
    clear Gavg_CheckAll
    
for ss = 1:height(stream_Checkers_features)  
    
    fprintf('Currently nr %i out of %i\n',ss,height(stream_Checkers_features))
    Subj = stream_ClnEEG.IDses{ss}; %ppt code
    fprintf('Subject %s\n',Subj)
    
    % 1) load clean data
        load(stream_ClnEEG.CleanData_path{ss},'EEGdata_Checkers', 'FastERP_info')

    % 2) preallocate datasets for tracking table
        Number_of_randomselections = length(Nrantrls);
        Ntrls = nan(1,Number_of_randomselections);
        ERPtime = cell(1,Number_of_randomselections);
        ERPavg = cell(1,Number_of_randomselections);
        P1lat = nan(1,Number_of_randomselections);
        P1pamp = nan(1,Number_of_randomselections);
        DTWstim = nan(1,Number_of_randomselections);
        DTWP1win = nan(1,Number_of_randomselections);
        P1_valid = nan(1,Number_of_randomselections);
        % preallocate datasets for later saving
        CheckerERPs_RandomTrialSelection = struct;
        CheckerERPs_RandomTrialSelection.Nrantrls = Nrantrls;
        CheckerERPs_RandomTrialSelection.ERP = cell(1,Number_of_randomselections);
        CheckerERPs_RandomTrialSelection.ERPfeatures = cell(1,Number_of_randomselections);

    % Loop through different numbers of trials to randomly select 
        
        for tt = 1:Number_of_randomselections
            % randomly draw N trials and calculate ERP avg
               Numcurr = Nrantrls(1,tt);
               [Individual_ERP_Checker] = BrtUKtrt_032a_randomNs_indivERPs(EEGdata_Checkers, FastERP_info, 'checkers', Numcurr);
            
            % get all features for checkers
               [ERPfeatures] = BrtUKtrt_032b_AllERPfeatures(Individual_ERP_Checker, 'checkers', Ref_gavg);
               
            % add features for tracking table
                % check if the number of trials found was not 0
                if ~isequal(Individual_ERP_Checker.Navg,0)
                    ERPtime{1,tt} = Individual_ERP_Checker.time;
                    ERPavg{1,tt} = Individual_ERP_Checker.avg;
                else
                    ERPtime{1,tt} = [];
                    ERPavg{1,tt} = [];
                end
                Ntrls(1,tt) = Individual_ERP_Checker.Navg;
                P1lat(1,tt) = ERPfeatures.P1_Lat;
                P1pamp(1,tt) = ERPfeatures.P1_pAmp;
                DTWstim(1,tt) = ERPfeatures.DTWdir_stim;
                DTWP1win(1,tt) = ERPfeatures.DTWdir_P1;                
            % test validity of the P1 peak 
                 if ~isequal(Individual_ERP_Checker.Navg,0)
                    [valid] = BrtUK_03c_PeakValid(Individual_ERP_Checker, FastERP_info, ERPfeatures.P1_Lat);
                 else 
                     valid = NaN;
                 end
                 P1_valid(1,tt) = valid;
            % organise data for later saving
                CheckerERPs_RandomTrialSelection.ERP{1,tt} = Individual_ERP_Checker;
                CheckerERPs_RandomTrialSelection.ERPfeatures{1,tt} = ERPfeatures;
            
            clear ERPface ERPchecker
            clear Numcurr
        end %end loop through thresholds
        clear tt
        
    % save the data
        part1_path = extractBefore(stream_ClnEEG.CleanData_path{ss},'_CleanData.mat');
        FullNameData = strcat(part1_path,'_CheckersSubsets_ERPs.mat');
        save(FullNameData, 'CheckerERPs_RandomTrialSelection')    

    % add values to tracking table
        stream_Checkers_features.IDses(ss) = {Subj};
        stream_Checkers_features.CleanData_path(ss) = {stream_ClnEEG.CleanData_path{ss}};
        stream_Checkers_features.ERPs_path(ss) = {FullNameData};
        stream_Checkers_features.Nrantrls(ss) = {Ntrls};
        stream_Checkers_features.ERPtime(ss) = {ERPtime};
        stream_Checkers_features.ERPavg(ss) = {ERPavg};
        stream_Checkers_features.P1lat(ss) = {P1lat};
        stream_Checkers_features.P1pamp(ss) = {P1pamp};
        stream_Checkers_features.DTWdir_stim(ss) = {DTWstim};
        stream_Checkers_features.DTWdir_P1time(ss) = {DTWP1win};
        stream_Checkers_features.P1_valid(ss) = {P1_valid};
  
        save('/Users/teresa/Documents/MATLAB/data/stream/0_stream_Trt/stream_Checkers_features.mat','stream_Checkers_features');
    
        % clean up
        clear FullNameData 
        clear CheckerERPs_RandomTrialSelection
        clear EEGdata_Checkers FastERP_info
        clear Number_of_randomselections Ntrls ERPtime ERPavg P1lat P1pamp DTWstim DTWP1win P1_valid 

        fprintf('Data saved for subject %s\n',Subj)

        clear Subj


end % end loop through IDs

clear Ref_gavg ss ERPfeatures Individual_ERP_Checkers


%% Faces
% Loop through participants for test data    
    % load old and new trackers
%         load /Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BraintoolsUK_Cleandata_tracker.mat
%	load /XXXXX/BrtUK_Faces_features.mat


    % Define the different numbers of trials to average across
    Nrantrls = [10, 20, 30, 40, 50, 0]; % 0 = all trials available

% create a table with variable for tracking
% Variables: ID+session, CleanData_path, ERPs_path, Nrantrls, 
% ERPtime, ERPavg, N290lat, N290pamp, N290mamp,P400mamp, 
% DTWdir_stim, DTWdir_N290time, DTWdir_P400time

    PPTfolder = dir('/Users/teresa/Documents/MATLAB/data/stream');
    Nrows = numel(PPTfolder)-7;
    stream_Faces_features = table('Size',[Nrows 14], ...
        'VariableNames',{'IDses','CleanData_path','ERPs_path','Nrantrls','ERPtime','ERPavg',...
        'N290lat','N290pamp','N290mamp','P400mamp',...
        'DTWdir_stim','DTWdir_N290time','DTWdir_P400time','N290_valid'},...
        'VariableTypes',{'cell','cell','cell','cell','cell','cell','cell', 'cell','cell','cell','cell',...
        'cell','cell','cell'});

    save('/Users/teresa/Documents/MATLAB/data/stream/0_stream_Trt/stream_Faces_features.mat','stream_Faces_features');
    
    % load the grand average for the dtw
    load('/Users/teresa/Documents/MATLAB/data/stream/0_stream_Trt/stream_GrandAverages.mat','Gavg_FaceAll')
    Ref_gavg = Gavg_FaceAll.avg;
    clear Gavg_FaceAll
    
for ss = 1:height(stream_Faces_features)  
    
    fprintf('Currently nr %i out of %i\n',ss,height(stream_Faces_features))
    Subj = stream_ClnEEG.IDses{ss}; %ppt code
    fprintf('Subject %s\n',Subj)
    
    % 1) load clean data
        load(stream_ClnEEG.CleanData_path{ss},'EEGdata_Faces_Obj', 'FastERP_info')

    % 2) preallocate datasets for tracking table
        Number_of_randomselections = length(Nrantrls);
        Ntrls = nan(1,Number_of_randomselections);
        ERPtime = cell(1,Number_of_randomselections);
        ERPavg = cell(1,Number_of_randomselections);
        N290lat = nan(1,Number_of_randomselections);
        N290pamp = nan(1,Number_of_randomselections);
        N290mamp = nan(1,Number_of_randomselections);
        P400mamp = nan(1,Number_of_randomselections);
        DTWdir_stim = nan(1,Number_of_randomselections);
        DTWdir_N290time = nan(1,Number_of_randomselections);
        DTWdir_P400time = nan(1,Number_of_randomselections);
        N290_valid = nan(1,Number_of_randomselections);
        
        % preallocate datasets for later saving
        FacesERPs_RandomTrialSelection = struct;
        FacesERPs_RandomTrialSelection.Nrantrls = Nrantrls;
        FacesERPs_RandomTrialSelection.ERP = cell(1,Number_of_randomselections);
        FacesERPs_RandomTrialSelection.ERPfeatures = cell(1,Number_of_randomselections);

    % Loop through different numbers of trials to randomly select 
        
        for tt = 1:Number_of_randomselections
            % randomly draw N trials and calculate ERP avg
               Numcurr = Nrantrls(1,tt);
               [Individual_ERP_Faces] = BrtUKtrt_032a_randomNs_indivERPs(EEGdata_Faces_Obj, FastERP_info, 'facesUp', Numcurr);
            % get all features for checkers
               [ERPfeatures] = BrtUKtrt_032b_AllERPfeatures(Individual_ERP_Faces, 'faces', Ref_gavg);
            % add features for tracking table
                % check if the number of trials found was not 0
                if ~isequal(Individual_ERP_Faces.Navg,0)
                    ERPtime{1,tt} = Individual_ERP_Faces.time;
                    ERPavg{1,tt} = Individual_ERP_Faces.avg;
                else
                    ERPtime{1,tt} = [];
                    ERPavg{1,tt} = [];
                end
                Ntrls(1,tt) = Individual_ERP_Faces.Navg;
                N290lat(1,tt) = ERPfeatures.N290_Lat;
                N290pamp(1,tt) = ERPfeatures.N290_pAmp;
                N290mamp(1,tt) = ERPfeatures.N290_mAmp;
                P400mamp(1,tt) = ERPfeatures.P400_mAmp;
                DTWdir_stim(1,tt) = ERPfeatures.DTWdir_stim;
                DTWdir_N290time(1,tt) = ERPfeatures.DTWdir_N290;
                DTWdir_P400time(1,tt) = ERPfeatures.DTWdir_P400;
            % test validity of the N290 peak 
            if ~isequal(Individual_ERP_Faces.Navg,0)
                [valid] = BrtUK_03c_PeakValid(Individual_ERP_Faces, FastERP_info, ERPfeatures.N290_Lat);
            else
                valid = NaN;
            end
                 N290_valid(1,tt) = valid; clear valid
            % organise data for later saving
                FacesERPs_RandomTrialSelection.ERP{1,tt} = Individual_ERP_Faces;
                FacesERPs_RandomTrialSelection.ERPfeatures{1,tt} = ERPfeatures;
            
            clear ERPface ERPchecker
            clear Numcurr
        end %end loop through thresholds
        clear tt
        
    % save the data
        part1_path = extractBefore(stream_ClnEEG.CleanData_path{ss},'_CleanData.mat');
        FullNameData = strcat(part1_path,'_FacesSubsets_ERPs.mat');
        save(FullNameData, 'FacesERPs_RandomTrialSelection')    

    % add values to tracking table
        stream_Faces_features.IDses(ss) = {Subj};
        stream_Faces_features.CleanData_path(ss) = {stream_ClnEEG.CleanData_path{ss}};
        stream_Faces_features.ERPs_path(ss) = {FullNameData};
        stream_Faces_features.Nrantrls(ss) = {Ntrls};
        stream_Faces_features.ERPtime(ss) = {ERPtime};
        stream_Faces_features.ERPavg(ss) = {ERPavg};
        stream_Faces_features.N290lat(ss) = {N290lat};
        stream_Faces_features.N290pamp(ss) = {N290pamp};
        stream_Faces_features.N290mamp(ss) = {N290mamp};
        stream_Faces_features.P400mamp(ss) = {P400mamp};
        stream_Faces_features.DTWdir_stim(ss) = {DTWdir_stim};
        stream_Faces_features.DTWdir_N290time(ss) = {DTWdir_N290time};
        stream_Faces_features.DTWdir_P400time(ss) = {DTWdir_P400time};
        stream_Faces_features.N290_valid(ss) = {N290_valid};
  
        save('/Users/teresa/Documents/MATLAB/data/stream/0_stream_Trt/stream_Faces_features.mat','stream_Faces_features');
    
        % clean up
        clear FullNameData 
        clear FacesERPs_RandomTrialSelection 
        clear EEGdata_Faces_Obj FastERP_info 
        clear Number_of_randomselections Ntrls ERPtime ERPavg N290lat N290pamp N290mamp P400mamp 
        clear DTWdir_stim DTWdir_N290time DTWdir_P400time N290_valid
        clear part1_path ERPfeatures Individual_ERP_Faces

        fprintf('Data saved for subject %s\n',Subj)

        clear Subj


end % end loop through IDs

