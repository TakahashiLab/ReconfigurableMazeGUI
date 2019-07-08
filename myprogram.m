function myprogram

    f = figure('WindowStyle','normal');
    ax = axes;
    x = 0:100;
    y = x.^2;

    plotline = plot(x,y);
    c = uicontextmenu;

    % Assign the uicontextmenu to the plot line
    plotline.UIContextMenu = c;

    % Create child menu items for the uicontextmenu
    m1 = uimenu(c,'Label','dashed','Callback',@setlinestyle);
    m2 = uimenu(c,'Label','dotted','Callback',@setlinestyle);
    m3 = uimenu(c,'Label','solid','Callback',@setlinestyle);

        function setlinestyle(source,callbackdata)
            switch source.Label
                case 'dashed'
                    plotline.LineStyle = '--';
                case 'dotted'
                    plotline.LineStyle = ':';
                case 'solid'
                    plotline.LineStyle = '-';
            end
        end
end