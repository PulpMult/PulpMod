if CLIENT then return end

GrandEspace = {}
print("----> [Grand espace executed serverside.] <----")

include("shared.lua")
include("sv_resources.lua")

AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_thirdperson.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")