TOOL.Category = "PulpMod"
TOOL.Name = "#tool.pocketizer.name"

if CLIENT then
	language.Add("tool.pocketizer.name", "Pocketizer tool")
	language.Add("tool.pocketizer.desc", "Use it to transport spaceships to pockets.")
	language.Add("tool.pocketizer.0", "Click to transport your spaceship.")
end

function TOOL:LeftClick( trace )
	if CLIENT then return true end

	local ent = trace.Entity
	
	if not IsValid( ent ) then return end

	local e = constraint.GetAllConstrainedEntities( ent )

	local spaceship = Spaceship.new()
	spaceship:setEntities( e )
	spaceship:setGridPos( Vector() )
	spaceship:setGalaxyPos( Vector() )
	spaceship:setWorldPos( Vector() )
	World.addSpaceship( spaceship )
	
	return true
end

function TOOL:RightClick( trace )
	return false
end