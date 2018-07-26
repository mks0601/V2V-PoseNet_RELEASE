function draw_NYU()
 
    
    jointNum =  14;
    annot_path = '/home/gyeongsikmoon/workspace/Data/Hand_pose_estimation/NYU/dataset/test/joint_data.mat';
    gt = load(annot_path);
    gt = gt.joint_xyz(1,:,:,:);
    gt = gt(:,:,[1 4 7 10 13 16 19 22 25 26 28 31 32 33],:); %1, frameNum, jointNum, (x,y,z)
    gt = squeeze(gt);
    frameNum = 8252;
        
    coord_pixel = load('result_pixel.txt');
    coord_pixel = reshape(coord_pixel,[size(coord_pixel,1),3,jointNum]); %frameNum, (x,y,z), jointNum
    coord_world = load('result_world.txt');
    coord_world = reshape(coord_world,[size(coord_world,1),3,jointNum]); %frameNum, (x,y,z), jointNum

    fid = 1;
    while fid <= frameNum
        
        fprintf('%d / %d\n',fid,frameNum);

        img = draw_2Dskeleton_NYU(fid,gt(fid,:,:),coord_pixel(fid,:,:));
        f = draw_3Dskeleton_NYU(img,coord_world(fid,:,:));

        set(gcf, 'InvertHardCopy', 'off');
        set(gcf,'color','w');
        saveas(f, strcat('./output/',int2str(fid)), 'jpg');
        close(f);

        fid = fid + 1;

    end

end
