function [Individual_ERP] = BrtUKtrt_032a_randomNs_indivERPs_copy(DATAclean, FastERP_info, condition, NumRantrls)
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
% - Individual_ERP: fieldtrip structure with average timeseries across
% NumRantrls 

% RH: 18-02-21 & EJ for peak identification
% updated RH 04-05-21: facesUp and facesInv conditions added

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
        elseif length(Check_inds) >= NumRantrls
            Inds1 = randperm(length(Check_inds),NumRantrls);
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
        % get the avg ERP for the N randomised trials
        % average over channels and select  trials
            cfg = [];
            cfg.channel     = ChsoI_C;
            cfg.avgoverchan = 'yes';
            cfg.trials      = IndsToI_C;
            data_avgchoi = ft_selectdata(cfg,DATAclean);
        % calculate timelocked ERP
            cfg = [];
            erp_NoBl = ft_timelockanalysis(cfg, data_avgchoi);
            cfg = [];
            cfg.baseline    = FastERP_info.Baseline_timewindow;
            Individual_ERP = ft_timelockbaseline(cfg, erp_NoBl);
            clear data_avgchoi erp_NoBl
        % add N trials
            Individual_ERP.Navg = length(IndsToI_C);
            Individual_ERP.condition = condition;
    else
        Individual_ERP.Navg = 0;
        Individual_ERP.condition = condition;
    end
    
% faces up
if strcmp(condition, 'facesUp')
    % initial checks
    % Identify EEG markers for each condition
    Mrkr_faces = [310 312 314 316];
    if ~isempty(DATAclean)
        faces_inds = find(DATAclean.trialinfo == Mrkr_faces);
        % further check data
        if NumRantrls == 0
            IndsToI_F = faces_inds;
        elseif length(faces_inds) >= NumRantrls
            Inds1 = randperm(length(Check_inds),NumRantrls);
            IndsToI_F = Check_inds(Inds1);
            IndsToI_F = sort(IndsToI_F);
            clear Inds1
        else
            warning('Not enough faces trials for N random trials selected')
            IndsToI_F = NaN;
        end
        clear faces_inds
        % check whether the channel of interest is present
        ChsoI_F = {'P7' 'P8'};
        if ~ismember(ChsoI_F,DATAclean.label)
            warning('Channel of interest not present in data for checkers')
            IndsToI_F = NaN;
        end
    else % data is empty
        IndsToI_F = NaN;
    end
    
    % calculate timelocked ERP if trials are found
    if ~isnan(IndsToI_F(1,1))
        % get the avg ERP for the N randomised trials
        % average over channels and select  trials
            cfg = [];
            cfg.channel     = ChsoI_F;
            cfg.avgoverchan = 'yes';
            cfg.trials      = IndsToI_F;
            data_avgchoi = ft_selectdata(cfg,DATAclean);
        % calculate timelocked ERP
            cfg = [];
            erp_NoBl = ft_timelockanalysis(cfg, data_avgchoi);
            cfg = [];
            cfg.baseline    = FastERP_info.Baseline_timewindow;
            Individual_ERP = ft_timelockbaseline(cfg, erp_NoBl);
            clear data_avgchoi erp_NoBl
        % add N trials
            Individual_ERP.Navg = length(IndsToI_F);
            Individual_ERP.condition = condition;
    else
        Individual_ERP.Navg = 0;
        Individual_ERP.condition = condition;
    end
    
else
    warning('Condition not recognised')
end

end % end of function