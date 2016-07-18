hook.Add( "HUDPaint", "GrandEspace - HUD while in space", function()
	local ply = LocalPlayer()
	if not IsValid( ply ) then return end

	local World = GrandEspace.World
	local thirdPerson = LocalPlayer():getThirdPerson()
	
	local ship = ply:getSpaceship()
	if not ship then return end
	
	for k, v in pairs( World.spaceships ) do
		if ship ~= v and ship:getGalaxyPos() == v:getGalaxyPos() then
			local gridPos, pos, dist
			
			if thirdperson then
				gridPos = ship:getGridPos() - EyeAngles():Forward()*1000 - (LocalPlayer():GetShootPos()-ship:getPocketPos())
				dist = v:getGridPos() - gridPos
				pos = ( ship:getPocketPos() + dist ):ToScreen()
			else
				local gridRelativePos = WorldToLocal(v:getGridPos(), v:getGridAngle(), ship:getGridPos(), ship:getGridAngle())
				pos = (ship:getPocketPos() + gridRelativePos):ToScreen()
			end

			dist = v:getGridPos() - ship:getGridPos()
			draw.SimpleText( "Spaceship " .. tostring( k ), "TargetID", pos.x + 16, pos.y - 16, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			draw.SimpleText( "dist: " .. tostring( math.Round( dist:Length() ) ) .. "gu", "TargetID", pos.x + 16, pos.y + 4, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			surface.DrawCircle( pos.x, pos.y, 8, 255, 255, 255, 100 )
		end
	end
end )