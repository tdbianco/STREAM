%% % Braintools UK project test-retest data: Extracting ERP component features for different face orientation conditions

% This script reads in all the clean data, then randomly draws different
% numbers of trials from the data, and extracts the relevant EEG features.

% N trials: 10 - 20 - 30 - 40 - 50 - all available
% for faces up and inverted

% EEG features: 
% faces; N290 lat, N290 pamp, N290 mamp, N290 dtw, P400 mean ampl, P400 dtw
% for faces up and faces inv ERPs
% condition effect: Faces inv - faces up

% check ERPs and peaks
% save info into table

% calls to: LM functions, ft functions, and Brt_UK_trt_randomNs_ERPfeatures
% - BrtUKtrt_032a_randomNs_indivERPs
% - BrtUKtrt_032b_AllERPfeatures
% - BrtUKtrt_032c_PeakValid

% RH 04-05-21

%%

clear variables
% braintools UK specific analysis scripts    
    addpath('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrT_UK_scripts_publication');
% add fieldtrip path and set to defaults
    addpath('/Users/riannehaartsen/Documents/MATLAB/fieldtrip-20180925'); 
    ft_defaults

%% Loop through participants for test data    
    % load old and new trackers
%         load /Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BraintoolsUK_Cleandata_tracker.mat
        load /Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_CE_ERPs_Nrandtrls.mat

    % Define the different numbers of trials to average across
        Nrantrls = [10, 20, 30, 40, 50, 60, 70, 0]; % 0 = all trials available

% create a table with variable for tracking
% Variables: ID+session, CleanData_path, ERPs_path, Nrantrls,  
% Fu_Ntls, ERPtime, Fu_ERPavg, Fu_N290lat, Fu_N290pamp, Fu_N290mamp, Fu_N290dtw, Fu_P400mamp, Fu_P400dtw,
% Fi_Ntls, Fi_ERPavg, Fi_N290lat, Fi_N290pamp, Fi_N290mamp, Fi_N290dtw, Fi_P400mamp, Fi_P400dtw, 
% CE_N290lat, CE_N290pamp, CE_N290mamp, CE_N290dtw, CE_P400mamp, CE_P400dtw 
% 
%     Nrows = 76;
%     BrtUK_CE_ERPs_Nrandtrls = table('Size',[Nrows 29], ...
%         'VariableNames',{'IDses','CleanData_path','ERPs_path','Nrantrls',...
%         'Fu_Ntls', 'ERPtime', 'Fu_ERPavg','Fu_val', 'Fu_N290lat', 'Fu_N290pamp', 'Fu_N290mamp', 'Fu_N290dtw', 'Fu_P400mamp', 'Fu_P400dtw',...
%         'Fi_Ntls', 'Fi_ERPavg', 'Fi_val', 'Fi_N290lat', 'Fi_N290pamp', 'Fi_N290mamp', 'Fi_N290dtw', 'Fi_P400mamp', 'Fi_P400dtw', ...
%         'CE_N290lat', 'CE_N290pamp', 'CE_N290mamp', 'CE_N290dtw', 'CE_P400mamp', 'CE_P400dtw'},...
%         'VariableTypes',{'cell','cell','cell','cell',...
%         'cell','cell','cell','cell','cell', 'cell','cell','cell','cell','cell',...
%         'cell','cell','cell','cell','cell','cell','cell','cell', 'cell',...
%         'cell','cell','cell','cell','cell','cell'});
% 
%     save('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_CE_ERPs_Nrandtrls.mat','BrtUK_CE_ERPs_Nrandtrls');
%     
% load the grand average for the dtw
    load('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BraintoolsUK_GrandAverages.mat','Gavg_FaceAll')
    Ref_gavg_FaceAll = Gavg_FaceAll.avg;
    clear Gavg_FaceAll
    
