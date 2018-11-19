
function d2img = draw_2Dskeleton_ITOP(db,fileId,coord_pixel)
    
    db_path = strcat('/home/gyeongsikmoon/workspace/Data/Human_pose_estimation/ITOP/',db,'_view/','ITOP_',db,'_test_depth_map.h5');
    jointNum =  15;
    cubicSz = 2.0;
    imgHeight = 240;
    imgWidth = 320;

    annot_path = strcat('/home/gyeongsikmoon/workspace/Data/Human_pose_estimation/ITOP/',db,'_view/','ITOP_',db,'_test_labels.h5');
       
    coord_pixel = squeeze(coord_pixel);
    rgb_img = zeros(imgHeight,imgWidth,3);
    refDepths = zeros(1,jointNum);
    line_width = 6;

    gt = h5read(annot_path,'/real_world_coordinates',[1 1 fileId],[3 jointNum 1]);
    for jid = 1:jointNum
        refDepths(1,jid) = gt(3,jid,1);
    end
    refDepth = (min(refDepths(:)) + max(refDepths(:)))/2;

    img = h5read(db_path,'/data',[1 1 fileId],[imgWidth imgHeight 1]);
    img = permute(img,[2,1]);
    img(img==0) = refDepth+cubicSz/2;
    
    if strcmp(db,'top')
        mask = h5read(annot_path,'/segmentation',[1 1 fileId],[imgWidth imgHeight 1]);
        mask = permute(mask,[2,1]);
        img(mask==-1) = refDepth+cubicSz/2;    
    end
    
    if strcmp(db,'side')
        if 1 <= min(coord_pixel(2,:)-15)
            img(1:round(min(coord_pixel(2,:)))-15,:) = refDepth+cubicSz/2;
        end
        if max(coord_pixel(2,:))+15 <= imgHeight
            img(round(max(coord_pixel(2,:)))+15:imgHeight,:) = refDepth+cubicSz/2;
        end
        if 1 <= min(coord_pixel(1,:)) - 15
            img(:,1:round(min(coord_pixel(1,:)))-15) = refDepth+cubicSz/2;
        end
        if max(coord_pixel(1,:)) + 15 <= imgWidth
            img(:,round(max(coord_pixel(1,:)))+15:imgWidth) = refDepth+cubicSz/2;
        end

        img(img < min(coord_pixel(3,:))-0.15) = refDepth+cubicSz/2;
        img(img > max(coord_pixel(3,:))+0.15) = refDepth+cubicSz/2;
    end
    
    img(img>refDepth+cubicSz/2) = refDepth + cubicSz/2;
    img(img<refDepth-cubicSz/2) = refDepth - cubicSz/2;
    img = img - refDepth;
    img = img/(cubicSz/2);
    
    img = img + 1;
    img = img/2;

    rgb_img(:,:,1) = img*255/255;
    rgb_img(:,:,2) = img*240/255;
    rgb_img(:,:,3) = img*204/255;

    
    f = figure;
    set(f, 'visible', 'off');
    imshow(rgb_img);
    hold on;

    plot([coord_pixel(1,1),coord_pixel(1,2)],[coord_pixel(2,1),coord_pixel(2,2)],'Color',[255/255,178/255,102/255],'LineWidth',line_width) %neck to head

    plot([coord_pixel(1,2),coord_pixel(1,3)],[coord_pixel(2,2),coord_pixel(2,3)],'Color',[255/255,153/255,153/255],'LineWidth',line_width) %neck to r_shoulder
    plot([coord_pixel(1,3),coord_pixel(1,5)],[coord_pixel(2,3),coord_pixel(2,5)],'Color',[255/255,102/255,102/255],'LineWidth',line_width) %r_shoulder to r_elbow
    plot([coord_pixel(1,5),coord_pixel(1,7)],[coord_pixel(2,5),coord_pixel(2,7)],'Color',[255/255,51/255,51/255],'LineWidth',line_width) %r_elbow to r_hand

    plot([coord_pixel(1,2),coord_pixel(1,4)],[coord_pixel(2,2),coord_pixel(2,4)],'Color',[153/255,255/255,153/255],'LineWidth',line_width) %neck to l_shoulder
    plot([coord_pixel(1,4),coord_pixel(1,6)],[coord_pixel(2,4),coord_pixel(2,6)],'Color',[102/255,255/255,102/255],'LineWidth',line_width) %l_shoulder to l_elbow
    plot([coord_pixel(1,6),coord_pixel(1,8)],[coord_pixel(2,6),coord_pixel(2,8)],'Color',[51/255,255/255,51/255],'LineWidth',line_width) %l_elbow to l_hand

    plot([coord_pixel(1,2),coord_pixel(1,9)],[coord_pixel(2,2),coord_pixel(2,9)],'Color',[230/255,230/255,0/255],'LineWidth',line_width) %neck to torso

    plot([coord_pixel(1,9),coord_pixel(1,10)],[coord_pixel(2,9),coord_pixel(2,10)],'Color',[255/255,153/255,255/255],'LineWidth',line_width) %torso to r_hip
    plot([coord_pixel(1,10),coord_pixel(1,12)],[coord_pixel(2,10),coord_pixel(2,12)],'Color',[255/255,102/255,255/255],'LineWidth',line_width) %r_hip to r_knee
    plot([coord_pixel(1,12),coord_pixel(1,14)],[coord_pixel(2,12),coord_pixel(2,14)],'Color',[255/255,51/255,255/255],'LineWidth',line_width) %r_knee to r_foot

    plot([coord_pixel(1,9),coord_pixel(1,11)],[coord_pixel(2,9),coord_pixel(2,11)],'Color',[153/255,204/255,255/255],'LineWidth',line_width) %torso to l_hip
    plot([coord_pixel(1,11),coord_pixel(1,13)],[coord_pixel(2,11),coord_pixel(2,13)],'Color',[102/255,178/255,255/255],'LineWidth',line_width) %l_hip to l_knee
    plot([coord_pixel(1,13),coord_pixel(1,15)],[coord_pixel(2,13),coord_pixel(2,15)],'Color',[51/255,153/255,255/255],'LineWidth',line_width) %l_knee to l_foot

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
    scatter(coord_pixel(1,:),coord_pixel(2,:),150,colorList,'filled');

    set(gca,'Units','normalized','Position',[0 0 1 1]);  %# Modify axes size
    set(gcf,'Units','pixels','Position',[200 200 2*imgWidth 2*imgHeight]);  %# Modify figure size

    frame = getframe(gcf);
    framedata = frame.cdata;
    
    xmin = min(coord_pixel(1,:));
    xmax = max(coord_pixel(1,:));
    ymin = min(coord_pixel(2,:));
    ymax = max(coord_pixel(2,:));

    len = max(xmax-xmin+1,ymax-ymin+1) + 70;
    xcenter = (xmin + xmax)/2;
    ycenter = (ymin + ymax)/2;
    
    xmin = max(round(xcenter - len/2),1);
    xmax = min(round(xmin + len),imgWidth);
    ymin = max(round(ycenter - len/2),1);
    ymax = min(round(ymin + len),imgHeight);
    framedata = framedata(2*ymin:2*ymax,2*xmin:2*xmax,:);

    hold off;
    close(f); 

    d2img = framedata;

end
