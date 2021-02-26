%% Braintools UK project test-retest data

% This script prepares the data for EEG preprocessing analyses.

% For each session folder:

% 1) Find the fieldtrip data (or creates them if there are enobio data)
% 2) Extract the number of events for the fast ERP task in the EEG data
% 3) Extract the number of events for the fast ERP task in the ET data, and
% number of events the child was looking at 50% or more of the trial
% 4) Save all information from the session folder

% 5) Save all information in the matlab table

% % create a table with variable for tracking
%     PPTfolder = dir('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/DATAtest/');
%     Nrows = numel(PPTfolder)-3;
%     BraintoolsUK_IDs_tracking_wETint = table('Size',[Nrows 13], ...
%         'VariableNames',{'ID','tEEG_path','tNev_EEG','tNev_ET','tN_ETraw50','tN_ETint50','tETpropVal_raw_int',...
%         'rtEEG_path','rtNev_EEG','rtNev_ET','rtN_ETraw50','rtN_ETint50','rtETpropVal_raw_int'},...
%         'VariableTypes',{'cell','cell','cell','cell','cell','cell','cell',...
%         'cell','cell','cell','cell','cell','cell'});
% 
%     save('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BraintoolsUK_IDs_tracking_wETint.mat','BraintoolsUK_IDs_tracking_wETint');

% Calls to functions from Fieldtrip, 
% and Task Engine and Braintools created by Luke Mason

% by Rianne Haartsen: jan-feb 21


%% Load the table with info

clear variables
load('/XXXXX/BraintoolsUK_IDs_tracking_wETint.mat');

% % or you can create a table with variable for tracking if it does not
% exist yet
%     PPTfolder = dir('/XXXXX/DATAtest/');
%     Nrows = numel(PPTfolder)-3;
%     BraintoolsUK_IDs_tracking_wETint = table('Size',[Nrows 13], ...
%         'VariableNames',{'ID','tEEG_path','tNev_EEG','tNev_ET','tN_ETraw50','tN_ETint50','tETpropVal_raw_int',...
%         'rtEEG_path','rtNev_EEG','rtNev_ET','rtN_ETraw50','rtN_ETint50','rtETpropVal_raw_int'},...
%         'VariableTypes',{'cell','cell','cell','cell','cell','cell','cell',...
%         'cell','cell','cell','cell','cell','cell'});
% 
%     save('/XXXXX/BraintoolsUK_IDs_tracking_wETint.mat','BraintoolsUK_IDs_tracking_wETint');


% add common paths
% braintools and task engine scripts
    addpath(genpath('/XXXXX'));
% braintools UK specific analysis scripts    
    addpath('/XXXXX');
%add fieldtrip path and set to defaults
    addpath('XXXXX/fieldtrip-20180925'); 
    ft_defaults

