import numpy as np

db = 'ITOP'

if db == 'ICVL':

    def world2pixel(coord,fx,fy,imgWidth,imgHeight):

        pixelX = imgWidth/2 + np.divide(coord[:,:,0],coord[:,:,2]) * fx
        pixelY = imgHeight/2 + np.divide(coord[:,:,1],coord[:,:,2]) * fy
        
        return pixelX, pixelY
else:

    def world2pixel(coord,fx,fy,imgWidth,imgHeight):

        pixelX = imgWidth/2 + np.divide(coord[:,:,0],coord[:,:,2]) * fx
        pixelY = imgHeight/2 - np.divide(coord[:,:,1], coord[:,:,2]) * fy
        
        return pixelX, pixelY


if db == 'ICVL':
    jointNum = 16
    fx = 241.42
    fy = 241.42
    imgWidth = 320
    imgHeight = 240

elif db == 'NYU':
    jointNum = 14
    imgWidth = 640
    imgHeight = 480
    fx = 588.036865
    fy = 587.075073

elif db == 'MSRA':
    jointNum = 21
    imgWidth = 320
    imgHeight = 240
    fx = 241.42
    fy = 241.42

elif db == 'ITOP':
    jointNum = 15
    imgWidth = 320
    imgHeight = 240
    fx = 285.714
    fy = 285.714

labels = np.loadtxt('result.txt')
labels = np.reshape(labels, (-1, jointNum, 3))
labels[:,:,0],labels[:,:,1] = world2pixel(labels,fx,fy,imgWidth,imgHeight)
labels = np.reshape(labels,(-1,jointNum*3))

np.savetxt('result_pixel.txt', labels, fmt='%0.3f')


