GrandEspace.thirdPerson = false

function GrandEspace.setThirdPerson( bool )
	local ship = LocalPlayer():getSpaceship()
	if not ship then return end
	
	GrandEspace.thirdPerson = bool
	
	GrandEspace.refreshEntitiesVisibility( ship )
end

function GrandEspace.getThirdPerson()
	return GrandEspace.thirdPerson or false
end
