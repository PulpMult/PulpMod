hook.Add( "HUDPaint", "Grand_Espace - HUD while in space", function()
	local ply = LocalPlayer()
	if not IsValid( ply ) then return end
	
	local ship = ply:getSpaceship()
	if not ship then return end
	
	for k, v in pairs( World.spaceships ) do
		if ship ~= v then
			local pos = ( ship:getPocketPos() + ( v:getGridPos() - ship:getGridPos() ) ):ToScreen()
			draw.SimpleText( "Spaceship " .. tostring( k ), "TargetID", pos.x + 16, pos.y - 16, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			surface.DrawCircle( pos.x, pos.y, 8, 255, 255, 255, 100 )
		end
	end
end )