function [version, versionString, trialFun] = restingvideos2_ver
% [version, versionString] = task_ver where 'task' is the name of the
% current task. This function returns 'version' in numeric form, and
% 'versionString' as 'task.0001', where '0001' is version. 
%
% This is used to track the version number of a particular task. At
% load-time, the presenter will attempt to execute this function as it
% defines the task. The tracker then records the version information that
% this function returns. Whenever a task is updated, the version number of
% the task should be updated. 
    version         = 1;
    verDate         = '20190618';
    versionString   = sprintf('restingvideos2.%04d_%s', version, verDate);
    trialFun        = 'restingvideos2_trial';
end