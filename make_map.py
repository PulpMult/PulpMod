BASEPATH = "materials/"

import matplotlib.pyplot as plt
from scipy import misc
import numpy as np
import os


SIZE_WINDOW = 10
SIZE_IMAGE  = 1024*2
MAX_ZOOM_COEF = 3
MIN_ZOOM_COEF = 0
RADIUS_STARS = 2

stars = []

print("- Reading milkyway.txt")

f = open(BASEPATH + "milkyway.txt", "r")
line = f.readline()

while line != "":
    
    splot = line.split(",")
    
    id = int(splot[0])
    x = float(splot[1])
    y = float(splot[2])
    z = float(splot[3])
    
    if( abs(x) < SIZE_WINDOW and abs(y) < SIZE_WINDOW and abs(z) < SIZE_WINDOW):
        stars.append( (id,x,y) )
        
    line = f.readline()

f.close()

print("Loaded " + str(len(stars)) + " systems.")


def drawLosange( radius, array, x, y ):
    for y2 in range(y-radius,y+radius+1):
        w = radius-abs(y2-y)
        for x2 in range(x-w, x+w+1):
            if(x2 >= 0 and x2 < SIZE_IMAGE and y2 >= 0 and y2 < SIZE_IMAGE):
                array[x2,y2,0] = 255
                array[x2,y2,1] = 255
                array[x2,y2,2] = 255
                array[x2,y2,3] = 255


for zoomCoef in range(MIN_ZOOM_COEF, MAX_ZOOM_COEF+1):
    zoom = 2**zoomCoef
    windowSize = (SIZE_WINDOW*2) / zoom
    starSize = RADIUS_STARS*zoom
    
    
    print("- Creating the pictures for zoom " + str(zoom))

    if not os.path.exists(BASEPATH+"zoom"+str(zoom)+"/"):
            os.makedirs(BASEPATH+"zoom"+str(zoom)+"/")    
    
    for x in range(zoom):
        for y in range(zoom):
            print("  - Creating the picture " + str(x) + "x" + str(y))
            
            image = np.zeros( (SIZE_IMAGE, SIZE_IMAGE, 4) )
            windowPosX = -SIZE_WINDOW + x * (SIZE_WINDOW*2)/zoom
            windowPosY = -SIZE_WINDOW + y * (SIZE_WINDOW*2)/zoom
            
            for star in stars:
                posStarX = star[1]
                posStarY = star[2]
                
                posStarX_onScreen = round( (posStarX - windowPosX) / windowSize * SIZE_IMAGE )
                posStarY_onScreen = round( (posStarY - windowPosY) / windowSize * SIZE_IMAGE )          
                
                if( posStarX_onScreen > -starSize and posStarX_onScreen < SIZE_IMAGE+starSize \
                 and posStarY_onScreen > -starSize and posStarY_onScreen < SIZE_IMAGE+starSize):
                    drawLosange( starSize, image, posStarX_onScreen, posStarY_onScreen)
            
            misc.imsave(BASEPATH+"zoom"+str(zoom)+"/"+"map" + str(y) + "x" + str(x) + ".png", image)
                
    