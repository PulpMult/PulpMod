assert( WireLib )

AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.PrintName = "Piloting Interface"
ENT.Author = "Doctor Who"

ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.WireDebugName = ENT.PrintName

function ENT:Initialize()
	
	if CLIENT then return end
	
	self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:PhysicsInit( SOLID_VPHYSICS )

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:Wake()
	end
	
	WireLib.CreateSpecialInputs( self,
		{ "Forward", "Backward", "Left", "Right", "Up", "Down", "PitchUp", "PitchDown","YawLeft", "YawRight", "RollLeft", "RollRight", "Seat" },
		{ "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "ENTITY" } )
end

function ENT:GetWireInputAsNumber( name )
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
	return end
	
	if not self.parentSpaceship then return end
	if not self.Inputs then return end
	
	local ship = self.parentSpaceship
	
	local gridAngle = ship:getGridAngle()
	
	// This will be later implemented into spaceship class and depend on modules or other shit.
	local speed = 1000
	local degrees = 5
	
	local acceleration = Vector()
	
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
		gridAngle:RotateAroundAxis( gridAngle:Right(), degrees )
	elseif self:GetWireInputAsNumber( "PitchDown" ) > 0 then
		gridAngle:RotateAroundAxis( gridAngle:Right(), -degrees )
	end
	
	if self:GetWireInputAsNumber( "YawRight" ) > 0 then
		gridAngle:RotateAroundAxis( gridAngle:Up(), degrees )
	elseif self:GetWireInputAsNumber( "YawLeft" ) > 0 then
		gridAngle:RotateAroundAxis( gridAngle:Up(), -degrees )
	end
	
	if self:GetWireInputAsNumber( "RollRight" ) > 0 then
		gridAngle:RotateAroundAxis( gridAngle:Forward(), degrees )
	elseif self:GetWireInputAsNumber( "RollLeft" ) > 0 then
		gridAngle:RotateAroundAxis( gridAngle:Forward(), -degrees )
	end
	
	ship:setAcceleration( acceleration, true )
	ship:setGridAngle( gridAngle, true )
	
	if not self.Inputs[ "Seat" ] then return end
	if not self.Inputs[ "Seat" ].value then return end
	
	self.seat = self.Inputs[ "Seat" ].value
	self:SendToClients()
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