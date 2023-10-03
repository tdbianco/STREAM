function list = vis_ss_orderTrials(numBlocks, trialsPerBlock, freqs)
% create a randomised (but structured) order of presentation. Each of
% numBlocks contains trialsPerBlock trials, with an equal number of freqs
% within it. The images are chosen randomly, but without replacement (so as
% to avoid repeating images). 

% default name of images. These will be appended with numeric indices, e.g.
% 'img_vis_ss_00001.png' (note four leading zeros). Note that we assume
% there are numBlocks * trialsPerBlock stimuli available, but don't
% actually check this here. It will error during the trial function is a
% stimulus is not available.
     
    imgName = 'img_vis_ss';
    
% check that the input args make sense

    % number of freqs must match number of trials per block
    if length(freqs) ~= trialsPerBlock
        error('Number of freqs must match trialsPerBlock.')
    end
    
% permute the order of images - these will then be selected on a
% trial-by-trial basis when building the order (below)

    totalNumTrials = numBlocks * trialsPerBlock;
    imgOrder = randperm(totalNumTrials);
    
% init a teList instance to hold the order

    list = teList;
    list.Name = 'vis_ss_block';
    list.AddVariable('block');
    list.AddVariable('trial');
    list.AddVariable('freq');
    list.AddVariable('stim');
    
% create a temp Matlab table to store the order in. This will be added to
% the teList at the end. 

    tab = table;
    
% loop through blocks, then through trials. Write out block and trial
% number. Cycle through frequencies in a random order within each block,
% and 

    % trialCounter keeps a running count of each trial 
    trialCounter = 1;
    
    for block = 1:numBlocks
        
        % make a random order for frequencies
        freqOrder = randperm(length(freqs));
        
        for trial = 1:trialsPerBlock
            
            % vars for this trial. Note that we store all of this in a cell
            % array (even when numeric) to make everything consistent in
            % the final table
            enabled = true;
            type = 'trial';
            target = 'vis_ss_trial';
            task = 'vis_ss';
            startSample = nan;
            numSamples = nan;
            key = nan;
            thisFreq = num2cell(freqs(freqOrder(trial)));
            thisStim = sprintf('%s_%05d.png', imgName,...
                imgOrder(trialCounter));
            
            % make one row of the table as a cell array
            row = [enabled, type, target, task, startSample, numSamples,...
                key, block, trial, thisFreq, thisStim];
            
            % put into table
            tab = [tab; cell2table(row, 'VariableNames',...
                list.Table.Properties.VariableNames)];
            
            % increment trial counter
            trialCounter = trialCounter + 1;

        end
        
    end

    % put into teList 
    list.CustomSetTable(tab);

end