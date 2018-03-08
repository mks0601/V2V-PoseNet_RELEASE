%train
%dataset_dir = '/home/gyeongsikmoon/workspace/Data/Hand_pose_estimation/NYU/dataset/train/';
%save_dir = '/home/gyeongsikmoon/workspace/Data/Hand_pose_estimation/NYU/dataset/train/parsed/';
%tot_frame_num = 72757;

%test
dataset_dir = '/home/gyeongsikmoon/workspace/Data/Hand_pose_estimation/NYU/dataset/test/';
save_dir = '/home/gyeongsikmoon/workspace/Data/Hand_pose_estimation/NYU/dataset/test/parsed/';
tot_frame_num = 8252;

kinect_index = 1;

for image_index = 1:tot_frame_num
    filename_prefix = sprintf('%d_%07d', kinect_index, image_index);

    if exist([dataset_dir, 'depth_', filename_prefix, '.png'], 'file')

        %% Load and display a depth example
        % The top 8 bits of depth are packed into green and the lower 8 bits into blue.
        depth = imread([dataset_dir, 'depth_', filename_prefix, '.png']);
        depth = uint16(depth(:,:,3)) + bitsll(uint16(depth(:,:,2)), 8);
        
        fp_save = fopen([save_dir, 'depth_', filename_prefix, '.bin'],'w');
        fwrite(fp_save,permute(depth,[2,1,3]),'float');
        fclose(fp_save);

        %delete(strcat(folderpath,img_name));
    end

end
