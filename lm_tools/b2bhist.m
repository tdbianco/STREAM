function b2bhist(d1, d2)

    % make row vectors
    if size(d1, 1) > size(d1, 2)
        d1 = d1';
    end
    if size(d2, 1) > size(d2, 2)
        d2 = d2';
    end
    
    % get x limits
    xl(1) = min([d1, d2]);
    xl(2) = max([d1, d2]);
    
    % set bin width
    bw = (xl(2) - xl(1)) / 30;
    
    % hist 1
    sp1 = subplot(2, 1, 1);
    histogram(d1, 'binwidth', bw)
    set(gca, 'xtick', [])
    xlim(xl)
    
    % hist 2
    sp2 = subplot(2, 1, 2);
    hs = histogram(d2, 'binwidth', bw);
    col = sp2.ColorOrder(2, :);
    hs.FaceColor = col;
    set(gca, 'ydir', 'reverse')
    xlim(xl)
    
    % repos
    sp1.Position(2) = .50;
    sp2.Position(4) = 0.5 - sp2.Position(2);
    sp1.Position(4) = sp2.Position(4);
    
    % set ylim
    tmp = [sp1.YLim; sp2.YLim];
    yl(1) = min(tmp(:, 1));
    yl(2) = max(tmp(:, 2));
    sp1.YLim = yl;
    sp2.YLim = yl;
    
end