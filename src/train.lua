require 'torch'
require 'nn'
require 'optim'
require 'image'
require 'sys'

params, gradParams = model:getParameters()
optimState = {
    learningRate = lr,
    learningRateDecay = 0.0,
    weightDecay = 0.0,
    momentum = 0.0,
    alpha = aph,
    epsilon = eps
}
optimMethod = optim.rmsprop
epoch = 0

function train()
 
    print('==> training start')
   
    tot_error = 0
    iter = 0
    
    model:training()
    for n, sample in DataLoad() do 
        
        inputs = sample[1] --voxelized depth map
        heatmaps = sample[2] --3D heatmap
        
        inputs = inputs:type('torch.CudaTensor')
        collectgarbage() 

        local feval = function(x)
            
            if x ~= params then
                params:copy(x)
            end
            model:zeroGradParameters() 
            outputs = model:forward(inputs)

            err = criterion:forward(outputs,heatmaps)
            dfdo = criterion:backward(outputs,heatmaps)
            
            model:backward(inputs,dfdo)

            tot_error = tot_error + err
            iter = iter + 1

            return err,gradParams

        end
        
        optimMethod(feval, params, optimState)
        
        if iter % loss_display_interval == 0 then
            print("epoch: " .. epoch .. "/" .. epochLimit .. " batch: " ..  n*batchSz .. "/" .. trainSz .. " loss: " .. tot_error/iter)
            tot_error = 0
            iter = 0
        end
    
    end

    epoch = epoch + 1    
  
end



