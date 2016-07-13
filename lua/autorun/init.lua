if CLIENT then return end

print("----> [Grand espace executed serverside.] <----")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

include("sv_resources.lua")