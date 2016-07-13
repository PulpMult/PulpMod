if SERVER then
	AddCSLuaFile()
else
	function buildCPanel_Ships( CPanel )
		CPanel:AddControl("Header", { Text = "Ship's Available", Description = "Select a ship and press the button to join its crew." })
	end
	
	hook.Add( "PopulateToolMenu", "Grand_Espace - Populate Tool Menu", function()
		spawnmenu.AddToolMenuOption( "Utilities", "User", "grandespace_ships", "Go to spaceship", nil, nil, buildCPanel_Ships )
	end )
end