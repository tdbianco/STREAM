function [ numPres ] = restingvideos_count( log )
% restingvideos_count - counts the number of presentations of videos and
%displays them in the console

    % find column indexes for 'condition' and 'validtrial' variables
    logFun          =   find(strcmpi(log.FunName,'restingvideos_trial')...
        ,1,'first');
    
    if isempty(logFun)
        % no logs yet
        numPres=0;
        return
    end
        
    colVideo        =   find(strcmpi(log.Headings{logFun},'Video'),1,'first');

    % find data
    data            =   log.Data{logFun}(:,colVideo);

    fprintf('\n<strong>Resting videos presented:</strong>\n\n');
    disp(data)
end

