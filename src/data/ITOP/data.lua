require 'hdf5'

--head(1), neck(2), r_shoulder(3), l_shoulder(4), r_elbow(5), l_elbow(6), r_hand(7), l_hand(8)
--torso(9), r_hip(10), l_hip(11), r_knee(12), l_knee(13), r_foot(14), l_foot(15)

db_dir = "/home/mks0601/workspace/Data/Human_pose_estimation/ITOP/" .. db .. "_view/"
result_dir = "/home/mks0601/workspace/Data/Human_pose_estimation/Result_ITOP/"
model_dir = result_dir .. "model/" .. db .. "_view/"
fig_dir = result_dir .. "fig/" .. db .. "_view/"
center_dir = result_dir .. "center/" .. db .. "_view/"

jointNum = 15

imgWidth = 320
imgHeight = 240
cubicSz = 2.0
loss_display_interval = 750

trainSz = 39795
testSz = 10501

d2Input_x = torch.view(torch.range(1,imgWidth),1,imgWidth):repeatTensor(imgHeight,1) - 1
d2Input_y = torch.view(torch.range(1,imgHeight),imgHeight,1):repeatTensor(1,imgWidth) - 1

function pixel2world(x,y,z)

    if type(x) == type(y) and type(y) == type(z) and type(z) == "number" then
        local worldX = (x - 160.0) * z * 0.0035
        local worldY = (120.0 - y) * z * 0.0035
        
        return worldX, worldY

    elseif type(x) == type(y) and type(y) == type(z) and type(z) == "userdata" then
        local worldX = torch.cmul((x - 160.0),z) * 0.0035
        local worldY = torch.cmul((120.0 - y),z) * 0.0035
        
        return worldX, worldY

    end
end

function world2pixel(x,y,z)
    
    if type(x) == type(y) and type(y) == type(z) and type(z) == "number" then
        local pixelX = 160.0 + x / (0.0035 * z)
        local pixelY = 120.0 - y / (0.0035 * z)
        
        return pixelX, pixelY

    elseif type(x) == type(y) and type(y) == type(z) and type(z) == "userdata" then
        local pixelX = 160.0 + torch.cdiv(x, 0.0035*z)
        local pixelY = 120.0 - torch.cdiv(y, 0.0035*z)

        return pixelX, pixelY
    end

end

function load_depthmap(fileId,db_type)
    

    local file = hdf5.open(db_dir .. 'ITOP_' .. db .. '_' .. tostring(db_type) .. '_depth_map.h5','r')
    local depthmap = file:read('data'):partial({fileId,fileId},{1,imgHeight},{1,imgWidth})
    file:close()
    depthmap = torch.view(depthmap,imgHeight,imgWidth)

    return depthmap

end

function load_data(db_type)
    
    local file = hdf5.open(db_dir .. 'ITOP_' .. db .. '_' .. tostring(db_type) .. '_labels.h5','r')
    local jointWorld_original = file:read('real_world_coordinates'):all()
    file:close()
    
    if db_type == "train" then
        frameNum = trainSz
        print("training data loading...")
    elseif db_type == "test" then
        frameNum = testSz
        print("test data loading...")
    end
    
    jointWorld = torch.Tensor(frameNum,jointNum,worldDim):zero()
    refPt = torch.Tensor(frameNum,worldDim)
    name = {}

 	refPt_ = {}
	for line in io.lines(center_dir .. "center_" .. tostring(db_type) .. ".txt") do
		table.insert(refPt_,line)
	end

    frameId = 1
    invalidFrameNum = 1 
    for fid = 1,frameNum do
        
        splitted = str_split(refPt_[fid]," ")
        if splitted[1] == "invalid" then
            invalidFrameNum = invalidFrameNum + 1
            goto invalidFrame
        else
            refPt[frameId][1] = splitted[1]
            refPt[frameId][2] = splitted[2]
            refPt[frameId][3] = splitted[3]
        end

        jointWorld[{{frameId},{}}] = jointWorld_original[fid]
        table.insert(name,fid)
        
        frameId = frameId + 1
        ::invalidFrame::

    end
    
    jointWorld = jointWorld[{{1,-invalidFrameNum},{}}]
    refPt = refPt[{{1,-invalidFrameNum},{}}]
    if db_type == "train" then
        trainSz = trainSz - invalidFrameNum + 1
    elseif db_type == "test" then
        testSz = testSz - invalidFrameNum + 1
    end
    
    return jointWorld, refPt, name

end


function draw_depthmap(name,save_filename,db_type)
    
    fileId = name
    
    local file = hdf5.open(db_dir .. 'ITOP_' .. db .. '_' .. tostring(db_type) .. '_depth_map.h5','r')
    local depthmap = file:read('data'):partial({fileId,fileId},{1,imgHeight},{1,imgWidth})
    file:close()
    depthmap = torch.view(depthmap,imgHeight,imgWidth)

    depthmap = depthmap - torch.min(depthmap)
    depthmap = depthmap/torch.max(depthmap)
    
    local img = torch.Tensor(3,imgHeight,imgWidth):zero()
    img[1] = depthmap*135/255
    img[2] = depthmap*206/255
    img[3] = depthmap*235/255
    
    image.save(save_filename .. ".jpg",img)

end
