
function f = draw_3Dskeleton_ITOP(d2img,coord_world,db)
 
    cubicSz = 1.8;
    coord_world = squeeze(coord_world);

    x = coord_world(1,:);
    y = coord_world(2,:);
    z = coord_world(3,:);
    if strcmp(db,'side')
        coord_world(1,:) = -z;
        coord_world(2,:) = x;
        coord_world(3,:) = y;
    elseif strcmp(db,'top')
        coord_world(1,:) = -y;
        coord_world(2,:) = x;
        coord_world(3,:) = -z;
    end
    line_width = 8;

    f = figure('Position',[100 100 600 450]);
    set(f, 'visible', 'off');
    hold on;
    grid on;

    plot3([coord_world(1,1),coord_world(1,2)],[coord_world(2,1),coord_world(2,2)],[coord_world(3,1),coord_world(3,2)],'Color',[255/255,178/255,102/255],'LineWidth',line_width) %neck to head

    plot3([coord_world(1,2),coord_world(1,3)],[coord_world(2,2),coord_world(2,3)],[coord_world(3,2),coord_world(3,3)],'Color',[255/255,153/255,153/255],'LineWidth',line_width) %neck to r_shoulder
    plot3([coord_world(1,3),coord_world(1,5)],[coord_world(2,3),coord_world(2,5)],[coord_world(3,3),coord_world(3,5)],'Color',[255/255,102/255,102/255],'LineWidth',line_width) %r_shoulder to r_elbow
    plot3([coord_world(1,5),coord_world(1,7)],[coord_world(2,5),coord_world(2,7)],[coord_world(3,5),coord_world(3,7)],'Color',[255/255,51/255,51/255],'LineWidth',line_width) %r_elbow to r_hand

    plot3([coord_world(1,2),coord_world(1,4)],[coord_world(2,2),coord_world(2,4)],[coord_world(3,2),coord_world(3,4)],'Color',[153/255,255/255,153/255],'LineWidth',line_width) %neck to l_shoulder
    plot3([coord_world(1,4),coord_world(1,6)],[coord_world(2,4),coord_world(2,6)],[coord_world(3,4),coord_world(3,6)],'Color',[102/255,255/255,102/255],'LineWidth',line_width) %l_shoulder to l_elbow
    plot3([coord_world(1,6),coord_world(1,8)],[coord_world(2,6),coord_world(2,8)],[coord_world(3,6),coord_world(3,8)],'Color',[51/255,255/255,51/255],'LineWidth',line_width) %l_elbow to l_hand

    plot3([coord_world(1,2),coord_world(1,9)],[coord_world(2,2),coord_world(2,9)],[coord_world(3,2),coord_world(3,9)],'Color',[230/255,230/255,0/255],'LineWidth',line_width) %neck to torso

    plot3([coord_world(1,9),coord_world(1,10)],[coord_world(2,9),coord_world(2,10)],[coord_world(3,9),coord_world(3,10)],'Color',[255/255,153/255,255/255],'LineWidth',line_width) %torso to r_hip
    plot3([coord_world(1,10),coord_world(1,12)],[coord_world(2,10),coord_world(2,12)],[coord_world(3,10),coord_world(3,12)],'Color',[255/255,102/255,255/255],'LineWidth',line_width) %r_hip to r_knee
    plot3([coord_world(1,12),coord_world(1,14)],[coord_world(2,12),coord_world(2,14)],[coord_world(3,12),coord_world(3,14)],'Color',[255/255,51/255,255/255],'LineWidth',line_width) %r_knee to r_foot

    plot3([coord_world(1,9),coord_world(1,11)],[coord_world(2,9),coord_world(2,11)],[coord_world(3,9),coord_world(3,11)],'Color',[153/255,204/255,255/255],'LineWidth',line_width) %torso to l_hip
    plot3([coord_world(1,11),coord_world(1,13)],[coord_world(2,11),coord_world(2,13)],[coord_world(3,11),coord_world(3,13)],'Color',[102/255,178/255,255/255],'LineWidth',line_width) %l_hip to l_knee
    plot3([coord_world(1,13),coord_world(1,15)],[coord_world(2,13),coord_world(2,15)],[coord_world(3,13),coord_world(3,15)],'Color',[51/255,153/255,255/255],'LineWidth',line_width) %l_knee to l_foot

    colorList = [
    255/255 178/255 102/255;

    230/255 230/255 0/255;

    255/255 153/255 153/255;
    153/255 255/255 153/255;

    255/255 102/255 102/255;
    102/255 255/255 102/255;

    255/255 51/255 51/255;
    51/255 255/255 51/255;

    230/255 230/255 0/255;

    255/255 153/255 255/255;
    153/255 204/255 255/255;

    255/255 102/255 255/255;
    102/255 178/255 255/255;

    255/255 51/255 255/255;
    51/255 153/255 255/255];
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
    ymax = max(coord_world(2,:))+0.3;
    zmin = min(zcenter-cubicSz/2, min(coord_world(3,:)));
    zmax = max(zcenter+cubicSz/2, max(coord_world(3,:)));
    
    xlim([xmin xmax]);
    ylim([ymin ymax]);
    zlim([zmin zmax]);
    
    h_img = surf([xmin;xmin],[ymin ymax;ymin ymax],[zmax zmax;zmin zmin],'CData',d2img,'FaceColor','texturemap');
    set(h_img,'edgecolor',[96/255 96/255 96/255]);
    
    view(62,7);

end

