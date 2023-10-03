function lists = faceerp_makeBlockListsFromOrder
% Makes a teListCollection and stores a separate teList in it for each
% block of the Face ERP task. 
%
% Two files are loaded. If these are not found in the path then an error is
% thrown:
%
%   faceerp_block.mat   - a teList instance with all possible combinations
%                       of trial types 
%
%   faceerp_order.mat   - a [block x trial] matrix of list indices
%
% This function interates through the rows (blocks) of the order matrix,
% and makes a copy of the master list. It applies the order to the list,
% and adds it to the list collection. Each list is named 'faceerp_block_0x'
% where x is block number

    % check that files exist
    if ~exist('faceerp_block.mat', 'file')
        error('faceerp_block.mat not found.')
    end
    
    if ~exist('faceerp_order.mat', 'file')
        error('faceerp_order.mat not found.')
    end
    
    % load
    tmp = load('faceerp_block.mat');
    faceerp_block = tmp.faceerp_block;
    tmp = load('faceerp_order.mat');
    faceerp_order = tmp.faceerp_order;
    clear order
    
    % make collection
    lists = teListCollection;
    
    % iterate through blocks
    numBlocks = size(faceerp_order, 1);
    for block = 1:numBlocks
    
        % clone the list
        tmp = copyHandleClass(faceerp_block);
        
        % apply the order for this block
        tmp.OrderType = faceerp_order(block, :);
        
        % add to collection
        name = sprintf('faceerp_block0%d', block);
        lists(name) = tmp;
        
    end

end