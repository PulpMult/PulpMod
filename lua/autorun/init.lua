if CLIENT then return end

AddCSLuaFile()

function addCSLuaFileRecur(name, len)

	if not len then 
		len = #name + 2
	end

	local files, directories = file.Find(name .. "/*", "GAME");

	for _, f in pairs(files) do


		local name = string.sub(name,len) .. "/" .. f
		if string.sub(name,len) == "" then
			name =  f
		end

		print("Adding ",name)
		AddCSLuaFile(name)
	end

	for _, d in pairs(directories) do
		addCSLuaFileRecur(name .. "/" .. d, len);
	end

end

addCSLuaFileRecur("addons/grand_espace/lua")

print("----> [Grand espace executed serverside.] <----")

--[[
	SV: Function to create a new spaceship easily
]]
local function makeThatASpaceship(ent)

	if not IsValid(ent) then return end

	local e = constraint.GetAllConstrainedEntities(ent)
	local m = 0
	local mp = Vector()
	local radius = 0

	for k,v in pairs(e) do
		local propMass = 1
		local po = v:GetPhysicsObject()
		if IsValid(po) then
			propMass = po:GetMass()
		end

		m = m+propMass
		mp = mp + v:GetPos()*propMass
	end

	mp = mp/m

	for k,v in pairs(e) do
		
		local a,b = v:WorldSpaceAABB()

		local pos = v:GetPos()
		local tr = (pos-mp):Length() + math.max((a-pos):Length(), (b-pos):Length())
		if tr > radius then
			radius = tr
		end

	end
	radius = math.ceil(radius)

	local spaceship = Spaceship.new()
	spaceship:setEntities(e)
	spaceship:setGridPos( Vector() )
	spaceship:setGalaxyPos( Vector() )
	spaceship:setWorldPos(mp)
	World.addSpaceship( spaceship )

end

for k,v in pairs( ents.GetAll() ) do
	if IsValid(v) and v.GetModel and v:GetModel() == "models/props_wasteland/controlroom_chair001a.mdl" then
		makeThatASpaceship(v)
	end
end