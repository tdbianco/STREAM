function [EEGdata_Faces_Obj, EEGdata_Checkers, Info_struct] = BrtUK_01a_Preprocess_Allcond(FT_dataname, Info_struct)

% This function [EEGdata_Face_Obj, EEGdata_Checkers, Info_struct] = BtUK_01a_Preprocess_Allcond(FT_dataname, Info_struct)
% reads in the EEG data from Braintools UK and preprocesses the data for
% the checkerboard trials and other (face and object/ animal) trials. 

% INPUT:
% - FT_dataname; string data name and path for the fieldtrip unsegmented
% data
% - Info_struct; structure with cleaning parameters in the fields

% OUTPUT:
% - EEGdata; cleaned trial EEG data for the Faces_Objects and Checkerboard trials
% - Info_struct; structure with cleaning parameters, re-ref info, and
% numbers of trials presented - valid - clean

% Calls to:
% - Task engine and in-house scripts from Luke Mason
% - Fieldtrip functions
% - Braintools UK purpose written scripts: 
%       - BrTUK_trialfun_braintoolsUKtrt_FastERP
%       - BrTUK_01aa_NumberTrials_ERPs
%       - BrTUK_01ab_preproc_cleandata


% by Rianne Haartsen: jan-feb 21

%% Read in the fieldtrip data and define the trials

    % define all trials 
        cfg = [];
        cfg.trialfun            = 'BrtUK_trialfun_braintoolsUKtrt_FastERP'; %trials -100 ms - 600 ms stimulus onset for different stimuli
        cfg.dataset             = FT_dataname;
        cfg.trialdef.prestim    = .1; % s before the stimulus onset
        cfg.trialdef.poststim   = .6; % s after the stimulus onset
        Trlinfo = ft_definetrial(cfg);
    % calculate N presented and valid trials
        N_trials = BrtUK_01aa_NumberTrials_ERPs(Trlinfo);
    % remove invalid trials 
        Trlinfo.trlprev = Trlinfo.trl;
        IndValid = Trlinfo.trlprev(:,5)==1;
        Trlinfo.trl = Trlinfo.trlprev(IndValid,1:4);
        clear IndValid
        disp('Valid trials identified')
    % segment the data into trials
        load(FT_dataname, 'ft_data')
        cfg = [];
        cfg.trl = Trlinfo.trl;
        Raw_trials = ft_redefinetrial(cfg, ft_data);
        
    % Check if Cz is present in the layout
    if ismember('Cz',Raw_trials.label)

        % Split the dataset according to condition    
        % faces up
        cfg = [];
        cfg.trials      = find(Raw_trials.trialinfo == 310 | Raw_trials.trialinfo == 312 | Raw_trials.trialinfo == 314 | Raw_trials.trialinfo == 316);
        cfg.channel     = {'Oz','P7','P8','Cz','C3','C4'};
        Raw_trials_Faces_Obj = ft_selectdata(cfg, Raw_trials); 
        % checkers
        cfg.trials = [];
        cfg.trials      = find(Raw_trials.trialinfo == 330);
        cfg.channel     = {'Oz','P7','P8','Cz','C3','C4'};
        Raw_trials_Checkers = ft_selectdata(cfg, Raw_trials); 
        
        
        %% Preprocess the data per condition

        % [EEG_data, IndividualERP, REFinfo] = BrTUK_01aa_preprocCondition(Raw_trials_cond, Condition, Info_struct)
            % Faces and objects
                [EEGdata_Faces_Obj, REFinfo_faces_obj] = BrtUK_01ab_preproc_cleandata(Raw_trials_Faces_Obj, 'faces_obj', Info_struct);
            % Checkerboard
                [EEGdata_Checkers, REFinfo_checkers] = BrtUK_01ab_preproc_cleandata(Raw_trials_Checkers, 'checkers', Info_struct);

            % bookkeeping for conditions
            % Number of clean trials
            if ~isempty(EEGdata_Faces_Obj)
                % find the number of clean trials for each condition
                    FaceUp = find(Raw_trials.trialinfo == 310 | Raw_trials.trialinfo == 312 | Raw_trials.trialinfo == 314 | Raw_trials.trialinfo == 316);
                    
                % Calculate the number of presented trials for each condition
                    N_trials.FaceUp.Nclean = length(FaceUp); 
%                     N_trials.FaceInv.Nclean = length(FaceInv);
%                     N_trials.ObjUp.Nclean = length(ObjUp);
%                     N_trials.ObjInv.Nclean = length(ObjInv);
            else
                    N_trials.FaceUp.Nclean = 0; 
%                     N_trials.FaceInv.Nclean = 0;
%                     N_trials.ObjUp.Nclean = 0;
%                     N_trials.ObjInv.Nclean = 0;
            end
            if ~isempty(EEGdata_Checkers)
                N_trials.Checkers.Nclean = length(EEGdata_Checkers.trial);
            else
                N_trials.Checkers.Nclean = 0;
            end
                Info_struct.N_trials = N_trials;

            % Re-referencing
                Info_struct.REFs.Faces_Obj.Cz_prop = REFinfo_faces_obj.Cz_prop;
                Info_struct.REFs.Faces_Obj.C34_prop = REFinfo_faces_obj.C34_prop;
                Info_struct.REFs.Checkers.Cz_prop = REFinfo_checkers.Cz_prop;
                Info_struct.REFs.Checkers.C34_prop = REFinfo_checkers.C34_prop;   
                
    else % Cz not included as ch in the layout
        % return empty variables
        EEGdata_Faces_Obj = [];
        EEGdata_Checkers = [];
        N_trials.FaceUp.Nclean = 999; 
        N_trials.FaceInv.Nclean = 999;
        N_trials.ObjUp.Nclean = 999;
        N_trials.ObjInv.Nclean = 999;
        N_trials.Checkers.Nclean = 999;
        Info_struct.N_trials = N_trials;
        Info_struct.REFs.Faces_Obj.Cz_prop = 999;
        Info_struct.REFs.Faces_Obj.C34_prop = 999;
        Info_struct.REFs.Checkers.Cz_prop = 999;
        Info_struct.REFs.Checkers.C34_prop = 999;    
    end
        
end % end of function       
        
