TOOL.Category = "PulpMod"
TOOL.Name = "#tool.pm_spawn_tool.name"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.ClientConVar["selected"] = "prop_physics"

AddCSLuaFile()

local categories = {}
local lookupTableName = {}

local function registerEntity( cat, ent, name, icon )

	local t = categories[cat] or {}
	t[#t+1] = {ent, name, icon}
	categories[cat] = t
	lookupTableName[ent] = name

	cleanup.Register( name )
	
	if CLIENT then
		language.Add( "Cleanup_" .. name, ent )
	end

end

registerEntity( "Controllers", "grandespace_warpdrive", "Warp drive", "materials/icon16/control_fastforward.png" )
registerEntity( "Controllers", "grandespace_piloting_interface", "Piloting interface", "materials/icon16/car.png" )
registerEntity( "Controllers", "grandespace_teleporter", "Teleporter", "materials/icon16/text_letter_omega.png" )

registerEntity( "Modules", "grandespace_module_receptacle", "Module holder", "materials/icon16/briefcase.png" )
registerEntity( "Modules", "grandespace_module_warp", "Basic warp module", "materials/icon16/add.png" )
registerEntity( "Modules", "grandespace_module_lifesupport", "Basic life suport module", "materials/icon16/add.png" )
registerEntity( "Modules", "grandespace_module_shield", "Basic shield module", "materials/icon16/add.png" )

if CLIENT then
	language.Add( "tool.pm_spawn_tool.name", "Spawn tool" )
	language.Add( "tool.pm_spawn_tool.desc", "Use it to spawn spaceship components." )
	language.Add( "tool.pm_spawn_tool.0", "Click to spawn the component." )
	
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


		for categoryName, entitiesInCat in pairs( categories ) do

			local catNode = dtree:AddNode( categoryName )
			catNode:SetExpanded(true)

			for _, ent in pairs(entitiesInCat) do
		
				local node = catNode:AddNode( ent[2] )
				node.Icon:SetImage( ent[3] )
				node.path = ent[1]

				print(categoryName,  ent[2])

			end
		end

	end
end

function TOOL:LeftClick(trace)
	if CLIENT then return true end
	if not trace.Entity or trace.Entity:IsPlayer() then return false end

	local selected = self:GetClientInfo( "selected" )
	if not selected then return end
	
	local entity = ents.Create( selected )
	entity:Spawn()
	entity:Activate()
	entity:SetPos( trace.HitPos - trace.HitNormal * entity:OBBMins().z )
	entity:SetAngles( entity:GetAngles() + ( trace.HitNormal:Angle() - Vector(0, 0, 1):Angle() ) )
	
	if entity.Setup then
		entity:Setup( true )
	end

	local ply = self:GetOwner()

	undo.Create( lookupTableName[ selected ] )
		undo.AddEntity( entity )
		undo.SetPlayer( ply )
		undo.SetCustomUndoText("Undone " .. lookupTableName[ selected ] )
		cleanup.Add( ply, entity.PrintName, entity )
	undo.Finish()

	ply:AddCleanup( selected, entity )

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
