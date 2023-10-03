function ylabelLineBreaks(axs, label)

    % get plot height
    opos = get(axs, 'Position');
    ax_extent = opos(4);
    
    broken = labelLineBreaks(label, ax_extent, axs);
   
    ylabel(axs, broken)

end