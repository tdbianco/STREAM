function [setA_Individual_ERP, setB_Individual_ERP] = BrtUKtrt_232a_alternatingNs_indivERPs(DATAclean, FastERP_info, condition, NumRantrls)
% This function randomly selects a number of trials, and then extracts the 
% individual ERP features. 

% INPUT:
% - DATAclean; fieldtrip structure with clean, segmented data from Braintools 
% (EEG markers are paradigm specific)
% - FastERP_info; structure with information on the data, eg baseline time
% window
% - NumRantrls; number of random trials to select (if empty or 0, all trials
% will be included in the time series)
% - condition; string of characters with the condition; 'checkers' or
% 'faces'


% OUTPUT:
% - setA_Individual_ERP: fieldtrip structure with average timeseries across
% NumRantrls for set A
% - setB_Individual_ERP: fieldtrip structure with average timeseries across
% NumRantrls for set B

% RH: 11-05-21 & EJ for peak identification
% updated for faces condition 13-05-21


%% Random selection of trials

% Check number of random trials 
if nargin < 4
    NumRantrls = 0;
    disp('All trials available will be included')
elseif (NumRantrls ~= 0) && (mod(NumRantrls,2) == 1)
    error('Uneven number of random trials selected, select different number')
end

% Checkers
if strcmp(condition, 'checkers')
    % initial checks
    % Identify EEG markers for each condition
    Mrkr_checks = 330;
    if ~isempty(DATAclean)
        Check_inds = find(DATAclean.trialinfo == Mrkr_checks);
        % further check data
        if NumRantrls == 0
            IndsToI_C = Check_inds;
        elseif length(Check_inds) >= NumRantrls*2
            Inds1 = randperm(length(Check_inds),NumRantrls*2);
            IndsToI_C = Check_inds(Inds1);
            IndsToI_C = sort(IndsToI_C);
            clear Inds1
        else
            warning('Not enough checkerboard trials for N random trials selected')
            IndsToI_C = NaN;
        end
        clear Check_inds
        % check whether the channel of interest is present
        ChsoI_C = 'Oz';
        if ~ismember(ChsoI_C,DATAclean.label)
            warning('Channel of interest not present in data for checkers')
            IndsToI_C = NaN;
        end
    else % data is empty
        IndsToI_C = NaN;
    end
    
    % calculate timelocked ERP if trials are found
    if ~isnan(IndsToI_C(1,1))
        % create indices with alternating selected trials
            IndsToI_CA = IndsToI_C(1:2:end);
            IndsToI_CB = IndsToI_C(2:2:end);
        % for set A
            % get the avg ERP for the N randomised trials
            % average over channels and select  trials
                cfg = [];
                cfg.channel     = ChsoI_C;
                cfg.avgoverchan = 'yes';
                cfg.trials      = IndsToI_CA;
                data_avgchoi = ft_selectdata(cfg,DATAclean);
            % calculate timelocked ERP
                cfg = [];
                erp_NoBl = ft_timelockanalysis(cfg, data_avgchoi);
                cfg = [];
                cfg.baseline    = FastERP_info.Baseline_timewindow;
                setA_Individual_ERP = ft_timelockbaseline(cfg, erp_NoBl);
                clear data_avgchoi erp_NoBl cfg
            % add N trials
                setA_Individual_ERP.Navg = length(IndsToI_CA);
                setA_Individual_ERP.condition = condition;
                
            % set B    
            % get the avg ERP for the N randomised trials
            % average over channels and select  trials
                cfg = [];
                cfg.channel     = ChsoI_C;
                cfg.avgoverchan = 'yes';
                cfg.trials      = IndsToI_CB;
                data_avgchoi = ft_selectdata(cfg,DATAclean);
            % calculate timelocked ERP
                cfg = [];
                erp_NoBl = ft_timelockanalysis(cfg, data_avgchoi);
                cfg = [];
                cfg.baseline    = FastERP_info.Baseline_timewindow;
                setB_Individual_ERP = ft_timelockbaseline(cfg, erp_NoBl);
                clear data_avgchoi erp_NoBl cfg
            % add N trials
                setB_Individual_ERP.Navg = length(IndsToI_CB);
                setB_Individual_ERP.condition = condition;
                
    else
        setA_Individual_ERP.avg = NaN;
        setA_Individual_ERP.Navg = 0;
        setA_Individual_ERP.condition = condition;
        setB_Individual_ERP.avg = NaN;
        setB_Individual_ERP.Navg = 0;
        setB_Individual_ERP.condition = condition;
    end

    
    
    
    
