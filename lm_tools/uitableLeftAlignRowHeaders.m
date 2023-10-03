function uitableLeftAlignRowHeaders(h)

    %get java stuff:
    jscroll=findjobj(h);
    rhv=jscroll.getComponent(4); %row header viewport
    rh=rhv.getComponent(0); %row header table

    %resize header:
    headerWidth=200; %the width you want for the rowheader in pixels
    rhHeight=rh.getPreferredSize.height;
    rh.setPreferredSize(java.awt.Dimension(headerWidth,rhHeight))
    rh.setSize(java.awt.Dimension(headerWidth,rhHeight))
    rhv.setPreferredSize(java.awt.Dimension(headerWidth,rhHeight))
    rhv.setSize(java.awt.Dimension(headerWidth,rhHeight))
    rhv.doLayout;

end