function draw_ITOP(db)
 
    jointNum =  15;
    annot_path = strcat('/home/gyeongsikmoon/workspace/Data/Human_pose_estimation/ITOP/',db,'_view/','ITOP_',db,'_test_labels.h5');
    frameNum = 10501;
    
    coord_pixel = load(strcat('result_',db,'_pixel.txt'));
    coord_pixel = reshape(coord_pixel,[size(coord_pixel,1),3,jointNum]); %frameNum, (x,y,z), jointNum
    coord_world = load(strcat('result_',db,'_world.txt'));
    coord_world = reshape(coord_world,[size(coord_world,1),3,jointNum]); %frameNum, (x,y,z), jointNum
    
    fileId = 1;
    fid = 1;
    while fileId <= frameNum
        
        fprintf('%d / %d\n',fileId,frameNum);
    
        is_valid = h5read(annot_path,'/is_valid',[fileId],[1]);
        if is_valid == 1

            img = draw_2Dskeleton_ITOP(db,fileId,coord_pixel(fid,:,:));
            f = draw_3Dskeleton_ITOP(img,coord_world(fid,:,:),db);

            set(gcf, 'InvertHardCopy', 'off');
            set(gcf,'color','w');
            saveas(f, strcat('./output_',db,'/',int2str(fid)), 'jpg');
            close(f);

            fid = fid + 1;
        end

        fileId = fileId + 1;

    end

end
