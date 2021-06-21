function [valid] = BrtUKtrt_032c_PeakValid(IndividualERP, FastERP_info, peak_latency)

% This function checks whether the peak is valid. A peak is valid when it
% exceeds the deflections -/+ 10% during the baseline time window. 

% INPUT;
% IndividualERP; strucure with individual ERP data
% FastERP_info; structure with info on preprocessing parameteres
% peak_latency; latency of the peak of interest

% RH; 18-12-20

%%

time_wholetrl = round(IndividualERP.time,3);
peak_lat_sec = round(peak_latency/1000,3); Ind_peak = find(time_wholetrl == peak_lat_sec);
Peak_pamp = IndividualERP.avg(1,Ind_peak);
% check the deflection of the peak
amp_prepeak = IndividualERP.avg(1,(Ind_peak-1));
    if Peak_pamp > amp_prepeak % positive peak
        peak_defl = 1;
    elseif Peak_pamp < amp_prepeak % negative peak
        peak_defl = -1;
    end

% find all peaks during the baseline
Baseline_toi = FastERP_info.Baseline_timewindow; 
bl_beg = find(time_wholetrl == Baseline_toi(1,1)); bl_end = find(time_wholetrl == Baseline_toi(1,2));
trialcurr = IndividualERP.avg(1,bl_beg:bl_end);
timecurr = IndividualERP.time(1,bl_beg:bl_end);

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
    
    % find largest negative deflection or use the min if no peaks
        if ~isnan(peaks(1,1)) % check if peaks have been found
            % find all negative peaks
            Negpeaks = peaks((peaks(:,3)==-1),:);
            if size(Negpeaks,1) == 1 %only 1 neg peak found in window
                Minamp2exc = Negpeaks(1,1);
            elseif size(Negpeaks,1) > 1 % if multiple peaks are found, take largest one
                Minamp2exc = min(Negpeaks(:,1));
            else % no neg peaks in window
                warning('No negative peaks found during narrow or wide window')
                % take the minimum value in the time series
                Minamp2exc = min(trialcurr);
            end
        else
            warning('No peaks found in the trial')
            % take the minimum value in the time series
                Minamp2exc = min(trialcurr);
        end    
        
        
    % find largest positive deflection or use the max if no peaks
        if ~isnan(peaks(1,1)) % check if peaks have been found
            % find all positive peaks
            Pospeaks = peaks((peaks(:,3)==1),:);
            if size(Pospeaks,1) == 1 %only 1 neg peak found in window
                Maxamp2exc = Pospeaks(1,1);
            elseif size(Pospeaks,1) > 1 % if multiple peaks are found, take largest one
                Maxamp2exc = max(Pospeaks(:,1));
            else % no neg peaks in window
                warning('No positive peaks found during narrow or wide window')
                % take the minimum value in the time series
                Maxamp2exc = min(trialcurr);
            end
        else
            warning('No peaks found in the trial')
            % take the minimum value in the time series
                Maxamp2exc = max(trialcurr);
        end    
    
    
    % check the validity of the peak
    if peak_defl == 1 && Peak_pamp >= (Maxamp2exc*1.1) % check if positive peak is larger than baseline positive peak
        valid = 1;
    elseif peak_defl == -1 || Peak_pamp <= (Minamp2exc*1.1) % check if negative peak is larger than baseline negative peak
        valid = 1;
    else
        valid = 0;
    end
end
