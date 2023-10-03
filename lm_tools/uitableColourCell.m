function text = uitableColourCell(text, col)

    if iscellstr(text) && ismatrix(col) && isequal(size(text, 1), size(col, 1))
        col_cell = cell(size(col, 1), 1);
        for r = 1:size(col, 1)
            col_cell{r} = col(r, :);
        end
        text = cellfun(@(t, c) uitableColourCell(t, c), text, col_cell,...
            'uniform', false);
        return
    end

    col = uint8(col * 255);
    col_hex = rgb2hex(col);
%     text = sprintf('<body bgcolor="#%s">%s</body>', col_hex, text);
    text = sprintf('<html><table border=0 width=400 bgcolor="#%s"><TR><TD>%s</TD></TR> </table></html>', col_hex, text);
end