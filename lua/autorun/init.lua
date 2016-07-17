if CLIENT then return end

print("----> [Grand espace executed serverside.] <----")

include("shared.lua")
include("sv_resources.lua")

AddCSLuaFile("cl_hud.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")