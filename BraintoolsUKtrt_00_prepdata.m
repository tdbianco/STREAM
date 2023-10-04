%% Adapting the Braintools UK Script for STREAM

% This script prepares the data for EEG preprocessing analyses.

% For each session folder:

% 1) Find the fieldtrip data (or creates them if there are enobio data)
% 2) Extract the number of events for the fast ERP task in the EEG data
% 3) Extract the number of events for the fast ERP task in the ET data, and
% number of events the child was looking at 50% or more of the trial
% 4) Save all information from the session folder

% 5) Save all information in the matlab table

% % create a table with variable for tracking
%     PPTfolder = dir('/Users/teresa/Documents/MATLAB/data/stream');
%     Nrows = numel(PPTfolder)-3;
%     BraintoolsUK_IDs_tracking_wETint = table('Size',[Nrows 13], ...
%         'VariableNames',{'ID','tEEG_path','tNev_EEG','tNev_ET','tN_ETraw50','tN_ETint50','tETpropVal_raw_int',...
%         'rtEEG_path','rtNev_EEG','rtNev_ET','rtN_ETraw50','rtN_ETint50','rtETpropVal_raw_int'},...
%         'VariableTypes',{'cell','cell','cell','cell','cell','cell','cell',...
%         'cell','cell','cell','cell','cell','cell'});
% 
%     save('/Users/teresa/Documents/MATLAB/data/stream/stream_Trt/stream_IDs_tracking_wETint.mat','stream_IDs_tracking_wETint');

% Calls to functions from Fieldtrip, 
% and Task Engine and Braintools created by Luke Mason

% Based on Rianne Haartsen: jan-feb 21


%% Create the table to compilate with info %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear variables
% load('/XXXXX/BraintoolsUK_IDs_tracking_wETint.mat');

% or you can create a table with variable for tracking if it does not exist yet
    PPTfolder = dir('/Users/teresa/Documents/MATLAB/data/stream');
    Nrows = numel(PPTfolder)-7;
    stream_IDs_tracking_wETint = table('Size',[Nrows 13], ...
        'VariableNames',{'ID','tEEG_path','tNev_EEG','tNev_ET','tN_ETraw50','tN_ETint50','tETpropVal_raw_int',...
        'rtEEG_path','rtNev_EEG','rtNev_ET','rtN_ETraw50','rtN_ETint50','rtETpropVal_raw_int'},...
        'VariableTypes',{'cell','cell','cell','cell','cell','cell','cell',...
        'cell','cell','cell','cell','cell','cell'});

    save('/Users/teresa/Documents/MATLAB/data/stream/0_stream_Trt/stream_IDs_tracking_wETint.mat','stream_IDs_tracking_wETint');


% Set up local paths to scripts
%add LM code TaskEngine2
    addpath(genpath('/Users/teresa/Documents/MATLAB/STREAM/TaskEngine2'))
    addpath(genpath('/Users/teresa/Documents/MATLAB/STREAM/lm_tools'));
    addpath(genpath('/Users/teresa/Documents/MATLAB/STREAM/ettools-main'));
    addpath(genpath('/Users/teresa/Documents/MATLAB/STREAM/tasks')); 
% braintools UK specific analysis scripts    
    addpath('/Users/teresa/Documents/MATLAB/STREAM');
    addpath('/Users/teresa/Documents/MATLAB/EEG_QC/BrT_Arb_scripts')
%add fieldtrip path and set to defaults
    addpath('/Users/teresa/Documents/MATLAB/fieldtrip-20180925'); 
    ft_defaults

%% Populating the table %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for ii = 1 : height(stream_IDs_tracking_wETint) % per subject
    
    fprintf('Currently nr %i out of %i\n',ii,height(stream_IDs_tracking_wETint))
    fprintf('Subject %s \n',PPTfolder(7+ii).name)
    Subj = PPTfolder(7+ii).name; %ppt code
    
    ppt_folder_t = strcat('/Users/teresa/Documents/MATLAB/data/stream/',Subj);
    session_folders = dir(ppt_folder_t);
    session_folders(strncmp({session_folders.name}, '.', 1)) = []; % remove folders starting with '.'
    session_folders  = session_folders([session_folders.isdir]);
        
    % check the number of session folders (I assume 1 session)