%% Test session %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for ii = 1 : height(BraintoolsUK_IDs_tracking_wETint) % per subject
    
    fprintf('Currently nr %i out of %i\n',ii,height(BraintoolsUK_IDs_tracking_wETint))
    fprintf('Subject %s \n',BraintoolsUK_IDs_tracking_wETint.ID{ii})
    Subj = BraintoolsUK_IDs_tracking_wETint.ID{ii}; %ppt code
    
    if ~strcmp(BraintoolsUK_IDs_tracking_wETint.tEEG_path{ii},'TBC-multiple')
        ppt_folder_t = strcat('/XXXXX/DATAtest/',Subj);
        session_folders = dir(ppt_folder_t);
        session_folders(strncmp({session_folders.name}, '.', 1)) = []; % remove folders starting with '.'
        session_folders  = session_folders([session_folders.isdir]);
        
        % check the number of session folders
        N_sessions = numel(session_folders);
        Info.tEEG_path = cell(1,N_sessions); % path to EEG data
        Info.tNev_EEG = nan([1,N_sessions]); % number of events in EEG
        Info.tNev_ET = nan([1,N_sessions]); % number of events in ET
        Info.tN_ETraw50 = nan([1,N_sessions]); % number of trials valid before interpolation
        Info.tN_ETint50 = nan([1,N_sessions]); % number of trials valid after interpolation
        Info.tETpropVal_raw_int = cell(1,N_sessions); % prop valid before interpolation and after per trial
              
        
        for sss = 1:N_sessions % per session folder
            SessionFolderCur = strcat(session_folders(sss).folder,'/',session_folders(sss).name);
            %% 1) Find the EEG data 
            TEdata = teSession(SessionFolderCur);
            ext = TEdata.ExternalData;
               if isempty(ext('fieldtrip'))
                    warning('No fieldtrip folder found in the session folder')
                    % check whether the enobio data exist
                    if isempty(ext('enobio')), error('Enobio data not found'), end
                    % find the path to the easy file
                    extEn = ext('enobio').Paths;
                    if isempty(extEn('enobio_easy')), error('No .easy file found'), end   
                    extEnEasy = extEn('enobio_easy');
                    % convert the enobio data to fieldtrip format
                    [ft_data, events, t] = eegEnobio2Fieldtrip(extEnEasy);
                    ft_folder = strcat(SessionFolderCur,'/fieldtrip/');
                    mkdir(ft_folder)
                    % create a name for the document 
                    file_name = extractAfter(extEnEasy,'enobio/');
                    ft_dataname = strcat(ft_folder,'/',extractBefore(file_name,'.easy'),'_fieldtrip_raw.mat');
                    save(ft_dataname,'ft_data');
                    % get the external data information again now including
                    % fieldtrip data
                    TEdata = teSession(SessionFolderCur);
                    ext = TEdata.ExternalData;
               end

            %% 2) Find the number of events in the EEG for the fastERP task in the fieldtrip data
            % check whether the fieldtrip data exist
            if ~isempty(ext('fieldtrip'))
                % find raw data in the fieldtrip folder
                extFT = ext('fieldtrip').Paths; extFTeeg = extFT('fieldtrip');
                load(extFTeeg,'ft_data')
                % identify the number of events for the fastERP task
                EVvalue    = [ft_data.events.value]';
                numEvents = length(EVvalue);
                StimCodes = [310 311 312 313 314 315 316 317 320 321 330]; % faces up/inv, animals up/inv, checkerboards onset
                XOnset = zeros(numEvents,length(StimCodes));
                for ss = 1:length(StimCodes)
                    XOnset((StimCodes(1,ss) == EVvalue),ss) = 1;
                end
                clear ss
                XOnset = sum(XOnset,2); IndTStim = find(XOnset==1);
                Nev_EEG = numel(IndTStim);
                clear EVvalue NumEvents StimCodes XOnset IndTStim
                clear FT_folder_cont Ind_ftraw Ind_ftraw_files
            else
                warning('Fieldtrip data not found')
                extFTeeg = 'NA';
                Nev_EEG = 0;
            end

            %% 3) Explore the eye-tracking ET data
            % check whether the eye-tracking data exist
            if ~isempty(ext('eyetracking'))
                % Filter Log data for the fasterp task
                tab = teLogFilter(TEdata.Log.LogArray, 'task', 'fasterp', 'topic', 'trial_log_data');
                t_n = height(tab); %find n of trials
                % Loop through trials
                propVal = nan(t_n, 1);
                propVal_i = nan(t_n, 1);
                for i = 1:t_n
                    % Select Onset and Offset of trial *1 & 2*
                    onset = tab.stim_onset{i}; %{trial i}
                    offset = tab.stim_offset{i};
                    s1 = find(TEdata.ExternalData('eyetracking').Buffer(:, 1) >= onset, 1);
                    s2 = find(TEdata.ExternalData('eyetracking').Buffer(:, 1) >= offset, 1);
                    % Get proportion valid for the current trial
                    gaze = etGazeDataBino('te2', TEdata.ExternalData('eyetracking').Buffer(s1:s2, :));
                    missing_int = lm_interpLogicalVector(gaze.Missing,gaze.Time,0.150); %criterion in sec (same as gaze.Time)
                    propVal(i) = gaze.PropValid;
                    propVal_i(i) = prop(~missing_int);
                    clear onset offset s1 s2 gaze missing_int
                end    
                Nev_ET = t_n;
                Nev_ETraw50 = size(find(propVal >= .50),1); 
                Nev_ETint50 = size(find(propVal_i >= .50),1); 
                PropVal_raw_int = [propVal propVal_i];
                clear tab t_n
                clear FT_folder_cont Ind_ftraw Ind_ftraw_files propVal propVal_i
            else
                warning('Eye-tracking data not found')
                Nev_ET = 0;
                Nev_ETraw50 = 0; 
                Nev_ETint50 = 0;
                PropVal_raw_int = [];
            end
            
            % Save info for this session folder
            Info.tEEG_path{1,sss} = extFTeeg;
            Info.tNev_EEG(1,sss) = Nev_EEG;
            Info.tNev_ET(1,sss) = Nev_ET; % number of events in ET
            Info.tN_ETraw50(1,sss) = Nev_ETraw50; % number of trials valid before interpolation
            Info.tN_ETint50(1,sss) = Nev_ETint50; % number of trials valid after interpolation
            Info.tETpropVal_raw_int{1,sss} = PropVal_raw_int; % prop valid before and after interpolation per trial
            
            clear extFTeeg Nev_EEG Nev_ET Nev_ETraw50 Nev_ETint50 PropVal_raw_int
           
        end % end loop per session folder
        
        % Save the info in the ppt table
        BraintoolsUK_IDs_tracking_wETint.tEEG_path(ii) = {Info.tEEG_path};
        BraintoolsUK_IDs_tracking_wETint.tNev_EEG(ii) = {Info.tNev_EEG};
        BraintoolsUK_IDs_tracking_wETint.tNev_ET(ii) = {Info.tNev_ET};
        BraintoolsUK_IDs_tracking_wETint.tN_ETraw50(ii) = {Info.tN_ETraw50};
        BraintoolsUK_IDs_tracking_wETint.tN_ETint50(ii) = {Info.tN_ETint50};
        BraintoolsUK_IDs_tracking_wETint.tETpropVal_raw_int(ii) = {Info.tETpropVal_raw_int};
        
        clear Info
        
        save('/XXXXX/BraintoolsUK_IDs_tracking_wETint.mat','BraintoolsUK_IDs_tracking_wETint');

    end % check if the tEEG_path is not 'multiple' > use troubleshoot script for complicated subjects


