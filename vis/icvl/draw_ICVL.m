function draw_ICVL()
 
    annot_path = '/home/gyeongsikmoon/workspace/Data/Hand_pose_estimation/ICVL/Testing/test_seq_1.txt';
    jointNum =  16;
    frameNum = 702 + 894;
        
    fp_gt = fopen(annot_path);
    coord_pixel = load('result_pixel.txt');
    coord_pixel = reshape(coord_pixel,[size(coord_pixel,1),3,jointNum]); %frameNum, (x,y,z), jointNum
    coord_world = load('result_world.txt');
    coord_world = reshape(coord_world,[size(coord_world,1),3,jointNum]); %frameNum, (x,y,z), jointNum

    fid = 1;
    tline = fgetl(fp_gt);
    while fid <= frameNum
        
        fprintf('%d / %d\n',fid,frameNum);

        img = draw_2Dskeleton_ICVL(tline,coord_pixel(fid,:,:));
        f = draw_3Dskeleton_ICVL(img,coord_world(fid,:,:));

        set(gcf, 'InvertHardCopy', 'off');
        set(gcf,'color','w');
        saveas(f, strcat('./output/',int2str(fid)), 'jpg');
        close(f);

        tline = fgetl(fp_gt);
        fid = fid + 1;

        if fid == 702 + 1
            annot_path = '/home/gyeongsikmoon/workspace/Data/Hand_pose_estimation/ICVL/Testing/test_seq_2.txt';
             
            fclose(fp_gt);
            fp_gt = fopen(annot_path);
            tline = fgetl(fp_gt);
        end

    end

end