%     N_sessions = numel(session_folders);
%     Info.tEEG_path = cell(1,N_sessions); % path to EEG data
%     Info.tNev_EEG = nan([1,N_sessions]); % number of events in EEG
%     Info.tNev_ET = nan([1,N_sessions]); % number of events in ET
%     Info.tN_ETraw50 = nan([1,N_sessions]); % number of trials valid before interpolation
%     Info.tN_ETint50 = nan([1,N_sessions]); % number of trials valid after interpolation
%     Info.tETpropVal_raw_int = cell(1,N_sessions); % prop valid before interpolation and after per trial
              
    SessionFolderCur = strcat(session_folders.folder,'/',session_folders.name);
%% 1) Find the EEG data 
    TEdata = teData(SessionFolderCur);
    ext = TEdata.ExternalData;
    % find the path to the easy file
    extEn = ext('enobio').Paths;
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
    TEdata = teData(SessionFolderCur);
    ext = TEdata.ExternalData;

%% 2) Find the number of events in the EEG for the fastERP task in the fieldtrip data
    % find raw data in the fieldtrip folder
    extFT = ext('fieldtrip').Paths; extFTeeg = extFT('fieldtrip');
    load(extFTeeg,'ft_data')
    % identify the number of events for the fastERP task
    EVvalue    = [ft_data.events.value]';
    numEvents = length(EVvalue);
    StimCodes = [310, 312, 314, 316, 318, 330, 331]; % faces up, checkerboards onset
    XOnset = zeros(numEvents,length(StimCodes));
    for ss = 1:length(StimCodes)
        XOnset((StimCodes(1,ss) == EVvalue),ss) = 1;
    end
    clear ss
    XOnset = sum(XOnset,2); IndTStim = find(XOnset==1);
    Nev_EEG = numel(IndTStim);
    clear EVvalue NumEvents StimCodes XOnset IndTStim
    clear FT_folder_cont Ind_ftraw Ind_ftraw_files

%% 3) Explore the eye-tracking ET data
% check whether the eye-tracking data exist
% Filter Log data for the fasterp task
tab = teLogFilter(TEdata.Log, 'task', 'fasterp', 'topic', 'trial_log_data');
t_n = height(tab); %find n of trials
% Loop through trials
propVal = nan(t_n, 1);
propVal_i = nan(t_n, 1);
for i = 1:t_n
    % Select Onset and Offset of trial i
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

% Save info for this session folder
Info.tEEG_path{1} = extFTeeg;
Info.tNev_EEG(1) = Nev_EEG;
Info.tNev_ET(1) = Nev_ET; % number of events in ET
Info.tN_ETraw50(1) = Nev_ETraw50; % number of trials valid before interpolation
Info.tN_ETint50(1) = Nev_ETint50; % number of trials valid after interpolation
Info.tETpropVal_raw_int{1} = PropVal_raw_int; % prop valid before and after interpolation per trial

clear extFTeeg Nev_EEG Nev_ET Nev_ETraw50 Nev_ETint50 PropVal_raw_int
        
% Save the info in the ppt table
stream_IDs_tracking_wETint.ID(ii) = {Subj};
stream_IDs_tracking_wETint.tEEG_path(ii) = {Info.tEEG_path};
stream_IDs_tracking_wETint.tNev_EEG(ii) = {Info.tNev_EEG};
stream_IDs_tracking_wETint.tNev_ET(ii) = {Info.tNev_ET};
stream_IDs_tracking_wETint.tN_ETraw50(ii) = {Info.tN_ETraw50};
stream_IDs_tracking_wETint.tN_ETint50(ii) = {Info.tN_ETint50};
stream_IDs_tracking_wETint.tETpropVal_raw_int(ii) = {Info.tETpropVal_raw_int};

clear Info

save('/Users/teresa/Documents/MATLAB/data/stream/0_stream_Trt/stream_IDs_tracking_wETint.mat','stream_IDs_tracking_wETint');

end %end loop per ID

