function [ strOut ] = LeadingString( paddingStr,num )
%LEADINGSTRING - takes a string (e.g. '000') and a number (e.g. 12) and
%pads the start of the number with a portion of the string (e.g. '012')

if ~ischar(paddingStr)
    error('Input argument paddingStr must be a string.')
end

if ~isnumeric(num)
    error('Input argument num must be numeric.')
end

strOut=[paddingStr(1:size(paddingStr,2)-size(num2str(num),2))...
    num2str(num)];
end

