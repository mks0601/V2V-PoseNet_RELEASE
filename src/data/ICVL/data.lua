require 'torch'
require 'os'

--palm(1), 
--thumb root(2), thumb mid(3), thumb tip(4),
--index root(5), index mid(6), index tip(7)
--middle root(8), middle mid(9), middle tip(10)
--ring root(11), ring mid(12), ring tip(13)
--pinky root(14), pinky mid(15), pinky tip(16)

--training set
--minDepth of joint: 157.88
--maxDepth of joint: 570.74
--avgDepth of joint: 345.06

db_dir = "/home/gyeongsikmoon/workspace/Data/Hand_pose_estimation/ICVL/"
result_dir = "/home/gyeongsikmoon/workspace/Data/Hand_pose_estimation/Result_ICVL/"
model_dir = result_dir .. "model/"
fig_dir = result_dir .. "fig/"
center_dir = result_dir .. "center/"

trainSz = 331006
testSz = 1596
jointNum = 16
fx = 241.42
fy = 241.42
imgWidth = 320
imgHeight = 240
cubicSz = 200
minDepth = 100
maxDepth = 600
loss_display_interval = 20000

d2Input_x = torch.view(torch.range(1,imgWidth),1,imgWidth):repeatTensor(imgHeight,1) - 1
d2Input_y = torch.view(torch.range(1,imgHeight),imgHeight,1):repeatTensor(1,imgWidth) - 1

function pixel2world(x,y,z)

    if type(x) == type(y) and type(y) == type(z) and type(z) == "number" then
        local worldX = (x - imgWidth/2) * z / fx
        local worldY = (y - imgHeight/2) * z / fy
        
        return worldX, worldY

    else
        local worldX = torch.cmul(x - imgWidth/2,z) / fx
        local worldY = torch.cmul(y - imgHeight/2,z) / fy
        
        return worldX, worldY

    end
end

function world2pixel(x,y,z)
    
    if type(x) == type(y) and type(y) == type(z) and type(z) == "number" then
        local pixelX = imgWidth/2 + x / z * fx
        local pixelY = imgHeight/2 + y / z * fy
        
        return pixelX, pixelY

    else
        local pixelX = imgWidth/2 + torch.cdiv(x, z) * fx
        local pixelY = imgHeight/2 + torch.cdiv(y, z) * fy

        return pixelX, pixelY
    end

end

function load_depthmap(filename)
    
    local isExist = os.rename(filename,filename) and true or false

    if isExist then
        local fp = torch.DiskFile(filename,"r"):binary()
        local depthimage = torch.view(torch.FloatTensor(fp:readFloat(imgWidth*imgHeight)),imgHeight,imgWidth)
        depthimage[depthimage:eq(0)] = maxDepth
        fp:close()
        return depthimage
    else
        return nil
    end
   
end


