function draw_MSRA()
 
    db_path = '/home/gyeongsikmoon/workspace/Data/Hand_pose_estimation/MSRA/cvpr15_MSRAHandGestureDB/';
    jointNum =  21;

    folder_list = ["1","2","3","4","5","6","7","8","9","I","IP","L","MP","RP","T","TIP","Y"];
    modelNum = 1;

    coord_pixel = load('result_pixel.txt');
    coord_pixel = reshape(coord_pixel,[size(coord_pixel,1),3,jointNum]); %frameNum, (x,y,z), jointNum
    coord_world = load('result_world.txt');
    coord_world = reshape(coord_world,[size(coord_world,1),3,jointNum]); %frameNum, (x,y,z), jointNum

    modelId = 0;
    fid = 1;
    while modelId < modelNum
        
        folderId = 1;
        while folderId <= size(folder_list,2)
            
            annot_path = strcat(db_path,'P',num2str(modelId),'/',folder_list(folderId),'/','joint.txt');
            
            fp_gt = fopen(annot_path);
            tline = fgetl(fp_gt);

            frameNum = str2num(tline);

            frameId = 1;
            tline = fgetl(fp_gt);
            while frameId <= frameNum
    
                fprintf('%d / 76391\n',fid);
                
                img = draw_2Dskeleton_MSRA(tline,frameId,folderId,modelId,coord_pixel(fid,:,:));
                f = draw_3Dskeleton_MSRA(img,coord_world(fid,:,:));

                set(gcf, 'InvertHardCopy', 'off');
                set(gcf,'color','w');
                saveas(f, strcat('./output/',int2str(fid)), 'jpg');
                close(f);

                fid = fid + 1;
                frameId = frameId + 1;
                tline = fgetl(fp_gt);

            end
            fclose(fp_gt);
            folderId = folderId + 1;
        end
        modelId = modelId + 1;
    end

end
