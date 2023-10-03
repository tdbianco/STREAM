function varargout = ptoc
    
    global ptic_onset
    t = GetSecs - ptic_onset;
    if nargout == 0
        fprintf('Elapsed time is %.6f seconds | %.3f ms | %.0f us.\n',...
            t, t * 1e3, t* 1e6);
    else
        varargout{1} = t;
    end
    
end