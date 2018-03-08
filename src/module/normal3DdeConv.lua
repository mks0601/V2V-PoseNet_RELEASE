require 'nn'
require 'cudnn'

do

    local VolumetricFullConvolution, parent = torch.class('cudnn.normal3DdeConv', 'cudnn.VolumetricFullConvolution')
    
    -- override the constructor to have the additional range of initialization
    function VolumetricFullConvolution:__init(nInputPlane, nOutputPlane, kT, kW, kH, dT, dW, dH, padT, padW, padH, adjT, adjW, adjH, mean, std)
        parent.__init(self,nInputPlane, nOutputPlane, kT, kW, kH, dT, dW, dH, padT, padW, padH, adjT, adjW, adjH)
                
        self:reset(mean,std)
    end
    
    -- override the :reset method to use custom weight initialization.        
    function VolumetricFullConvolution:reset(mean,stdv)
        
        if mean and stdv then
            self.weight:normal(mean,stdv)
            self.bias:zero()
        else
            self.weight:normal(0,1)
            self.bias:zero()
        end
    end

end