end %end loop per ID




%% Retest session %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for ii = 1:height(BraintoolsUK_IDs_tracking_wETint) % per subject
    
    fprintf('Currently nr %i out of %i\n',ii,height(BraintoolsUK_IDs_tracking_wETint))
    fprintf('Subject %s \n',BraintoolsUK_IDs_tracking_wETint.ID{ii})
    Subj = BraintoolsUK_IDs_tracking_wETint.ID{ii}; %ppt code
    
    if ~strcmp(BraintoolsUK_IDs_tracking_wETint.rtEEG_path{ii},'TBC-multiple')
        ppt_folder_t = strcat('/XXXXX/Braintools_UK_Trt/DATAretest/',Subj);
        session_folders = dir(ppt_folder_t);
        session_folders(strncmp({session_folders.name}, '.', 1)) = []; % remove folders starting with '.'
        session_folders  = session_folders([session_folders.isdir]);
        
       % check the number of session folders
        N_sessions = numel(session_folders);
        Info.rtEEG_path = cell(1,N_sessions); % path to EEG data
        Info.rtNev_EEG = nan([1,N_sessions]); % number of events in EEG
        Info.rtNev_ET = nan([1,N_sessions]); % number of events in ET
        Info.rtN_ETraw50 = nan([1,N_sessions]); % number of trials valid before interpolation
        Info.rtN_ETint50 = nan([1,N_sessions]); % number of trials valid after interpolation
        Info.rtETpropVal_raw_int = cell(1,N_sessions); % prop valid before interpolation and after per trial
        
        
        
        for sss = 1:N_sessions % per session folder
            SessionFolderCur = strcat(session_folders(sss).folder,'/',session_folders(sss).name);
            %% 1) Find the EEG data 
            TEdata = teSession(SessionFolderCur);
            ext = TEdata.ExternalData;
               if isempty(ext('fieldtrip'))
                    warning('No fieldtrip folder found in the session folder')
                    % check whether the enobio data exist
                    if ~isempty(ext('enobio')) 
                    % find the path to the easy file
                        extEn = ext('enobio').Paths;
                        if isempty(extEn('enobio_easy')), error('No .easy file found'), end   
                        extEnEasy = extEn('enobio_easy');
                        % convert the enobio data to fieldtrip format
                        [ft_data, events, t] = eegEnobio2Fieldtrip(extEnEasy);
                        ft_folder = strcat(SessionFolderCur,'/fieldtrip/');
                        mkdir(ft_folder)
                        % create a name for the document 
                        file_name = extractAfter(extEnEasy,'enobio/');
                        ft_dataname = strcat(ft_folder,'/',extractBefore(file_name,'.easy'),'_fieldtrip_raw.mat');
                        save(ft_dataname,'ft_data');
                        % get the external data information again now including
                        % fieldtrip data
                        TEdata = teSession(SessionFolderCur);
                        ext = TEdata.ExternalData;
                    else
                        warning('Enobio data not found');
                    end
               end

            %% 2) Find the number of events in the EEG for the fastERP task in the fieldtrip data
            % check whether the fieldtrip data exist
            if ~isempty(ext('fieldtrip'))
                % find raw data in the fieldtrip folder
                extFT = ext('fieldtrip').Paths; extFTeeg = extFT('fieldtrip');
                load(extFTeeg,'ft_data')
                % identify the number of events for the fastERP task
                EVvalue    = [ft_data.events.value]';
                numEvents = length(EVvalue);
                StimCodes = [310 311 312 313 314 315 316 317 320 321 330]; % faces up/inv, animals up/inv, checkerboards onset
                XOnset = zeros(numEvents,length(StimCodes));
                for ss = 1:length(StimCodes)
                    XOnset((StimCodes(1,ss) == EVvalue),ss) = 1;
                end
                clear ss
                XOnset = sum(XOnset,2); IndTStim = find(XOnset==1);
                Nev_EEG = numel(IndTStim);
                clear EVvalue NumEvents StimCodes XOnset IndTStim
                clear FT_folder_cont Ind_ftraw Ind_ftraw_files
            else
                warning('Fieldtrip data not found')
                extFTeeg = 'NA';
                Nev_EEG = 0;
            end

            %% 3) Explore the eye-tracking ET data
            % check whether the eye-tracking data exist
            if ~isempty(ext('eyetracking'))
                % Filter Log data for the fasterp task
                tab = teLogFilter(TEdata.Log.LogArray, 'task', 'fasterp', 'topic', 'trial_log_data');
                t_n = height(tab); %find n of trials
                % Loop through trials
                propVal = nan(t_n, 1);
                propVal_i = nan(t_n, 1);
                for i = 1:t_n
                    % Select Onset and Offset of trial *1 & 2*
                    onset = tab.stim_onset{i}; %{trial i}
                    offset = tab.stim_offset{i};
                    s1 = find(TEdata.ExternalData('eyetracking').Buffer(:, 1) >= onset, 1);
                    s2 = find(TEdata.ExternalData('eyetracking').Buffer(:, 1) >= offset, 1);
                    % Get proportion valid for the current trial
                    gaze = etGazeDataBino('te2', TEdata.ExternalData('eyetracking').Buffer(s1:s2, :));
                    missing_int = lm_interpLogicalVector(gaze.Missing,gaze.Time,0.150); %criterion in sec (same as gaze.Time)
                    propVal(i) = gaze.PropValid;
                    propVal_i(i) = prop(~missing_int);
                    clear onset offset s1 s2 gaze missing_int
                end    
                Nev_ET = t_n;
                Nev_ETraw50 = size(find(propVal >= .50),1); 
                Nev_ETint50 = size(find(propVal_i >= .50),1); 
                PropVal_raw_int = [propVal propVal_i];
                clear tab t_n
                clear FT_folder_cont Ind_ftraw Ind_ftraw_files propVal propVal_i
            else
                warning('Eye-tracking data not found')
                Nev_ET = 0;
                Nev_ETraw50 = 0; 
                Nev_ETint50 = 0; 
                PropVal_raw_int = [];
            end
            
            % Save info for this session folder
            Info.rtEEG_path{1,sss} = extFTeeg;
            Info.rtNev_EEG(1,sss) = Nev_EEG;
            Info.rtNev_ET(1,sss) = Nev_ET; % number of events in ET
            Info.rtN_ETraw50(1,sss) = Nev_ETraw50; % number of trials valid before interpolation
            Info.rtN_ETint50(1,sss) = Nev_ETint50; % number of trials valid after interpolation
            Info.rtETpropVal_raw_int{1,sss} = PropVal_raw_int; % prop valid before and after interpolation per trial
            
            clear extFTeeg Nev_EEG Nev_ET Nev_ETraw50 Nev_ETint50 PropVal_raw_int
            
        end % end loop per session folder
        
               % Save the info in the ppt table
        BraintoolsUK_IDs_tracking_wETint.rtEEG_path(ii) = {Info.rtEEG_path};
        BraintoolsUK_IDs_tracking_wETint.rtNev_EEG(ii) = {Info.rtNev_EEG};
        BraintoolsUK_IDs_tracking_wETint.rtNev_ET(ii) = {Info.rtNev_ET};
        BraintoolsUK_IDs_tracking_wETint.rtN_ETraw50(ii) = {Info.rtN_ETraw50};
        BraintoolsUK_IDs_tracking_wETint.rtN_ETint50(ii) = {Info.rtN_ETint50};
        BraintoolsUK_IDs_tracking_wETint.rtETpropVal_raw_int(ii) = {Info.rtETpropVal_raw_int};
        
        clear Info
        
        save('/XXXXX/BraintoolsUK_IDs_tracking_wETint.mat','BraintoolsUK_IDs_tracking_wETint');

    end % check if the tEEG_path is empty


