TOOL.Category = "PulpMod"
TOOL.Name = "#tool.pm_spawn_tool.name"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.ClientConVar["selected"] = "prop_physics"

AddCSLuaFile()

local entities = {}
local nodes = {}
local icons = {}

local function registerEntity( cat, ent, name, icon )
	entities[ ent ] = name
	nodes[ ent ] = cat
	icons[ ent ] = icon
end

registerEntity( "Controllers", "warpdrive_small", "Warp drive", "materials/icon16/control_fastforward.png" )
registerEntity( "Controllers", "pilot_interface", "Piloting interface", "materials/icon16/car.png" )
registerEntity( "Modules", "grandespace_module_warp", "Module LV0: Warp", "materials/icon16/add.png" )
registerEntity( "Modules", "grandespace_module_receptacle", "Module holder", "materials/icon16/briefcase.png" )


for k, v in pairs( entities ) do
	cleanup.Register( k )
	
	if CLIENT then
		language.Add( "Cleanup_" .. k, v )
	end
end

if CLIENT then
	language.Add( "tool.pm_spawn_tool.name", "Spawn tool" )
	language.Add( "tool.pm_spawn_tool.desc", "Use it to spawn spaceship components." )
	language.Add( "tool.pm_spawn_tool.0", "Click to spawn the component." )

	local function addComponent( tree, ent )
		local sub = nodes[ ent ]
		sub:SetExpanded(true)

		local node = sub:AddNode( entities[ ent ] )
		node.Icon:SetImage( icons[ ent ] )
		node.path = ent
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

		for k, v in pairs( nodes ) do
			nodes[ k ] = dtree:AddNode( v )
		end
		
		local sx, sy = CPanel:GetSize()
		local xmargin = 15
		
		dtree:SetPos(xmargin, 60)
		dtree:SetSize(sx - 2*xmargin, 240)
		
		for k, v in pairs( entities ) do
			addComponent( dtree, k )
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

	undo.Create( entities[ selected ] )
		undo.AddEntity( entity )
		undo.SetPlayer( ply )
		undo.SetCustomUndoText("Undone " .. entities[ selected ] )
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
