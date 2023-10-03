function vis_ss_plotTiming(logArray)

    smry = teLogFilter(logArray, 'topic', 'trial_log_data', 'task', 'vis_ss');
    fs_delta = cell2mat(smry.freq) - cell2mat(smry.actual_fs_mu);
    
    figure
    subplot(2, 1, 1)
    scatter(1:length(fs_delta), fs_delta)
    xlabel('Trial')
    ylabel('Fs delta (Hz, fs_target - fs_achieved)', 'Interpreter', 'none')
    title('Frequency delta by trial')
    
    subplot(2, 1, 2)
    histogram(fs_delta, 15);
    xlabel('Fs delta (Hz, fs_target - fs_achieved)', 'Interpreter', 'none')
    ylabel('Frequency (trials)', 'Interpreter', 'none')
    title('Distribution of frequency delta', 'Interpreter', 'none')

end