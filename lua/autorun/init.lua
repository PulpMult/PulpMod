if CLIENT then return end

print("----> [Grand espace executed serverside.] <----")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
include("sv_pockets.lua")


--[[
	SV: Function to create a new spaceship easily
]]
local function makeThatASpaceship(ent)

	if not IsValid(ent) then return end

	local e = constraint.GetAllConstrainedEntities(ent)
	
	local spaceship = Spaceship.new()
	spaceship:setEntities(e)
	local a,b = spaceship:getAABB()
	spaceship:setGridPos( Vector() )
	spaceship:setGalaxyPos( Vector() )
	spaceship:setPocketPos(a)
	spaceship:setPocketSize(b)

	World.addSpaceship( spaceship )

end

for k,v in pairs( ents.GetAll() ) do
	if IsValid(v) and v.GetModel and v:GetModel() == "models/props_wasteland/controlroom_chair001a.mdl" then
		makeThatASpaceship(v)
	end
end

