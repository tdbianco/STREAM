function h_table = table2uitable(tab, varargin)

%     f = figure('visible', 'off');
    h_table = uitable(...
        'Units', 'normalized',...
        'Position', [0, 0, 1, 1],...
        'Data', table2cell(tab),...
        'ColumnName', tab.Properties.VariableNames,...
        varargin{:});
    uitableAutoColumnHeaders(h_table);
        
%     h_table.Units = 'pixels';
%     sz_t = h_table.Extent;
%     h_table.Units = 'normalized';
%     
%     sz_s = get(0, 'screensize');
%     
%     if sz_s(3) < sz_t(3)
%         sz_s(3) = sz_s(3);
%     else
%         error('need to write this code')
%     end
    
%     f.Units = 'pixels';
%     f.Position = sz_s;
%     f.Visible = 'on';
    
end
        
            