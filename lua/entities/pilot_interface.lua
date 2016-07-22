AddCSLuaFile()

DEFINE_BASECLASS("base_wire_entity")

ENT.PrintName = "Piloting Interface"
ENT.Author = "Doctor Who"

ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.WireDebugName = ENT.PrintName

function ENT:Initialize()
	assert( WireLib )
	
	if CLIENT then return end
	
	self:SetModel( "models/maxofs2d/hover_plate.mdl" )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:PhysicsInit( SOLID_VPHYSICS )

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:Wake()
	end
	
	if not self.Inputs then
		WireLib.CreateSpecialInputs( self,
		{ "Forward", "Backward", "Left", "Right", "Up", "Down", "PitchUp", "PitchDown", "YawRight", "YawLeft", "RollLeft", "RollRight", "Seat" },
		{ "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "ENTITY" } )
	end
end

function ENT:GetWireInputAsNumber( name )
	if not self.Inputs[ name ] then return 0 end
	return self.Inputs[ name ].value or 0
end

function ENT:Think()
	self:NextThink( CurTime() )
	if CLIENT then
		local ply = LocalPlayer()
	
		if not ply:InVehicle() then
			GrandEspace.setThirdPerson( false )
		return true end
		
		if ( not IsValid( self.seat ) ) or ( not self.seat:IsVehicle() ) then return true end
		if ply:GetVehicle() ~= self.seat then return true end
		
		GrandEspace.setThirdPerson( self.seat:GetThirdPersonMode() )
	return true end
	
	if not self.parentSpaceship or not self.parentSpaceship.getGridAngle then return true end
	if not self.Inputs then return true end
	
	local ship = self.parentSpaceship
	
	// This will be later implemented into spaceship class and depend on modules or other shit.
	local speed = 1000
	local degrees = 50
	
	local velocity = ship:getVelocity()
	local angVelocity = ship:getAngularVelocity()
	
	local gridAngle = ship:getGridAngle()
	
	local acceleration = Vector()
	local angularAcceleration = Angle()
	
	// Moving
	if self:GetWireInputAsNumber( "Forward" ) > 0 then
		acceleration = acceleration + gridAngle:Forward() * speed
	elseif self:GetWireInputAsNumber( "Backward" ) > 0 then
		acceleration = acceleration - gridAngle:Forward() * speed
	end
	
	if self:GetWireInputAsNumber( "Right" ) > 0 then
		acceleration = acceleration + gridAngle:Right() * speed
	elseif self:GetWireInputAsNumber( "Left" ) > 0 then
		acceleration = acceleration - gridAngle:Right() * speed
	end
	
	if self:GetWireInputAsNumber( "Up" ) > 0 then
		acceleration = acceleration + gridAngle:Up() * speed
	elseif self:GetWireInputAsNumber( "Down" ) > 0 then
		acceleration = acceleration - gridAngle:Up() * speed
	end
	
	// Turning
	if self:GetWireInputAsNumber( "PitchUp" ) > 0 then
		angularAcceleration = angularAcceleration + Angle(-degrees, 0, 0)
	elseif self:GetWireInputAsNumber( "PitchDown" ) > 0 then
		angularAcceleration = angularAcceleration + Angle(degrees, 0, 0)
	end
	
	if self:GetWireInputAsNumber( "YawLeft" ) > 0 then
		angularAcceleration = angularAcceleration + Angle(0, degrees, 0)
	elseif self:GetWireInputAsNumber( "YawRight" ) > 0 then
		angularAcceleration = angularAcceleration + Angle(0, -degrees, 0)
	end
	
	if self:GetWireInputAsNumber( "RollRight" ) > 0 then
		angularAcceleration = angularAcceleration + Angle(0, 0, degrees)
	elseif self:GetWireInputAsNumber( "RollLeft" ) > 0 then
		angularAcceleration = angularAcceleration + Angle(0, 0, -degrees)
	end
	
	// Drag
	if acceleration.x == 0 then
		acceleration.x = -velocity.x
	end
	
	if acceleration.y == 0 then
		acceleration.y = -velocity.y
	end
	
	if acceleration.z == 0 then
		acceleration.z = -velocity.z
	end
	
	if angularAcceleration.x == 0 then
		angularAcceleration.x = -angVelocity.x
	end
	
	if angularAcceleration.y == 0 then
		angularAcceleration.y = -angVelocity.y
	end
	
	if angularAcceleration.z == 0 then
		angularAcceleration.z = -angVelocity.z
	end
	
	ship:setAcceleration( acceleration, true )
	ship:setAngularAcceleration( angularAcceleration, true )
	
	if not self.Inputs[ "Seat" ] then
		if not self.Inputs[ "Seat" ].value then
			self.seat = self.Inputs[ "Seat" ].value
			self:SendToClients()
		end		
	end
	
	return true
end

function ENT:Draw()
	self:DrawModel()
	
	if not self.hoverball then
		self.hoverball = ClientsideModel( "models/maxofs2d/hover_rings.mdl" )
		self.hoverball:SetNoDraw( true )
	end
	
	self.hoverball:SetPos( self:GetPos() + self:GetUp() * 9 )
	self.hoverball:DrawModel()
end

function ENT:TriggerInput( iname, value )
	self.Inputs[ iname ].value = value
end

function ENT:SendToClients()
	if CLIENT then return end
	
	net.Start( "PulpMod_PilotInterface" )
		net.WriteInt( self:EntIndex(), 32 )
		net.WriteInt( self.seat:EntIndex(), 32 )
	net.Broadcast()
end

if CLIENT then
	net.Receive( "PulpMod_PilotInterface", function( len )
		local self = Entity( net.ReadInt( 32 ) )
		self.seat = Entity( net.ReadInt( 32 ) )
	end )
else
	util.AddNetworkString( "PulpMod_PilotInterface" )
end