function [ERPfeatures] = BrtUK_03b_AllERPfeatures(IndivERP, condition, Ref_gavg)
% This function randomly selects a number of trials, and then extracts the 
% individual ERP features. 

% INPUT:
% - IndivERP; fieldtrip structure with individual average
% - condition; string of characters with the condition; 'checkers' or
% 'faces'
% - Ref_gavg; reference grand average ERP for DTW analysis


% OUTPUT:
% - ERPfeatures: structure with traditional and DTW features

% Calls to fieldtrip functions and dtw function in Matlab

% by Rianne Haartsen and Emily J.H. Jones: jan-feb 21
%%

% for checkerboards
if strcmp(condition, 'checkers')
    if ~isequal(IndivERP.Navg,0)
        
        % Peak identification %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        trialcurr = IndivERP.avg;
        timecurr = round(IndivERP.time*1000); %convert from s to ms
        WindowNar = [50 200]; %narrower window for looking for P1 peaks in ms
        WindowWide =[WindowNar(1,1)-20 WindowNar(1,2)+20]; %wider window for looking for P1 peaks

        % identify all peaks in trialcurr
        clear peaks
        peaks (1,1:3) = NaN;
        p = 1;
        for sample = 2:size(trialcurr,2)-1 %finds positive
            if trialcurr(1,sample) > trialcurr(1,sample - 1)
                if trialcurr (1, sample)> trialcurr (1,sample + 1)
                    peaks (p,1) = trialcurr (1, sample); %amp
                    peaks (p,2) = timecurr(1, sample); %latency in ms
                    peaks (p,3) = 1; % 1 = positive, -1 = negative
                    p = p + 1;
                end
                if trialcurr (1, sample)== trialcurr (1,sample - 1)
                    for x = sample+1: size (trialcurr, 2)
                        if trialcurr(x + 1) < trialcurr(x)
                            peaks (p,1) = trialcurr (1, sample); %amp
                            peaks (p,2) = timecurr(1, sample); %latency in ms
                            peaks (p,3) = 1; % 1 = positive, -1 = negative 
                        end
                        if x + 1 > x
                            x = size (trialcurr,2); %i.e. skip to end if this isn't a real peak, but just a plateau
                        end
                    end
                end
            end
            if trialcurr(1,sample) < trialcurr(1,sample - 1) % finds negative
                if trialcurr (1, sample)< trialcurr (1,sample + 1)
                    peaks (p,1) = trialcurr (1, sample); %amp
                    peaks (p,2) = timecurr(1, sample); %latency in ms
                    peaks (p,3) = -1; % 1 = positive, -1 = negative
                    p = p + 1;
                end
                if trialcurr (1, sample)== trialcurr (1,sample - 1)
                    for x = sample+1: size (trialcurr, 2)
                        if trialcurr(x + 1) > trialcurr(x)
                            peaks (p,1) = trialcurr (1, sample); %amp
                            peaks (p,2) = timecurr(1, sample); %latency in ms
                            peaks (p,3) = -1; % 1 = positive, -1 = negative 
                        end
                        if x + 1 < x
                            x = size (trialcurr,2);
                        end
                    end
                end
            end
        end 
        clear p x
    
        % find the P1 peak %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if isnan(peaks(1,1)) ==0 % check if peaks have been found
            % find all positive peaks
                Pospeaks = peaks((peaks(:,3)==1),:);
            % identify possible P1 peak
                Ind_posP1 = find(Pospeaks(:,2) >= WindowNar(1,1) & Pospeaks(:,2) <= WindowNar(1,2));
            if size(Ind_posP1,1) == 1 %only 1 pos peak found in window
                IndP1 = Ind_posP1;
            elseif size(Ind_posP1,1) > 1 % if multiple peaks are found, take largest one
                Poss_peaksP1 = Pospeaks(Ind_posP1,:);
                MaxAmp = max(Poss_peaksP1(:,1));
                IndP1 = find(Pospeaks(:,1) == MaxAmp);
            else % no pos peaks in window, pick largest in wide window
                Ind2_posP1 = find(Pospeaks(:,2) >= WindowWide(1,1) & Pospeaks(:,2) <= WindowWide(1,2));
                if size(Ind2_posP1,1) == 1 %only 1 pos peak found in window
                    IndP1 = Ind2_posP1;
                elseif size(Ind2_posP1,1) > 1 % if multiple peaks are found, take largest one
                    Poss_peaksP1 = Pospeaks(Ind2_posP1,:);
                    MaxAmp = max(Poss_peaksP1(:,1));
                    IndP1 = find(Pospeaks(:,1) == MaxAmp);
                else
                    warning('No positive peaks found during narrow or wide window')
                    IndP1 = NaN;
                end
            end
            clear Ind_posP1 MaxAmp
        else % if no peaks have been found
            warning('No peaks found in the trial')
            IndP1 = NaN;
            Pospeaks = NaN;
        end    
        
        % Extract P1 features and save in ERPs struct
        if ~isnan(IndP1)
            Latency = Pospeaks(IndP1,2);
            ERPfeatures.P1_Lat = round(Latency);
            pAmp_Twin = [(Pospeaks(IndP1,2)-30) (Pospeaks(IndP1,2)+30)];
            pAmp_beg = find(round(timecurr) == round(pAmp_Twin(1,1)));
            pAmp_end = find(round(timecurr) == round(pAmp_Twin(1,2)));
            pAmp = mean(trialcurr(1,pAmp_beg:pAmp_end),2);
            ERPfeatures.P1_pAmp = pAmp;
            clear Latency pAmpTwin pAmp_beg pAmpend pAmp
        else
            ERPfeatures.P1_Lat = NaN;
            ERPfeatures.P1_pAmp = NaN;
        end 
        
        % DTW direction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % during stimulus time
                ToI_Stim = [0, 500]; 
                Stim_beg = find(timecurr == ToI_Stim(1,1)); Stim_end = find(timecurr == ToI_Stim(1,2));
                QUERYseries = trialcurr(1,Stim_beg:Stim_end);
                REFseries = Ref_gavg(1,Stim_beg:Stim_end);
                % apply dtw
                [~, ix, iy] = dtw(REFseries, QUERYseries);
                % extract features
                auc = trapz(ix, iy); % Awp (area under warping path) in Zoumpoulaki 2015
                aud = trapz(1:max(ix),1:max(iy)); % Adiagonal (area under diagonal) in Zoumpoulaki 2015
                direction_stim = (aud-auc)/aud; % negative means that individual is slower than comparison; DTWdiff in Zoumpoulaki 2015
                clear REFseries QUERYseries auc aud ix iy Stim_beg Stim_end ToI_Stim
            % during P1 time window
                P1_beg = find(timecurr == WindowNar(1,1)); P1_end = find(timecurr == WindowNar(1,2));
                QUERYseries = trialcurr(1,P1_beg:P1_end);
                REFseries = Ref_gavg(1,P1_beg:P1_end);
                % apply dtw
                [~, ix, iy] = dtw(REFseries, QUERYseries);
                % extract features
                auc = trapz(ix, iy); % Awp (area under warping path) in Zoumpoulaki 2015
                aud = trapz(1:max(ix),1:max(iy)); % Adiagonal (area under diagonal) in Zoumpoulaki 2015
                direction_P1 = (aud-auc)/aud; % negative means that individual is slower than comparison; DTWdiff in Zoumpoulaki 2015
                clear REFseries QUERYseries auc aud ix iy P1_beg P1_end 
            % add variables to ERP features    
            ERPfeatures.DTWdir_stim = direction_stim;
            ERPfeatures.DTWdir_P1 = direction_P1;

    else
        % fill ERP features with NaNs
        ERPfeatures.P1_Lat = NaN;
        ERPfeatures.P1_pAmp = NaN;
        ERPfeatures.DTWdir_stim = NaN;
        ERPfeatures.DTWdir_P1 = NaN;
    end





    
