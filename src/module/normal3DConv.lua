require 'nn'
require 'cudnn'

do

    local VolumetricConvolution, parent = torch.class('cudnn.normal3DConv', 'cudnn.VolumetricConvolution')
    
    -- override the constructor to have the additional range of initialization
    function VolumetricConvolution:__init(nInputPlane, nOutputPlane, kT, kW, kH, dT, dW, dH, padT, padW, padH, mean, std)
        parent.__init(self,nInputPlane, nOutputPlane, kT, kW, kH, dT, dW, dH, padT, padW, padH)
                
        self:reset(mean,std)
    end
    
    -- override the :reset method to use custom weight initialization.        
    function VolumetricConvolution:reset(mean,stdv)
        
        if mean and stdv then
            self.weight:normal(mean,stdv)
            self.bias:zero()
        else
            self.weight:normal(0,1)
            self.bias:zero()
        end
    end

end
