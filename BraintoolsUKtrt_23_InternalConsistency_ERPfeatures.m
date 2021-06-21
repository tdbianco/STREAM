%% % Braintools UK project test-retest data: Extracting ERP component features for different face orientation conditions

% This script reads in all the clean data, then randomly draws different
% numbers of trials from the data, and extracts the relevant EEG features.

% N trials: 10 - 20 - 30 - 40 - 50 - all available
% for faces and objects
% creating 2 subsets of data within each session: setA and setB
% to calculate alternating split-half reliability

% EEG features: 
% checkerboards: P1 lat, P1 pamp, P1 dtw
% faces; N290 lat, N290 pamp, N290 mamp, N290 dtw, P400 mean ampl 
% at both test and retest

% check ERPs and peaks
% save info into table

% check internal consistency at test and retest for each measure

% calls to: LM functions, ft functions, and Brt_UK_trt_randomNs_ERPfeatures
% - BrtUKtrt_232a_alternatingNs_indivERPs
% - BrtUKtrt_032b_AllERPfeatures
% - BrtUKtrt_032c_PeakValid

% RH 10-05-21

%%

clear variables
% braintools UK specific analysis scripts    
    addpath('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrT_UK_scripts_publication');
% add fieldtrip path and set to defaults
    addpath('/Users/riannehaartsen/Documents/MATLAB/fieldtrip-20180925'); 
    ft_defaults
    
    cd('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/')

%% Loop through participants for test data    
    % load old and new trackers
%         load /Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BraintoolsUK_Cleandata_tracker.mat
%         load /Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_CE_ERPs_Nrandtrls.mat

    
%     % create a table with variable for tracking for checkers
%     % Variables: ID+session, CleanData_path, ERPs_path, Nrantrls, ERPtime 
%     % C_Ntrls, CA_ERPavg, CA_P1lat, CA_P1pamp, CA_P1dtw, CA_P1val, CB_ERPavg,
%     % CB_P1lat, CB_P1pamp, CB_P1dtw,CA_P1val 
% 
%         Nrows = 76;
%         BrtUK_InternCons_Checkers = table('Size',[Nrows 18], ...
%             'VariableNames',{'IDses','CleanData_path','ERPs_path','Nrantrls', 'ERPtime', ...
%             'C_Ntrls','CA_Ntrls','CA_ERPavg', 'CA_P1lat', 'CA_P1pamp', 'CA_P1dtw', 'CA_P1val','CB_Ntrls','CB_ERPavg', 'CB_P1lat', 'CB_P1pamp', 'CB_P1dtw', 'CB_P1val'},...
%             'VariableTypes',{'cell','cell','cell','cell','cell',...
%             'cell','cell','cell','cell','cell', 'cell','cell','cell','cell','cell','cell','cell','cell'});
% 
%         save('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_InternCons_Checkers.mat','BrtUK_InternCons_Checkers');
% 
% 
%     % create a table with variable for tracking for faces
%     % Variables: ID+session, CleanData_path, ERPs_path, Nrantrls, ERPtime 
%     % F_Ntls, FA_ERPavg, FA_N290lat, FA_N290pamp, FA_N290mamp, FA_N290dtw, FA_P400mamp, 
%     % FB_ERPavg, FB_N290lat, FB_N290pamp, FB_N290mamp, FB_N290dtw, FB_P400mamp, 
% 
%         Nrows = 76;
%         BrtUK_InternCons_Faces = table('Size',[Nrows 22], ...
%             'VariableNames',{'IDses','CleanData_path','ERPs_path','Nrantrls','ERPtime'...
%             'F_Ntls','FA_Ntls','FA_ERPavg', 'FA_N290lat', 'FA_N290pamp', 'FA_N290mamp', 'FA_N290dtw', 'FA_P400mamp', 'FA_N290val',...
%             'FB_Ntls','FB_ERPavg', 'FB_N290lat', 'FB_N290pamp', 'FB_N290mamp', 'FB_N290dtw', 'FB_P400mamp','FB_N290val'},...
%             'VariableTypes',{'cell','cell','cell','cell','cell',...
%             'cell','cell','cell','cell','cell', 'cell','cell','cell',...
%             'cell','cell','cell','cell','cell','cell','cell','cell','cell'});
% 
%         save('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_InternCons_Faces.mat','BrtUK_InternCons_Faces');

    % Define the different numbers of trials to average across
        Nrantrls = [10, 20, 30, 40, 50, 60, 70, 0]; % 0 = all trials available

    % load the grand average for the dtw
    load('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BraintoolsUK_GrandAverages.mat','Gavg_Checkers')
    Ref_gavg_Checkers = Gavg_Checkers.avg;
    clear Gavg_Checkers
    
    load('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_InternCons_Checkers.mat');

    
