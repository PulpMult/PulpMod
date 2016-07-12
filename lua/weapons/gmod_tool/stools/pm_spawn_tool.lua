TOOL.Category = "PulpMod"
TOOL.Name = "#tool.pm_spawn_tool.name"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.ClientConVar["selected"] = "prop_physics"

AddCSLuaFile()

local warpdrives = { warpdrive_small = "Warp Drive (small)" }

if CLIENT then
	language.Add("tool.pm_spawn_tool.name", "Spawn tool")
	language.Add("tool.pm_spawn_tool.desc", "Use it to spawn spaceship components.")
	language.Add("tool.pm_spawn_tool.0", "Click to spawn the component.")

	local function BuildSubNode(tree, name, arr, icon)
		local sub = tree:AddNode(name)
		sub:SetExpanded(true)

		for k,v in pairs(arr) do
			local node = sub:AddNode(v)
			node.Icon:SetImage(icon)
			node.path = k
		end
	end
	
	function TOOL.BuildCPanel(CPanel)
		SUPERPANEL = CPanel
		
		CPanel:AddControl("Header", { Text = "Spawn tool", Description = "Left click to spawn a spaceship component" })
		
		local dtree = vgui.Create("DTree", SUPERPANEL)
		CPanel:AddPanel(dtree)
		dtree.OnNodeSelected = function(self, node)
			if node.path then
				LocalPlayer():ConCommand("pm_spawn_tool_selected " .. node.path)
			end
		end

		local sx, sy = CPanel:GetSize()
		local xmargin = 15
		
		dtree:SetPos(xmargin, 60)
		dtree:SetSize(sx - 2*xmargin, 240)
		
		-- Append components
		BuildSubNode(dtree, "Warp Drives", warpdrives, "materials/icon16/control_fastforward.png")
	end
end

function TOOL:LeftClick(trace)
	if trace.Entity && trace.Entity:IsPlayer() then return false end
	
	if CLIENT then return true end

	local selected = self:GetClientInfo("selected")
	if not selected then return end
		
	local entity = ents.Create(selected)
	entity:Spawn()
	entity:Activate()
	entity:SetPos(trace.HitPos - trace.HitNormal*entity:OBBMins().z)
	entity:SetAngles(entity:GetAngles() + (trace.HitNormal:Angle() - Vector(0, 0, 1):Angle()))
	
	local ply = self:GetOwner()

	undo.Create("SpaceShip Component")
		undo.AddEntity(entity)
		undo.SetPlayer(ply)
		undo.SetCustomUndoText("Undone " .. (warpdrives[selected]))
	undo.Finish()

	ply:AddCleanup("SpaceShip Component", entity)

	return true
end

function TOOL:RightClick(trace)

end

function TOOL:Think()

end

function TOOL:Reload(trace)

end

function TOOL:FreezeMovement()

end

function TOOL:Holster()

end
