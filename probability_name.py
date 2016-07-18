# -*- coding: utf-8 -*-
"""
Created on Mon Jul 18 01:53:13 2016

@author: Nicolas
"""

import random
import json 

f = open("D:/User/Desktop/words3.txt")

memoryLen = 3

nextLetter = {}
blacklist = {
    "\n":True,
    "/": True,
    '"':True,
    "1":True,
    "2":True,
    "3":True,
    "4":True,
    "5":True,
    "6":True,
    "7":True,
    "8":True,
    "9":True,
    "0":True,
    
    
}

lineRead = 1
line = f.readline()
while( line != '' ):
    line = f.readline().split(" ")[0].lower()
    
    last = ""
    for c in line:
    
        if c in blacklist:
            continue
        
        if not last in nextLetter:
            nextLetter[last] = {}
        if not c in nextLetter[last]:
            nextLetter[last][c] = 0
            
        nextLetter[last][c] += 1
        last = last + c
        if len(last) > memoryLen:
            
            last = last[1:]
            
    
    
    lineRead+=1

f.close()

for c in nextLetter:
    m = 0
    for nxt in nextLetter[c]:
        m += nextLetter[c][nxt]
        
    for nxt in nextLetter[c]:
        nextLetter[c][nxt] /= m

nextLetter["BEGIN"] = nextLetter[""]

def generateName( length ):
    last = ""
    name = ""
    for i in range(length):
        r = random.random()
        stop = False
        if last in nextLetter:
            for c in nextLetter[last]:
                if not stop:
                    r = r-nextLetter[last][c]
                    if r < 0:
                        name = name + c
                        last = last + c
                        if len(last) > memoryLen:
                            last = last[1:]
                        stop = True
        else:
            print("Random:s")
            c = chr(random.randint(97,122))
            last = last + c
            if len(last) > memoryLen:
                last = last[1:]
            
                
                
    return name[:1].upper()+name[1:]
    


print(str(lineRead) + " words read.")

f = open("data/jsonnames.txt", "w")
f.write(json.dumps(nextLetter))
f.close()