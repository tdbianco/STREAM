function [ord, isi] = aud_ss_orderTrials
% Creates a pseudorandom order of trials for the auditory steady state
% task. Trial types are 10Hz and 40Hz train of clicks, reprenseted by
% indices 1 and 2, respectively.
% The ISI between trains is random 1000-1500ms. So that all participants
% get the same ISI, we also pre-calculate this and return it in the isi
% output arg.

    numTrials = 100;
    
    % check that number of trials is evenly divisible by 2
    if ~mod(numTrials, 2) == 0
        numTrials = numTrials + 1;
        warning('Number of trials must be evenly dividisble by 2. Making it %d.',...
            numTrials)
    end
                
% we want no more than three repeats of the same trial type. Brute
% force this by continually shuffling until that criterion is reached

    repeat = true;
    while repeat
        
        % make two vectors, of 1 (10Hz) and 2 (40Hz) indices, then join them.
        % At this point they are in sequential order (all 1's, then all 2's)
        half = numTrials / 2;
        ord = [ones(half, 1); repmat(2, half, 1)];        

        % now permute a random order to shuffle the trials
        so = randperm(numTrials);
        ord = ord(so);
        
        % check for repeats
        ct = findcontig2(ord);
        repeat = any(ct(:, 3) > 3);
        
    end
    
% make ISI, random 1000-1500ms

    isi = (1000 + randi(500, numTrials, 1)) / 1000;
    
end