% for faces
elseif strcmp(condition, 'faces')
    
    if ~isequal(IndivERP.Navg,0)
        
        % Peak identification %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        trialcurr = IndivERP.avg;
        timecurr = round(IndivERP.time*1000); %convert from s to ms
        WindowNarN = [190 350]; %narrower window for looking for N290 peaks in ms
        WindowWideN =[WindowNarN(1,1)-20 WindowNarN(1,2)+20]; %wider window for looking for N290 peaks

        % identify all peaks in trial
        clear peaks
        peaks (1,1:3) = NaN;
        p = 1;
        for sample = 2:size(trialcurr,2)-1 %finds positive
            if trialcurr(1,sample) > trialcurr(1,sample - 1)
                if trialcurr (1, sample)> trialcurr (1,sample + 1)
                    peaks (p,1) = trialcurr (1, sample); %amp
                    peaks (p,2) = timecurr(1, sample); %latency in ms
                    peaks (p,3) = 1; % 1 = positive, -1 = negative
                    p = p + 1;
                end
                if trialcurr (1, sample)== trialcurr (1,sample - 1)
                    for x = sample+1: size (trialcurr, 2)
                        if trialcurr(x + 1) < trialcurr(x)
                            peaks (p,1) = trialcurr (1, sample); %amp
                            peaks (p,2) = timecurr(1, sample); %latency in ms
                            peaks (p,3) = 1; % 1 = positive, -1 = negative 
                        end
                        if x + 1 > x
                            x = size (trialcurr,2); %i.e. skip to end if this isn't a real peak, but just a plateau
                        end
                    end
                end
            end
            if trialcurr(1,sample) < trialcurr(1,sample - 1) % finds negative
                if trialcurr (1, sample)< trialcurr (1,sample + 1)
                    peaks (p,1) = trialcurr (1, sample); %amp
                    peaks (p,2) = timecurr(1, sample); %latency in ms
                    peaks (p,3) = -1; % 1 = positive, -1 = negative
                    p = p + 1;
                end
                if trialcurr (1, sample)== trialcurr (1,sample - 1)
                    for x = sample+1: size (trialcurr, 2)
                        if trialcurr(x + 1) > trialcurr(x)
                            peaks (p,1) = trialcurr (1, sample); %amp
                            peaks (p,2) = timecurr(1, sample); %latency in ms
                            peaks (p,3) = -1; % 1 = positive, -1 = negative 
                        end
                        if x + 1 < x
                            x = size (trialcurr,2);
                        end
                    end
                end
            end
        end 
        clear p x
    
        % find the N290 peak %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if isnan(peaks(1,1)) ==0 % check if peaks have been found

            % find all negative peaks
                Negpeaks = peaks((peaks(:,3)==-1),:);
            % identify possible N290 peak
                Ind_posN290 = find(Negpeaks(:,2) >= WindowNarN(1,1) & Negpeaks(:,2) <= WindowNarN(1,2));
            if size(Ind_posN290,1) == 1 %only 1 neg peak found in window
                IndN290 = Ind_posN290;
            elseif size(Ind_posN290,1) > 1 % if multiple peaks are found, take largest one
                Poss_peaksN290 = Negpeaks(Ind_posN290,:);
                MinAmp = min(Poss_peaksN290(:,1));
                IndN290 = find(Negpeaks(:,1) == MinAmp);
            else % no neg peaks in window, pick largest in wide window
                Ind2_posN290 = find(Negpeaks(:,2) >= WindowWideN(1,1) & Negpeaks(:,2) <= WindowWideN(1,2));
                if size(Ind2_posN290,1) == 1 %only 1 neg peak found in window
                    IndN290 = Ind2_posN290;
                elseif size(Ind2_posN290,1) > 1 % if multiple peaks are found, take largest one
                    Poss_peaksN290 = Negpeaks(Ind2_posN290,:);
                    MinAmp = max(Poss_peaksN290(:,1));
                    IndN290 = find(Negpeaks(:,1) == MinAmp);
                else
                    warning('No negative peaks found during narrow or wide window')
                    IndN290 = NaN;
                end
            end
            clear Ind_posN290 MaxAmp

        else
            warning('No peaks found in the trial')
            IndN290 = NaN;
            Negpeaks = NaN;
        end    

        % Extract N290 features and save in ERPs struct
        if ~isnan(IndN290)
            Latency = Negpeaks(IndN290,2);
            ERPfeatures.N290_Lat = round(Latency);
            pAmp_Twin = [(Negpeaks(IndN290,2)-30) (Negpeaks(IndN290,2)+30)];
            pAmp_beg = find(round(timecurr) == round(pAmp_Twin(1,1)));
            pAmp_end = find(round(timecurr) == round(pAmp_Twin(1,2)));
            pAmp = mean(trialcurr(1,pAmp_beg:pAmp_end),2);
            ERPfeatures.N290_pAmp = pAmp;
            clear Latency pAmpTwin pAmp_beg pAmpend pAmp
        else
            ERPfeatures.N290_Lat = NaN;
            ERPfeatures.N290_pAmp = NaN;
        end
        
    % calculate the N290 mean amplitude %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % average amplitude across 190-350 ms timewindow
        N290_beg = find(round(timecurr) == WindowNarN(1,1)); % find which sample corresponds to t = 190ms
        N290_end = find(round(timecurr) == WindowNarN(1,2)); % find which sample corresponds to t = 350ms
        mAmp = mean(trialcurr(1,N290_beg:N290_end),2);
        ERPfeatures.N290_mAmp = mAmp;
        clear mAmp
   
        
     % calculate the P400 amplitude %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % average amplitude across 300 - 500 ms timewindow
        P400_ToI = [300, 500];
        P400_beg = find(round(timecurr) == P400_ToI(1,1)); % find which sample corresponds to t = 300ms
        P400_end = find(round(timecurr) == P400_ToI(1,2)); % find which sample corresponds to t = 500ms
        mAmp = mean(trialcurr(1,P400_beg:P400_end),2);
        ERPfeatures.P400_mAmp = mAmp;
        clear mAmp

        
            
        % DTW direction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % during stimulus time
            ToI_Stim = [0, 500]; 
            Stim_beg = find(timecurr == ToI_Stim(1,1)); Stim_end = find(timecurr == ToI_Stim(1,2));
            QUERYseries = trialcurr(1,Stim_beg:Stim_end);
            REFseries = Ref_gavg(1,Stim_beg:Stim_end);
            % apply dtw
            [~, ix, iy] = dtw(REFseries, QUERYseries);
            % extract features
            auc = trapz(ix, iy); % Awp (area under warping path) in Zoumpoulaki 2015
            aud = trapz(1:max(ix),1:max(iy)); % Adiagonal (area under diagonal) in Zoumpoulaki 2015
            direction_stim = (aud-auc)/aud; % negative means that individual is slower than comparison; DTWdiff in Zoumpoulaki 2015
            clear REFseries QUERYseries auc aud ix iy Stim_beg Stim_end ToI_Stim
        % during N290 time window
            QUERYseries = trialcurr(1,N290_beg:N290_end);
            REFseries = Ref_gavg(1,N290_beg:N290_end);
            % apply dtw
            [~, ix, iy] = dtw(REFseries, QUERYseries);
            % extract features
            auc = trapz(ix, iy); % Awp (area under warping path) in Zoumpoulaki 2015
            aud = trapz(1:max(ix),1:max(iy)); % Adiagonal (area under diagonal) in Zoumpoulaki 2015
            direction_N290 = (aud-auc)/aud; % negative means that individual is slower than comparison; DTWdiff in Zoumpoulaki 2015
            clear REFseries QUERYseries auc aud ix iy N290_beg N290_end 
        % during P400 time window
            QUERYseries = trialcurr(1,P400_beg:P400_end);
            REFseries = Ref_gavg(1,P400_beg:P400_end);
            % apply dtw
            [~, ix, iy] = dtw(REFseries, QUERYseries);
            % extract features
            auc = trapz(ix, iy); % Awp (area under warping path) in Zoumpoulaki 2015
            aud = trapz(1:max(ix),1:max(iy)); % Adiagonal (area under diagonal) in Zoumpoulaki 2015
            direction_P400 = (aud-auc)/aud; % negative means that individual is slower than comparison; DTWdiff in Zoumpoulaki 2015
            clear REFseries QUERYseries auc aud ix iy P400_beg P400_end 
        % add variables to ERP features    
        ERPfeatures.DTWdir_stim = direction_stim;
        ERPfeatures.DTWdir_N290 = direction_N290;
        ERPfeatures.DTWdir_P400 = direction_P400;
        
    else
        ERPfeatures.N290_Lat = NaN;
        ERPfeatures.N290_pAmp = NaN;
        ERPfeatures.N290_mAmp = NaN;
        ERPfeatures.P400_mAmp = NaN;
        ERPfeatures.DTWdir_stim = NaN;
        ERPfeatures.DTWdir_N290 = NaN;
        ERPfeatures.DTWdir_P400 = NaN;
    end

end



end