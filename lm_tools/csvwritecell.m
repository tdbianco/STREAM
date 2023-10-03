function [ success ] = csvwritecell( filename, m, cmdEcho )
% csvwritecell - writes a cell array (m) to a .csv file (filename). 

% check args
if ~iscell(m)
    error('Passed variable was not a cell array.')
end

if isempty(m)
    error('Empty variable passed.')
end

if ~exist('cmdEcho', 'var') || isempty(cmdEcho)
    cmdEcho = true;
end

% if exist(filename,'file')
%     error('File already exists.')
% end

% set up delimiter (just commas for now)
del=',';
msg='Saving file: 0%';
perc=0;

% open file
[fid,msg] = fopen(filename, 'W','ieee-le.l64');
if fid==-1
    error('File coule not be opened for writing: \n%s\n',msg)
end

startTime=now;

for curRow = 1:size(m,1)
     
    out=''; 

    for curCol = 1:size(m,2)
                
        % Determine data type
        curCell = m{curRow, curCol};
        
%         if iscell(curCell)
%             error('Cannot write cells of a cell array that contain nested cell arrays.')
%         end
        
        if isnumeric(curCell)
            % determine required precision
            if isa(curCell,'int64') || isa(curCell,'uint64')
                out = sprintf('%s%i%s',out,curCell,del);
            elseif isfloat(curCell)
                out = sprintf('%s%.50f%s',out,curCell,del);
            end
        elseif ischar(curCell)
            out = sprintf('%s%s%s',out,curCell,del);
        elseif islogical(curCell)
            out = sprintf('%s%i%s',out,curCell,del);
        elseif iscell(curCell)
            % if is cell, attempt to convert to char
            try
                out = sprintf('%s%i%s',out,char(curCell),del);
            catch ERR
                error('Cannot write cells of a cell array that contain nested cell arrays.')
            end
        else
            error('Unknown data type.')
            fclose(fid);
        end
        
    end
    
    % write to file
    fprintf(fid,'%s\n',out);
    
    % display progress
    oldPerc   = perc;
    perc      = floor((curRow/size(m,1))*100);
    
    if perc >=1 && cmdEcho
        timeTaken = now - startTime;
        timeTotal = timeTaken * (100 / perc);
        timeLeft  = timeTotal - timeTaken;
        timeVec   = datevec(timeLeft);
        timeStr   = sprintf('%ih:%im:%is',timeVec(1,4), timeVec(1,5),...
            floor(timeVec(1,6)));

        if perc ~= oldPerc && cmdEcho;
            backSpaces=repmat('\b',[1,size(msg,2)]);
            msg=sprintf('Saving file: %i%%, remaining: %s', perc, timeStr);
            fprintf(1,[backSpaces,'%s'],msg);
        end
    end
end

fclose(fid);
success=true;

if cmdEcho
    backSpaces=repmat('\b',[1,size(msg,2)]);
    msg=sprintf('\tFile saved to: %s\n',filename);
    fprintf(1,[backSpaces,'%s'],msg);
end

end