%% Histogram percentages valid ET of all ET trials %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% and extraction of IDs for highly attentive sample

% For India
stream_IDs_tracking_wETint_IN = stream_IDs_tracking_wETint(startsWith(stream_IDs_tracking_wETint.ID,'IN'), : );
IN_info = nan(height(stream_IDs_tracking_wETint_IN),3);
for ii = 1:height(stream_IDs_tracking_wETint_IN)
    % number of ET events
    xxx = stream_IDs_tracking_wETint_IN.tNev_ET{ii};
    if size(xxx,2) == 1
        IN_info(ii,1) = xxx;
    else 
        IN_info(ii,1) = xxx(1,end);
    end
    % trials looking at after int
    xxx2 = stream_IDs_tracking_wETint_IN.tN_ETint50{ii};
    IN_info(ii,2) = sum(xxx2,2);
end
    clear xxx xxx2 

% For Malawi
stream_IDs_tracking_wETint_MW = stream_IDs_tracking_wETint(startsWith(stream_IDs_tracking_wETint.ID,'MW'), : );
MW_info = nan(height(stream_IDs_tracking_wETint_MW),3);
for ii = 1:height(stream_IDs_tracking_wETint_MW)
    % number of ET events
    xxx = stream_IDs_tracking_wETint_MW.tNev_ET{ii};
    if size(xxx,2) == 1
        MW_info(ii,1) = xxx;
    else 
        MW_info(ii,1) = xxx(1,end);
    end
    % trials looking at after int
    xxx2 = stream_IDs_tracking_wETint_MW.tN_ETint50{ii};
    MW_info(ii,2) = sum(xxx2,2);
end
clear xxx xxx2 
    
% Collate and calculate percentage
All_info = [IN_info; MW_info];
All_info(:,3) = round(All_info(:,2)./All_info(:,1)*100);

% Create histogram
figure
nbins = 30;
histogram(All_info(:,3),nbins)
xlabel('Percentage of valid ET trials from recorded ET trials')
ylabel('N datasets')
title('Data availability STREAM')

xxx = All_info((All_info(:,3) >= 60),:);


IN_info(:,3) = round(IN_info(:,2)./IN_info(:,1)*100);
xxxin = IN_info(:,3) >= 60;
% MW_info(:,3) = round(MW_info(:,2)./MW_info(:,1)*100);
% xxxmw = MW_info(:,3) >= 60;
% Indboth = find((xxxin + xxxmw) == 2);
% Nboth = length(Indboth);

% find out number of trials for these good participants
% For India
IN_EEGn = nan(height(stream_IDs_tracking_wETint_IN),3);
for ii = 1:height(stream_IDs_tracking_wETint_IN)
    % number of EEG events
    xxxE = stream_IDs_tracking_wETint_IN.tNev_EEG{ii};
    IN_EEGn(ii,1) = sum(xxxE,2);
end
clear xxxE 

% % For Malawi
% MW_EEGn = nan(height(stream_IDs_tracking_wETint_MW),3);
% for ii = 1:height(stream_IDs_tracking_wETint_MW)
%     % number of EEG events
%     xxxE = stream_IDs_tracking_wETint_MW.rtNev_EEG{ii};
%     MW_EEGn(ii,1) = sum(xxxE,2);
% end
% clear xxxE 
    
Ntrls_EEGIN = IN_EEGn(xxxin,1);
% Ntrls_EEGrt = Retest_EEGn(Indboth,1);
figure;
h1 = histogram(Ntrls_EEGIN);
hold on
h2 = histogram(Ntrls_EEGIN);
h1.BinWidth = 5;
h2.BinWidth = 5;
% legend('India','Malawi')
ylabel('N participants')
xlabel('N EEG trials')

IDs_HighlyAttentiveET_IN = stream_IDs_tracking_wETint_IN.ID(xxxin);
% Ntrls_EEG = [Ntrls_EEGt, Ntrls_EEGrt];

% IDs_HighlyAttentiveET = BraintoolsUK_IDs_tracking_wETint.ID(Indboth);
% Ntrls_EEG = [Ntrls_EEGt, Ntrls_EEGrt];