% Faces 
elseif strcmp(condition, 'faces')
    % intial checks
    % Identify EEG markers for each condition
    Mrkr_faceup = [310 312 314 316];
    Mrkr_faceinv = [311 313 315 317];
    if ~isempty(DATAclean)
        FaceUp_inds = find(ismember(DATAclean.trialinfo, Mrkr_faceup));
        FaceInv_inds = find(ismember(DATAclean.trialinfo, Mrkr_faceinv));
        % further check the DATAclean
            if NumRantrls == 0
                % face up 
                    IndsToI_Fu = sort(FaceUp_inds);
                    IndsToI_FuA = IndsToI_Fu(1:2:end);
                    IndsToI_FuB = IndsToI_Fu(2:2:end);
                % face inv
                    IndsToI_Fi = sort(FaceInv_inds);
                    IndsToI_FiA = IndsToI_Fi(1:2:end);
                    IndsToI_FiB = IndsToI_Fi(2:2:end);
                % concatenate up and in into indices per set
                    IndsToI_FA = cat(1,IndsToI_FuA, IndsToI_FiA);
                    IndsToI_FA = sort(IndsToI_FA);
                    IndsToI_FB = cat(1,IndsToI_FuB, IndsToI_FiB);
                    IndsToI_FB = sort(IndsToI_FB);
                    clear IndsToI_Fu IndsToI_Fi 

            elseif length(FaceUp_inds) >= (NumRantrls) && length(FaceInv_inds) >= (NumRantrls)
                % create indices with alternating selected trials
                % face up 
                    Inds1 = randperm(length(FaceUp_inds),(NumRantrls));
                    IndsToI_Fu = FaceUp_inds(Inds1);
                    IndsToI_Fu = sort(IndsToI_Fu);
                    IndsToI_FuA = IndsToI_Fu(1:2:end);
                    IndsToI_FuB = IndsToI_Fu(2:2:end);
                % face inv
                    Inds2 = randperm(length(FaceInv_inds),(NumRantrls));
                    IndsToI_Fi = FaceInv_inds(Inds2);
                    IndsToI_Fi = sort(IndsToI_Fi);
                    IndsToI_FiA = IndsToI_Fi(1:2:end);
                    IndsToI_FiB = IndsToI_Fi(2:2:end);
                % concatenate up and in into indices per set
                    IndsToI_FA = cat(1,IndsToI_FuA, IndsToI_FiA);
                    IndsToI_FA = sort(IndsToI_FA);
                    IndsToI_FB = cat(1,IndsToI_FuB, IndsToI_FiB);
                    IndsToI_FB = sort(IndsToI_FB);
                    clear Inds1 IndsToI_Fu 
                    clear Inds2 IndsToI_Fi 
            else
                warning('Not enough Face Up and/or Inv trials for N random trials selected')
                IndsToI_FA = NaN;
                IndsToI_FB = NaN;
            end
            clear FaceUp_inds FaceInv_inds 
        % check whether the channel of interest is present
        ChsoI_F = {'P7','P8'};
        if ~isequal(sum(ismember(ChsoI_F ,DATAclean.label),2),2)
            warning('Channels of interest not present in data for faces')
            IndsToI_FA = NaN;
            IndsToI_FB = NaN;
        end
    else % data is empty
        IndsToI_FA = NaN;
        IndsToI_FB = NaN;
    end
    
    % calculate timelocked ERP if trials are found    
    if ~isnan(IndsToI_FA(1,1)) &&  ~isnan(IndsToI_FB(1,1))
        % for set A
            % get the avg ERP for the N randomised trials
            % average over channels and select  trials
                cfg = [];
                cfg.channel     = ChsoI_F;
                cfg.avgoverchan = 'yes';
                cfg.trials      = IndsToI_FA;
                data_avgchoi = ft_selectdata(cfg,DATAclean);
            % calculate timelocked ERP
                cfg = [];
                erp_NoBl = ft_timelockanalysis(cfg, data_avgchoi);
                cfg = [];
                cfg.baseline    = FastERP_info.Baseline_timewindow;
                setA_Individual_ERP = ft_timelockbaseline(cfg, erp_NoBl);
                clear data_avgchoi erp_NoBl cfg
            % add N trials
                setA_Individual_ERP.Navg_fu = length(IndsToI_FuA);
                setA_Individual_ERP.Navg_fi = length(IndsToI_FiA);
                setA_Individual_ERP.Navg = length(IndsToI_FA);
                setA_Individual_ERP.condition = condition;
                
        % for set B
            % get the avg ERP for the N randomised trials
            % average over channels and select  trials
                cfg = [];
                cfg.channel     = ChsoI_F;
                cfg.avgoverchan = 'yes';
                cfg.trials      = IndsToI_FB;
                data_avgchoi = ft_selectdata(cfg,DATAclean);
            % calculate timelocked ERP
                cfg = [];
                erp_NoBl = ft_timelockanalysis(cfg, data_avgchoi);
                cfg = [];
                cfg.baseline    = FastERP_info.Baseline_timewindow;
                setB_Individual_ERP = ft_timelockbaseline(cfg, erp_NoBl);
                clear data_avgchoi erp_NoBl cfg
            % add N trials
                setB_Individual_ERP.Navg_fu = length(IndsToI_FuB);
                setB_Individual_ERP.Navg_fi = length(IndsToI_FiB);
                setB_Individual_ERP.Navg = length(IndsToI_FB);
                setB_Individual_ERP.condition = condition;  
                
    else 
        setA_Individual_ERP.Navg_fu = NaN;
        setA_Individual_ERP.Navg_fi = NaN;
        setA_Individual_ERP.Navg = NaN;
        setA_Individual_ERP.condition = condition;
        setB_Individual_ERP.Navg_fu = NaN;
        setB_Individual_ERP.Navg_fi = NaN;
        setB_Individual_ERP.Navg = NaN;
        setB_Individual_ERP.condition = condition;
    end

else
    warning('Condition not recognised')
end

end % end of function