%% % Braintools UK project test-retest data: Individual grand averages

% This script creates ERPs and grand averages of the EEG data (fieldtrip format).

% For each session folder:
% 1) Find clean data
% 2) Create individual ERPs for the different conditions
%   - Face (all) vs. Checkers (all)
%
% 3) Save the data in the session fieldtrip folder

% For all datasets:
% 4) Load all data into cell array
% 5) Calculate grand averages for each comparison 
% 6) Plot the grand averages

% Calls to functions from Fieldtrip

% by Rianne Haartsen: jan-feb 21

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
    
%% For each dataset: create individual averages

load '/Users/teresa/Documents/MATLAB/data/stream/0_stream_Trt/stream_Cleandata_tracker_man.mat'
    
for ss = 1:height(stream_ClnEEG)  
    
    fprintf('Currently nr %i out of %i\n',ss,height(stream_ClnEEG))
    Subj = stream_ClnEEG.IDses{ss}; %ppt code
    disp(Subj)
    
    % 1) load clean data
        load(stream_ClnEEG.CleanData_path{ss}, 'EEGdata_Faces_Obj','EEGdata_Checkers', 'FastERP_info')

    % 2) Create individual ERPs for the different conditions
    
    % For Face up
        ChsoI = {'P7','P8'};
        NFaceUp = length(EEGdata_Faces_Obj.trialinfo);
       
        % check whether there are more than 10 trials for each condition and
        % whether the channels of interest are present in the dataset
        if  NFaceUp > 10 && sum(ismember(ChsoI,EEGdata_Faces_Obj.label),2) == 2
            % Face up
            % average over channels and select  trials
                cfg = [];
                cfg.channels     = ChsoI;
                cfg.avgoverchan = 'yes';
                cfg.trials      = find(EEGdata_Faces_Obj.trialinfo == 310 | EEGdata_Faces_Obj.trialinfo == 312 | ...
                    EEGdata_Faces_Obj.trialinfo == 314 | EEGdata_Faces_Obj.trialinfo == 316);
                data_avgchoi = ft_selectdata(cfg,EEGdata_Faces_Obj);
            % calculate timelocked ERP
                cfg = [];
                erp_NoBl = ft_timelockanalysis(cfg, data_avgchoi);
                cfg = [];
                cfg.baseline    = FastERP_info.Baseline_timewindow;
                IndividualERP_FaceUp = ft_timelockbaseline(cfg, erp_NoBl);
                stream_ClnEEG.Valid_FaceUp(ss) = {1};
                clear data_avgchoi erp_NoBl
        else
            IndividualERP_FaceUp = [];
            stream_ClnEEG.Valid_FaceUp(ss) = {0};
        end
    
    
   % Checkerboard
        ChsoI = {'P7','P8'};
        NChecker = length(EEGdata_Checkers.trialinfo);
        % check whether there are more than 10 trials for each condition and
        % whether the channels of interest are present in the dataset
        if  NChecker > 10 & ismember(ChsoI,EEGdata_Checkers.label)
            % Checkerboard
            % average over channels and select  trials
                cfg = [];
                cfg.channels     = ChsoI;
                cfg.avgoverchan = 'yes';
                cfg.trials      = find(EEGdata_Checkers.trialinfo == 330);
                data_avgchoi = ft_selectdata(cfg,EEGdata_Checkers);
            % calculate timelocked ERP
                cfg = [];
                erp_NoBl = ft_timelockanalysis(cfg, data_avgchoi);
                cfg = [];
                cfg.baseline    = FastERP_info.Baseline_timewindow;
                IndividualERP_Checkers = ft_timelockbaseline(cfg, erp_NoBl);
                stream_ClnEEG.Valid_Checkers(ss) = {1};
                clear data_avgchoi erp_NoBl
        else
            IndividualERP_Checkers = [];
            stream_ClnEEG.Valid_Checkers(ss) = {0};
        end
    % 3) Save the data in the session fieldtrip folder
        % append the individual averages to the clean data file
        save(stream_ClnEEG.CleanData_path{ss}, 'IndividualERP_FaceUp','IndividualERP_Checkers','-append');
        
end

save('/Users/teresa/Documents/MATLAB/data/stream/0_stream_Trt/stream_Cleandata_tracker.mat','stream_ClnEEG');

%% For all datasets: create grand average

% 4) Load all data into cell array for each condition
% load '/Users/teresa/Documents/MATLAB/data/stream/0_stream_Trt/stream_Cleandata_tracker.mat'

    % For Face (all) vs. Checkers (all)
        path_indavg_facevscheck = {};
        for ss = 1:height(stream_ClnEEG)
            % check if valid
            if (stream_ClnEEG.Valid_FaceUp{ss} == 1) & (stream_ClnEEG.Valid_Checkers{ss} == 1)
            % Ntrials per condition
