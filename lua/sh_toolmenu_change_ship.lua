if SERVER then
	AddCSLuaFile()
else
	function buildCPanel_Ships( Panel )
		-- I shall continue working on it later in the evening.
		
		Panel:Clear()
		
		local label = vgui.Create( "DLabel", Panel )
		
		label:SetText( "This is a label." )
		
		label:Dock( TOP )
	end
	
	hook.Add( "PopulateToolMenu", "Grand_Espace - Populate Tool Menu", function()
		spawnmenu.AddToolMenuOption( "Utilities", "User", "grandespace_ships", "Go to spaceship", nil, nil, buildCPanel_Ships )
	end )
end