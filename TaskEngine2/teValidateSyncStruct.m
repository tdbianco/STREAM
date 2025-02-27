function val = teValidateSyncStruct(sync)
% determines whether a sync struct is valid. Note that this does not mean
% there is sync data available. A sync struct is written whenever a video
% is synced. If no sync markers are found in the video, then an empty sync
% struct, with GUID "NOT_FOUND" is written. This is a valid sync struct and
% this function will return true for it. Use teVideoHasSync to determine
% whether the sync itself is (valid and) present. 

    if ~isstruct(sync) && ~isa(sync, 'logicalstruct')
        val = false;
        return
    end

    exp_fnames = {...
            'numMarkers',...
            'teTime'    ,...
            'videoTime' ,...
            'GUID'      ,...
            'file_in'   ,...
            'frames'    ,...
            'frameTimes',...
            'timestamps',...
            'intercept' ,...
            'video2te'  ,...
            'te2video'  ,...
            };
        
    % remove time sync coefficient (b1) from the candidate sync struct (if
    % present) because this is optional in a sync struct (videos with only
    % one marker will only have an intercept, and no coefficient)
    if isfield(sync, 'b1')
        sync = rmfield(sync, 'b1');
    end
    
    % two conditions return true, 1) expected field names, or 2) GUID of
    % "NOT_FOUND" (which indicates failed video sync - prob no markers)
    hasFieldNames = all(ismember(exp_fnames, fieldnames(sync)));
    emptySyncStruct =...
        isfield(sync, 'GUID') && strcmpi(sync.GUID, 'NOT_FOUND');
        
    val = hasFieldNames || emptySyncStruct;
    
end