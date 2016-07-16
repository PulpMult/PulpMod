AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.PrintName = "Piloting Interface"
ENT.Author = "Doctor Who"

ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.WireDebugName = ENT.PrintName

cleanup.Register( ENT.PrintName )

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
	
	WireLib.CreateSpecialInputs( self, { "Forward", "Backward", "Left", "Right", "Up", "Down", "Seat" }, { "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "ENTITY" } )
	WireLib.CreateSpecialOutputs( self, { "Grid Positon", "Galaxy Position" }, { "VECTOR", "VECTOR" } )
end

function ENT:Think()
	if not self.parentSpaceship then return end
	if not self.Inputs then return end
	
	local speed = 100
	
	local a = Vector()
	
	if self.Inputs[ "Forward" ].value > 0 then
		a = a + self.parentSpaceship:getForward() * speed
	elseif self.Inputs[ "Backward" ].value > 0 then
		a = a + self.parentSpaceship:getForward() * -speed
	end
	
	if self.Inputs[ "Left" ].value > 0 then
		a = a + self.parentSpaceship:getRight() * -speed
	elseif self.Inputs[ "Right" ].value > 0 then
		a = a + self.parentSpaceship:getRight() * speed
	end
	
	if self.Inputs[ "Up" ].value > 0 then
		a = a + self.parentSpaceship:getUp() * speed
	elseif self.Inputs[ "Down" ].value > 0 then
		a = a + self.parentSpaceship:getUp() * -speed
	end
	
	self.parentSpaceship.velocity = a
end

function ENT:Setup(firstSpawn)
	if firstSpawn then
		//self:SetAngles(self:GetAngles() + Angle(-90, 0, 0))
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
