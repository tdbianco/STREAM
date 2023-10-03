function tStr = reportTimeElapsed(t)

    secsInDay = 86400;
    prop = t / secsInDay;
    h = datestr(prop, 'HH');
    m = datestr(prop, 'MM');
    s = datestr(prop, 'SS');
    tStr = sprintf('%s hours, %s minutes, %s seconds.\n', h, m, s);

end