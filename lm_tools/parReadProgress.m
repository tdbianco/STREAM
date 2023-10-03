function prog = parReadProgress(guid)

%     uPath = userpath;
%     uPath = uPath(1:end - 1);
%     progPath = [uPath, filesep, '_progress'];

    try
        
        progPath = [tempdir, '_progress'];
        guidPath = [progPath, filesep, guid];

    %     if ~exist(guidPath, 'dir'), prog = []; return, end

        d = dir([guidPath, filesep, '*.mat']);
        num = length(d);
        tmp = load([guidPath, filesep, d(1).name]);
        prog = num / tmp.total;
        
    catch ERR
        
        prog = 0;
        
    end
    
end