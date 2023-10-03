function newLabel = labelLineBreaks(label, ax_extent, axs)

    
    parts = strsplit(label, ' ');
    newLabel = parts(1);
    i = 2;
    row = 1;
    while i <= length(parts)
        testLabel = sprintf('%s %s', newLabel{row}, parts{i});
        testExtent = textBounds(testLabel, axs);
        testWidth = testExtent(3);
        if ~isempty(newLabel{row}) && testWidth > ax_extent
            row = row + 1;
            newLabel{row} = parts{i};
        else
            newLabel{row} = testLabel;
        end
        i = i + 1;
    end
%     % break
%     
%     
%     
%     
%     if lab_extent > ax_extent
%         numBreaks = ceil(lab_extent / ax_extent);
%         spaces = strsplit(label, ' ');
%         
%         
%         
%         
%         numSpace = length(spaces);
%         spacesPerBreak = ceil(numSpace / numBreaks);
%         broken = cell(1, numBreaks);
%         counter = 1;
%         for b = 1:numBreaks
%             s1 = counter;
%             s2 = counter + spacesPerBreak - 1;
%             if s2 > length(spaces), s2 = length(spaces); end
%             broken{b} = sprintf('%s ', spaces{s1:s2});
%             counter = counter + spacesPerBreak;
%         end
%         broken(cellfun(@isempty, broken)) = [];
%     else
%         broken = label;
%     end
    
end