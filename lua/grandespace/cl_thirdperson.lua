GrandEspace.thirdPerson = false

function GrandEspace.setThirdPerson( bool )
	local ship = LocalPlayer():getSpaceship()
	if not ship then return end
	
	GrandEspace.thirdPerson = bool
	
	if bool == true then
		for k, v in pairs( ship.entities ) do
			if IsValid( v ) then v:SetNoDraw( true ) end
		end
	else
		for k, v in pairs( ship.entities ) do
			if IsValid( v ) then v:SetNoDraw( false ) end
		end
	end
	
	--GrandEspace.refreshEntitiesVisibility( ship ) TODO: replace code above with this function.
end

function GrandEspace.getThirdPerson()
	return GrandEspace.thirdPerson or false
end
