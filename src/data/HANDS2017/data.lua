require 'torch'

--wrist(1), 
--TMCP(2), IMCP(3), MMCP(4), RMCP(5), PMCP(6)
--TPIP(7), TDIP(8), TTIP(9)
--IPIP(10), IDIP(11), ITIP(12)
--MPIP(13), MDIP(14), MTIP(15)
--RPIP(16), RDIP(17), RTIP(18)
--PPIP(19), PDIP(20), PTIP(21)

--training set
--mindepth of joint: 138.70
--maxdepth of joint: 906.58
--avg depth of joint: 547

db_dir = "/home/gyeongsikmoon/workspace/Data/Hand_pose_estimation/HANDS2017/"
result_dir = "/home/gyeongsikmoon/workspace/Data/Hand_pose_estimation/Result_HANDS2017/"
model_dir = result_dir .. "model/"
fig_dir = result_dir .. "fig/"
center_dir = result_dir .. "center/"

trainSz = 957032
testSz = 295510

jointNum = 21
u0 = 315.944855
v0 = 245.287079
fx = 475.065948
fy = 475.065857
imgWidth = 640
imgHeight = 480
cubicSz = 250
loss_display_interval = 57000
minDepth = 100
maxDepth = 1500

d2Input_x = torch.view(torch.range(1,imgWidth),1,imgWidth):repeatTensor(imgHeight,1) - 1
d2Input_y = torch.view(torch.range(1,imgHeight),imgHeight,1):repeatTensor(1,imgWidth) - 1

function pixel2world(x,y,z)

    if type(x) == type(y) and type(y) == type(z) and type(z) == "number" then
        local worldX = (x - u0) * z / fx
        local worldY = (y - v0) * z / fy
        
        return worldX, worldY

    else
        local worldX = torch.cmul(x - u0,z) / fx
        local worldY = torch.cmul(y - v0,z) / fy
        
        return worldX, worldY

    end
end

function world2pixel(x,y,z)
    
    if type(x) == type(y) and type(y) == type(z) and type(z) == "number" then
        local pixelX = u0 + x / z * fx
        local pixelY = v0 + y / z * fy
        
        return pixelX, pixelY

    else
        local pixelX = u0 + torch.cdiv(x, z) * fx
        local pixelY = v0 + torch.cdiv(y, z) * fy

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
        jointWorld = torch.Tensor(trainSz,jointNum,worldDim):zero()
        RefPt = torch.Tensor(trainSz,worldDim)
        name = {}
        
        RefPt_ = {}
        for line in io.lines(center_dir .. "center_train_refined.txt") do
            table.insert(RefPt_,line)
        end

        fid = 1
        cid = 1
        invalidFrameNum = 0
        for line in  io.lines(db_dir .. "training/Training_Annotation.txt") do
            
            splitted = str_split(RefPt_[cid]," ")
            if splitted[1] == "invalid" then
                invalidFrameNum = invalidFrameNum + 1
                goto INVALID_FRAME_TRAIN
            else
                RefPt[fid][1] = splitted[1]
                RefPt[fid][2] = splitted[2]
                RefPt[fid][3] = splitted[3]
            end

            splitted = str_split(line," ")
            for jid = 1,jointNum do
                jointWorld[fid][jid][1] = splitted[1+(jid-1)*3+1]
                jointWorld[fid][jid][2] = splitted[1+(jid-1)*3+2]
                jointWorld[fid][jid][3] = splitted[1+(jid-1)*3+3]
            end
            
            filename = db_dir .. "training/images/" .. string.sub(splitted[1],1,-5) .. "bin"
            table.insert(name,filename)
            fid = fid + 1

            ::INVALID_FRAME_TRAIN::
            cid = cid + 1
            if cid > trainSz then
                break
            end

        end

        trainSz = trainSz - invalidFrameNum
        jointWorld = jointWorld[{{1,trainSz},{}}]
        RefPt = RefPt[{{1,trainSz},{}}]

        return jointWorld,RefPt,name


    elseif db_type == "test" then
        
        print("testing data loading...")
        RefPt = torch.Tensor(testSz,worldDim)
        name = {}
        
        RefPt_ = {}
        for line in io.lines(center_dir .. "center_test_refined.txt") do
            table.insert(RefPt_,line)
        end

        fid = 1
        for line in io.lines(db_dir .. "frame/BoundingBox.txt") do
            
            splitted = str_split(RefPt_[fid]," ")
            RefPt[fid][1] = splitted[1]
            RefPt[fid][2] = splitted[2]
            RefPt[fid][3] = splitted[3]

            splitted = str_split(line," ")
            local filename =  db_dir .. "frame/images/" .. string.sub(splitted[1],1,-5) .. "bin"
            table.insert(name,filename)
            fid = fid + 1

            if fid > testSz then
                break
            end
        end

        return nil,RefPt,name

    end
    

end