for ss = 2:height(BrtUK_CE_ERPs_Nrandtrls)  
    
    fprintf('Currently nr %i out of %i\n',ss,height(BrtUK_CE_ERPs_Nrandtrls))
    Subj = BrtUK_CE_ERPs_Nrandtrls.IDses{ss}; %ppt code
    fprintf('Subject %s\n',Subj)
    
    % 1) load clean data
        load(BrtUK_CE_ERPs_Nrandtrls.CleanData_path{ss},'EEGdata_Faces_Obj', 'FastERP_info')

    % 2) preallocate datasets for tracking table
        Number_of_randomselections = length(Nrantrls);
        % face up
        FuNtrls = nan(1,Number_of_randomselections);
        ERPtime = cell(1,Number_of_randomselections);
        FuERPavg = cell(1,Number_of_randomselections);
        Fuval = nan(1,Number_of_randomselections);
        FuN290lat = nan(1,Number_of_randomselections);
        FuN290pamp = nan(1,Number_of_randomselections);
        FuN290mamp = nan(1,Number_of_randomselections);
        FuN290dtw = nan(1,Number_of_randomselections);
        FuP400mamp = nan(1,Number_of_randomselections);
        FuP400dtw = nan(1,Number_of_randomselections);
        % face inverted
        FiNtrls = nan(1,Number_of_randomselections);
        FiERPavg = cell(1,Number_of_randomselections);
        Fival = nan(1,Number_of_randomselections);
        FiN290lat = nan(1,Number_of_randomselections);
        FiN290pamp = nan(1,Number_of_randomselections);
        FiN290mamp = nan(1,Number_of_randomselections);
        FiN290dtw = nan(1,Number_of_randomselections);
        FiP400mamp = nan(1,Number_of_randomselections);
        FiP400dtw = nan(1,Number_of_randomselections);
        % condition effects: inv - up
        CeN290lat = nan(1,Number_of_randomselections);
        CeN290pamp = nan(1,Number_of_randomselections);
        CeN290mamp = nan(1,Number_of_randomselections);
        CeN290dtw = nan(1,Number_of_randomselections);
        CeP400mamp = nan(1,Number_of_randomselections);
        CeP400dtw = nan(1,Number_of_randomselections);
 
        % preallocate datasets for later saving
        CE_FacesERPs_RandomTrialSelection = struct;
        CE_FacesERPs_RandomTrialSelection.Nrantrls = Nrantrls;
        CE_FacesERPs_RandomTrialSelection.Up_ERP = cell(1,Number_of_randomselections);
        CE_FacesERPs_RandomTrialSelection.Up_ERPfeatures = cell(1,Number_of_randomselections);
        CE_FacesERPs_RandomTrialSelection.Inv_ERP = cell(1,Number_of_randomselections);
        CE_FacesERPs_RandomTrialSelection.Inv_ERPfeatures = cell(1,Number_of_randomselections);
        CE_FacesERPs_RandomTrialSelection.CE_ERPfeatures = cell(1,Number_of_randomselections);

    % Loop through different numbers of trials to randomly select 
        
        for tt = 1:Number_of_randomselections
            % randomly draw N trials and calculate ERP avg
               Numcurr = Nrantrls(1,tt);
               [IndivERP_FacesUp] = BrtUKtrt_032a_randomNs_indivERPs(EEGdata_Faces_Obj, FastERP_info, 'facesUp', Numcurr);
               [IndivERP_FacesInv] = BrtUKtrt_032a_randomNs_indivERPs(EEGdata_Faces_Obj, FastERP_info, 'facesInv', Numcurr);
            % get all features for checkers
               [ERPfeat_FacesUp] = BrtUKtrt_032b_AllERPfeatures(IndivERP_FacesUp, 'faces', Ref_gavg_FaceAll);
               [ERPfeat_FacesInv] = BrtUKtrt_032b_AllERPfeatures(IndivERP_FacesInv, 'faces', Ref_gavg_FaceAll);
               
            % add features for tracking table
                % faces up %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % check if the number of trials found was not 0
                if ~isequal(IndivERP_FacesUp.Navg,0)
                    ERPtime{1,tt} = IndivERP_FacesUp.time;
                    FuERPavg{1,tt} = IndivERP_FacesUp.avg;
                else
                    ERPtime{1,tt} = [];
                    FuERPavg{1,tt} = [];
                end
                
                FuNtrls(1,tt) = IndivERP_FacesUp.Navg;
                FuN290lat(1,tt) = ERPfeat_FacesUp.N290_Lat;
                FuN290pamp(1,tt) = ERPfeat_FacesUp.N290_pAmp;
                FuN290mamp(1,tt) = ERPfeat_FacesUp.N290_mAmp;
                FuN290dtw(1,tt) = ERPfeat_FacesUp.DTWdir_N290;
                FuP400mamp(1,tt) = ERPfeat_FacesUp.P400_mAmp;
                FuP400dtw(1,tt) = ERPfeat_FacesUp.DTWdir_P400;
                                
                % test validity of the N290 peak 
                if ~isequal(IndivERP_FacesUp.Navg,0)
                    [valid] = BrtUKtrt_032c_PeakValid(IndivERP_FacesUp, FastERP_info, ERPfeat_FacesUp.N290_Lat);
                else
                    valid = NaN;
                end
                Fuval(1,tt) = valid; clear valid
                     
                % faces inv %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % check if the number of trials found was not 0
                if ~isequal(IndivERP_FacesInv.Navg,0)
                    ERPtime{1,tt} = IndivERP_FacesInv.time;
                    FiERPavg{1,tt} = IndivERP_FacesInv.avg;
                else
                    ERPtime{1,tt} = [];
                    FiERPavg{1,tt} = [];
                end
                
                FiNtrls(1,tt) = IndivERP_FacesInv.Navg;
                FiN290lat(1,tt) = ERPfeat_FacesInv.N290_Lat;
                FiN290pamp(1,tt) = ERPfeat_FacesInv.N290_pAmp;
                FiN290mamp(1,tt) = ERPfeat_FacesInv.N290_mAmp;
                FiN290dtw(1,tt) = ERPfeat_FacesInv.DTWdir_N290;
                FiP400mamp(1,tt) = ERPfeat_FacesInv.P400_mAmp;
                FiP400dtw(1,tt) = ERPfeat_FacesInv.DTWdir_P400;
                                
                % test validity of the N290 peak 
                if ~isequal(IndivERP_FacesInv.Navg,0)
                    [valid] = BrtUKtrt_032c_PeakValid(IndivERP_FacesInv, FastERP_info, ERPfeat_FacesInv.N290_Lat);
                else
                    valid = NaN;
                end
                Fival(1,tt) = valid; clear valid     
                         
                % Condition effects: Inv - up
                CeN290lat(1,tt) = ERPfeat_FacesInv.N290_Lat - ERPfeat_FacesUp.N290_Lat;
                CeN290pamp(1,tt) = ERPfeat_FacesInv.N290_pAmp - ERPfeat_FacesUp.N290_pAmp;
                CeN290mamp(1,tt) = ERPfeat_FacesInv.N290_mAmp - ERPfeat_FacesUp.N290_mAmp;
                CeN290dtw(1,tt) = ERPfeat_FacesInv.DTWdir_N290 - ERPfeat_FacesUp.DTWdir_N290;
                CeP400mamp(1,tt) = ERPfeat_FacesInv.P400_mAmp - ERPfeat_FacesUp.P400_mAmp;
                CeP400dtw(1,tt) = ERPfeat_FacesInv.DTWdir_P400 - ERPfeat_FacesUp.DTWdir_P400;
                
                ERPfeat_CE.DiffN290_Lat = CeN290lat(1,tt); 
                ERPfeat_CE.DiffN290_pAmp = CeN290pamp(1,tt);
                ERPfeat_CE.DiffN290_mAmp = CeN290mamp(1,tt); 
                ERPfeat_CE.DiffN290_DTWdir = CeN290dtw(1,tt); 
                ERPfeat_CE.DiffP400_mAmp = CeP400mamp(1,tt); 
                ERPfeat_CE.DiffP400_DTWdir =CeP400dtw(1,tt);
                
  
            % organise data for later saving 
                CE_FacesERPs_RandomTrialSelection.Up_ERP{1,tt} = IndivERP_FacesUp;
                CE_FacesERPs_RandomTrialSelection.Up_ERPfeatures{1,tt} = ERPfeat_FacesUp;
                CE_FacesERPs_RandomTrialSelection.Inv_ERP{1,tt} = IndivERP_FacesInv;
                CE_FacesERPs_RandomTrialSelection.Inv_ERPfeatures{1,tt} = ERPfeat_FacesInv;
                CE_FacesERPs_RandomTrialSelection.CE_ERPfeatures{1,tt} = ERPfeat_CE;

               
            clear IndivERP_FacesUp ERPfeat_FacesUp IndivERP_FacesInv ERPfeat_FacesInv ERPfeat_CE
            clear Numcurr
        end %end loop through thresholds
        clear tt
        
    % save the data
        part1_path = extractBefore(BrtUK_CE_ERPs_Nrandtrls.CleanData_path{ss},'_CleanData.mat');
        FullNameData = strcat(part1_path,'_FacesUpInvSubsets_ERPs.mat');
        save(FullNameData, 'CE_FacesERPs_RandomTrialSelection')    
        
    % add values to tracking table
        BrtUK_CE_ERPs_Nrandtrls.ERPs_path(ss) = {FullNameData};
        BrtUK_CE_ERPs_Nrandtrls.Nrantrls(ss) = {Nrantrls};
        % face up
        BrtUK_CE_ERPs_Nrandtrls.Fu_Ntls(ss) = {FuNtrls};
        BrtUK_CE_ERPs_Nrandtrls.ERPtime(ss) = {ERPtime};
        BrtUK_CE_ERPs_Nrandtrls.Fu_ERPavg(ss) = {FuERPavg};
        BrtUK_CE_ERPs_Nrandtrls.Fu_val(ss) = {Fuval};
        BrtUK_CE_ERPs_Nrandtrls.Fu_N290lat(ss) = {FuN290lat};
        BrtUK_CE_ERPs_Nrandtrls.Fu_N290pamp(ss) = {FuN290pamp};
        BrtUK_CE_ERPs_Nrandtrls.Fu_N290mamp(ss) = {FuN290mamp};
        BrtUK_CE_ERPs_Nrandtrls.Fu_N290dtw(ss) = {FuN290dtw};
        BrtUK_CE_ERPs_Nrandtrls.Fu_P400mamp(ss) = {FuP400mamp};
        BrtUK_CE_ERPs_Nrandtrls.Fu_P400dtw(ss) = {FuP400dtw};
        % face inv
        BrtUK_CE_ERPs_Nrandtrls.Fi_Ntls(ss) = {FiNtrls};
        BrtUK_CE_ERPs_Nrandtrls.Fi_ERPavg(ss) = {FiERPavg};
        BrtUK_CE_ERPs_Nrandtrls.Fi_val(ss) = {Fival};
        BrtUK_CE_ERPs_Nrandtrls.Fi_N290lat(ss) = {FiN290lat};
        BrtUK_CE_ERPs_Nrandtrls.Fi_N290pamp(ss) = {FiN290pamp};
        BrtUK_CE_ERPs_Nrandtrls.Fi_N290mamp(ss) = {FiN290mamp};
        BrtUK_CE_ERPs_Nrandtrls.Fi_N290dtw(ss) = {FiN290dtw};
        BrtUK_CE_ERPs_Nrandtrls.Fi_P400mamp(ss) = {FiP400mamp};
        BrtUK_CE_ERPs_Nrandtrls.Fi_P400dtw(ss) = {FiP400dtw};
        % condition effects; inv - up
        BrtUK_CE_ERPs_Nrandtrls.CE_N290lat(ss) = {CeN290lat};
        BrtUK_CE_ERPs_Nrandtrls.CE_N290pamp(ss) = {CeN290pamp};
        BrtUK_CE_ERPs_Nrandtrls.CE_N290mamp(ss) = {CeN290mamp};
        BrtUK_CE_ERPs_Nrandtrls.CE_N290dtw(ss) = {CeN290dtw};
        BrtUK_CE_ERPs_Nrandtrls.CE_P400mamp(ss) = {CeP400mamp};
        BrtUK_CE_ERPs_Nrandtrls.CE_P400dtw(ss) = {CeP400dtw};
        
        
        save('/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BrtUK_CE_ERPs_Nrandtrls.mat','BrtUK_CE_ERPs_Nrandtrls');
    
        % clean up
        clear FullNameData 
        clear CE_FacesERPs_RandomTrialSelection 
        clear EEGdata_Faces_Obj FastERP_info 
        clear Number_of_randomselections 
        clear Ntrls 
        clear part1_path ERPfeatures Individual_ERP_Faces

        % face up
        clear FuNtrls ERPtime FuERPavg Fuval FuN290lat FuN290pamp FuN290mamp FuN290dtw FuP400mamp FuP400dtw
        % face inv
        clear FiNtrls FiERPavg Fival FiN290lat FiN290pamp FiN290mamp FiN290dtw FiP400mamp FiP400dtw
        % condition effects; inv - up
        clear CeN290lat CeN290pamp CeN290mamp CeN290dtw CeP400mamp CeP400dtw

        fprintf('Data saved for subject %s\n',Subj)

        clear Subj


end % end loop through IDs


