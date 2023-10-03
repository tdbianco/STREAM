function [version, versionString, trialFun] = aud_ss_ver
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
    verDate         = '20191121';
    taskName        = 'aud_ss';
    versionString   = sprintf('%s.%04d_%s', taskName, version, verDate);
    trialFun        = sprintf('%s_trial', taskName);
end