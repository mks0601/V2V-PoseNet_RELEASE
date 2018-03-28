require 'torch'
require 'cunn'
require 'torch'
require 'nn'
require 'cudnn'
require 'module/normal3DConv'
require 'module/normal3DdeConv'

torch.setnumthreads(1)
torch.setdefaulttensortype('torch.FloatTensor')
torch.manualSeed(0)
cutorch.manualSeedAll(0)
math.randomseed(os.time())

dofile "config.lua"

if db == "ICVL" then
    dofile "./data/ICVL/data.lua"
elseif db == "NYU" then
    dofile "./data/NYU/data.lua"
elseif db == "MSRA" then
    dofile "./data/MSRA/data.lua"
elseif db == "side" or db == "top" then
    dofile "./data/ITOP/data.lua"
end

dofile "util.lua"
dofile "model.lua"
dofile "train.lua"
dofile "test.lua"


print("db: " .. db .. " mode: " .. mode)
if mode == "train" then
    
    --resume training with saved model
    if resume == true then
        print("model loading...")
        model = torch.load(model_dir .. model_name)
        dofile "train.lua"
        epoch = resume_epoch
    end
    
    trainJointWorld, trainRefPt, trainName = load_data("train")
    testJointWorld, testRefPt, testName = load_data("test")
    
    --multi thread
    threads = init_thread(trainJointWorld,trainRefPt,trainName,db)
    --multi GPU
    if nGPU > 1 then
        model = makeDataParallel(model, gpu_table)
    end

    while epoch < epochLimit do
        train()
        test(testRefPt, testName)
        
        filename = paths.concat(model_dir, "epoch" .. tostring(epoch), model_name)
        os.execute('mkdir -p ' .. sys.dirname(filename))
        model:clearState()
        if nGPU == 1 then
            torch.save(filename, model)
        else
            torch.save(filename, model:get(1))
        end
        print('==> saved model to '..filename)
        collectgarbage()
    end
end


if mode == "test" then
    
    print("model loading...")
    model = torch.load(model_dir .. model_name)
    
    testJointWorld, testRefPt, testName = load_data("test")
    test(testRefPt, testName)

end

