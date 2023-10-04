function [trl, events] = BrtUK_trialfun_braintoolsUKtrt_FastERP(cfg)

% The function [trl, events] = trialfun_braintoolsUKtrt_FastERP(cfg) 
% defines the trial events in the EEG data and checks whether trials are 
% valid (correct length, or skipped). It returns a trl fieldtrip structure
% that is used to define the trials.

% output: 
% trl file with trl = [begsample endsample offset task valid];
% event variable containing all the events in the raw data

% by Rianne Haartsen: jan-feb 21

%% read the header (needed for the samping rate) and the events
load(cfg.dataset);
hdr        = ft_data.hdr;
events      = ft_data.events;

% for the events of interest, find the sample numbers (these are integers)
% for the events of interest, find the trigger values (these are strings in the case of BrainVision)
EVsample   = [events.sample]';
EVvalue    = [events.value]';
numEvents = length(EVvalue);

%% Selecting event specific for braintools

% EEG markers in Stream:
    % checkerboards; 330
    % faces up; 310 312 314 316
    
% select the target onset stimuli
StimCodes = [310 312 314 316 330]; % faces up/inv, obj/animals up/inv, checkerboards onset
XOnset = zeros(numEvents,length(StimCodes));
for ii = 1:length(StimCodes)
%     XOnset(:,ii) = strcmp(num2str(StimCodes(1,ii)), EVvalue);
    XOnset((StimCodes(1,ii) == EVvalue),ii) = 1;
end
XOnset = sum(XOnset,2); IndTStim = find(XOnset==1);

% check validity of the stimuli
StimOffset = [318 331]; % faces up, checkerboards offset
XOffset = zeros(numEvents,length(StimOffset));
for ii = 1:length(StimOffset)
%     XOffset(:,ii) = strcmp(num2str(StimOffset(1,ii)), EVvalue);
    XOffset((StimOffset(1,ii) == EVvalue),ii) = 1;
end
XOffset = sum(XOffset,2); %IndOffStim = find(XOffset==1);

StimSkipped = 248; % skipped
XSkipped = zeros(numEvents,length(StimSkipped));
for ii = 1:length(StimSkipped)
%     XSkipped(:,ii) = strcmp(num2str(StimSkipped(1,ii)), EVvalue);
    XSkipped((StimSkipped(1,ii) == EVvalue),ii) = 1;
end
XSkipped = sum(XSkipped,2); %IndSkipped = find(XSkipped==1);

validTStim = zeros(numEvents,1);
    for e = 1:numEvents
        % if this is a relevant event
        if XOnset(e)
            
            % find the offset
            nextOffset = e - 1 + find(XOffset(e:end), 1);
            if ~isempty(nextOffset)
                % calculate the time between the onset and offset
    %             delta = events(nextOffset).latency_ms - events(e).latency_ms;
                delta = events(nextOffset).sample - events(e).sample;
                % time between must be within 40ms of 500ms 
    %             validEvent = abs(delta - 500) < 40;
                validEvent = abs(delta - (500/1000*hdr.fs)) < (40/1000*hdr.fs);
                % and no skipped events
                validEvent = validEvent & ~any(XSkipped(e:nextOffset));              
                if validEvent == 1
                    validTStim(e,1) = 1;
                end
            else
                warning('Cannot pair offsets with onsets.')
                disp(e)
            end
            
        end
    end

% define trials around onset stimuli
PreTrig  = round(cfg.trialdef.prestim  * hdr.fs);
PostTrig =  round(cfg.trialdef.poststim * hdr.fs);

begsample = EVsample(IndTStim) - PreTrig;
endsample = EVsample(IndTStim) + PostTrig;
offset = -PreTrig*ones(size(endsample));
% task = str2double(EVvalue(IndTStim,1));
task = EVvalue(IndTStim,1);
valid = validTStim(IndTStim,1);


trl = [begsample endsample offset task valid];



end % function