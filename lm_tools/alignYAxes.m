function alignYAxes

    % find all axes
    allAxes = findall(gcf, 'type','axes');
    
    % get y axes
    allY = cellfun(@(x) x.Y
    
    % get pos and x 
    pos = arrayfun(@(x) x.Position, allAxes, 'uniform', false);
    x = cellfun(@(x) x(1), pos);
    w = cellfun(@(x) x(3), pos);

% Number of axes (i.e. subplots)
naxes    = length(allAxes);
% Vector containing the x-position of all the axes in the figure
axxPos   = zeros(naxes,1);

for k = 1:naxes
    axPos  = get(allAxes(k),'Pos');
    axxPos(k) = axPos(1);
end
