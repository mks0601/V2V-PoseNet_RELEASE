%% set parameters
%folderpath = '/home/gyeongsikmoon/workspace/Data/Hand_pose_estimation/ICVL/Training/Depth/';
%filepath = '/home/gyeongsikmoon/workspace/Data/Hand_pose_estimation/ICVL/Training/labels.txt';
%frameNum = 331006;

folderpath = '/home/gyeongsikmoon/workspace/Data/Hand_pose_estimation/ICVL/Testing/Depth/';
filepath = '/home/gyeongsikmoon/workspace/Data/Hand_pose_estimation/ICVL/Testing/test_seq_1.txt';
frameNum = 702;

%folderpath = '/home/gyeongsikmoon/workspace/Data/Hand_pose_estimation/ICVL/Testing/Depth/';
%filepath = '/home/gyeongsikmoon/workspace/Data/Hand_pose_estimation/ICVL/Testing/test_seq_2.txt';
%frameNum = 894;

fp = fopen(filepath);
fid = 1;

tline = fgetl(fp);
while fid <= frameNum
    
    splitted = strsplit(tline);
    img_name = splitted{1};
    
    if exist(strcat(folderpath,img_name), 'file')
        img = imread(strcat(folderpath,img_name));
       
        fp_save = fopen(strcat(folderpath,img_name(1:size(img_name,2)-3),'bin'),'w');
        fwrite(fp_save,permute(img,[2,1,3]),'float');
        fclose(fp_save);
        
        %delete(strcat(folderpath,img_name));
    end

    tline = fgetl(fp);
    fid = fid + 1;
end

fclose(fp);
