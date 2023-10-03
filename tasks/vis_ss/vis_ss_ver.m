function [version, versionString, trialFun] = vis_ss_ver
% [version, versionString] = task_ver where 'task' is the name of the
% current task. This function returns 'version' in numeric form, and
% 'versionString' as 'task.0001', where '0001' is version. 
%
% This is used to track the version number of a particular task. At
% load-time, the presenter will attempt to execute this function as it
% defines the task. The tracker then records the version information that
% this function returns. Whenever a task is updated, the version number of
% the task should be updated. 
    version         = 3;
    verDate         = '20190916';
    taskName        = 'vis_ss';
    versionString   = sprintf('%s.%04d_%s', taskName, version, verDate);
    trialFun        = sprintf('%s_trial', taskName);
end
%
% version 3 / 20190916
%
% Based on piloting, double probe frequencies because we are using
% image/blank sequences which are perceived as one "unit" of flicker by the
% brain. See vis_ss_trial for more detail. 