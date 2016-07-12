TOOL.Category = "Render"
TOOL.Name = "#tool.pocketizer.name"

function TOOL:LeftClick( trace )
	if CLIENT then return true end

	local ent = trace.Entity
	pocket.allocateContraption( ent )
	
	return true
end

function TOOL:RightClick( trace )
	return false
end