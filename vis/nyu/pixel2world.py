import numpy as np

db = 'NYU'

if db == 'ICVL' or db == 'HANDS2017':

    def pixel2world(coord,fx,fy,u0,v0):

        worldX = np.multiply(coord[:,:,0] - u0,coord[:,:,2]) / fx
        worldY = np.multiply(coord[:,:,1] - v0,coord[:,:,2]) / fy
        
        return worldX, worldY
else:

    def pixel2world(coord,fx,fy,u0,v0):

        worldX = np.multiply(coord[:,:,0] - u0, coord[:,:,2]) / fx
        worldY = np.multiply(v0 - coord[:,:,1], coord[:,:,2]) / fy
        
        return worldX, worldY


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

labels = np.loadtxt('result_pixel.txt')
labels = np.reshape(labels, (-1, jointNum, 3))
labels[:,:,0],labels[:,:,1] = pixel2world(labels,fx,fy,u0,v0)
labels = np.reshape(labels,(-1,jointNum*3))

np.savetxt('result_world.txt', labels, fmt='%0.3f')


