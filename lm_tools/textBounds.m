function extent = textBounds(label, axs)

    tmp = uicontrol('style', 'text', 'visible', 'off', 'string', label,...
        'units', 'normalized');
    extent = tmp.Extent;
    
end