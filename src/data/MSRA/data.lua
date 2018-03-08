require 'torch'

--1(wrist)
--2(index_mcp), 3(index_pip), 4(index_dip), 5(index_tip)
--6(middle_mcp), 7(middle_pip), 8(middle_dip), 9(middle_tip)
--10(ring_mcp), 11(ring_pip), 12(ring_dip), 13(ring_tip)
--14(little_mcp), 15(little_pip), 16(little_dip), 17(little_tip)
--18(thumb_mcp), 19(thumb_pip), 20(thumb_dip), 21(thumb_tip)

--training set
--minDepth of joint: 122.01
--maxDepth of joint: 599.05
--avgDepth of joint: 328.93

db_dir = "/home/mks0601/workspace/Data/Hand_pose_estimation/MSRA/cvpr15_MSRAHandGestureDB/"
result_dir = "/home/mks0601/workspace/Data/Hand_pose_estimation/Result_MSRA/"
model_dir = result_dir .. "model/"
fig_dir = result_dir .. "fig/"
center_dir = result_dir .. "center/"

test_model = 3

jointNum = 21
imgWidth = 320
imgHeight = 240
fx = 241.42
fy = 241.42
cubicSz = 200

minDepth = 100
maxDepth = 700
loss_display_interval = 5000

d2Input_x = torch.view(torch.range(1,imgWidth),1,imgWidth):repeatTensor(imgHeight,1) - 1
d2Input_y = torch.view(torch.range(1,imgHeight),imgHeight,1):repeatTensor(1,imgWidth) - 1

folder_list = {"1","2","3","4","5","6","7","8","9","I","IP","L","MP","RP","T","TIP","Y"}
trainSz = 0
testSz = 0
for mid = 0,8 do

    if mid ~= test_model then
        
        for fid = 1,#folder_list do
            annot_dir = db_dir .. "P" .. tostring(mid) .. "/" .. folder_list[fid] .. "/" .. "joint.txt"
            fp = io.open(annot_dir,"r")
            trainSz = trainSz + fp:read()
            fp:close()
        end
    else
        for fid = 1,#folder_list do
            annot_dir = db_dir .. "P" .. tostring(mid) .. "/" .. folder_list[fid] .. "/" .. "joint.txt"
            fp = io.open(annot_dir,"r")
            testSz = testSz + fp:read()
            fp:close()
        end


    end
end

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
    
    local depthimage = torch.Tensor(imgHeight,imgWidth):zero()
    local fp = torch.DiskFile(filename,"r"):binary()
    local image_info = torch.IntTensor(fp:readInt(6))

    local bb = torch.Tensor(4)
    bb[1] = image_info[3] --left
    bb[2] = image_info[4] --top
    bb[3] = image_info[5]-1 --right
    bb[4] = image_info[6]-1 --bottom

    local cropped_depthimage = torch.view(torch.FloatTensor(fp:readFloat(((bb[4]-bb[2]+1)*(bb[3]-bb[1]+1)))),bb[4]-bb[2]+1,bb[3]-bb[1]+1)
    fp:close()
    
    depthimage[{{bb[2],bb[4]},{bb[1],bb[3]}}] = cropped_depthimage
    depthimage[depthimage:eq(0)] = maxDepth

    return depthimage

end


function load_data(db_type)
    
     
    if db_type == "train" then
        print("training data loading...")
        RefPt_ = {}
	 	for line in io.lines(center_dir .. "center_train_" .. tostring(test_model) .. "_refined.txt") do
            table.insert(RefPt_,line)
        end
    elseif db_type == "test" then
        print("testing data loading...")
        RefPt_ = {}
	 	for line in io.lines(center_dir .. "center_test_" .. tostring(test_model) .. "_refined.txt") do
            table.insert(RefPt_,line)
        end
    end
    
    jointWorld = torch.Tensor(trainSz,jointNum,worldDim):zero()
    RefPt = torch.Tensor(trainSz,worldDim):zero()
    name = {}
    
    fileId = 1
    frameId = 1
    for mid = 0,8 do
        if db_type == "train" then
            modelChk = (mid ~= test_model)
        elseif db_type == "test" then
            modelChk = (mid == test_model)
        end

        if modelChk then
            
            for fid = 1,#folder_list do
                
                annot_dir = db_dir .. "P" .. tostring(mid) .. "/" .. folder_list[fid] .. "/" .. "joint.txt"
                lid = 1

                for line in io.lines(annot_dir) do
                    if lid > 1 then
                        
                        splitted = str_split(RefPt_[fileId]," ")
                        if splitted[1] == "invalid" then
                            invalidFrameNum = invalidFrameNum + 1
                            goto INVALIDFRAME
                        else
                            RefPt[frameId][1] = splitted[1]
                            RefPt[frameId][2] = splitted[2]
                            RefPt[frameId][3] = splitted[3]
                        end

                        splitted = str_split(line," ")
                        for jid = 1,jointNum do
                            jointWorld[frameId][jid][1] = splitted[(jid-1)*worldDim+1]
                            jointWorld[frameId][jid][2] = splitted[(jid-1)*worldDim+2]
                            jointWorld[frameId][jid][3] = -splitted[(jid-1)*worldDim+3]
                        end
                        
                        filename = db_dir .. "P" .. tostring(mid) .. "/" .. folder_list[fid] .. "/" .. string.format("%06d",lid-2) .. "_depth.bin"
                        table.insert(name,filename)
                        
                        frameId = frameId + 1
                        ::INVALIDFRAME::
                        fileId = fileId + 1
                    end
                    lid = lid + 1
                end
                
            end
        end
    end

    return jointWorld, RefPt, name

end