% loop through participants for checkers
    
for ss = 1:height(BrtUK_InternCons_Checkers)  
    
    fprintf('Currently nr %i out of %i\n',ss,height(BrtUK_InternCons_Checkers))
    Subj = BrtUK_InternCons_Checkers.IDses{ss}; %ppt code
    fprintf('Subject %s\n',Subj)
    
    % 1) load clean data
        load(BrtUK_InternCons_Checkers.CleanData_path{ss}, 'EEGdata_Checkers', 'FastERP_info')

    % preallocate datasets for tracking table
        Number_of_randomselections = length(Nrantrls);
        Checker_Ntrls = nan(1,Number_of_randomselections);
        CheckerA_Ntrls = nan(1,Number_of_randomselections);
        CheckerA_ERPavg = cell(1,Number_of_randomselections);
        CheckerA_P1lat = nan(1,Number_of_randomselections);
        CheckerA_P1pamp = nan(1,Number_of_randomselections);
        CheckerA_P1dtw = nan(1,Number_of_randomselections);
        CheckerA_P1val = nan(1,Number_of_randomselections);
        CheckerB_Ntrls = nan(1,Number_of_randomselections);
        CheckerB_ERPavg = cell(1,Number_of_randomselections);
        CheckerB_P1lat = nan(1,Number_of_randomselections);
        CheckerB_P1pamp = nan(1,Number_of_randomselections);
        CheckerB_P1dtw = nan(1,Number_of_randomselections);
        CheckerB_P1val = nan(1,Number_of_randomselections);
        
        % preallocate datasets for later saving
        InternCons_Checkers = struct;
        InternCons_Checkers.Nrantrls = Nrantrls;
        InternCons_Checkers.SetA.Individual_ERP = cell(1,Number_of_randomselections);
        InternCons_Checkers.SetA.ERP_features = cell(1,Number_of_randomselections);
        InternCons_Checkers.SetB.Individual_ERP = cell(1,Number_of_randomselections);
        InternCons_Checkers.SetB.ERP_features = cell(1,Number_of_randomselections);

    % Loop through different numbers of trials to randomly select 
        
        for tt = 1:Number_of_randomselections
            % randomly draw N trials and calculate ERP avg and component
            % features
                Numcurr = Nrantrls(1,tt);
                [setA_Individual_ERP, setB_Individual_ERP] = BrtUKtrt_232a_alternatingNs_indivERPs(EEGdata_Checkers, FastERP_info, 'checkers', Numcurr);
                % ERP features
                [setA_ERPfeatures] = BrtUKtrt_032b_AllERPfeatures(setA_Individual_ERP, 'checkers', Ref_gavg_Checkers);
                [setB_ERPfeatures] = BrtUKtrt_032b_AllERPfeatures(setB_Individual_ERP, 'checkers', Ref_gavg_Checkers);
                % validity of ERP
                if ~isnan(setA_ERPfeatures.P1_Lat)
                    [validA] = BrtUKtrt_032c_PeakValid(setA_Individual_ERP, FastERP_info, setA_ERPfeatures.P1_Lat);
                    [validB] = BrtUKtrt_032c_PeakValid(setB_Individual_ERP, FastERP_info, setB_ERPfeatures.P1_Lat);
                else
                    validA = NaN;
                    validB = NaN;
                end
                
            % get values for tracking table
                Checker_Ntrls(1,tt) = setA_Individual_ERP.Navg + setB_Individual_ERP.Navg;
                CheckerA_Ntrls(1,tt) = setA_Individual_ERP.Navg;
                CheckerA_ERPavg{1,tt} = setA_Individual_ERP.avg;
                CheckerA_P1lat(1,tt) = setA_ERPfeatures.P1_Lat;
                CheckerA_P1pamp(1,tt) = setA_ERPfeatures.P1_pAmp;
                CheckerA_P1dtw(1,tt) = setA_ERPfeatures.DTWdir_P1;
                CheckerA_P1val(1,tt) = validA;
                CheckerB_Ntrls(1,tt) = setB_Individual_ERP.Navg;
                CheckerB_ERPavg{1,tt} = setB_Individual_ERP.avg;
                CheckerB_P1lat(1,tt) = setB_ERPfeatures.P1_Lat;
                CheckerB_P1pamp(1,tt) = setB_ERPfeatures.P1_pAmp;
                CheckerB_P1dtw(1,tt) = setB_ERPfeatures.DTWdir_P1;
                CheckerB_P1val(1,tt) = validB;
                
         
            % organise data for later saving
                InternCons_Checkers.SetA.Individual_ERP{1,tt} = setA_Individual_ERP;
                InternCons_Checkers.SetA.ERP_features{1,tt} = setA_ERPfeatures;
                InternCons_Checkers.SetB.Individual_ERP{1,tt} = setB_Individual_ERP;
                InternCons_Checkers.SetB.ERP_features{1,tt} = setB_ERPfeatures;
            
            clear setA_Individual_ERP setA_ERPfeatures setB_Individual_ERP setB_ERPfeatures
            clear Numcurr

        end %end loop through Ntrials
        clear tt
        
    % save the data
        part1_path = extractBefore(BrtUK_InternCons_Checkers.CleanData_path{ss},'_CleanData.mat');
        FullNameData = strcat(part1_path,'_InterConsCheckers_setA_setB.mat');
        save(FullNameData, 'InternCons_Checkers')    

    % add values to tracking table
        BrtUK_InternCons_Checkers.ERPs_path(ss) = {FullNameData};
        BrtUK_InternCons_Checkers.Nrantrls(ss) = {Nrantrls};
        BrtUK_InternCons_Checkers.ERPtime(ss) = {EEGdata_Checkers.time{1,1}};
        BrtUK_InternCons_Checkers.C_Ntrls(ss) = {Checker_Ntrls};
        BrtUK_InternCons_Checkers.CA_Ntrls(ss) = {CheckerA_Ntrls};
        BrtUK_InternCons_Checkers.CA_ERPavg(ss) = {CheckerA_ERPavg};
        BrtUK_InternCons_Checkers.CA_P1lat(ss) = {CheckerA_P1lat};
        BrtUK_InternCons_Checkers.CA_P1pamp(ss) = {CheckerA_P1pamp};
        BrtUK_InternCons_Checkers.CA_P1dtw(ss) = {CheckerA_P1dtw};
        BrtUK_InternCons_Checkers.CA_P1val(ss) = {CheckerA_P1val};
        BrtUK_InternCons_Checkers.CB_Ntrls(ss) = {CheckerA_Ntrls};
        BrtUK_InternCons_Checkers.CB_ERPavg(ss) = {CheckerB_ERPavg};
        BrtUK_InternCons_Checkers.CB_P1lat(ss) = {CheckerB_P1lat};
        BrtUK_InternCons_Checkers.CB_P1pamp(ss) = {CheckerB_P1pamp};
        BrtUK_InternCons_Checkers.CB_P1dtw(ss) = {CheckerB_P1dtw};
        BrtUK_InternCons_Checkers.CB_P1val(ss) = {CheckerB_P1val};
  
        save('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_InternCons_Checkers.mat','BrtUK_InternCons_Checkers');

        % clean up
        clear FullNameData Checker_Ntrls Checker_P1lat Checker_P1mamp
        clear ERPtime CheckerA_ERPavg CheckerA_P1lat CheckerA_P1pamp CheckerA_P1dtw CheckerA_P1val 
        clear CheckerB_ERPavg CheckerB_P1lat CheckerB_P1pamp CheckerB_P1dtw CheckerB_P1val 
        clear CheckerA_Ntrls CheckerB_Ntrls part1_path validA validB
        clear InternCons_Checkers
        clear EEGdata_Checkers FastERP_info


        fprintf('Data saved for subject %s\n',Subj)

        clear Subj


