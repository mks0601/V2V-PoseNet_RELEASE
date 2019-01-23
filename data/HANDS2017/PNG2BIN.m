%% set parameters
folderpath = '/home/gyeongsikmoon/workspace//Data/Hand_pose_estimation/HANDS2017/training/images/';
filepath = '/home/gyeongsikmoon/workspace/Data/Hand_pose_estimation/HANDS2017/training/Training_Annotation.txt';
frameNum = 957032;

%folderpath = '/home/gyeongsikmoon/workspace//Data/Hand_pose_estimation/HANDS2017/frame/images/';
%filepath = '/home/gyeongsikmoon/workspace/Data/Hand_pose_estimation/HANDS2017/frame/BoundingBox.txt';
%frameNum = 295510;

fp = fopen(filepath);
fid = 1;

tline = fgetl(fp);
while fid <= frameNum
    
    disp(fid);
    
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

