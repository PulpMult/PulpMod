AddCSLuaFile()

include("sh_player_functions.lua")
GrandEspace = {}

include("sh_world.lua")
include("sh_spaceship.lua")
include("sh_write_stars_to_sql.lua")
include("sh_map.lua")
include("sh_pockets.lua")

if World then
	World.removeEverything()
end
