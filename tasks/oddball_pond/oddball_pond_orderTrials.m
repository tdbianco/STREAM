function ord = oddball_pond_orderTrials
% compute a random order of sounds for the POND oddball task. There are six
% different trains of sounds, and we present each 10 times. This function
% ensures that we don't play two identical trains next to each other, by
% iteratively shuffling trials 

    numTrains = 6;
    numReps = 10;
    
    % first order is sequential repeats of 1:numTrains
    ord = repmat((1:numTrains)', numReps, 1);
    
    % loop until no repeats are found
    repeat = true;
    while repeat
        
        % permute a sort order
        so = randperm(numTrains * numReps)';
        
        % sort the order
        ord = ord(so);
        
        % check for repeats
        repeat = any(diff(ord) == 0);
                
    end
    
end