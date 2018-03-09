require 'sys'
require 'ffi'
local Threads = require 'threads'
Threads.serialization('threads.sharedserialize')

function discretize(coord)
   
    --normalized value
    local min_normalized = -1
    local max_normalized = 1
    local str = (max_normalized - min_normalized)/croppedSz
        
    return torch.floor((coord - min_normalized)/str)

end


function scattering(cubic,coord)
    

    local coord = coord:clone()
    coord = torch.view(coord,worldDim,imgHeight*imgWidth)
    
    lower_mask = (coord[1]:ge(1)):cmul(coord[2]:ge(1)):cmul(coord[3]:ge(1))
    if torch.sum(lower_mask) == 0 then
        return cubic
    end
    coord = coord[lower_mask:repeatTensor(worldDim,1)]
    coord = torch.view(coord,worldDim,-1)

    upper_mask = (coord[1]:le(croppedSz)):cmul(coord[2]:le(croppedSz)):cmul(coord[3]:le(croppedSz))
    if torch.sum(upper_mask) == 0 then
        return cubic
    end
    coord = coord[upper_mask:repeatTensor(worldDim,1)]
    coord = torch.view(coord,worldDim,-1)
    
    i = 0
    coord = coord:t()
    coord:apply(function(x)
        i = i + 1
        if i == 1 then
            x_ = x
        elseif i == 2 then
            y_ = x
        elseif i == 3 then
            z_ = x
            cubic[z_][y_][x_] = 1
            i = 0
        end
    end)

    return cubic

end

function warp2continuous(coord,refPt)
    
    local min_normalized = -1
    local max_normalized = 1

    local str = (max_normalized - min_normalized)/croppedSz
    coord = coord * str + min_normalized + (str/2)
    
    coord[{{},{1}}] = coord[{{},{1}}] * (cubicSz/2) + refPt[1]
    coord[{{},{2}}] = coord[{{},{2}}] * (cubicSz/2) + refPt[2]
    coord[{{},{3}}] = coord[{{},{3}}] * (cubicSz/2) + refPt[3]

    return coord

end

function extract_coord_from_output(output,xyzOutput)

    maxVal_per_xy, maxIdx_per_xy = torch.max(output,3)
    maxVal_per_x, maxIdx_per_x = torch.max(maxVal_per_xy,4)
    maxVal, maxIdx = torch.max(maxVal_per_x,5)
    
    maxIdx_x = maxIdx
    maxIdx_y = maxIdx_per_x:gather(5,maxIdx_x)
    maxIdx_z = maxIdx_per_xy:gather(4,maxIdx_y:repeatTensor(1,1,1,1,croppedSz/poolFactor))
    maxIdx_z = maxIdx_z:gather(5,maxIdx_x)
    
    xyzOutput[{{},{},{1}}] = maxIdx_x - 1
    xyzOutput[{{},{},{2}}] = maxIdx_y - 1
    xyzOutput[{{},{},{3}}] = maxIdx_z - 1

    return xyzOutput

end

function generate_cubic_input(cubic,depthimage,refPt,newSz,angle,trans)
    
    --generate three 2D arrays (x_world, y_world, z_world corodinates)
    local coord = torch.Tensor(worldDim,imgHeight,imgWidth):zero()
    coord[1],coord[2] = pixel2world(d2Input_x,d2Input_y,depthimage)
    coord[3] = depthimage:clone()

    --normalize
    coord[1] = (coord[1] - refPt[1])/(cubicSz/2)
    coord[2] = (coord[2] - refPt[2])/(cubicSz/2)
    coord[3] = (coord[3] - refPt[3])/(cubicSz/2)

    --discretize
    coord = discretize(coord)
    coord = coord + (originalSz/2 - croppedSz/2) 

    --resize
    if newSz < 100 then
        coord = coord / originalSz * math.floor(originalSz*newSz/100) + math.floor(originalSz/2 - originalSz/2*newSz/100)
    elseif newSz > 100 then
        coord = coord / originalSz * math.floor(originalSz*newSz/100) - math.floor(originalSz/2*newSz/100 - originalSz/2)
    end
    
    --rotation
    if angle ~= 0 then
        local original_coord = coord:clone()
        original_coord[2] = originalSz-1 - original_coord[2]
        original_coord[1] = original_coord[1] - (originalSz-1)/2
        original_coord[2] = original_coord[2] - (originalSz-1)/2
        coord[1] = original_coord[1]*math.cos(angle) - original_coord[2]*math.sin(angle)
        coord[2] = original_coord[1]*math.sin(angle) + original_coord[2]*math.cos(angle)
        coord[1] = coord[1] + (originalSz-1)/2
        coord[2] = coord[2] + (originalSz-1)/2
        coord[2] = originalSz-1 - coord[2]
    end

    --translation
    coord[1] = coord[1] - (trans[1] - 1)
    coord[2] = coord[2] - (trans[2] - 1)
    coord[3] = coord[3] - (trans[3] - 1)
    
    --scattering
    coord = torch.floor(coord + 0.5) + 1
    cubic = scattering(cubic,coord)
    
    return cubic

end

