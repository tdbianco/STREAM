%% % Braintools UK project test-retest data: Individual grand averages

% This script creates ERPs and grand averages of the EEG data (fieldtrip format).

% For each session folder:
% 1) Find clean data
% 2) Create individual ERPs for the different conditions
%   - Face (all) vs. Obj (all)
%   - Face up vs. Face inv
%   - Checker
% 3) Save the data in the session fieldtrip folder

% For all datasets:
% 4) Load all data into cell array
% 5) Calculate grand averages for each comparison 
% 6) Plot the grand averages

% Calls to functions from Fieldtrip

% by Rianne Haartsen: jan-feb 21

%%

clear variables
% add common paths
% braintools and task engine scripts
    addpath(genpath('/XXXXX'));
% braintools UK specific analysis scripts    
    addpath('/XXXXX');
%add fieldtrip path and set to defaults
    addpath('/XXXXX/fieldtrip-20180925'); 
    ft_defaults
    
%% For each dataset: create individual averages

load '/XXXXX/BraintoolsUK_Cleandata_tracker.mat'
    
for ss = 1:height(BrtUK_ClnEEG)  
    
    fprintf('Currently nr %i out of %i\n',ss,height(BrtUK_ClnEEG))
    Subj = BrtUK_ClnEEG.IDses{ss}; %ppt code
    disp(Subj)
    
    % 1) load clean data
        load(BrtUK_ClnEEG.CleanData_path{ss}, 'EEGdata_Faces_Obj','EEGdata_Checkers', 'FastERP_info')

    % 2) Create individual ERPs for the different conditions    
    % For Face (all) vs. Obj (all)
        ChsoI = {'P7','P8'};
        NFaceAll = BrtUK_ClnEEG.Nfaceup{ss} + BrtUK_ClnEEG.Nfaceinv{ss};
        NObjAll = BrtUK_ClnEEG.Nobjup{ss} + BrtUK_ClnEEG.Nobjinv{ss};
        % check whether there are more than 10 trials for each condition and
        % whether the channels of interest are present in the dataset
        if  NFaceAll > 10 && NObjAll > 10 && sum(ismember(ChsoI,EEGdata_Faces_Obj.label),2) == 2
            % Face all
            % average over channels and select  trials
                cfg = [];
                cfg.channel     = ChsoI;
                cfg.avgoverchan = 'yes';
                cfg.trials      = find(EEGdata_Faces_Obj.trialinfo == 310 | EEGdata_Faces_Obj.trialinfo == 312 | ...
                    EEGdata_Faces_Obj.trialinfo == 314 | EEGdata_Faces_Obj.trialinfo == 316 | ...
                EEGdata_Faces_Obj.trialinfo == 311 | EEGdata_Faces_Obj.trialinfo == 313 | ...
                EEGdata_Faces_Obj.trialinfo == 315 | EEGdata_Faces_Obj.trialinfo == 317);
                data_avgchoi = ft_selectdata(cfg,EEGdata_Faces_Obj);
            % calculate timelocked ERP
                cfg = [];
                erp_NoBl = ft_timelockanalysis(cfg, data_avgchoi);
                cfg = [];
                cfg.baseline    = FastERP_info.Baseline_timewindow;
                IndividualERP_FaceAll = ft_timelockbaseline(cfg, erp_NoBl);
                clear data_avgchoi erp_NoBl
            % Object all 
            % average over channels and select  trials
                cfg = [];
                cfg.channel     = ChsoI;
                cfg.avgoverchan = 'yes';
                cfg.trials      = find(EEGdata_Faces_Obj.trialinfo == 320 | EEGdata_Faces_Obj.trialinfo == 321);
                data_avgchoi = ft_selectdata(cfg,EEGdata_Faces_Obj);
            % calculate timelocked ERP
                cfg = [];
                erp_NoBl = ft_timelockanalysis(cfg, data_avgchoi);
                cfg = [];
                cfg.baseline    = FastERP_info.Baseline_timewindow;
                IndividualERP_ObjAll = ft_timelockbaseline(cfg, erp_NoBl);
                clear data_avgchoi erp_NoBl
        else
            IndividualERP_FaceAll = [];
            IndividualERP_ObjAll = [];
        end

    
    % For Face up vs. Face inv
        ChsoI = {'P7','P8'};
        NFaceUp = BrtUK_ClnEEG.Nfaceup{ss};
        NFaceInv = BrtUK_ClnEEG.Nfaceinv{ss};
        % check whether there are more than 10 trials for each condition and
        % whether the channels of interest are present in the dataset
        if  NFaceUp > 10 && NFaceInv > 10 && sum(ismember(ChsoI,EEGdata_Faces_Obj.label),2) == 2
            % Face up
            % average over channels and select  trials
                cfg = [];
                cfg.channel     = ChsoI;
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
                clear data_avgchoi erp_NoBl
            % Face inv
            % average over channels and select  trials
                cfg = [];
                cfg.channel     = ChsoI;
                cfg.avgoverchan = 'yes';
                cfg.trials      = find(EEGdata_Faces_Obj.trialinfo == 311 | EEGdata_Faces_Obj.trialinfo == 313 | ...
                EEGdata_Faces_Obj.trialinfo == 315 | EEGdata_Faces_Obj.trialinfo == 317);
                data_avgchoi = ft_selectdata(cfg,EEGdata_Faces_Obj);
            % calculate timelocked ERP
                cfg = [];
                erp_NoBl = ft_timelockanalysis(cfg, data_avgchoi);
                cfg = [];
                cfg.baseline    = FastERP_info.Baseline_timewindow;
                IndividualERP_FaceInv = ft_timelockbaseline(cfg, erp_NoBl);
                clear data_avgchoi erp_NoBl
        else
            IndividualERP_FaceUp = [];
            IndividualERP_FaceInv = [];
        end
    
    
   % Checkerboard
        ChsoI = 'Oz';
        NChecker = BrtUK_ClnEEG.Ncheckers{ss};
        % check whether there are more than 10 trials for each condition and
        % whether the channels of interest are present in the dataset
        if  NChecker > 10 && ismember(ChsoI,EEGdata_Checkers.label)
            % Checkerboard
            % average over channels and select  trials
                cfg = [];
                cfg.channel     = ChsoI;
                cfg.avgoverchan = 'yes';
                cfg.trials      = find(EEGdata_Checkers.trialinfo == 330);
                data_avgchoi = ft_selectdata(cfg,EEGdata_Checkers);
            % calculate timelocked ERP
                cfg = [];
                erp_NoBl = ft_timelockanalysis(cfg, data_avgchoi);
                cfg = [];
                cfg.baseline    = FastERP_info.Baseline_timewindow;
                IndividualERP_Checkers = ft_timelockbaseline(cfg, erp_NoBl);
                clear data_avgchoi erp_NoBl
        else
            IndividualERP_Checkers = [];
        end
    % 3) Save the data in the session fieldtrip folder
        % append the individual averages to the clean data file
        save(BrtUK_ClnEEG.CleanData_path{ss}, 'IndividualERP_FaceAll','IndividualERP_ObjAll',...
            'IndividualERP_FaceUp', 'IndividualERP_FaceInv', 'IndividualERP_Checkers','-append');
        
