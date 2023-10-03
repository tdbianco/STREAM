function parpoolnum(num)

    c = parcluster('local');
    c.NumWorkers = num;
    parpool(c, c.NumWorkers);

end