end %end loop per ID



%% Histogram percentages valid ET of all ET trials
% and extraction of IDs for highly attentive sample

% For test
Test_info = nan(height(BraintoolsUK_IDs_tracking_wETint),3);
for ii = 1:height(BraintoolsUK_IDs_tracking_wETint)
    % number of ET events
    xxx = BraintoolsUK_IDs_tracking_wETint.tNev_ET{ii};
    if size(xxx,2) == 1
        Test_info(ii,1) = xxx;
    else 
        Test_info(ii,1) = xxx(1,end);
    end
    % trials looking at after int
    xxx2 = BraintoolsUK_IDs_tracking_wETint.tN_ETint50{ii};
    Test_info(ii,2) = sum(xxx2,2);
end
    clear xxx xxx2 

% For retest
Retest_info = nan(height(BraintoolsUK_IDs_tracking_wETint),3);
for ii = 1:height(BraintoolsUK_IDs_tracking_wETint)
    % number of ET events
    xxx = BraintoolsUK_IDs_tracking_wETint.rtNev_ET{ii};
    if size(xxx,2) == 1
        Retest_info(ii,1) = xxx;
    else 
        Retest_info(ii,1) = xxx(1,end);
    end
    % trials looking at after int
    xxx2 = BraintoolsUK_IDs_tracking_wETint.rtN_ETint50{ii};
    Retest_info(ii,2) = sum(xxx2,2);