end


%% For all datasets: create grand average

% 4) Load all data into cell array for each condition
load '/Users/riannehaartsen/Documents/02b_Braintools/Braintools_UK_Trt/BraintoolsUK_Cleandata_tracker.mat'

    % For Face (all) vs. Obj (all)
        path_indavg_facevsobj = {};
        for ss = 1:height(BrtUK_ClnEEG)
            % check if valid
            if (BrtUK_ClnEEG.Valid_FaceUp{ss} == 1) 
                % Ntrials per condition
                NFaceAll = BrtUK_ClnEEG.Nfaceup{ss} + BrtUK_ClnEEG.Nfaceinv{ss};
                NObjAll = BrtUK_ClnEEG.Nobjup{ss} + BrtUK_ClnEEG.Nobjinv{ss};
                if  NFaceAll > 10 && NObjAll > 10
                    if  size(path_indavg_facevsobj,2)== 0
                        path_indavg_facevsobj{1,1} = BrtUK_ClnEEG.CleanData_path{ss};
                    else
                        path_indavg_facevsobj{1,(size(path_indavg_facevsobj,2)+1)} = BrtUK_ClnEEG.CleanData_path{ss};
                    end
                end   
            end
        end
     % load the variables for those with enough trials  
        FacevsObj_indivERPs = cellfun(@load, path_indavg_facevsobj,'uniform',false);  
     % extract the ERPs of interest
        FaceAll_indivERPs =  cellfun(@(x) x.IndividualERP_FaceAll, FacevsObj_indivERPs, 'uniform', false);
        ObjAll_indivERPs =  cellfun(@(x) x.IndividualERP_ObjAll, FacevsObj_indivERPs, 'uniform', false);
        clear FacevsObj_indivERPs 
        
        
     % For Face up vs. Face inv
        path_indavg_faceupvsinv = {};
        for ss = 1:height(BrtUK_ClnEEG)
            % check if valid
            if (BrtUK_ClnEEG.Valid_FaceUp{ss} == 1) && (BrtUK_ClnEEG.Valid_FaceInv{ss} == 1) 
                % Ntrials per condition
                NFaceUp = BrtUK_ClnEEG.Nfaceup{ss};
                NFaceInv = BrtUK_ClnEEG.Nfaceinv{ss};
                if  NFaceUp > 10 && NFaceInv > 10
                    if  size(path_indavg_faceupvsinv,2)== 0
                        path_indavg_faceupvsinv{1,1} = BrtUK_ClnEEG.CleanData_path{ss};
                    else
                        path_indavg_faceupvsinv{1,(size(path_indavg_faceupvsinv,2)+1)} = BrtUK_ClnEEG.CleanData_path{ss};
                    end
                end   
            end
        end
     % load the variables for those with enough trials  
        FaceUpvsInv_indivERPs = cellfun(@load, path_indavg_faceupvsinv,'uniform',false);  
     % extract the ERPs of interest
        FaceUp_indivERPs =  cellfun(@(x) x.IndividualERP_FaceUp, FaceUpvsInv_indivERPs, 'uniform', false);
        FaceInv_indivERPs =  cellfun(@(x) x.IndividualERP_FaceInv, FaceUpvsInv_indivERPs, 'uniform', false);
        clear FaceUpvsInv_indivERPs
        
     % For Checkers
        path_indavg_checkers = {};
        for ss = 1:height(BrtUK_ClnEEG)
            % check if valid
            if (BrtUK_ClnEEG.Valid_Checkers{ss} == 1) 
                % N trials
                if  BrtUK_ClnEEG.Ncheckers{ss} > 10
                    if  size(path_indavg_checkers,2)== 0
                        path_indavg_checkers{1,1} = BrtUK_ClnEEG.CleanData_path{ss};
                    else
                        path_indavg_checkers{1,(size(path_indavg_checkers,2)+1)} = BrtUK_ClnEEG.CleanData_path{ss};
                    end
                end   
            end
        end
     % load the variables for those with enough trials  
        Checkers_indivERPs = cellfun(@load, path_indavg_checkers,'uniform',false);  
     % extract the ERPs of interest
        Checkers_indivERPs =  cellfun(@(x) x.IndividualERP_Checkers, Checkers_indivERPs, 'uniform', false);

      

