AddCSLuaFile()

GrandEspace = {}

AddCSLuaFile("sh_world.lua")
AddCSLuaFile("sh_player_functions.lua")
AddCSLuaFile("sh_spaceship.lua")
AddCSLuaFile("sh_write_stars_to_sql.lua")
AddCSLuaFile("sh_map.lua")
AddCSLuaFile("sh_pockets.lua")

include("sh_world.lua")
include("sh_player_functions.lua")
include("sh_spaceship.lua")
include("sh_write_stars_to_sql.lua")
include("sh_map.lua")
include("sh_pockets.lua")

if World then
	World.removeEverything()
end
