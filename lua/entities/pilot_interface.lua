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
	if CLIENT then return end
	if not self.parentSpaceship then return end
	if not self.Inputs then return end
	
	local speed = 1000
	local ship = self.parentSpaceship
	
	local a = Vector()
	
	local _, ang = fromWorldToGrid( ship:getGridPos(), ship:getGridAngle(), ship:getPocketPos(), self:GetPos(), self:GetAngles() )
	
	if self:GetWireInput( "Forward" ) > 0 then
		a = a + ang:Forward() * speed
		print( "FLYING" )
	elseif self:GetWireInput( "Backward" ) > 0 then
		a = a + ang:Forward() * -speed
	end
	
	if self:GetWireInput( "Left" ) > 0 then
		a = a + ang:Right() * -speed
	elseif self:GetWireInput( "Right" ) > 0 then
		a = a + ang:Right() * speed
	end
	
	if self:GetWireInput( "Up" ) > 0 then
		a = a + ang:Up() * speed
	elseif self:GetWireInput( "Down" ) > 0 then
		a = a + ang:Up() * -speed
	end
	
	self.parentSpaceship.acceleration = a
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
