function draw_HANDS2017()
 
    
    center_path = '/home/gyeongsikmoon/workspace/Data/Hand_pose_estimation/Result_HANDS2017/center/center_test_refined.txt';
    jointNum =  21;
    annot_path = '/home/gyeongsikmoon/workspace/Data/Hand_pose_estimation/HANDS2017/frame/BoundingBox.txt';
    frameNum = 295510;
        
    fp_gt = fopen(annot_path);
    fp_center = fopen(center_path);

    coord_pixel = load('result_pixel.txt');
    coord_pixel = reshape(coord_pixel,[size(coord_pixel,1),3,jointNum]); %frameNum, (x,y,z), jointNum
    coord_world = load('result_world.txt');
    coord_world = reshape(coord_world,[size(coord_world,1),3,jointNum]); %frameNum, (x,y,z), jointNum
    
    fid = 1;
    tline = fgetl(fp_gt);
    tline_center = fgetl(fp_center);
    while fid <= frameNum
        
        fprintf('%d / %d\n',fid,frameNum);
              
        img = draw_2Dskeleton_HANDS2017(tline,tline_center,coord_pixel(fid,:,:));
        f = draw_3Dskeleton_HANDS2017(img,coord_world(fid,:,:));
        
        set(gcf, 'InvertHardCopy', 'off');
        set(gcf,'color','w');
        saveas(f, strcat('./output/',int2str(fid)), 'jpg');
        close(f);
        
        tline = fgetl(fp_gt);
        tline_center = fgetl(fp_center);
        fid = fid + 1;

    end

    fclose(fp_gt);
    fclose(fp_center);

end