function generate_heatmap_gt(heatmap,jointWorld,refPt,newSz,angle,trans)
    
    local coord = jointWorld:clone()
    
    --normalize
    coord[{{},{1}}] = (coord[{{},{1}}] - refPt[1])/(cubicSz/2)
    coord[{{},{2}}] = (coord[{{},{2}}] - refPt[2])/(cubicSz/2)
    coord[{{},{3}}] = (coord[{{},{3}}] - refPt[3])/(cubicSz/2)
    
    --discretize
    coord = discretize(coord)
    coord = coord + (originalSz/2 - croppedSz/2)

    --resize
    if newSz < 100 then
        coord = coord / originalSz * math.floor(originalSz*newSz/100) + math.floor(originalSz/2 - originalSz/2*newSz/100)
    elseif newSz > 100 then
        coord = coord / originalSz * math.floor(originalSz*newSz/100) - math.floor(originalSz/2*newSz/100 - originalSz/2)
    end

    --rotation
    if angle ~= 0 then
        local original_coord = coord:clone()
        original_coord[{{},{2}}] = originalSz-1 - original_coord[{{},{2}}]
        original_coord[{{},{1}}] = original_coord[{{},{1}}] - (originalSz-1)/2
        original_coord[{{},{2}}] = original_coord[{{},{2}}] - (originalSz-1)/2
        coord[{{},{1}}] = original_coord[{{},{1}}]*math.cos(angle) - original_coord[{{},{2}}]*math.sin(angle)
        coord[{{},{2}}] = original_coord[{{},{1}}]*math.sin(angle) + original_coord[{{},{2}}]*math.cos(angle)
        coord[{{},{1}}] = coord[{{},{1}}] + (originalSz-1)/2
        coord[{{},{2}}] = coord[{{},{2}}] + (originalSz-1)/2
        coord[{{},{2}}] = originalSz-1 - coord[{{},{2}}]
    end

    --translation
    coord[{{},{1}}] = coord[{{},{1}}] - (trans[1] - 1)
    coord[{{},{2}}] = coord[{{},{2}}] - (trans[2] - 1)
    coord[{{},{3}}] = coord[{{},{3}}] - (trans[3] - 1)
    
    coord = coord/poolFactor
    coord = coord + 1
     
    --heatmap generation
    for jid =1,jointNum do
        heatmap[jid] = torch.exp(-(torch.pow((d3Output_x-coord[jid][1])/std,2)/2 + torch.pow((d3Output_y-coord[jid][2])/std,2)/2 + torch.pow((d3Output_z-coord[jid][3])/std,2)/2))
    end

    return heatmap

end

--multi thread
function init_thread(jointWorld,RefPt,allName,db)
    local manualSeed = 0
    local function init()
        require 'cudnn'
        torch.setdefaulttensortype('torch.FloatTensor')
        dofile("data/" .. db .. "/data.lua")
        dofile("config.lua")
        dofile("util.lua")
    end
    local function main(idx)
        if manualSeed ~= 0 then
            torch.manualSeed(manualSeed + idx)
        end
        torch.setnumthreads(1) 
        _jointWorld = jointWorld
        _RefPt = RefPt
        _allName = allName
    end

    local threads = Threads(nThread, init, main)
    
    return threads

end

--multi thread data loading
--modified from https://github.com/facebook/fb.resnet.torch
function DataLoad()
   
    local perm = torch.randperm(trainSz)
    
    local idx, sample = 1, nil
    local function enqueue()
        while idx <= trainSz and threads:acceptsjob() do
            local indices = perm:narrow(1, idx, math.min(batchSz, trainSz - idx + 1))
            threads:addjob(
                function(indices)

                local sz = indices:size(1)
                inputs = torch.Tensor(sz,inputDim,croppedSz,croppedSz,croppedSz):fill(bkgValue)
                heatmaps = torch.CudaTensor(sz,jointNum,croppedSz/poolFactor,croppedSz/poolFactor,croppedSz/poolFactor):zero()
                for i, idx in ipairs(indices:totable()) do

                    --load each data
                    local jointworld = _jointWorld[idx]:clone()
                    local refPt = _RefPt[idx]:clone()
                    local input_name = _allName[idx]
                    local depthimage = load_depthmap(input_name)
                    
                    --Augmentation
                    --resize
                    local newSz = torch.rand(1)[1] * 40
                    newSz = newSz + 80
                    --rotation
                    local angle = torch.rand(1)[1] * 80/180*math.pi - 40/180*math.pi
                    --translation
                    local trans = torch.Tensor(worldDim)
                    trans[1] = torch.random(1,originalSz-croppedSz+1)
                    trans[2] = torch.random(1,originalSz-croppedSz+1)
                    trans[3] = torch.random(1,originalSz-croppedSz+1)
        
                    --voxelizing
                    inputs[i] = generate_cubic_input(inputs[i][1],depthimage,refPt,newSz,angle,trans)
                    --generate 3D heatmap
                    heatmaps[i] = generate_heatmap_gt(heatmaps[i],jointworld,refPt,newSz,angle,trans)

               end
 
               collectgarbage()
               return {
                   inputs,heatmaps,
               }
            end,
            function(_sample_)
                sample = _sample_
                collectgarbage()
            end,
            indices
         )
         idx = idx + batchSz
      end
   end

   local n = 0
   local function loop()
      enqueue()
      if not threads:hasjob() then
         return nil
      end
      threads:dojob()
      if threads:haserror() then
         threads:synchronize()
      end
      enqueue()
      n = n + 1
      return n, sample
   end

   return loop
end

--multi GPU
function makeDataParallel(model, gpu_table)   

	local dpt = nn.DataParallelTable(1, true):add(model, gpu_table):threads(function() require 'cudnn'
                                    require 'module/normal3DConv'
                                    require 'module/normal3DdeConv'
                                    cudnn.fastest = true
								   cudnn.benchmark = true  end)
	dpt.gradInput = nil
	model = dpt:cuda()

   return model
end

function str_split(inputstr, sep)
    
    if sep == nil then
            sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            t[i] = str
            i = i + 1
    end
    return t

end

