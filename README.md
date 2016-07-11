PulpMod
===================
Table of content
-------------
[TOC]

Introduction
-------------

In this file I will explain what **PulpMod** is, what are the tasks we need to realise and what has been done.


What is it ?
-------------



**PulpMod** is a space gamemode for Garry's mod. It is inspired by *Final Frontier*[^ff], *Spacebuild* and *Pulsar*[^pul]. In a nutshell, it is a cooperative space simulator. You make your ship, you put it into space and you live your life in space. You can do several things up there such as exploring, mining or fighting other ships. The goal of this gamemode is to make the players feel like they are evolving in a huge space.

  [^pul]: *Pulsar* official site: http://www.pulsarthegame.com/.
  
  [^ff]: *Final Frontier* post: https://facepunch.com/showthread.php?t=1277720.
  


#### Space simulation
To reproduce the feeling of vastness of space, we obviously cannot only use the space available *Garry's Mod*'s maps. Moreover, flying several spaceships around the map tend to make the server lag or crash (collisions!). 

To solve this problem we have to implement a *spaceship simulator*. The spaceships will be frozen and placed in an aera of the map where the ship's crew will only be able to see the ship. These aeras will be called *blocks*. Anywhere else outside the block will appear as a black void. 

To create the illusion of being in a universe with other ships, small reproductions of the other ships must be rendered next to the borders of the block. It will give the impression that they are far away. In addition, stars will be handled the same way with small lights.

> **Note:**
>We might want to disable the noclip inside of the blocks to add more realism (and prevent people from exiting the blocks).

##### The grid
The other ships will only be drawn within a certain range. The ship will only be able to interact (initiate combat) with them in this range. This aera is called the **grid**. 

##### The galaxy
All the players will have a map of the **galaxy** so they can see where they are. It is much bigger than the grid, and the only viable way to travel from a point to another in the galaxy is to warp. 


> **Note:**
> The position of the block of the ship is called the **realPos**.
> The ship's position in the galaxy is called the **galaxyPos**.
> The ship's position in his grid is called the **gridPos**.
> Thus the position of all ships is determined by all these 3 vectors.

#### Life support
Life support will not be a priority in the early stages of the developpement. It will consists of modules that you add to your spaceship, that requires resources. It must be simple to add/replace a module and there will not have any kind of linking. (unlike *Spacebuild*)

#### Planet exploration/Teleportation
To fully exploit the *spacebuild* maps that have already been created, we will have to implement a way of teleporting to other planets when the ships are close to them. We will start simple with a console like *Final Frontier*. We might adapt the stargate mod (*CAP*) to work with our mod: for instance, teleportation ring will only work with a short range around the ship.


#### Combat / Guns
A combat system will have to be implemented. Each ship will have a health (hull) bar. If it drops to 0, the ship will be destroyed and the crew will be teleported to the spawn planet.

Shields will be added for protection against energy consumption and might be required to warp.

Weapons will be modules (like life suport), they will not have to aim for the target. A radar console will let the crew decide what weapon they should use and on which ship. (dead angles for the weapons might be added later)
 
#### Mining
Mining will consist of getting close of a big floating rock, extract the ore with a module and then use the ore to make more efficient generators/weapons.

What should be done ?
-------------
In this part, I will try to list every task we will have to achieve to make the mod.


| Task     | Member in charge | 
| :------- | ----: |
| Create a way of handling spaceships | Pulp |
| Create bubbles that will contain the props of the ships | Doctor |

Public discussion:
-------------
>**Recommendation:**
> Feel free to edit this file to add suggestions or ideas but do not forget to add your name to the modification.

#### Space McDonalds:
- (This is an example) I believe adding a space mcdonald where ships can go and grab food for their crew is a good idea. What do you think of that guys ? [FatPulp]

- This is not a good idea. [RationnalPulp]

- Fuck you. [GrumpyPulp]
