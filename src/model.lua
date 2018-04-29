require 'torch'
require 'nn'
require 'cudnn'
require 'module/normal3DConv'
require 'module/normal3DdeConv'

function build_3DBlock(prev_fDim,next_fDim,kernelSz)
    
    local module = nn.Sequential()
 
    module:add(cudnn.normal3DConv(prev_fDim,next_fDim,kernelSz,kernelSz,kernelSz,1,1,1,(kernelSz-1)/2,(kernelSz-1)/2,(kernelSz-1)/2,0,0.001))
    module:add(cudnn.VolumetricBatchNormalization(next_fDim))
    module:add(nn.ReLU(true))

    return module

end

function build_3DResBlock(prev_fDim,next_fDim)
    
    local module = nn.Sequential()

    local concat = nn.ConcatTable()
    local resBranch = nn.Sequential()
    local skipCon = nn.Sequential()

    resBranch:add(cudnn.normal3DConv(prev_fDim,next_fDim,3,3,3,1,1,1,1,1,1,0,0.001))
    resBranch:add(cudnn.VolumetricBatchNormalization(next_fDim))
    resBranch:add(nn.ReLU(true))

    resBranch:add(cudnn.normal3DConv(next_fDim,next_fDim,3,3,3,1,1,1,1,1,1,0,0.001))
    resBranch:add(cudnn.VolumetricBatchNormalization(next_fDim))

    if prev_fDim == next_fDim then
        skipCon = nn.Identity()
    else
        skipCon:add(cudnn.normal3DConv(prev_fDim,next_fDim,1,1,1,1,1,1,0,0,0,0,0.001)):add(cudnn.VolumetricBatchNormalization(next_fDim))
    end
    
    concat:add(resBranch)
    concat:add(skipCon)

    module:add(concat)
    module:add(nn.CAddTable(true))
    module:add(nn.ReLU(true))

    return module

end

function build_3DpoolBlock(poolSz)
    
    local module = nn.VolumetricMaxPooling(poolSz,poolSz,poolSz,poolSz,poolSz,poolSz)
    return module

end

function build_3DupsampleBlock(prev_fDim,next_fDim,kernelSz,str)
    
    local module = nn.Sequential()
    
    module:add(cudnn.normal3DdeConv(prev_fDim,next_fDim,kernelSz,kernelSz,kernelSz,str,str,str,(kernelSz-1)/2,(kernelSz-1)/2,(kernelSz-1)/2,str-1,str-1,str-1,0,0.001))
    module:add(cudnn.VolumetricBatchNormalization(next_fDim))
    module:add(nn.ReLU(true))

    return module

end

function build_model()
	
    local module = nn.Sequential()

    concat1 = nn.ConcatTable()
    branch1 = nn.Sequential()

    branch1:add(build_3DpoolBlock(2))
    branch1:add(build_3DResBlock(32,64))

    concat2 = nn.ConcatTable()
    branch2 = nn.Sequential()

    branch2:add(build_3DpoolBlock(2))
    branch2:add(build_3DResBlock(64,128))
    branch2:add(build_3DResBlock(128,128))
    branch2:add(build_3DResBlock(128,128))
    branch2:add(build_3DupsampleBlock(128,64,2,2))

    concat2:add(branch2)
    concat2:add(build_3DResBlock(64,64))

    branch1:add(concat2)
    branch1:add(nn.CAddTable())
    
    branch1:add(build_3DResBlock(64,64))
    branch1:add(build_3DupsampleBlock(64,32,2,2))

    concat1:add(branch1)
    concat1:add(build_3DResBlock(32,32))

    module:add(concat1)
    module:add(nn.CAddTable())
    
    module:add(build_3DResBlock(32,32))
    module:add(build_3DBlock(32,32,1))
    module:add(build_3DBlock(32,32,1)) 

    return module

end
------------
model = nn.Sequential()

model:add(build_3DBlock(inputDim,16,7))
model:add(build_3DpoolBlock(2))

model:add(build_3DResBlock(16,32))
model:add(build_3DResBlock(32,32))
model:add(build_3DResBlock(32,32))

model:add(build_model())
model:add(cudnn.normal3DConv(32,jointNum,1,1,1,1,1,1,0,0,0,0,0.001))

----------------------

cudnn.convert(model, cudnn)
model:cuda()
criterion = nn.MSECriterion()
criterion:cuda()
cudnn.fastest = true
cudnn.benchmark = true


