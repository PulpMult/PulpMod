if SERVER then
	AddCSLuaFile()
	
	concommand.Add( "changeship", function( ply, cmd, args )
		if not args[1] then return end
		
		local ship = World.spaceships[ tonumber( args[1] ) ]
		if not ship then return end
		
		ply:SetPos( ship:getPocketPos() )
		ply:assignToSpaceship( ship )
	end	)
	
	concommand.Add( "returnfromship", function( ply, cmd, args )
		local ship = ply:getSpaceship()
		if not ship then return end
		
		ply:SetPos( ship:getOriginalPos() )
		ply:assignToSpaceship( nil )
	end	)
else
	local scrollPanel
	
	local function refreshShipList()
		if not scrollPanel then return end
		
		scrollPanel:Clear()
		
		for k, v in pairs( World.spaceships ) do
			local n = vgui.Create( "DButton", scrollPanel )
			n:Dock( TOP )
			n:SetText( "Ship " .. tostring( k ) )
			n.DoClick = function() RunConsoleCommand( "changeship", tostring( k ) ) end
		end
	end

	local function buildCPanel_Ships( CPanel )
		CPanel:AddControl("Header", { Text = "Ship's Available", Description = "Select a ship and press the button to join its crew." })
		CPanel:DockPadding( 4, 0, 4, 4 )
		
		scrollPanel = vgui.Create( "DScrollPanel", CPanel )
		scrollPanel:Dock( TOP )
		scrollPanel:DockPadding( 4, 4, 4, 4 )
		scrollPanel:DockMargin( 4, 8, 4, 8 )
		scrollPanel:InvalidateLayout( true )
		scrollPanel:SetHeight( 300 )
		
		scrollPanel.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color( 200, 200, 200, 255 ) )
		end
		
		refreshShipList()
		
		local refresh = vgui.Create( "DButton", CPanel )
		refresh:DockMargin( 4, 8, 4, 8 )
		refresh:Dock( TOP )
		refresh:SetText( "Refresh" )
		refresh.DoClick = refreshShipList
		
		local returnFromShip = vgui.Create( "DButton", CPanel )
		returnFromShip:DockMargin( 4, 8, 4, 8 )
		returnFromShip:Dock( TOP )
		returnFromShip:SetText( "Return from ship" )
		returnFromShip.DoClick = function() RunConsoleCommand( "returnfromship" ) end
	end
	
	hook.Add( "PopulateToolMenu", "Grand_Espace - Populate Tool Menu", function()
		spawnmenu.AddToolMenuOption( "Utilities", "User", "grandespace_ships", "Go to spaceship", nil, nil, buildCPanel_Ships )
	end )
end