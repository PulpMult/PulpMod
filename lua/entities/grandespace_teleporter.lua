AddCSLuaFile()

ENT.PrintName = "Teleporter"
ENT.Author = "Doctor Who"

ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:Initialize()
	if CLIENT then
		self:SetRenderBounds( Vector( -60, -60, -20 ), Vector( 60, 60, 120 ) )
	return end
	
	self:SetModel( "models/mechanics/wheels/wheel_speed_72.mdl" )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:PhysicsInit( SOLID_VPHYSICS )
	
	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:Wake()
	end
end

function ENT:Think()
	if self.parentSpaceship then
		local ship = self.parentSpaceship
		
		if not ship.telepad then ship.telepad = self end -- I guess I could move it into a hook later on.
	end
end

if CLIENT then
	-- A font that will be used on the control panel
	surface.CreateFont( "PanelFont", { font = "DermaLarge", size = 96, weight = 500 } )
end

-- pos, size, label and onClick
local function drawButton( x, y, w, h, t, f )
	draw.RoundedBox( 0, x, y, w, h, Color( 255, 255, 255 ) )
	draw.SimpleText( t, "PanelFont", x + w/2, y + h/2, Color( 0, 0, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

local function drawCursor()
	local pos, rot = EyePos(), EyeAngles()
	local x, y = 0, 0
	-- Some highly advanced magical equations will go here.
	draw.RoundedBox( 0, x - 4, y - 4, 8, 8, Color( 255, 255, 255 ) )
end

-- I need to draw a quad using render.DrawQuad() and not 3d2d camera because of depth buffer issues.
local function drawPanel( pos, rotation )
	render.SetColorMaterial()
	render.DrawQuadEasy( pos, rotation:Forward(), 40, 40, Color( 0, 0, 0, 255 ), 0 )
	
	-- Now I need to draw the GUI. I wonder how can I make the button without using hacky sphagetti code...
	cam.Start3D2D( pos + rotation:Right() * 20 + rotation:Up() * 20, Angle( rotation.x, rotation.y + 90, rotation.z + 90 ), 0.025 )
		drawButton( 80, 80, 500, 100, "BUTTON", nil )
		drawCursor()
	cam.End3D2D()
end

function ENT:Draw()
	self:DrawModel()
	drawPanel( self:GetPos() + self:GetUp() * 50 + self:GetForward() * 40, self:GetAngles() )
end

function ENT:RetrievePlayer( ply )
	ply:SetPos( self:GetPos() )
end

if SERVER then
	hook.Add( "PostPlayerDeath", "GrandEspace - Handle player's death.", function( ply )
		local ship = ply:getSpaceship()
		
		if ship and IsValid( ship.telepad ) then
			ply.returnShip = ship
		end
	end	)
	
	hook.Add( "PlayerSpawn", "GrandEspace - Handle player's respawn.", function( ply )
		if ply.returnShip and IsValid( ply.returnShip.telepad ) then
			ply.returnShip.telepad:RetrievePlayer( ply )
			ply.returnShip = nil
		end
	end	)
end