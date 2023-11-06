function [EEG_data, REFinfo] = BrtUK_01ab_preproc_cleandata(Raw_trials_cond, Condition, Info_struct)

% This function [EEG_data, REFinfo] = BrTUK_01ab_preproc_cleandata(Raw_trials_cond, Condition, Info_struct)
% takes the raw segmented data for a condition of Braintools UK and preprocesses all the data:

% Preprocessing steps:

% INPUT:
% - Raw_trials_cond; data segmented into trials for the Condition of interest
% - Condition; condition of the dataset in str options: 'face', 'checkers'
% - Info_struct; structure with cleaning parameters, re-ref info, and
% numbers of trials presented - valid - clean

% OUTPUT:
% - EEG_data; cleaned EEG trials for the Condition of interest
% - REFinfo; proportion of trials re-referenced to Cz or C3-C4 average


% Calls to:
% - Task engine and in-house scripts from Luke Mason
% - Fieldtrip functions

% by Rianne Haartsen: jan-feb 21

%% Check input
    % for EEG data
        if isempty(Raw_trials_cond)
            error('Data for raw trials for the condition is empty')
        end
    % for Condition
        if strcmp(Condition, 'faces_obj')
            ChsoI = {'Oz','P7','P8','Cz','C3','C4'}; % define channels of interest
            disp('Processing data for faces')
        elseif strcmp(Condition, 'checkers')
            ChsoI = {'Oz'}; % define channel of interest
            disp('Processing data for checkerboards')
        else
            error('Condition for raw trials has not been recognised.')
        end
    % for Info_struct
        if isempty(Info_struct)
            error('Info with parameters isempty')
        end


%% Preprocessing and artefact identification

    % Artefact rejection A: flat channels    
        % correct for the offset of the signal
        cfg = [];
        cfg.detrend          = 'yes'; %
        data1 = ft_preprocessing(cfg, Raw_trials_cond);     
        % Apply artifact identification
        data_art_flat = eegAR_Detect(data1, 'method', 'flat'); 
    
    % Artefact rejection B: thresholds and range 
        % apply filtering to the trials
        cfg = [];
        cfg.padding         = 3;
        cfg.bpfilter        = 'yes';
        cfg.bpfreq          = Info_struct.BPfilter;
        cfg.dftfilter       = 'yes'; % default at [50 100 150]
        if ~isempty(Info_struct.Baseline_timewindow)
            cfg.demean          = 'yes';
            cfg.baselinewindow  = Info_struct.Baseline_timewindow;
        end
        data = ft_preprocessing(cfg, data1);
 
    % AR step B1) Thesholds
        data = eegAR_Detect(data, 'method', 'minmax', 'threshold', [Info_struct.AR_Thresholds(1,1), Info_struct.AR_Thresholds(1,2)]); 
    % AR step B2) range 
        if ~isempty(Info_struct.AR_Range)
            data = eegAR_Detect(data, 'method', 'range', 'threshold', Info_struct.AR_Range); 
        end
        disp('Artefacts identified')

