require 'torch'
local matio = require 'matio'

--1(pinky tip), 4(pinky mid), 
--7(ring tip), 10(ring mid), 
--13(middle tip), 16(middle mid)
--19(index tip), 22(index mid)
--25(thumb tip), 26(thumb mid), 28(thumb root)
--31(wrist back), 32(wrist), 33(palm)

--training set
--joint minDepth: 349.96
--joint maxDepth: 1078.65
--joint avgDepth: 701.48

db_dir = "/home/gyeongsikmoon/workspace/Data/Hand_pose_estimation/NYU/dataset/"
result_dir = "/home/gyeongsikmoon/workspace/Data/Hand_pose_estimation/Result_NYU/"
model_dir = result_dir .. "model/"
fig_dir = result_dir .. "fig/"
center_dir = result_dir .. "center/"

jointNum = 14
trainSz = 72757
testSz = 8252
imgWidth = 640
imgHeight = 480
fx = 588.036865
fy = 587.075073
cubicSz = 250
minDepth = 300
maxDepth = 1200
loss_display_interval = 5000
eval_joint = torch.LongTensor({1,4,7,10,13,16,19,22,25,26,28,31,32,33})

d2Input_x = torch.view(torch.range(1,imgWidth),1,imgWidth):repeatTensor(imgHeight,1) - 1
d2Input_y = torch.view(torch.range(1,imgHeight),imgHeight,1):repeatTensor(1,imgWidth) - 1

function pixel2world(x,y,z)

    if type(x) == type(y) and type(y) == type(z) and type(z) == "number" then
        local worldX = (x - imgWidth/2) * z / fx
        local worldY = (imgHeight/2 - y) * z / fy
        
        return worldX, worldY

    else
        local worldX = torch.cmul(x - imgWidth/2, z) / fx
        local worldY = torch.cmul(imgHeight/2 - y, z) / fy
        
        return worldX, worldY

    end
end

function world2pixel(x,y,z)
    
    if type(x) == type(y) and type(y) == type(z) and type(z) == "number" then
        local pixelX = fx * x / z + imgWidth/2
        local pixelY = imgHeight/2 - fy * y / z
        
        return pixelX, pixelY

    else
        local pixelX = fx * torch.cdiv(x,z) + imgWidth/2
        local pixelY = imgHeight/2 - fy * torch.cdiv(y,z)

        return pixelX, pixelY
    end

end

function load_depthmap(filename)

    local fp = torch.DiskFile(filename,"r"):binary()
    local depthimage = torch.view(torch.FloatTensor(fp:readFloat(imgWidth*imgHeight)),imgHeight,imgWidth)
    depthimage[depthimage:eq(0)] = maxDepth
    fp:close()
    
    return depthimage

end


function load_data(db_type)
    
    if db_type == "train" then
        
        print("training data loading...")
        
        jointWorld_ = matio.load(db_dir .. 'train/joint_data.mat','joint_xyz')[1] --#1 kinect cemara (front view)
        jointWorld = torch.Tensor(trainSz,jointNum,worldDim):zero()
        RefPt = torch.Tensor(trainSz,worldDim):zero()
        name = {}
     
        RefPt_ = {}
        for line in io.lines(center_dir .. "center_train_refined.txt") do
            table.insert(RefPt_,line)
        end

        jointWorld_ = jointWorld_:index(2,eval_joint)
        fid = 1
        invalidFrameNum = 0
        for fileId = 1,trainSz do
            
            splitted = str_split(RefPt_[fileId]," ")
            if splitted[1] == "invalid" then
                invalidFrameNum = invalidFrameNum + 1
                goto INVALIDFRAME_TRAIN
            else
                RefPt[fid][1] = splitted[1]
                RefPt[fid][2] = splitted[2]
                RefPt[fid][3] = splitted[3]
            end

            local filename = db_dir .. "train/parsed/depth_" .. string.format("1_%07d",fileId) .. ".bin"
            table.insert(name,filename)
            jointWorld[fid] = jointWorld_[fileId]
        
            fid = fid + 1
            ::INVALIDFRAME_TRAIN::
        end
         
        jointWorld = jointWorld[{{1,-invalidFrameNum-1},{},{}}]
        RefPt = RefPt[{{1,-invalidFrameNum-1},{}}]
        trainSz = trainSz - invalidFrameNum

    elseif db_type == "test" then
        
        print("testing data loading...")
        
        jointWorld_ = matio.load(db_dir .. 'test/joint_data.mat','joint_xyz')[1] --#1 kinect cemara (front view)
        jointWorld = torch.Tensor(testSz,jointNum,worldDim):zero()
        RefPt = torch.Tensor(testSz,worldDim):zero()
        name = {}
        
        RefPt_ = {}
        for line in io.lines(center_dir .. "center_test_refined.txt") do
            table.insert(RefPt_,line)
        end

        jointWorld_ = jointWorld_:index(2,eval_joint)
        fid = 1
        invalidFrameNum = 0
        for fileId = 1,testSz do
            
            splitted = str_split(RefPt_[fileId]," ")
            if splitted[1] == "invalid" then
                invalidFrameNum = invalidFrameNum + 1
                goto INVALIDFRAME_TEST
            else
                RefPt[fid][1] = splitted[1]
                RefPt[fid][2] = splitted[2]
                RefPt[fid][3] = splitted[3]
            end

            local filename = db_dir .. "test/parsed/depth_" .. string.format("1_%07d",fileId) .. ".bin"
            table.insert(name,filename)
            jointWorld[fid] = jointWorld_[fileId]
           
            fid = fid + 1
            ::INVALIDFRAME_TEST::
        end
        print("invalid frame in test set: " .. tostring(invalidFrameNum))
        jointWorld = jointWorld[{{1,-invalidFrameNum-1},{},{}}]
        RefPt = RefPt[{{1,-invalidFrameNum-1},{}}]
        testSz = testSz - invalidFrameNum

    end
    
    return jointWorld, RefPt, name

end

