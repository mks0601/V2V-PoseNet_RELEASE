
function f = draw_3Dskeleton_MSRA(d2img,coord_world)
 
    cubicSz = 150;
    coord_world = squeeze(coord_world);

    x = coord_world(1,:);
    y = coord_world(2,:);
    z = coord_world(3,:);
    coord_world(1,:) = -z;
    coord_world(2,:) = x;
    coord_world(3,:) = y;
    line_width = 8;

    f = figure('Position',[100 100 600 450]);
    set(f, 'visible', 'off');
    hold on;
    grid on;

    plot3([coord_world(1,1),coord_world(1,18)],[coord_world(2,1),coord_world(2,18)],[coord_world(3,1),coord_world(3,18)],'Color',[255/255,153/255,153/255],'LineWidth',line_width) %wrist to thumb mcp
    plot3([coord_world(1,18),coord_world(1,19)],[coord_world(2,18),coord_world(2,19)],[coord_world(3,18),coord_world(3,19)],'Color',[255/255,102/255,102/255],'LineWidth',line_width) %thumb mcp to thumb pip
    plot3([coord_world(1,19),coord_world(1,20)],[coord_world(2,19),coord_world(2,20)],[coord_world(3,19),coord_world(3,20)],'Color',[255/255,51/255,51/255],'LineWidth',line_width) %thumb pip to thumb dip
    plot3([coord_world(1,20),coord_world(1,21)],[coord_world(2,20),coord_world(2,21)],[coord_world(3,20),coord_world(3,21)],'Color',[255/255,0/255,0/255],'LineWidth',line_width) %thumb dip to thumb tip

    plot3([coord_world(1,1),coord_world(1,2)],[coord_world(2,1),coord_world(2,2)],[coord_world(3,1),coord_world(3,2)],'Color',[153/255,255/255,153/255],'LineWidth',line_width) %wrist to index mcp
    plot3([coord_world(1,2),coord_world(1,3)],[coord_world(2,2),coord_world(2,3)],[coord_world(3,2),coord_world(3,3)],'Color',[102/255,255/255,102/255],'LineWidth',line_width) %index mcp to index pip
    plot3([coord_world(1,3),coord_world(1,4)],[coord_world(2,3),coord_world(2,4)],[coord_world(3,3),coord_world(3,4)],'Color',[51/255,255/255,51/255],'LineWidth',line_width) %index pip to index dip
    plot3([coord_world(1,4),coord_world(1,5)],[coord_world(2,4),coord_world(2,5)],[coord_world(3,4),coord_world(3,5)],'Color',[0/255,255/255,0/255],'LineWidth',line_width) %index dip to index tip

    plot3([coord_world(1,1),coord_world(1,6)],[coord_world(2,1),coord_world(2,6)],[coord_world(3,1),coord_world(3,6)],'Color',[255/255,204/255,153/255],'LineWidth',line_width) %wrist to middle mcp
    plot3([coord_world(1,6),coord_world(1,7)],[coord_world(2,6),coord_world(2,7)],[coord_world(3,6),coord_world(3,7)],'Color',[255/255,178/255,102/255],'LineWidth',line_width) %middle mcp to middle pip
    plot3([coord_world(1,7),coord_world(1,8)],[coord_world(2,7),coord_world(2,8)],[coord_world(3,7),coord_world(3,8)],'Color',[255/255,153/255,51/255],'LineWidth',line_width) %middle pip to middle dip
    plot3([coord_world(1,8),coord_world(1,9)],[coord_world(2,8),coord_world(2,9)],[coord_world(3,8),coord_world(3,9)],'Color',[255/255,128/255,0/255],'LineWidth',line_width) %middle dip to middle tip

    plot3([coord_world(1,1),coord_world(1,10)],[coord_world(2,1),coord_world(2,10)],[coord_world(3,1),coord_world(3,10)],'Color',[153/255,204/255,255/255],'LineWidth',line_width) %wrist to ring mcp
    plot3([coord_world(1,10),coord_world(1,11)],[coord_world(2,10),coord_world(2,11)],[coord_world(3,10),coord_world(3,11)],'Color',[102/255,178/255,255/255],'LineWidth',line_width) %ring mcp to ring pip
    plot3([coord_world(1,11),coord_world(1,12)],[coord_world(2,11),coord_world(2,12)],[coord_world(3,11),coord_world(3,12)],'Color',[51/255,153/255,255/255],'LineWidth',line_width) %ring pip to ring dip
    plot3([coord_world(1,12),coord_world(1,13)],[coord_world(2,12),coord_world(2,13)],[coord_world(3,12),coord_world(3,13)],'Color',[0/255,128/255,255/255],'LineWidth',line_width) %ring dip to ring tip

    plot3([coord_world(1,1),coord_world(1,14)],[coord_world(2,1),coord_world(2,14)],[coord_world(3,1),coord_world(3,14)],'Color',[255/255,153/255,255/255],'LineWidth',line_width) %wrist to little mcp
    plot3([coord_world(1,14),coord_world(1,15)],[coord_world(2,14),coord_world(2,15)],[coord_world(3,14),coord_world(3,15)],'Color',[255/255,102/255,255/255],'LineWidth',line_width) %little mcp to little pip
    plot3([coord_world(1,15),coord_world(1,16)],[coord_world(2,15),coord_world(2,16)],[coord_world(3,15),coord_world(3,16)],'Color',[255/255,51/255,255/255],'LineWidth',line_width) %little pip to little dip
    plot3([coord_world(1,16),coord_world(1,17)],[coord_world(2,16),coord_world(2,17)],[coord_world(3,16),coord_world(3,17)],'Color',[255/255,0/255,255/255],'LineWidth',line_width) %little dip to little tip
    

    colorList = [
    230/255 230/255 0/255;
    
    153/255 255/255 153/255;
    102/255 255/255 102/255;
    51/255 255/255 51/255;
    0/255 255/255 0/255;

    255/255 204/255 153/255;
    255/255 178/255 102/255;
    255/255 153/255 51/255;
    255/255 128/255 0/255;
    
    153/255 204/255 255/255;
    102/255 178/255 255/255;
    51/255 153/255 255/255;
    0/255 128/255 255/255;
    
    255/255 153/255 255/255;
    255/255 102/255 255/255;
    255/255 51/255 255/255;
    255/255 0/255 255/255;
    
    255/255 153/255 153/255;
    255/255 102/255 102/255;
    255/255 51/255 51/255;
    255/255 0/255 0/255;
    ];
    scatter3(coord_world(1,:),coord_world(2,:),coord_world(3,:),150,colorList,'filled');
    
    set(gca, 'color', [255/255 255/255 255/255])

    set(gca,'XTickLabel',[]);
    set(gca,'YTickLabel',[]);
    set(gca,'ZTickLabel',[]);

    
    xcenter = (min(coord_world(1,:)) + max(coord_world(1,:)))/2;
    ycenter = (min(coord_world(2,:)) + max(coord_world(2,:)))/2;
    zcenter = (min(coord_world(3,:)) + max(coord_world(3,:)))/2;
    
    xmin = xcenter - 3*cubicSz;
    xmax = max(coord_world(1,:));
    ymin = min(ycenter-cubicSz/2, min(coord_world(2,:)));
    ymax = max(coord_world(2,:))+30;
    zmin = min(zcenter-cubicSz/2, min(coord_world(3,:)));
    zmax = max(zcenter+cubicSz/2, max(coord_world(3,:)));
    
    xlim([xmin xmax]);
    ylim([ymin ymax]);
    zlim([zmin zmax]);
    
    h_img = surf([xmin;xmin],[ymin ymax;ymin ymax],[zmax zmax;zmin zmin],'CData',d2img,'FaceColor','texturemap');
    set(h_img,'edgecolor',[96/255 96/255 96/255]);
    
    view(62,7);

end

