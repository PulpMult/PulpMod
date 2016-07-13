TOOL.Category = "PulpMod"
TOOL.Name = "#tool.pocketizer.name"

if CLIENT then
	language.Add("tool.pocketizer.name", "Pocketizer tool")
	language.Add("tool.pocketizer.desc", "Use it to transform your contraption into a spaceship.")
	language.Add("tool.pocketizer.0", "Click on your spaceship.")
end

function TOOL:LeftClick( trace )
	if CLIENT then return true end

	local ent = trace.Entity
	
	if not IsValid( ent ) then return end
	if ent.parentSpaceship then
		print("This is already a spaceship.")
		return
	end

	local e = constraint.GetAllConstrainedEntities( ent )

	local spaceship = Spaceship.new()
	spaceship:setEntities( e )
	spaceship:setGridPos( Vector() )
	spaceship:setGalaxyPos( Vector() )

	GrandEspace.pocket.allocate( spaceship )
	GrandEspace.pocket.moveShipToPocket( spaceship )

	World.addSpaceship( spaceship )
	
	
	return true
end

function TOOL:RightClick( trace )
	return false
end