# -*- coding: utf-8 -*-

BASEPATH = "E:/Program Files (x86)/Steam/SteamApps/common/GarrysMod/garrysmod/addons/grand_espace/materials/"

import matplotlib.pyplot as plt
from scipy import misc
import numpy as np

import os

stars = []

f = open(BASEPATH + "milkyway.txt", "r")
line = f.readline()

starX = []
starY = []

maxC = [0,0]
minC = [0,0]

while line != "":
    splot = line.split(",")
    x = float(splot[1])
    y = float(splot[2])
    z = float(splot[3])
    
    if( abs(x) < 10 and abs(y) < 10 and abs(z) < 10):
        stars.append( (x,y,z) )
        starX.append(x)
        starY.append(y)
        
    if( maxC[0] < x):
        maxC[0] = x
    if( maxC[1] < y):
        maxC[1] = y
         
    if( minC[0] > x):
        minC[0] = x
    if( minC[1] > y):
        minC[1] = y
    
        
    line = f.readline()

f.close()
print("Done reading the file.")


#plt.plot(starX, starY,"+")




def resize(x,y,maxV, maxImg):
    x = x*(maxImg/2)/maxV + maxImg/2
    y = y*(maxImg/2)/maxV + maxImg/2
    return x,y
    
def patch(x,y):
    a = [(x,y), (x+1,y), (x-1,y), (x, y+1), (x,y-1)]
    return a    
    
def patch2(x,y):
    a = patch(x,y)
    for k in a:
        a = a + patch(k[0],k[1])
        
    return a


            

#for zoomCoef in range(4):
#    
#    zoom = 100/(2**zoomCoef)    
#    
#    if not os.path.exists(BASEPATH+"zoom"+str(zoom)+"/"):
#        os.makedirs(BASEPATH+"zoom"+str(zoom)+"/")
#        
#        
#    for xmap in range(2**zoomCoef):
#        for ymap in range(2**zoomCoef):
#                
#            img = np.zeros( (1000,1000) )        
#            for i in range(len(starX)):
#                
#                if( starX[i] >= xmap * 10/(2**zoomCoef) and starX[i] <= (xmap+1) * 10/(2**zoomCoef) \
#                and starY[i] >= ymap * 10/(2**zoomCoef) and starY[i] <= (ymap+1) * 10/(2**zoomCoef) )
#                
#                x,y = resize(starX[i], starY[i], 10*zoom/100, 1000)
#                t = [(x,y)]
#                for k in t:
#                    if( k[0] >= 0 and k[0] < 1000 and k[1] >= 0 and k[1] < 1000 ):
#                        img[k[0], k[1]] = 1
#                        
#            misc.imsave(BASEPATH+"zoom"+str(zoom)+"/"+"map" + str(xmap) + "x" + str(ymap) + ".png", img)
#            


def drawCircle( radius, array, x, y ):
    for x2 in range(x-radius, x+radius+1):
        for y2 in range(y-radius, y+radius+1):
            if( ((x2-x)**2+(y2-y)**2)**0.5 <= radius ):
                if(x2 >= 0 and x2 < SIZE_IMAGE and y2 >= 0 and y2 < SIZE_IMAGE):
                    array[x2,y2] = 1
                    
                    
def drawLosange( radius, array, x, y ):
    for y2 in range(y-radius,y+radius+1):
        w = radius-abs(y2-y)
        for x2 in range(x-w, x+w+1):
            if(x2 >= 0 and x2 < SIZE_IMAGE and y2 >= 0 and y2 < SIZE_IMAGE):
                array[x2,y2,0] = 255
                array[x2,y2,1] = 255
                array[x2,y2,2] = 255
                array[x2,y2,3] = 255
                
                
                
SIZE_WINDOW = 10
SIZE_IMAGE  = 1000
MAX_ZOOM_COEF = 3
MAX_ZOOM = 2**MAX_ZOOM_COEF

# Images vierges
image = np.zeros( (SIZE_IMAGE * MAX_ZOOM, SIZE_IMAGE * MAX_ZOOM, 4) )
    
for star in stars:
    xmap = star[0] * MAX_ZOOM * SIZE_IMAGE / SIZE_WINDOW
    ymap = star[1] * MAX_ZOOM * SIZE_IMAGE / SIZE_WINDOW
    
    
    drawLosange( 10, image,int(xmap),int(ymap) )
    #images[xmap][ymap][int(xOntheMap),int(yOntheMap)] = 1
    
print(" - Image arrays filled")

    
#       
print(" - Image arrays saved")
          
        
def a():
    for zoomC in range(0,4):     
          
        zoom = 2**zoomC
        
        c = MAX_ZOOM * SIZE_IMAGE / zoom  
        
        print("Zoom " + str(zoom))
        
        if not os.path.exists(BASEPATH+"zoom"+str(zoom)+"/"):
            os.makedirs(BASEPATH+"zoom"+str(zoom)+"/")
            
        for x in range( zoom ):
            for y in range( zoom ):
                part = image[c*x:c*(x+1), c*y:c*(y+1), :]
                if(part.shape != (1000, 1000, 4)):
                    part = misc.imresize( part, (1000,1000))
                print(part.shape)
                misc.imsave(BASEPATH+"zoom"+str(zoom)+"/"+"map" + str(x) + "x" + str(y) + ".png", part)
                print("Done saving.")
                
       
                
    
                        
        
        
        
    
                
    print("Images done")
a()

        

