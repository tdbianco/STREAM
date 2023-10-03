function resp = enforceinput(prompt, validOptions, caseSensitive)

    % check input args
    if ~ischar(prompt) 
        error('''prompt'' must be a string.')
    end
    if ~iscellstr(validOptions) && ~isnumeric(validOptions)
        error('''validOptions'' must be a numeric vector or cell array of string.')
    end
    if ~exist('caseSensitive', 'var') || isempty(caseSensitive)
        caseSensitive = false;
    end
    
    % if not operating in case sensitive mode, and validOptions is a cell
    % array of strings, make it lowercase
    if iscellstr(validOptions) && ~caseSensitive
        validOptions = lower(validOptions);
    end
    
    % loop until a valid response is made
    happy = false;
    while ~happy

        % get response
        resp = input(prompt, 's');
        
        % if validOptions are numeric, convert response to number
        if isnumeric(validOptions) && ischar(resp)
            resp = str2double(resp);
        end
        
        % if validOptions is a cellstr, and not in case sensitive mode,
        % make response lowercase
        if iscellstr(validOptions) && ~caseSensitive && ischar(resp)
            resp = lower(resp);
        end
        

        % validate
        if ~ismember(resp, validOptions)
            % report error
            fprintf(2, 'Invalid option. Valid options are:\n');
            % different format switch depending upon data type of
            % validOptions
            if iscellstr(validOptions)
                fprintf(2, '\t%s\n', validOptions{:});
            elseif isnumeric(validOptions)
                fprintf(2, '\t%d\n', validOptions(:));
            end

        else
            % response was a valid option
            happy = true;

        end

    end

end