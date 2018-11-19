
function d2img = draw_2Dskeleton_HANDS2017(tline,tline_center,coord_pixel)
    
    db_path = '/home/gyeongsikmoon/workspace/Data/Hand_pose_estimation/HANDS2017/frame/images/';
    cubicSz = 200;
    imgWidth = 640;
    imgHeight = 480;
    
    coord_pixel = squeeze(coord_pixel);
    rgb_img = zeros(imgHeight,imgWidth,3);
    line_width = 6;

    splitted = strsplit(tline);
    img_name = splitted{1};
    bin_name = strcat(db_path,img_name(1:size(img_name,2)-3),'bin');
   
    splitted = strsplit(tline_center);
    refDepth = str2num(splitted{3});

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

    plot([coord_pixel(1,1),coord_pixel(1,2)],[coord_pixel(2,1),coord_pixel(2,2)],'Color',[255/255,153/255,153/255],'LineWidth',line_width) %wrist to TMCP
    plot([coord_pixel(1,2),coord_pixel(1,7)],[coord_pixel(2,2),coord_pixel(2,7)],'Color',[255/255,102/255,102/255],'LineWidth',line_width) %TMCP to TPIP
    plot([coord_pixel(1,7),coord_pixel(1,8)],[coord_pixel(2,7),coord_pixel(2,8)],'Color',[255/255,51/255,51/255],'LineWidth',line_width) %TPIP to TDIP
    plot([coord_pixel(1,8),coord_pixel(1,9)],[coord_pixel(2,8),coord_pixel(2,9)],'Color',[255/255,0/255,0/255],'LineWidth',line_width) %TDIP to TTIP

    plot([coord_pixel(1,1),coord_pixel(1,3)],[coord_pixel(2,1),coord_pixel(2,3)],'Color',[153/255,255/255,153/255],'LineWidth',line_width) %wrist to IMCP
    plot([coord_pixel(1,3),coord_pixel(1,10)],[coord_pixel(2,3),coord_pixel(2,10)],'Color',[102/255,255/255,102/255],'LineWidth',line_width) %IMCP to IPIP
    plot([coord_pixel(1,10),coord_pixel(1,11)],[coord_pixel(2,10),coord_pixel(2,11)],'Color',[51/255,255/255,51/255],'LineWidth',line_width) %IPIP to IDIP
    plot([coord_pixel(1,11),coord_pixel(1,12)],[coord_pixel(2,11),coord_pixel(2,12)],'Color',[0/255,255/255,0/255],'LineWidth',line_width) %IDIP to ITIP

    plot([coord_pixel(1,1),coord_pixel(1,4)],[coord_pixel(2,1),coord_pixel(2,4)],'Color',[255/255,204/255,153/255],'LineWidth',line_width) %wrist to MMCP
    plot([coord_pixel(1,4),coord_pixel(1,13)],[coord_pixel(2,4),coord_pixel(2,13)],'Color',[255/255,178/255,102/255],'LineWidth',line_width) %MMCP to MPIP
    plot([coord_pixel(1,13),coord_pixel(1,14)],[coord_pixel(2,13),coord_pixel(2,14)],'Color',[255/255,153/255,51/255],'LineWidth',line_width) %MPIP to MDIP
    plot([coord_pixel(1,14),coord_pixel(1,15)],[coord_pixel(2,14),coord_pixel(2,15)],'Color',[255/255,128/255,0/255],'LineWidth',line_width) %MDIP to MTIP

    plot([coord_pixel(1,1),coord_pixel(1,5)],[coord_pixel(2,1),coord_pixel(2,5)],'Color',[153/255,204/255,255/255],'LineWidth',line_width) %wrist to RMCP
    plot([coord_pixel(1,5),coord_pixel(1,16)],[coord_pixel(2,5),coord_pixel(2,16)],'Color',[102/255,178/255,255/255],'LineWidth',line_width) %RMCP to RPIP
    plot([coord_pixel(1,16),coord_pixel(1,17)],[coord_pixel(2,16),coord_pixel(2,17)],'Color',[51/255,153/255,255/255],'LineWidth',line_width) %RPIP to RDIP
    plot([coord_pixel(1,17),coord_pixel(1,18)],[coord_pixel(2,17),coord_pixel(2,18)],'Color',[0/255,128/255,255/255],'LineWidth',line_width) %RDIP to RTIP

    plot([coord_pixel(1,1),coord_pixel(1,6)],[coord_pixel(2,1),coord_pixel(2,6)],'Color',[255/255,153/255,255/255],'LineWidth',line_width) %wrist to PMCP
    plot([coord_pixel(1,6),coord_pixel(1,19)],[coord_pixel(2,6),coord_pixel(2,19)],'Color',[255/255,102/255,255/255],'LineWidth',line_width) %PMCP to PPIP
    plot([coord_pixel(1,19),coord_pixel(1,20)],[coord_pixel(2,19),coord_pixel(2,20)],'Color',[255/255,51/255,255/255],'LineWidth',line_width) %PPIP to PDIP
    plot([coord_pixel(1,20),coord_pixel(1,21)],[coord_pixel(2,20),coord_pixel(2,21)],'Color',[255/255,0/255,255/255],'LineWidth',line_width) %PDIP to PTIP
    
    colorList = [
    230/255 230/255 0/255;

    255/255 153/255 153/255;
    153/255 255/255 153/255;
    255/255 204/255 153/255;
    153/255 204/255 255/255;
    255/255 153/255 255/255;
    
    255/255 102/255 102/255;
    255/255 51/255 51/255;
    255/255 0/255 0/255;

    102/255 255/255 102/255;
    51/255 255/255 51/255;
    0/255 255/255 0/255;

    255/255 178/255 102/255;
    255/255 153/255 51/255;
    255/255 128/255 0/255;

    102/255 178/255 255/255;
    51/255 153/255 255/255;
    0/255 128/255 255/255;

    255/255 102/255 255/255;
    255/255 51/255 255/255;
    255/255 0/255 255/255;
    ];
    scatter(coord_pixel(1,:),coord_pixel(2,:),200,colorList,'filled');

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
