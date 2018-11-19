import numpy as np

db = 'HANDS2017'

if db == 'ICVL' or db == 'HANDS2017':

    def world2pixel(coord,fx,fy,u0,v0):

        pixelX = u0 + np.divide(coord[:,:,0],coord[:,:,2]) * fx
        pixelY = v0 + np.divide(coord[:,:,1],coord[:,:,2]) * fy
        
        return pixelX, pixelY
else:

    def world2pixel(coord,fx,fy,u0,v0):

        pixelX = u0 + np.divide(coord[:,:,0],coord[:,:,2]) * fx
        pixelY = v0 - np.divide(coord[:,:,1], coord[:,:,2]) * fy
        
        return pixelX, pixelY


if db == 'ICVL':
    jointNum = 16
    fx = 241.42
    fy = 241.42
    u0 = 320/2
    v0 = 240/2

elif db == 'NYU':
    jointNum = 14
    u0 = 640/2
    v0 = 480/2
    fx = 588.036865
    fy = 587.075073

elif db == 'MSRA':
    jointNum = 21
    u0 = 320/2
    v0 = 240/2
    fx = 241.42
    fy = 241.42

elif db == 'HANDS2017':
    jointNum = 21
    u0 = 315.944855
    v0 = 245.287079
    fx = 475.065948
    fy = 475.065857

elif db == 'ITOP':
    jointNum = 15
    u0 = 320/2
    v0 = 240/2
    fx = 285.714
    fy = 285.714

labels = np.loadtxt('result_ensemble.txt')
labels = np.reshape(labels, (-1, jointNum, 3))
labels[:,:,0],labels[:,:,1] = world2pixel(labels,fx,fy,u0,v0)
labels = np.reshape(labels,(-1,jointNum*3))

np.savetxt('result_pixel.txt', labels, fmt='%0.3f')


