function xlabelLineBreaks(axs, label)

    % get plot height
    opos = get(axs, 'Position');
    ax_extent = opos(3);
    
    broken = labelLineBreaks(label, ax_extent, axs);
   
    xlabel(axs, broken)

end