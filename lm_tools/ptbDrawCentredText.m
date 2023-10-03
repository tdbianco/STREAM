function ptbDrawCentredText(winPtr, text, rect, colour, textSize)
    if ~exist('textSize', 'var')
        textSize = [];
        oldTextSize = [];
    else
        oldTextSize = Screen('TextSize', winPtr, textSize);
    end
    if ~exist('colour', 'var')
        colour = [];
    end
    % get width/height of text
    tb = Screen('TextBounds', winPtr, text, rect(1), rect(2));
    w = tb(3);
    h = tb(4);
    % find centre of rect
    cx = rect(1) + ((rect(3) - rect(1)) / 2);
    cy = rect(2) + ((rect(4) - rect(2)) / 2);
    % find top left of text
    x1 = cx - (w / 2);
    y1 = cy - (h / 2);
    % draw
    Screen('DrawText', winPtr, text, x1, y1, colour);
    % reset text size
    if ~isempty(textSize)
        Screen('TextSize', winPtr, oldTextSize);
    end
end