%% Artefact rejection and re-referencing

    % combine art info from data and data_art_flat and summarise
        data.art = cat(3, data.art, data_art_flat.art);
        data.art_type = cat(2, data.art_type, data_art_flat.art_type);
        summary.ar = eegAR_Summarise(data);

    % 1) drop channels with artefacts throughout
        Prop_badchs = summary.ar.channels.trialProp;
        badChannel = Prop_badchs >= .8;
        Channels_incl = {'all'};
        if any(badChannel) 
            % find the channels to exclude
            for cc = 1:numel(badChannel)
                if badChannel(cc) == 1
                    Excl_ch = strcat('-',data.label{cc,1});
                    Channels_incl = cat(2,Channels_incl,Excl_ch);
                end
            end
            cfg = [];
            cfg.channels = Channels_incl;
            CleanData1 = ft_selectdata(cfg, data); 
        else
            CleanData1 = data;
        end
        
    % 2) drop trials with artefacts in the channel(s) of interest
        % find the indices for the channel(s) of interest
        Inds = ismember(CleanData1.label, ChsoI);
        badTrials = any(any(CleanData1.art(Inds,:,:), 3), 1);
        if sum(badTrials) == length(CleanData1.trial)
            summary.success = false;
            summary.outcome = 'No good trials';
            return
        end
        if any(badTrials)
            cfg = [];
            cfg.trials = ~badTrials;
            CleanData2 = ft_selectdata(cfg, CleanData1); 
        else
            CleanData2 = CleanData1;
        end

    % 3) re-reference to Cz if good channel, otherwise re-ref to C3 and C4 avg
        % for each trial 
        numTrials = size(CleanData2.trial,2);
        art = CleanData2.art;
        % create temporary trials
        tmp_trial = cell(numTrials, 1);
        data_tref = CleanData2;
        Reref_Cz_C34 = nan(numTrials,2);
        Ind_Cz = find(ismember(CleanData2.label, {'Cz'}));
        Ind_C34 = find(ismember(CleanData2.label, {'C3','C4'}));
    
        % loop through trials
        for tr = 1:numTrials

            if ~isempty(art(Ind_Cz,tr,:)) && ~any(art(Ind_Cz,tr,:)) % check whether Cz is good, if yes, re-ref to Cz
                % select data from current trial 
                CurrTrlind = false(numTrials, 1);
                CurrTrlind(tr) = true;
                cfg = [];
                cfg.trials = CurrTrlind;
                chans = data_tref.label;
                cfg.channel = chans;
                data_stripped = rmfieldIfPresent(data_tref,...
                    {'art_type', 'art', 'summary'});
                tmp = ft_selectdata(cfg, data_stripped);
                % re-reference to Cz
                cfg = [];
                cfg.reref         = 'yes';
                cfg.refchannel    = data_tref.label{Ind_Cz,1};
                tmpi = ft_preprocessing(cfg, tmp);
                % store re-ref data in temp structure
                tmp_trial{tr} = tmpi.trial{1};    
                % record this trial was re-referenced to Cz
                Reref_Cz_C34(tr,:) = [1,0];
            elseif ~isempty(art(Ind_C34,tr,:)) & ~any(art(Ind_C34,tr,:)) % check whether C3 and C4 if good, if yes re-ref to C3/4
                % select data from current trial 
                CurrTrlind = false(numTrials, 1);
                CurrTrlind(tr) = true;
                cfg = [];
                cfg.trials = CurrTrlind;
                chans = data_tref.label;
                cfg.channel = chans;
                data_stripped = rmfieldIfPresent(data_tref,...
                    {'art_type', 'art', 'summary'});
                tmp = ft_selectdata(cfg, data_stripped);
                % re-reference to 34
                cfg = [];
                cfg.reref         = 'yes';
                cfg.refchannel    = data_tref.label{Ind_C34,1};
                cfg.refmethod     = 'avg';
                tmpi = ft_preprocessing(cfg, tmp);
                % store re-ref data in temp structure
                tmp_trial{tr} = tmpi.trial{1};    
                % record this trial was re-referenced to Cz
                Reref_Cz_C34(tr,:) = [0,1];
            else % otherwise record that Reref was unsuccessful
                % record this trial was not re-referenced 
                Reref_Cz_C34(tr,:) = [0,0];
            end
                
        end % end loop through trials for re-referencing
        
        % replace old trial with new re-referenced ones if
        % present
        for tr = 1:numTrials
            if ~isempty(tmp_trial{tr}) % put in new trials
                data_tref.trial{tr} = tmp_trial{tr};
            end
        end
        CleanData3 = data_tref;
        clear tr
        
        % reject trials where re-referencing was unsuccessful (Cz and C3/C4
        % were bad)
        noReREFTrials = ~any(Reref_Cz_C34,2);
        if sum(noReREFTrials) == length(CleanData1.trial)
            ReREF.success = false;
            ReREF.outcome = 'No good trials';
            return
        end
        cfg.trials = ~noReREFTrials;
        if any(noReREFTrials), CleanData4 = ft_selectdata(cfg, CleanData3); 
        else
            CleanData4 = CleanData3;
        end
        
   
%% Define the remaining output 

if ismember(ChsoI,CleanData4.label)
    % EEG_data: clean and re-referenced
        EEG_data = CleanData4;
    % REFinfo: proportion of clean trials averaged to Cz or C3/4   
        N_REFCz = sum(Reref_Cz_C34(:,1),1);
        N_REFC34 = sum(Reref_Cz_C34(:,2),1);
        Nclean = length(CleanData4.trial);
        if ~isequal(length(CleanData4.trial), (N_REFCz + N_REFC34))
            error('Mismatch number of trials in clean data and re-referencing info')
        end
        REFinfo.Cz_prop = N_REFCz / Nclean;
        REFinfo.C34_prop = N_REFC34 / Nclean;
        clear N_REFCz N_REFC34
else % create empty variables 
    % EEG_data: clean and re-referenced
        EEG_data = [];
    % REFinfo: proportion of clean trials averaged to Cz or C3/4   
        REFinfo.Cz_prop = NaN;
        REFinfo.C34_prop = NaN;
end

end