
function d2img = draw_2Dskeleton_ICVL(tline, coord_pixel)
 
    db_path = '/home/gyeongsikmoon/workspace/Data/Hand_pose_estimation/ICVL/Testing/Depth/';
    jointNum =  16;
     cubicSz = 200;
    imgWidth = 320;
    imgHeight = 240;
    
    coord_pixel = squeeze(coord_pixel);
    rgb_img = zeros(imgHeight,imgWidth,3);
    refDepths = zeros(1,jointNum);
    line_width = 4;
   
    splitted = strsplit(tline);
    img_name = splitted{1};
    bin_name = strcat(db_path,img_name(1:size(img_name,2)-3),'bin');
   
    for jid = 1:jointNum
        refDepths(1,jid) = str2num(splitted{(jid-1)*3+4});
    end
    refDepth = (min(refDepths(:)) + max(refDepths(:)))/2;
    
    fp_bin = fopen(bin_name,'r');
    img = fread(fp_bin,[imgWidth imgHeight],'float');
    img = permute(img,[2,1]);
    img(img==0) = refDepth+cubicSz/2;
    fclose(fp_bin);
    
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
    
    plot([coord_pixel(1,1),coord_pixel(1,2)],[coord_pixel(2,1),coord_pixel(2,2)],'Color',[255/255,153/255,153/255],'LineWidth',line_width); %wrist to thumb root
    plot([coord_pixel(1,2),coord_pixel(1,3)],[coord_pixel(2,2),coord_pixel(2,3)],'Color',[255/255,102/255,102/255],'LineWidth',line_width) %thumb root to thumb mid
    plot([coord_pixel(1,3),coord_pixel(1,4)],[coord_pixel(2,3),coord_pixel(2,4)],'Color',[255/255,51/255,51/255],'LineWidth',line_width) %thumb mid to thumb tip

    plot([coord_pixel(1,1),coord_pixel(1,5)],[coord_pixel(2,1),coord_pixel(2,5)],'Color',[153/255,255/255,153/255],'LineWidth',line_width) %wrist to index root
    plot([coord_pixel(1,5),coord_pixel(1,6)],[coord_pixel(2,5),coord_pixel(2,6)],'Color',[102/255,255/255,102/255],'LineWidth',line_width) %index root to index mid
    plot([coord_pixel(1,6),coord_pixel(1,7)],[coord_pixel(2,6),coord_pixel(2,7)],'Color',[51/255,255/255,51/255],'LineWidth',line_width) %index mid to index tip

    plot([coord_pixel(1,1),coord_pixel(1,8)],[coord_pixel(2,1),coord_pixel(2,8)],'Color',[255/255,204/255,153/255],'LineWidth',line_width) %wrist to middle root
    plot([coord_pixel(1,8),coord_pixel(1,9)],[coord_pixel(2,8),coord_pixel(2,9)],'Color',[255/255,178/255,102/255],'LineWidth',line_width) %middle root to middle mid
    plot([coord_pixel(1,9),coord_pixel(1,10)],[coord_pixel(2,9),coord_pixel(2,10)],'Color',[255/255,153/255,51/255],'LineWidth',line_width) %middle mid to middle tip

    plot([coord_pixel(1,1),coord_pixel(1,11)],[coord_pixel(2,1),coord_pixel(2,11)],'Color',[153/255,204/255,255/255],'LineWidth',line_width) %wrist to ring root
    plot([coord_pixel(1,11),coord_pixel(1,12)],[coord_pixel(2,11),coord_pixel(2,12)],'Color',[102/255,178/255,255/255],'LineWidth',line_width) %ring root to ring mid
    plot([coord_pixel(1,12),coord_pixel(1,13)],[coord_pixel(2,12),coord_pixel(2,13)],'Color',[51/255,153/255,255/255],'LineWidth',line_width) %ring mid to ring tip

    plot([coord_pixel(1,1),coord_pixel(1,14)],[coord_pixel(2,1),coord_pixel(2,14)],'Color',[255/255,153/255,255/255],'LineWidth',line_width) %wrist to pinky root
    plot([coord_pixel(1,14),coord_pixel(1,15)],[coord_pixel(2,14),coord_pixel(2,15)],'Color',[255/255,102/255,255/255],'LineWidth',line_width) %pinky root to pinky mid
    plot([coord_pixel(1,15),coord_pixel(1,16)],[coord_pixel(2,15),coord_pixel(2,16)],'Color',[255/255,51/255,255/255],'LineWidth',line_width) %pinky mid to pinky tip

    colorList = [
    230/255 230/255 0/255;
        
    255/255,153/255,153/255;
    255/255 102/255 102/255;
    255/255 51/255 51/255;
    
    153/255,255/255,153/255;
    102/255,255/255,102/255;
    51/255,255/255,51/255;
    
    255/255,204/255,153/255;
    255/255 178/255 102/255;
    255/255 153/255 51/255;
    
    153/255,204/255,255/255;
    102/255 178/255 255/255;
    51/255 153/255 255/255;
    
    255/255,153/255,255/255;
    255/255,102/255,255/255;
    255/255,51/255,255/255];
    scatter(coord_pixel(1,:),coord_pixel(2,:),100,colorList,'filled');
    
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
