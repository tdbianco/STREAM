function [order_freq, order_img, tab] = vis_ss_orderTrials(listCol)
% creates a pseudorandom but counterbalanced trial order for the visual
% steady state task. Frequencies are 6Hz, 10Hz and 15Hz. Computes a
% counterbalanced order of frequencies by permuting all permutations.
% Assigns an image to one presentation of each of the three frequencies,
% such that each image is shown exactly three times, once at 6Hz, once at
% 10Hz, once at 16Hz. 
%
% INPUT ARGS
%
%       listCol     - (optional) a teListCollection. As block lists are
%                   created, they will be added to listCol. 
%
% OUTPUT ARGS
% 
%       order_freq  - a [numBlocks x numTrialsPerBlock] matrix of frequency
%                    indices. 
% 
%       order_img   - a [numBlocks x numTrialsPerBlock] matrix of image
%                   indices
%
%       tab         - a cell array of tables, with each element
%                   representing one block. These are suitable for
%                   insertion into a teList using the CustomSetList method. 
%
% note that listCol is not an output argument, because teListCollections
% are handle classes, and so passed by reference

% define parameters. Note that most of these are set by the requirement to
% have all permutations of three frequencies. For example, blocks must
% appear in multuples of six, since there are six possible permutations of
% three frequencies

    numBlocks = 18;
    numTrials = 3;
    freqs = [6, 10, 15];
    numFreqs = length(freqs);

    % order of frequencies, in triplets, for each set of three
    order_freq = repmat(perms(1:3), 3, 1);
    
    % find midway point in height of matrix (middle block)
    half = round(size(order_freq, 1) / 2);
        
% randomise image order. Each image is assigned to exactly three
% frequencies (6Hz, 10Hz and 15Hz). This is done by finding all occurences
% of each frequency, and assigning a random permutation of image indices,
% before moving on to the next frequency
% 
% we also want to ensure that we are not repeating images within each
% triplet of frequencies (three trials, half a block). We brute force this
% but 1) making a random image-frequency assignment, 2) iterating until
% there are no repeats. It converges after ~40 iterations. 

    repeat = true;
    
    % start with a matrix of nans
    order_img = nan(size(order_freq));

    while repeat

        % loop through each frequency
        for f = 1:numFreqs

            % find the indices of each occurence of this frequency in the
            % frequency order matrix
            idx_f = find(order_freq == f);

            % make an image index, by randomly permuting an order
            idx_i = randperm(length(idx_f))';
            
            % store the permuted image indices in the image order matrix,
            % at the locations of occurence of the current frequency
            order_img(idx_f) = idx_i;

        end
        
        tmp_img = [order_img(1:half, :), order_img(half + 1:end, :)];
        idx_check = [1, 2; 1, 3; 1, 4; 1, 5; 1, 6; 2, 3; 2, 4; 2, 5; 2,...
            6; 3, 4; 3, 5; 3, 6; 4, 5; 4, 6; 5, 6];
        tmp = arrayfun(@(x, y) tmp_img(:, x) - tmp_img(:, y),...
            idx_check(:, 1), idx_check(:, 2), 'uniform', false);
        check = horzcat(tmp{:});


%         % compare all columns against each other
%         check = [...
%             order_img(:, 1) - order_img(:, 2),...
%             order_img(:, 1) - order_img(:, 3),...
%             order_img(:, 2) - order_img(:, 3)];

        % find all elements that have a repeat
        found = check == 0;

        % if any were found, a repeat has been found, so we try again
        repeat = any(found(:));

    end
    order_img = tmp_img;
       
% because we want to have six trials in 9 blocks (rather than three trials
% in 18 blocks) we split the matrix in half, cat it onto itself in the
% second dimension. Essentialy we are doubling the length of trials and
% halving the length of blocks. 

    % find midway point in height of matrix (middle block)
    half = round(size(order_freq, 1) / 2);
    
    % apply the transform
    order_freq = [order_freq(1:half, :), order_freq(half + 1:end, :)];
%     order_img = [order_img(1:half, :), order_img(half + 1:end, :)];

% default name of images. These will be appended with numeric indices, e.g.
% 'img_vis_ss_00001.png' (note four leading zeros). 

    imgName = 'img_vis_ss';

% loop through each trial and create a teList instance with the appropriate
% order of trials. Each block has its own list. Essentially what we are
% doing here is taking the 2D block x trial structure and flattening it
% into a continuous list, broken up into blocks. 

    % make a cell array of teLists
    lists = cell(numBlocks / 2, 1);
    
    % make a signature of frequency x image assignments for easy checking
    % later
    sig = cell(numBlocks * numTrials, 1);
    
    % make a cell array of tables, so we can return it 
    tab = cell(numBlocks / 2, 1);
    
    trialCounter = 1;
    for block = 1:numBlocks / 2
    
        % init list with relevant vars
        lists{block} = teList;
        lists{block}.Name = 'vis_ss_block';
        lists{block}.AddVariable('block');
        lists{block}.AddVariable('trial');
        lists{block}.AddVariable('freq');
        lists{block}.AddVariable('stim');

        % empty table to store this block in
        tab{block} = table;

        for trial = 1:numTrials * 2

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
            thisFreq = num2cell(freqs(order_freq(block, trial)));
            thisStim = sprintf('%s_%05d.png', imgName,...
                order_img(block, trial));

            % make one row of the table as a cell array
            row = [enabled, type, target, task, startSample, numSamples,...
                key, block, trialCounter, thisFreq, thisStim];

            % put into table
            tab{block} = [tab{block}; cell2table(row, 'VariableNames',...
                lists{block}.Table.Properties.VariableNames)];

            sig{trialCounter} = sprintf('%d#%s', thisFreq{1}, thisStim);

            % increment trial counter
            trialCounter = trialCounter + 1;

        end    

        % add to lists
        lists{block}.CustomSetTable(tab{block});
        
        % add to lists collection (if present)
        if nargin ~= 0
            key = sprintf('vis_ss_block%02d', block);
            listCol.AddItem(lists{block}, key);
        end

    end
    
end