end % end loop through IDs    
    
    
    
    
    
%%    
    
% loop through participants for faces

load('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_InternCons_Faces.mat');
% load the grand average for the dtw
    load('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BraintoolsUK_GrandAverages.mat','Gavg_FaceAll')
    Ref_gavg_FaceAll = Gavg_FaceAll.avg;
    clear Gavg_FaceAll 

% Define the different numbers of trials to average across
        Nrantrls = [10, 20, 30, 40, 50, 60, 70, 0]; % 0 = all trials available


for ss = 1:height(BrtUK_InternCons_Faces)  
    
    fprintf('Currently nr %i out of %i\n',ss,height(BrtUK_InternCons_Faces))
    Subj = BrtUK_InternCons_Faces.IDses{ss}; %ppt code
    fprintf('Subject %s\n',Subj)
    
    % 1) load clean data
        load(BrtUK_InternCons_Faces.CleanData_path{ss},'EEGdata_Faces_Obj', 'FastERP_info')

    % 2) preallocate datasets for tracking table
        Number_of_randomselections = length(Nrantrls);
        ERPtime = cell(1,Number_of_randomselections);
        Faces_Ntrls = nan(1,Number_of_randomselections);
        FacesA_Ntrls = nan(3,Number_of_randomselections);
        FacesA_ERPavg = cell(1,Number_of_randomselections);
        FacesA_N290lat = nan(1,Number_of_randomselections);
        FacesA_N290pamp = nan(1,Number_of_randomselections);
        FacesA_N290mamp = nan(1,Number_of_randomselections);
        FacesA_N290dtw = nan(1,Number_of_randomselections);
        FacesA_P400mamp = nan(1,Number_of_randomselections);
        FacesA_val = nan(1,Number_of_randomselections);
        FacesB_Ntrls = nan(3,Number_of_randomselections);
        FacesB_ERPavg = cell(1,Number_of_randomselections);
        FacesB_N290lat = nan(1,Number_of_randomselections);
        FacesB_N290pamp = nan(1,Number_of_randomselections);
        FacesB_N290mamp = nan(1,Number_of_randomselections);
        FacesB_N290dtw = nan(1,Number_of_randomselections);
        FacesB_P400mamp = nan(1,Number_of_randomselections);
        FacesB_val = nan(1,Number_of_randomselections);
 
        % preallocate datasets for later saving
        InternCons_Faces = struct;
        InternCons_Faces.Nrantrls = Nrantrls;
        InternCons_Faces.SetA.Individual_ERP = cell(1,Number_of_randomselections);
        InternCons_Faces.SetA.ERP_features = cell(1,Number_of_randomselections);
        InternCons_Faces.SetB.Individual_ERP = cell(1,Number_of_randomselections);
        InternCons_Faces.SetB.ERP_features = cell(1,Number_of_randomselections);

    % Loop through different numbers of trials to randomly select 
        
         for tt = 1:Number_of_randomselections
            % randomly draw N trials and calculate ERP avg and component
            % features
                Numcurr = Nrantrls(1,tt);
                [setA_Individual_ERP, setB_Individual_ERP] = BrtUKtrt_232a_alternatingNs_indivERPs(EEGdata_Faces_Obj, FastERP_info, 'faces', Numcurr);
                % ERP features
                [setA_ERPfeatures] = BrtUKtrt_032b_AllERPfeatures(setA_Individual_ERP, 'faces', Ref_gavg_FaceAll);
                [setB_ERPfeatures] = BrtUKtrt_032b_AllERPfeatures(setB_Individual_ERP, 'faces', Ref_gavg_FaceAll);
                % validity of ERP
                if ~isnan(setA_ERPfeatures.N290_Lat)
                    [validA] = BrtUKtrt_032c_PeakValid(setA_Individual_ERP, FastERP_info, setA_ERPfeatures.N290_Lat);
                    [validB] = BrtUKtrt_032c_PeakValid(setB_Individual_ERP, FastERP_info, setB_ERPfeatures.N290_Lat);
                else
                    validA = NaN;
                    validB = NaN;
                end
                
            % add features for tracking table
                % ERPs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                Faces_Ntrls(1,tt) = setA_Individual_ERP.Navg + setB_Individual_ERP.Navg;
                % check if the number of trials found was not 0
                if ~isequal(setA_Individual_ERP.Navg,0) && ~isnan(setA_Individual_ERP.Navg)
                    ERPtime{1,tt} = setA_Individual_ERP.time;
                    FacesA_Ntrls(:,tt) = [setA_Individual_ERP.Navg; setA_Individual_ERP.Navg_fu; setA_Individual_ERP.Navg_fi];
                    FacesA_ERPavg{1,tt} = setA_Individual_ERP.avg;
                    FacesB_Ntrls(:,tt) = [setB_Individual_ERP.Navg; setB_Individual_ERP.Navg_fu; setB_Individual_ERP.Navg_fi];
                    FacesB_ERPavg{1,tt} = setB_Individual_ERP.avg;
                else
                    ERPtime{1,tt} = [];
                    FacesA_ERPavg{1,tt} = [];
                    FacesB_ERPavg{1,tt} = [];
                    FacesA_Ntrls(:,tt) = [0; 0; 0];
                    FacesA_ERPavg{1,tt} = [];
                    FacesB_Ntrls(:,tt) = [0; 0; 0];
                    FacesB_ERPavg{1,tt} = [];
                end
                % ERP features
                FacesA_N290lat(1,tt) = setA_ERPfeatures.N290_Lat;
                FacesA_N290pamp(1,tt) = setA_ERPfeatures.N290_pAmp;
                FacesA_N290mamp(1,tt) = setA_ERPfeatures.N290_mAmp;
                FacesA_N290dtw(1,tt) = setA_ERPfeatures.DTWdir_N290;
                FacesA_P400mamp(1,tt) = setA_ERPfeatures.P400_mAmp;
                FacesA_val(1,tt) = validA;
                
                FacesB_N290lat(1,tt) = setB_ERPfeatures.N290_Lat;
                FacesB_N290pamp(1,tt) = setB_ERPfeatures.N290_pAmp;
                FacesB_N290mamp(1,tt) = setB_ERPfeatures.N290_mAmp;
                FacesB_N290dtw(1,tt) = setB_ERPfeatures.DTWdir_N290;
                FacesB_P400mamp(1,tt) = setB_ERPfeatures.P400_mAmp;
                FacesB_val(1,tt) = validB;

            % organise data for later saving 
                InternCons_Faces.SetA.Individual_ERP{1,tt} = setA_Individual_ERP;
                InternCons_Faces.SetA.ERP_features{1,tt} = setA_ERPfeatures;
                InternCons_Faces.SetB.Individual_ERP{1,tt} = setB_ERPfeatures;
                InternCons_Faces.SetB.ERP_features{1,tt} = setB_Individual_ERP;

               
            clear setA_Individual_ERP setB_Individual_ERP setA_ERPfeatures setB_ERPfeatures validA validB
            clear Numcurr
        end %end loop through thresholds
        clear tt
        
    % save the data
        part1_path = extractBefore(BrtUK_InternCons_Faces.CleanData_path{ss},'_CleanData.mat');
        FullNameData = strcat(part1_path,'_InterConsFaces_setA_setB.mat');
        save(FullNameData, 'InternCons_Faces')    
        
    % add values to tracking table
        BrtUK_InternCons_Faces.ERPs_path(ss) = {FullNameData};
        BrtUK_InternCons_Faces.Nrantrls(ss) = {Nrantrls};
        BrtUK_InternCons_Faces.F_Ntls(ss) = {Faces_Ntrls};
        BrtUK_InternCons_Faces.ERPtime(ss) = {ERPtime};
        BrtUK_InternCons_Faces.FA_Ntls(ss) = {FacesA_Ntrls};
        BrtUK_InternCons_Faces.FA_ERPavg(ss) = {FacesA_ERPavg};
        BrtUK_InternCons_Faces.FA_N290lat(ss) = {FacesA_N290lat};
        BrtUK_InternCons_Faces.FA_N290pamp(ss) = {FacesA_N290pamp};
        BrtUK_InternCons_Faces.FA_N290mamp(ss) = {FacesA_N290mamp};
        BrtUK_InternCons_Faces.FA_N290dtw(ss) = {FacesA_N290dtw};
        BrtUK_InternCons_Faces.FA_P400mamp(ss) = {FacesA_P400mamp};
        BrtUK_InternCons_Faces.FA_N290val(ss) = {FacesA_val};
        BrtUK_InternCons_Faces.FB_Ntls(ss) = {FacesB_Ntrls};
        BrtUK_InternCons_Faces.FB_ERPavg(ss) = {FacesB_ERPavg};
        BrtUK_InternCons_Faces.FB_N290lat(ss) = {FacesB_N290lat};
        BrtUK_InternCons_Faces.FB_N290pamp(ss) = {FacesB_N290pamp};
        BrtUK_InternCons_Faces.FB_N290mamp(ss) = {FacesB_N290mamp};
        BrtUK_InternCons_Faces.FB_N290dtw(ss) = {FacesB_N290dtw};
        BrtUK_InternCons_Faces.FB_P400mamp(ss) = {FacesB_P400mamp};
        BrtUK_InternCons_Faces.FB_N290val(ss) = {FacesB_val};       
        
        save('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_InternCons_Faces.mat','BrtUK_InternCons_Faces');

        % clean up
        clear FullNameData 
        clear InternCons_Faces EEGdata_Faces_Obj FastERP_info 
        clear Number_of_randomselectionsNtrls part1_path 
        clear Faces_Ntrls ERPtime FacesA_Ntrls FacesA_ERPavg FacesA_N290lat FacesA_N290pamp FacesA_N290mamp FacesA_N290dtw FacesA_P400mamp FacesA_val 
        clear FacesB_Ntrls FacesB_ERPavg FacesB_N290lat FacesB_N290pamp FacesB_N290mamp FacesB_N290dtw FacesB_P400mamp FacesB_val

        fprintf('Data saved for subject %s\n',Subj)

        clear Subj


end % end loop through IDs


