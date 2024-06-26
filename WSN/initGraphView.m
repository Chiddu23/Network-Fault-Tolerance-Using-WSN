function [fig] = initGraphView()
    
    % Bring global node list into scope
    global nodes showRoutesBtn range distance;
    
    % Make colors
    global colors;
    colors.RREPL = "blue";
    colors.RREQ = "cyan";
    colors.Data = "green";
    colors.RERR = "red";
    colors.Src = "yellow";
    colors.Dest = "yellow";

    % Figure basic setup
    fig = figure('NumberTitle','off',...
                 'Name','Node - Graph View',...
                 'Units','pixels',...
                 'MenuBar', 'none',...
                 'ToolBar', 'none',...
                 'WindowButtonDownFcn',@dragObject,...
                 'WindowButtonUpFcn',@dropObject,...
                 'WindowButtonMotionFcn',@moveObject);
    ax = axes(fig,...
                 'Units','pixels',...
                 'XTick',[],...
                 'YTick',[],...
                 'XColor','white',...
                 'YColor','white');
    hold all
    xlim([0,range])
    ylim([0,range])
    set(ax,'Position',ax.Position .* [1,1,0.9,1]);

    % Discover dimensions
    ui_x = ax.Position(1) + ax.Position(3);
    ui_y = ax.Position(2) + ax.Position(4);
    ui_w = fig.Position(3) - ui_x;
    ui_h = fig.Position(4) - ax.Position(2);

    % Make UI buttons
    showRoutesBtn = uicontrol(...
            'Style','togglebutton',...
            'String','Show Routes',...
            'Units','pixels',...
            'Position',[ui_x,ui_y-0.1*ui_h,ui_w,0.1*ui_h],...
            'Callback',@showRoutesBtnCallback);
    function [] = showRoutesBtnCallback(obj,event)
        calcConnections(distance,showRoutesBtn.Value);
    end
    uicontrol(...
            'Style','text',...
            'String','Distance',...
            'Units','pixels',...
            'Position',[ui_x,ui_y-0.15*ui_h,ui_w,0.05*ui_h]);
    distanceSlider = uicontrol(...
            'Style','slider',...
            'Units','pixels',...
            'Position',[ui_x,ui_y-0.2*ui_h,ui_w,0.05*ui_h],...
            'Callback',@distanceSliderCallback);
    function [] = distanceSliderCallback(obj,event)
        distance = range * get(distanceSlider,'Value');
        calcConnections(distance,showRoutesBtn.Value);
    end
    uicontrol(...
            'Style','text',...
            'String','Send node',...
            'Units','pixels',...
            'Position',[ui_x,ui_y-0.26*ui_h,ui_w,0.05*ui_h]);    
    srcNodeSel = uicontrol(...
            'Style','popup',...
            'String',{nodes.name},...
            'Position',[ui_x,ui_y-0.35*ui_h,ui_w*0.5,0.1*ui_h]);
    destNodeSel = uicontrol(...
            'Style','popup',...
            'String',{nodes.name},...
            'Position',[ui_x+ui_w*0.5,ui_y-0.35*ui_h,ui_w*0.5,0.1*ui_h]);
    sendBtn = uicontrol(...
            'Style','pushbutton',...
            'String','Go!',...
            'Units','pixels',...
            'Position',[ui_x,ui_y-0.4*ui_h,ui_w,0.075*ui_h],...
            'Callback',{@sendBtnCallback});
    function [] = sendBtnCallback(obj,event)
        sendPacket(srcNodeSel.Value,destNodeSel.Value);
        updateTableData()
    end
    clrRteTabsBtn = uicontrol(...
            'Style','pushbutton',...
            'String','Clear Route Tables',...
            'Units','pixels',...
            'Position',[ui_x,ui_y-0.5*ui_h,ui_w,0.075*ui_h],...
            'Callback',{@clrRteTabsCallback});
    function [] = clrRteTabsCallback(obj,event)
        for node = 1:numel(nodes)
            nodes(node).routeTable(:,:) = [];
            nodes(node).seqNum = 1;
        end
        updateTableData()
    end
    uicontrol(...
            'Style','text',...
            'String','Move:',...
            'Units','pixels',...
            'Position',[ui_x,ui_y-0.5725*ui_h,ui_w/2,0.05*ui_h]);   
    dragNodeSel = uicontrol(...
            'Style','popup',...
            'String',{nodes.name},...
            'Position',[ui_x+ui_w*0.5,ui_y-0.615*ui_h,ui_w*0.5,0.1*ui_h]);
    addBtn = uicontrol(...
            'Style','pushbutton',...
            'String','Add',...
            'Units','pixels',...
            'Position',[ui_x,ui_y-0.645*ui_h,ui_w/2,0.05*ui_h],...
            'Callback',{@addBtnCallback});
    function [] = addBtnCallback(obj,event)
        global steps tableFig;
        label = char(max([nodes.name])+1);
        idx = numel(nodes)+1;
        steps(idx,:) = [0,0];
        nodes(idx) = node(label,range/2,range/2);
        nodes(idx).updatePos(range/2,range/2);
        set(srcNodeSel,'String',{nodes.name});
        set(destNodeSel,'String',{nodes.name});
        set(dragNodeSel,'String',{nodes.name});
        set(dragNodeSel,'Value',idx);
        calcConnections(distance,showRoutesBtn.Value);
        updateGraphView();
        redrawTableView(tableFig);
    end
    deleteBtn = uicontrol(...
            'Style','pushbutton',...
            'String','Delete',...
            'Units','pixels',...
            'Position',[ui_x+ui_w*0.5,ui_y-0.645*ui_h,ui_w/2,0.05*ui_h],...
            'Callback',{@deleteBtnCallback});
    function  [] = deleteBtnCallback(obj,event)
        global steps tableFig;
        if(numel(nodes)<=1)
            return
        end
        idx = dragNodeSel.Value;
        delete(nodes(idx).circle);
        delete(nodes(idx).text);
        nodes(idx) = [];
        steps(idx,:) = [];
        updateGraphView()
        calcConnections(distance,showRoutesBtn.Value)
        size = numel(nodes);
        for i = 1:size
            badRoutes = find(nodes(i).routeTable.dest == idx | nodes(i).routeTable.nextHop == idx);
            nodes(i).routeTable(badRoutes,:) = [];
            badRoutes = find(nodes(i).routeTable.dest > idx);
            for route = badRoutes'
                nodes(i).routeTable(route,:).dest = nodes(i).routeTable(route,:).dest - 1;
            end
            badRoutes = find(nodes(i).routeTable.nextHop > idx);
            for route = badRoutes'
                nodes(i).routeTable(route,:).nextHop = nodes(i).routeTable(route,:).nextHop - 1;
            end
        end
        set(srcNodeSel,'Value',min(get(srcNodeSel,'Value'),size));
        set(destNodeSel,'Value',min(get(destNodeSel,'Value'),size));
        set(dragNodeSel,'Value',min(get(dragNodeSel,'Value'),size));
        set(srcNodeSel,'String',{nodes.name});
        set(destNodeSel,'String',{nodes.name});
        set(dragNodeSel,'String',{nodes.name});
        redrawTableView(tableFig);
    end
    movementBtn = uicontrol(...
            'Style','togglebutton',...
            'String','Movement',...
            'Units','pixels',...
            'Position',[ui_x,ui_y-0.75*ui_h,ui_w,0.1*ui_h],...
            'Callback',@movementBtnCallback);
    function [] = movementBtnCallback(obj,event)
        global movementTimer;
        if(movementBtn.Value)
            start(movementTimer)
        else
            stop(movementTimer)
        end
    end
    movementSpeedSlider = uicontrol(...
            'Style','slider',...
            'Units','pixels',...
            'Position',[ui_x,ui_y-0.8*ui_h,ui_w,0.05*ui_h],...
            'Callback',@movementSpeedSliderCallback);
    function [] = movementSpeedSliderCallback(obj,event)
        global movementTimer;
        max = 5.0;
        min = 0.25;
        period = 1.0 - get(movementSpeedSlider,'Value');
        period = ((max - min) * period) + min;
        period = round(period,3);
        stop(movementTimer)
        set(movementTimer,'Period',period)
        movementBtnCallback()
    end
        
    % Setup initial state
    set(distanceSlider,'Value',distance/range);    
    set(showRoutesBtn,'value',1.0);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Drag and drop stuff
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Calculate node circle radius
    global radius;
    radius = getpixelposition(gca);
    radius = radius(3) * 0.0004;
    
    % Initialize graph movement variables
    graphPos = get(gca,'Position');
    pixelsPerW = graphPos(3) / range;
    pixelsPerH = graphPos(4) / range;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Drag function
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dragging = false;
    function dragObject(obj,event)
        startPos = get(fig, 'CurrentPoint');
        dragging = true;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Drop function
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function dropObject(obj,event)
        if(dragging)
            dragging = false;
            calcConnections(distance,showRoutesBtn.Value);
            updateTableData()
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Move function
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function moveObject(obj,event)
        if(dragging)
            newPos = get(gcf,'CurrentPoint');
            newPos = newPos - [graphPos(1),graphPos(2)];
            nodes(dragNodeSel.Value) = nodes(dragNodeSel.Value).updatePos(...
                (newPos(1) / pixelsPerW),...
                (newPos(2) / pixelsPerH));
        end
    end

end