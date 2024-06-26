function [fig] = initTableView()
    
    % Figure basic setup
    fig = figure('NumberTitle','off',...
                 'Name','Simulation - Table View',...
                 'MenuBar', 'none',...
                 'ToolBar', 'none');
    set(fig,'ResizeFcn',@resize);
    redrawTableView(fig);
    
    function [] = resize(~,~)
        redrawTableView(fig);
        updateTableData()
    end
    
end