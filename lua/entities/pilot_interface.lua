AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.PrintName = "Piloting Interface"
ENT.Author = "Doctor Who"

ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.WireDebugName = ENT.PrintName

function ENT:Initialize()
	assert( WireLib )

	if CLIENT then
		
		return
	end

	self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:PhysicsInit( SOLID_VPHYSICS )

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:Wake()
	end
	
	self.keyInput = { up = false, down = false, left = false, right = false, forward = false, backward = false }
	
	WireLib.CreateSpecialInputs( self, { "Forward", "Backward", "Left", "Right", "Up", "Down", "Seat" }, { "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "ENTITY" } )
	WireLib.CreateSpecialOutputs( self, { "Grid Positon", "Galaxy Position" }, { "VECTOR", "VECTOR" } )
end

local function fromWorldToGrid( gridPos, gridAngle, pocketPos, pos, ang )
	local a,b = LocalToWorld( pos or Vector(), ang or Vector(), gridPos, gridAngle )
	return WorldToLocal( a, b, pocketPos, Angle() )
end

function ENT:GetWireInput( name )
	if not self.Inputs then return 0 end
	if not self.Inputs[ name ] then return 0 end
	return self.Inputs[ name ].value or 0
end

function ENT:Think()
	if CLIENT then
		local ply = LocalPlayer()
	
		if not ply:InVehicle() then
			ply:setThirdPerson( false )
		return end
		
		if ( not IsValid( self.seat ) ) or ( not self.seat:IsVehicle() ) then return end
		if ply:GetVehicle() ~= self.seat then return end
		ply:setThirdPerson( self.seat:GetThirdPersonMode() )
		
		if not self.keyInput then self.keyInput = {} end
		
		self.keyInput[ "up" ] = input.IsButtonDown( KEY_SPACE )
		self.keyInput[ "down" ] = input.IsButtonDown( KEY_LSHIFT )
		
		self.keyInput[ "forward" ] = input.IsButtonDown( KEY_W )
		self.keyInput[ "backward" ] = input.IsButtonDown( KEY_S )
		
		self.keyInput[ "left" ] = input.IsButtonDown( KEY_A )
		self.keyInput[ "right" ] = input.IsButtonDown( KEY_D )
		
		self:SendToServer()
	return end
	
	if not self.parentSpaceship then return end
	if not self.Inputs then return end
	
	local speed = 1000
	local ship = self.parentSpaceship
	
	if not ship then return end
	
	local a = Vector()
	
	local _, ang = fromWorldToGrid( ship:getGridPos(), ship:getGridAngle(), ship:getPocketPos(), self:GetPos(), self:GetAngles() )
	
	if self:GetWireInput( "Forward" ) > 0 or self.keyInput[ "forward" ] then
		a = a + ang:Forward() * speed
	elseif self:GetWireInput( "Backward" ) > 0 or self.keyInput[ "backward" ] then
		a = a + ang:Forward() * -speed
	end
	
	if self:GetWireInput( "Left" ) > 0 or self.keyInput[ "left" ] then
		a = a + ang:Right() * -speed
	elseif self:GetWireInput( "Right" ) > 0 or self.keyInput[ "right" ] then
		a = a + ang:Right() * speed
	end
	
	if self:GetWireInput( "Up" ) > 0 or self.keyInput[ "up" ] then
		a = a + ang:Up() * speed
	elseif self:GetWireInput( "Down" ) > 0 or self.keyInput[ "down" ] then
		a = a + ang:Up() * -speed
	end
	
	self.parentSpaceship:setAcceleration(a, true)	-- true to force synchronization with the clients
	
	if not self.Inputs then return end
	if not self.Inputs[ "Seat" ] then return end
	if not self.Inputs[ "Seat" ].value then return end
	
	if SERVER then
		if not self.seat or self.seat ~= self.Inputs[ "Seat" ].value then
			self.seat = self.Inputs[ "Seat" ].value
			self:SendToClients()
		end
	end
end

function ENT:Draw()
	self:DrawModel()
	
	render.DrawLine( self:GetPos(), self:GetPos() + self:GetForward() * 20, Color( 0, 0, 255, 255 ), true )
	render.DrawLine( self:GetPos(), self:GetPos() + self:GetRight() * 20, Color( 255, 0, 0, 255 ), true )
	render.DrawLine( self:GetPos(), self:GetPos() + self:GetUp() * 20, Color( 0, 255, 0, 255 ), true )
end

function ENT:TriggerInput( iname, value )
	self.Inputs[ iname ].value = value
end

function ENT:SendToClients()
	if CLIENT then return end
	
	net.Start( "PulpMod_PilotInterface_SERVER" )
		net.WriteEntity( self )
		net.WriteEntity( self.seat )
	net.Broadcast()
end

function ENT:SendToServer()
	if SERVER then return end
	net.Start( "PulpMod_PilotInterface_CLIENT" )
		net.WriteEntity( self )
		net.WriteTable( self.keyInput )
	net.SendToServer()
end

if SERVER then
	util.AddNetworkString( "PulpMod_PilotInterface_SERVER" )
	util.AddNetworkString( "PulpMod_PilotInterface_CLIENT" )
	
	net.Receive( "PulpMod_PilotInterface_CLIENT", function( len, ply )
		local self = net.ReadEntity()
		self.keyInput = net.ReadTable()
	end	)
end

if CLIENT then
	net.Receive( "PulpMod_PilotInterface_SERVER", function( len )
		local self = net.ReadEntity()
		self.seat = net.ReadEntity()
	end )
end