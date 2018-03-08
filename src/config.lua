--mode:
--train
--test

--db:
--ICVL
--NYU
--MSRA
--HANDS2017

mode = "train"
db = "ICVL"
resume = false
resume_epoch = 0
model_name = "model.net"
epochLimit = 10

nThread = 6
nGPU = 1
gpu_table = {1,2}
defaultGPU = 1

inputDim = 1
worldDim = 3
distThr = 20
bkgValue = 0

originalSz = 96
croppedSz = 88
poolFactor = 2
std = 1.7

lr = 2.5e-4
aph = 0.99
eps = 1e-8
batchSz = 1

d3Output_x = torch.view(torch.range(1,croppedSz/poolFactor),1,1,croppedSz/poolFactor):repeatTensor(croppedSz/poolFactor,croppedSz/poolFactor,1):type('torch.CudaTensor')
d3Output_y = torch.view(torch.range(1,croppedSz/poolFactor),1,croppedSz/poolFactor,1):repeatTensor(croppedSz/poolFactor,1,croppedSz/poolFactor):type('torch.CudaTensor')
d3Output_z = torch.view(torch.range(1,croppedSz/poolFactor),croppedSz/poolFactor,1,1):repeatTensor(1,croppedSz/poolFactor,croppedSz/poolFactor):type('torch.CudaTensor')