end
clear xxx xxx2 
    
% Collate and calculate percentage
All_info = [Test_info; Retest_info];
All_info(:,3) = round(All_info(:,2)./All_info(:,1)*100);

% Create histogram
figure
nbins = 30;
histogram(All_info(:,3),nbins)
xlabel('Percentage of valid ET trials from recorded ET trials')
ylabel('N datasets')
title('Data availability Braintools UK (Ntot = 86)')

xxx = All_info((All_info(:,3) >= 60),:);


Test_info(:,3) = round(Test_info(:,2)./Test_info(:,1)*100);
xxxtest = Test_info(:,3) >= 60;
Retest_info(:,3) = round(Retest_info(:,2)./Retest_info(:,1)*100);
xxxretest = Retest_info(:,3) >= 60;
Indboth = find((xxxtest + xxxretest) == 2);
Nboth = length(Indboth);

% find out number of trials for these good participants
% For test
Test_EEGn = nan(height(BraintoolsUK_IDs_tracking_wETint),3);
for ii = 1:height(BraintoolsUK_IDs_tracking_wETint)
    % number of EEG events
    xxxE = BraintoolsUK_IDs_tracking_wETint.tNev_EEG{ii};
    Test_EEGn(ii,1) = sum(xxxE,2);
end
clear xxxE 
% For retest
Retest_EEGn = nan(height(BraintoolsUK_IDs_tracking_wETint),3);
for ii = 1:height(BraintoolsUK_IDs_tracking_wETint)
    % number of EEG events
    xxxE = BraintoolsUK_IDs_tracking_wETint.rtNev_EEG{ii};
    Retest_EEGn(ii,1) = sum(xxxE,2);
end
clear xxxE 
    
Ntrls_EEGt = Test_EEGn(Indboth,1);
Ntrls_EEGrt = Retest_EEGn(Indboth,1);
figure;
h1 = histogram(Ntrls_EEGt);
hold on
h2 = histogram(Ntrls_EEGrt);
h1.BinWidth = 5;
h2.BinWidth = 5;
legend('test','retest')
ylabel('N participants')
xlabel('N EEG trials')

IDs_HighlyAttentiveET = BraintoolsUK_IDs_tracking_wETint.ID(Indboth);
Ntrls_EEG = [Ntrls_EEGt, Ntrls_EEGrt];