%% 5) Calculate grand averages for each comparison 

    % For Face (all) vs. Obj (all)
        cfg = [];
        Gavg_FaceAll = ft_timelockgrandaverage(cfg, FaceAll_indivERPs{:});
        cfg = [];
        Gavg_ObjAll = ft_timelockgrandaverage(cfg, ObjAll_indivERPs{:});
    % For Face up vs. Face inv
        cfg = [];
        Gavg_FaceUp = ft_timelockgrandaverage(cfg, FaceUp_indivERPs{:});
        cfg = [];
        Gavg_FaceInv = ft_timelockgrandaverage(cfg, FaceInv_indivERPs{:});
    % For Checkers
        cfg = [];
        Gavg_Checkers = ft_timelockgrandaverage(cfg, Checkers_indivERPs{:});
        
    cd /XXXXX
    save('BraintoolsUK_GrandAverages.mat','Gavg_FaceAll','Gavg_ObjAll','Gavg_FaceUp','Gavg_FaceInv','Gavg_Checkers')

        
%% 6) Plot the grand averages        
    % For Face (all) vs. Obj (all) 
    Fig_facevsobj = figure;
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
       
        % Obj all
        iERPs_ObjAll = nan(size(Gavg_ObjAll.cfg.previous,2),length(Gavg_ObjAll.avg));
        for ii = 1: size(Gavg_ObjAll.cfg.previous,2)
            iERPs_ObjAll(ii,:) = ObjAll_indivERPs{1,ii}.avg;
        end
        SEM_ObjAll = nanstd(iERPs_ObjAll,[],1)/sqrt(size(iERPs_ObjAll,1));
        GAVGwave_ObjAll = Gavg_ObjAll.avg;
        curve1 = GAVGwave_ObjAll + SEM_ObjAll;
        curve2 = GAVGwave_ObjAll - SEM_ObjAll;
        Time2 = [Time, fliplr(Time)];
        inBetween = [curve1, fliplr(curve2)];
        j = fill(Time2, inBetween, [0.6350 0.0780 0.1840],'FaceAlpha',0.2, 'linestyle','none');
        plot(Time, GAVGwave_ObjAll, 'LineStyle','--', 'Color',[0.6350 0.0780 0.1840],'LineWidth',2);
        clear curve1 curve2 Thresholds2 inBetween
        
    % add info
    ylabel('Amplitude (\muV)'); xlabel('Time (ms)')
    legend({'Faces SEM','Faces grand average',...
        'Animals SEM', 'Animals grand average'},...
        'Location','SouthWest')
        ax = gca; ax.XAxisLocation = 'origin'; ax.YAxisLocation = 'origin';
    title({'Braintools UK Faces versus Animals (all orientations)'},'FontSize',14);
    

    
    % For Face up vs. Face inv     
    Fig_faceupvsinv = figure;
    Time = Gavg_FaceUp.time*1000;
        % Face up
        iERPs_FaceUp = nan(size(Gavg_FaceUp.cfg.previous,2),length(Gavg_FaceUp.avg));
        for ii = 1: size(Gavg_FaceUp.cfg.previous,2)
            iERPs_FaceUp(ii,:) = FaceUp_indivERPs{1,ii}.avg;
        end
        SEM_FaceUp = nanstd(iERPs_FaceUp,[],1)/sqrt(size(iERPs_FaceUp,1));
        GAVGwave_FaceUp = Gavg_FaceUp.avg;
        curve1 = GAVGwave_FaceUp + SEM_FaceUp;
        curve2 = GAVGwave_FaceUp - SEM_FaceUp;
        Time2 = [Time, fliplr(Time)];
        inBetween = [curve1, fliplr(curve2)];
        k = fill(Time2, inBetween, [0.4660 0.6740 0.1880],'FaceAlpha',0.2, 'linestyle','none');
        hold on;
        plot(Time, GAVGwave_FaceUp, 'LineStyle','-', 'Color',[0.4660 0.6740 0.1880],'LineWidth',2);
        clear curve1 curve2 Thresholds2 inBetween Time2
       
        % Face inv
        iERPs_FaceInv = nan(size(Gavg_FaceInv.cfg.previous,2),length(Gavg_FaceInv.avg));
        for ii = 1: size(Gavg_FaceInv.cfg.previous,2)
            iERPs_FaceInv(ii,:) = FaceInv_indivERPs{1,ii}.avg;
        end
        SEM_FaceInv = nanstd(iERPs_FaceInv,[],1)/sqrt(size(iERPs_FaceInv,1));
        GAVGwave_FaceInv = Gavg_FaceInv.avg;
        curve1 = GAVGwave_FaceInv + SEM_FaceInv;
        curve2 = GAVGwave_FaceInv - SEM_FaceInv;
        Time2 = [Time, fliplr(Time)];
        inBetween = [curve1, fliplr(curve2)];
        l = fill(Time2, inBetween, [0.4940 0.1840 0.5560],'FaceAlpha',0.2, 'linestyle','none');
        plot(Time, GAVGwave_FaceInv, 'LineStyle','--', 'Color',[0.4940 0.1840 0.5560],'LineWidth',2);
        clear curve1 curve2 Thresholds2 inBetween
        
    % add info
    ylabel('Amplitude (\muV)'); xlabel('Time (ms)')
    legend({'Faces upright SEM','Faces upright grand average',...
        'Faces inverted SEM', 'Faces inverted grand average'},...
        'Location','SouthWest')
        ax = gca; ax.XAxisLocation = 'origin'; ax.YAxisLocation = 'origin';
    title({'Braintools UK Faces upright versus inverted'},'FontSize',14);
    
    
    
    % For Checkers         
    Fig_checkers = figure;
    Time = Gavg_Checkers.time*1000;
    % Checkers
        iERPs_Checkers = nan(size(Gavg_Checkers.cfg.previous,2),length(Gavg_Checkers.avg));
        for ii = 1: size(Gavg_Checkers.cfg.previous,2)
            iERPs_Checkers(ii,:) = Checkers_indivERPs{1,ii}.avg;
        end
        SEM_Checkers = nanstd(iERPs_Checkers,[],1)/sqrt(size(iERPs_Checkers,1));
        GAVGwave_Checkers = Gavg_Checkers.avg;
        curve1 = GAVGwave_Checkers + SEM_Checkers;
        curve2 = GAVGwave_Checkers - SEM_Checkers;
        Time2 = [Time, fliplr(Time)];
        inBetween = [curve1, fliplr(curve2)];
        k = fill(Time2, inBetween, [0.8500 0.3250 0.0980],'FaceAlpha',0.2, 'linestyle','none');
        hold on;
        plot(Time, GAVGwave_Checkers, 'LineStyle','-', 'Color',[0.8500 0.3250 0.0980],'LineWidth',3);
        clear curve1 curve2 Thresholds2 inBetween Time2
        
    % add info
    ax = gca; ax.XAxisLocation = 'origin'; ax.YAxisLocation = 'origin';
    ax.FontSize = 12;
    ylim([-5 22]) 
    ylabel('Amplitude (\muV)'); xlabel('Time (ms)')
    legend({'Checkers SEM','Checkers grand average'},...
        'Location','SouthWest')
    
    title({'Braintools UK Checkerboards'},'FontSize',14);
      
        
        
    
    % For Face up vs. Obj (all) 
    Fig_faceupvsobj = figure;
    Time = Gavg_FaceAll.time*1000;
        % Face up
        iERPs_FaceUp = nan(size(Gavg_FaceUp.cfg.previous,2),length(Gavg_FaceUp.avg));
        for ii = 1: size(Gavg_FaceUp.cfg.previous,2)
            iERPs_FaceUp(ii,:) = FaceUp_indivERPs{1,ii}.avg;
        end
        SEM_FaceUp = nanstd(iERPs_FaceUp,[],1)/sqrt(size(iERPs_FaceUp,1));
        GAVGwave_FaceUp = Gavg_FaceUp.avg;
        curve1 = GAVGwave_FaceUp + SEM_FaceUp;
        curve2 = GAVGwave_FaceUp - SEM_FaceUp;
        Time2 = [Time, fliplr(Time)];
        inBetween = [curve1, fliplr(curve2)];
        k = fill(Time2, inBetween, [0.4660 0.6740 0.1880],'FaceAlpha',0.2, 'linestyle','none');
        hold on;
        plot(Time, GAVGwave_FaceUp, 'LineStyle','-', 'Color',[0.4660 0.6740 0.1880],'LineWidth',2);
        clear curve1 curve2 Thresholds2 inBetween Time2
       
        % Obj all
        iERPs_ObjAll = nan(size(Gavg_ObjAll.cfg.previous,2),length(Gavg_ObjAll.avg));
        for ii = 1: size(Gavg_ObjAll.cfg.previous,2)
            iERPs_ObjAll(ii,:) = ObjAll_indivERPs{1,ii}.avg;
        end
        SEM_ObjAll = nanstd(iERPs_ObjAll,[],1)/sqrt(size(iERPs_ObjAll,1));
        GAVGwave_ObjAll = Gavg_ObjAll.avg;
        curve1 = GAVGwave_ObjAll + SEM_ObjAll;
        curve2 = GAVGwave_ObjAll - SEM_ObjAll;
        Time2 = [Time, fliplr(Time)];
        inBetween = [curve1, fliplr(curve2)];
        j = fill(Time2, inBetween, [0.6350 0.0780 0.1840],'FaceAlpha',0.2, 'linestyle','none');
        plot(Time, GAVGwave_ObjAll, 'LineStyle','--', 'Color',[0.6350 0.0780 0.1840],'LineWidth',2);
        clear curve1 curve2 Thresholds2 inBetween
        
    % add info
    ylabel('Amplitude (\muV)'); xlabel('Time (ms)')
    legend({'Faces upright SEM','Faces upright grand average',...
        'Animals SEM', 'Animals grand average'},...
        'Location','SouthWest')
        ax = gca; ax.XAxisLocation = 'origin'; ax.YAxisLocation = 'origin';
    title({'Braintools UK Faces upright versus Animals '},'FontSize',14);