%               NFaceAll = BrtUK_ClnEEG.Nfaceup{ss} + BrtUK_ClnEEG.Nfaceinv{ss};
                NFaceAll = length(EEGdata_Faces_Obj.trialinfo);
                NCheckAll = length(EEGdata_Checkers.trialinfo);
                if  NFaceAll > 10 && NCheckAll > 10
                    if  size(path_indavg_facevscheck,2)== 0
                        path_indavg_facevscheck{1,1} = stream_ClnEEG.CleanData_path{ss};
                    else
                        path_indavg_facevscheck{1,(size(path_indavg_facevscheck,2)+1)} = stream_ClnEEG.CleanData_path{ss};
                    end
                end 
            end
        end
     % load the variables for those with enough trials  
        FacevsCheck_indivERPs = cellfun(@load, path_indavg_facevscheck,'uniform',false);  
     % extract the ERPs of interest
        FaceAll_indivERPs =  cellfun(@(x) x.IndividualERP_FaceUp, FacevsCheck_indivERPs, 'uniform', false);
        CheckAll_indivERPs =  cellfun(@(x) x.IndividualERP_Checkers, FacevsCheck_indivERPs, 'uniform', false);
        clear FacevsCheck_indivERPs 

%% 5) Calculate grand averages for each comparison 

    % For Face (all) vs. Checkers (all)
        cfg = [];
        Gavg_FaceAll = ft_timelockgrandaverage(cfg, FaceAll_indivERPs{:});
        cfg = [];
        Gavg_CheckAll = ft_timelockgrandaverage(cfg, CheckAll_indivERPs{:});
    
     cd /Users/teresa/Documents/MATLAB/data/stream/0_stream_Trt/
     save('stream_GrandAverages.mat','Gavg_FaceAll','Gavg_CheckAll')

        
%% 6) Plot the grand averages        
    % For Face (all) vs. Checkers (all) 
    Fig_facevscheck = figure;
    Time = Gavg_FaceAll.time*1000;
        % Face all
        iERPs_FaceAll = nan(size(Gavg_FaceAll.cfg.previous,2),length(Gavg_FaceAll.avg));
        for ii = 1: size(Gavg_FaceAll.cfg.previous,2)
            iERPs_FaceAll(ii,:) = FaceAll_indivERPs{1,ii}.avg;
        end
        SEM_FaceAll = nanstd(iERPs_FaceAll,[],1)/sqrt(size(iERPs_FaceAll,1));
        GAVGwave_FaceAll = Gavg_FaceAll.avg;
        curve1 = GAVGwave_FaceAll + SEM_FaceAll;
        curve2 = GAVGwave_FaceAll - SEM_FaceAll;
        Time2 = [Time, fliplr(Time)];
        inBetween = [curve1, fliplr(curve2)];
        h = fill(Time2, inBetween, [0.3010 0.7450 0.9330],'FaceAlpha',0.2, 'linestyle','none');
        hold on;
        plot(Time, GAVGwave_FaceAll, 'LineStyle','-', 'Color',[0.3010 0.7450 0.9330],'LineWidth',2);
        clear curve1 curve2 Thresholds2 inBetween Time2
       
        % Checkers all
        iERPs_CheckAll = nan(size(Gavg_CheckAll.cfg.previous,2),length(Gavg_CheckAll.avg));
        for ii = 1: size(Gavg_CheckAll.cfg.previous,2)
            iERPs_CheckAll(ii,:) = CheckAll_indivERPs{1,ii}.avg;
        end
        SEM_CheckAll = nanstd(iERPs_CheckAll,[],1)/sqrt(size(iERPs_CheckAll,1));
        GAVGwave_CheckAll = Gavg_CheckAll.avg;
        curve1 = GAVGwave_CheckAll + SEM_CheckAll;
        curve2 = GAVGwave_CheckAll - SEM_CheckAll;
        Time2 = [Time, fliplr(Time)];
        inBetween = [curve1, fliplr(curve2)];
        j = fill(Time2, inBetween, [0.6350 0.0780 0.1840],'FaceAlpha',0.2, 'linestyle','none');
        plot(Time, GAVGwave_CheckAll, 'LineStyle','--', 'Color',[0.6350 0.0780 0.1840],'LineWidth',2);
        clear curve1 curve2 Thresholds2 inBetween
        
    % add info
    ylabel('Amplitude (\muV)'); xlabel('Time (ms)')
    legend({'Faces SEM','Faces grand average',...
        'Checkers SEM', 'Checkers grand average'},...
        'Location','SouthWest')
        ax = gca; ax.XAxisLocation = 'origin'; ax.YAxisLocation = 'origin';
    title({'Stream Faces versus Checkers'},'FontSize',14);
    

    
  