function load_data(db_type)
    
    
    if db_type == "train" then
        print("training data loading...")
        
        jointWorld = torch.Tensor(trainSz,jointNum,worldDim):zero()
        RefPt = torch.Tensor(trainSz,worldDim):zero()
        name = {}

        RefPt_ = {}
        for line in io.lines(center_dir .. "center_train_refined.txt") do
            table.insert(RefPt_,line)
        end
        
        fileId = 1
        fid = 1
        invalidFrameNum = 0
        for line in io.lines(db_dir .. "Training/labels.txt") do
         
            splitted = str_split(RefPt_[fileId]," ")
            if splitted[1] == "invalid" then
                invalidFrameNum = invalidFrameNum + 1
                goto INVALIDFRAME_TRAIN
            else
                RefPt[fid][1] = splitted[1]
                RefPt[fid][2] = splitted[2]
                RefPt[fid][3] = splitted[3]
            end
   
            splitted = str_split(line," ")
            for jid = 1,jointNum do
                jointWorld[fid][jid][1] = splitted[1+(jid-1)*3+1] --pixel coord
                jointWorld[fid][jid][2] = splitted[1+(jid-1)*3+2] --pixel coord
                jointWorld[fid][jid][3] = splitted[1+(jid-1)*3+3]
            end
            
            filename = db_dir .. "Training/Depth/" .. string.sub(splitted[1],1,-4) .. "bin"
            table.insert(name,filename)
            
            fid = fid + 1
            ::INVALIDFRAME_TRAIN::

            fileId = fileId + 1
            if fileId > trainSz then
                break
            end
        end
         
        jointWorld[{{},{},{1}}],jointWorld[{{},{},{2}}] = pixel2world(jointWorld[{{},{},{1}}],jointWorld[{{},{},{2}}],jointWorld[{{},{},{3}}])
        
        jointWorld = jointWorld[{{1,-invalidFrameNum-1},{},{}}]
        RefPt = RefPt[{{1,-invalidFrameNum-1},{}}]
        trainSz = trainSz - invalidFrameNum

    elseif db_type == "test" then
        print("testing data loading...")
        
        jointWorld = torch.Tensor(testSz,jointNum,worldDim):zero()
        RefPt = torch.Tensor(testSz,worldDim):zero()
        name = {}

        RefPt_ = {}
        for line in io.lines(center_dir .. "center_test_refined.txt") do
            table.insert(RefPt_,line)
        end

        fileId = 1
        fid = 1
        invalidFrameNum = 0
        for line in io.lines(db_dir .. "Testing/test_seq_1.txt") do

            splitted = str_split(RefPt_[fileId]," ")
            if splitted[1] == "invalid" then
                invalidFrameNum = invalidFrameNum + 1
                goto INVALIDFRAME_TEST1
            else
                RefPt[fid][1] = splitted[1]
                RefPt[fid][2] = splitted[2]
                RefPt[fid][3] = splitted[3]
            end

            splitted = str_split(line," ")
            for jid = 1,jointNum do
                jointWorld[fid][jid][1] = splitted[1+(jid-1)*3+1] --pixel coord
                jointWorld[fid][jid][2] = splitted[1+(jid-1)*3+2] --pixel coord
                jointWorld[fid][jid][3] = splitted[1+(jid-1)*3+3]
            end

            filename =  db_dir .. "Testing/Depth/" .. string.sub(splitted[1],1,-4) .. "bin"
            table.insert(name,filename)
            
            fid = fid + 1
            ::INVALIDFRAME_TEST1::

            fileId = fileId + 1

            if fileId > testSz then
                break
            end
        end


        for line in io.lines(db_dir .. "Testing/test_seq_2.txt") do

            splitted = str_split(RefPt_[fileId]," ")
            if splitted[1] == "invalid" then
                invalidFrameNum = invalidFrameNum + 1
                goto INVALIDFRAME_TEST2
            else
                RefPt[fid][1] = splitted[1]
                RefPt[fid][2] = splitted[2]
                RefPt[fid][3] = splitted[3]
            end

            splitted = str_split(line," ")
            for jid = 1,jointNum do
                jointWorld[fid][jid][1] = splitted[1+(jid-1)*3+1] --pixel coord
                jointWorld[fid][jid][2] = splitted[1+(jid-1)*3+2] --pixel coord
                jointWorld[fid][jid][3] = splitted[1+(jid-1)*3+3]
            end

            filename =  db_dir .. "Testing/Depth/" .. string.sub(splitted[1],1,-4) .. "bin"
            table.insert(name,filename)
            
            fid = fid + 1
            ::INVALIDFRAME_TEST2::
            fileId = fileId + 1

            if fileId > testSz then
                break
            end
        end
        
        jointWorld[{{},{},{1}}],jointWorld[{{},{},{2}}] = pixel2world(jointWorld[{{},{},{1}}],jointWorld[{{},{},{2}}],jointWorld[{{},{},{3}}])

        print("invalid frame in test set: " .. tostring(invalidFrameNum))
        jointWorld = jointWorld[{{1,-invalidFrameNum-1},{},{}}]
        RefPt = RefPt[{{1,-invalidFrameNum-1},{}}]
        testSz = testSz - invalidFrameNum

    end
    
    return jointWorld, RefPt, name

end
