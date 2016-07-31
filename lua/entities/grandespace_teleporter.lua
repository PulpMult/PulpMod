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

-- Taken from https://maurits.tv/data/garrysmod/wiki/wiki.garrysmod.com/indexedb0.html
local function worldToScreen(vWorldPos,vPos,vScale,aRot)
	local vWorldPos=vWorldPos-vPos
	vWorldPos:Rotate(Angle(0,-aRot.y,0))
	vWorldPos:Rotate(Angle(-aRot.p,0,0))
	vWorldPos:Rotate(Angle(0,0,-aRot.r))
	return vWorldPos.x/vScale,(-vWorldPos.y)/vScale
end

local function getCursorPos( camPos, camRot, rot )
	local hitPos = util.IntersectRayWithPlane( EyePos(), EyeVector(), camPos, rot:Forward() )
	if not hitPos then return end
	
	local x, y = worldToScreen( hitPos, camPos, 0.025, camRot )
	return { x = x, y = y }
end

-- pos, size, label, onClick and cursor position
local function drawButton( x, y, w, h, t, f, c )
	local hover = false
	
	if c and c.x > x and c.y > y and c.x < x + w and c.y < y + h then
		hover = true
	end

	if hover then
		draw.RoundedBox( 0, x, y, w, h, Color( 0, 149, 255 ) )
		draw.SimpleText( t, "PanelFont", x + w/2, y + h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	else
		draw.RoundedBox( 0, x, y, w, h, Color( 255, 255, 255 ) )
		draw.SimpleText( t, "PanelFont", x + w/2, y + h/2, Color( 0, 0, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
end

-- I need to draw a quad using render.DrawQuad() and not 3d2d camera because of depth buffer issues.
local function drawPanel( pos, rotation )
	render.SetColorMaterial()
	render.DrawQuadEasy( pos, rotation:Forward(), 40, 40, Color( 0, 0, 0, 255 ), 0 )
	
	local camPos = pos + rotation:Right() * 20 + rotation:Up() * 20
	local camRot = Angle( rotation.x, rotation.y + 90, rotation.z + 90 )
	cam.Start3D2D( camPos, camRot, 0.025 )
		local cpos = getCursorPos( camPos, camRot, rotation )
		
		drawButton( 80, 80, 500, 100, "BUTTON", nil, cpos )
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