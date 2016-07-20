AddCSLuaFile()

Spaceship = {}
Spaceship.__index = Spaceship

local Vector2 = GrandEspace.Vector2
local World = GrandEspace.World

-- Utility functions
local function vecToTbl(vec)
	if not vec then return end
	return { vec.x, vec.y, vec.z }
end

local function tblToVec(tbl)
	if not tbl then return end
	return Vector(tbl[1], tbl[2], tbl[3])
end

--[[
	SH: Constructor of Spaceship
]]
function Spaceship.new()

	self = setmetatable( {}, Spaceship)

	self.galaxyPos = Vector2(0, 5e-6)
	self.gridPos   = Vector()
	self.pocketPos  = Vector()
	self.gridAngle = Angle()

	self.originalPos = Vector()

	self.velocity = Vector()
	self.acceleration = Vector()

	self.angularVelocity = Angle()
	self.angularAcceleration = Angle()
	
	self.bb_pos = Vector()
	self.bb_size = Vector()

	self.entities = {}
	self.inHyperSpace = false

	self.lastSimulation = SysTime()
	self.toSync = {}
	self.syncOnForce = { 
		"galaxyPos", "gridPos", "gridAng", "velocity", 
		"acceleration", "pocketPos", "pocketSize",
		"entities", "inHyperSpace",
		"angularVelocity", "angularAcceleration" }

	self.prevGridPos = Vector()
	self.prevGridAngle = Angle()

	self.id = 0

	return self

end

--[[
	SH: Will destroy the spaceship from a contraption without touching it.
]]

function Spaceship:delete()
	if not self.id or self.id == 0 then return end
	GrandEspace.World.spaceships[ self.id ] = nil
	
	local relative = self.bb_pos
	
	for k, v in pairs( self.entities ) do
		if IsValid( v ) then
			v.parentSpaceship = nil
			v:SetPos( self.originalPos + v:GetPos() - relative )
			v:SetNoDraw( false )
		end
	end
	
	local players = player.GetAll()
	
	for k, v in pairs( players ) do
		if IsValid( v ) then
			if v.parentSpaceship and v.parentSpaceship.id and v.parentSpaceship.id == self.id then
				v:assignToSpaceship( nil )
			end
			
			if self:isIn( v:GetPos() ) then
				v:SetPos( self.originalPos + v:GetPos() - relative )
			end
		end
	end
	
	print( "Removed spaceship: " .. self.id )
	hook.Call("GrandEspace - Spaceship removal", {}, self )
	
	net.Start("GrandEspace - Delete Spaceship")
		net.WriteInt(self.id, 32)
	net.Broadcast()

	self = nil
end

function Spaceship:sync(varname)
	self.toSync[varname] = self[varname]
end

--[[
	SH: Accessor functions
]]
function Spaceship:getEntities()

	return self.entities 

end

function Spaceship:setEntities( e )

	assert( e and istable(e) )

	local entities = {}

	-- Calculate the bounding box limits
	local minV = Vector()
	local maxV = Vector()
	
	for k, v in pairs( e ) do
		if IsValid( v ) then
			minV, maxV = v:WorldSpaceAABB()
			break
		end
	end

	for k,v in pairs(e) do

		v.parentSpaceship = self
		entities[#entities+1] = v

		if IsValid(v) then

			local min, max = v:WorldSpaceAABB()
			
			minV.x = math.min( minV.x, min.x )
			minV.y = math.min( minV.y, min.y )
			minV.z = math.min( minV.z, min.z )
			
			maxV.x = math.max( maxV.x, max.x )
			maxV.y = math.max( maxV.y, max.y )
			maxV.z = math.max( maxV.z, max.z )

		end

	end

	self.bb_pos = Vector((minV+maxV)/2)
	self.bb_size = Vector(maxV-minV)
	self.entities = entities

	self:sync("entities")
end

function Spaceship:getAABB()
	return self.bb_pos, self.bb_size
end

function Spaceship:getGridPos( )

	return self.gridPos

end

function Spaceship:getGalaxyPos( )

	return self.galaxyPos

end

function Spaceship:getPocketPos()

	return self.pocketPos

end

function Spaceship:getAcceleration()

	return self.acceleration

end

function Spaceship:getAngularAcceleration()

	return self.angularAcceleration	

end

function Spaceship:getVelocity()

	return self.velocity

end

function Spaceship:getAngularVelocity()

	return self.angularVelocity

end

function Spaceship:getPocketSize()

	return self.pocketSize

end

-- To use for rendering
function Spaceship:getGridPosLerp()

	local lastRenderingTime = World.spaceTime - World.prevSpaceTime
	local dt = SysTime() - World.renderingStart
	local ratio = dt/lastRenderingTime
	if ratio <= 1 then
		return LerpVector(ratio, self.prevGridPos, self.gridPos)
	else
		return self.gridPos
	end
end

function Spaceship:getGridAngleLerp()

	local lastRenderingTime = World.spaceTime - World.prevSpaceTime
	local dt = SysTime() - World.renderingStart
	local ratio = dt/lastRenderingTime
	if ratio <= 1 then
		return LerpAngle(dt/lastRenderingTime, self.prevGridAngle, self.gridAngle)
	else
		return self.gridAngle
	end
	

end

function Spaceship:getUpdateTable(force)
	if force then
		local t = { id = self.id }

		-- Convert vectors to table
		for _,v in pairs(self.syncOnForce) do
			if type(self[v]) == "Vector" then
				t[v] = vecToTbl(self[v])
			else
				t[v] = self[v]
			end
		end

		return t
	elseif next(self.toSync) then
		local t = { id = self.id }

		-- Convert vectors to table
		for k,v in pairs(self.toSync) do
			if type(v) == "Vector" then
				t[k] = vecToTbl(v)
			else
				t[k] = v
			end
		end

		self.toSync = {}
		return t
	end
end

function Spaceship:getOriginalPos()
	return self.originalPos
end

function Spaceship:setGridPos( pos, forceSync )

	assert( pos )
	self.prevGridPos = self.gridPos
	if self.gridPos ~= pos then
		self.gridPos = pos

		if forceSync then
			self:sync("gridPos")
		end
	end


end

function Spaceship:setGalaxyPos( pos, forceSync )

	assert( pos )
	if self.galaxyPos ~= pos then
		self.galaxyPos = pos

		if forceSync then
			self:sync("galaxyPos")
		end
	end

end


function Spaceship:setPocketPos( pos, forceSync )

	assert( pos )
	if self.pocketPos ~= pos then
		self.pocketPos = pos

		if forceSync then
			self:sync("pocketPos")
		end
	end

end

function Spaceship:setAcceleration( a, forceSync )

	assert( a )
	if self.acceleration ~= a then
		self.acceleration = a

		if forceSync then
			self:sync("acceleration")
		end
	end

end

function Spaceship:setAngularAcceleration( a, forceSync )

	assert( a )
	if self.angularAcceleration ~= a then
		self.angularAcceleration = a

		if forceSync then
			self:sync("angularAcceleration")
		end
	end

end

function Spaceship:setVelocity( v, forceSync )

	assert( v )
	if self.velocity ~= v then
		self.velocity = v

		if forceSync then
			self:sync("velocity")
		end
	end

end

function Spaceship:setAngularVelocity( v, forceSync )

	assert( v )
	if self.angularVelocity ~= v then
		self.angularVelocity = v

		if forceSync then
			self:sync("angularVelocity")
		end
	end

end

function Spaceship:setPocketSize( size )

	self.pocketSize = size
	self:sync("pocketSize")

end

function Spaceship:getGridAngle( )

	return self.gridAngle

end

function Spaceship:setGridAngle( angle, forceSync )

	assert( angle )
	self.prevGridAngle = self.gridAngle
	if self.gridAngle ~= angle then
		self.gridAngle = angle

		if forceSync then
			self:sync("gridAngle")
		end
	end

end

function Spaceship:setOriginalPos( pos )
	self.originalPos = pos
end

function Spaceship:setInHyperSpace( bool )

	self.inHyperSpace = bool
	self:sync("inHyperSpace")

end

function Spaceship:isIn( pos, ofShip )

	local p = pos - (self.bb_pos or self:getPocketPos())
	local s = (self:getPocketSize() or self.bb_size) / 2

	if ofShip then
		p = pos - (self.bb_pos or self:getPocketPos())
		s = (self.bb_size or self:getPocketSize()) / 2
	else
		p = pos - (self.bb_pos or self:getPocketPos())
		s = (self:getPocketSize() or self.bb_size) / 2
	end

	return math.max( math.abs(p.x/s.x), math.abs(p.y/s.y), math.abs(p.z/s.z) ) <= 1
end

function Spaceship:isInHyperSpace()

	return self.inHyperSpace

end

hook.Add( "EntityRemoved", "GrandEspace - Remove removed props from ships", function(e) 
	e:SetNoDraw( false )
	
	if e.parentSpaceship and not e:IsPlayer() then
		
		print("Removed " .. tostring(e) .. " from spaceship " .. tostring(e.parentSpaceship.id) )
		table.RemoveByValue( e.parentSpaceship.entities, e )
		
		if table.Count( e.parentSpaceship.entities ) == 0 then
			if not e.parentSpaceship.id or e.parentSpaceship.id == 0 then return end
			print( "Removed spaceship: " .. e.parentSpaceship.id )
			GrandEspace.World.spaceships[ e.parentSpaceship.id ] = nil
			
			hook.Call("GrandEspace - Spaceship removal", {}, e.parentSpaceship)
		end
		
	end

end)

if SERVER then
	util.AddNetworkString("GrandEspace - Delete Spaceship")
end

if CLIENT then
	net.Receive("GrandEspace - Delete Spaceship", function(len)
		local id = net.ReadInt( 32 )
		local spaceship = GrandEspace.World.spaceships[ id ]

		if spaceship then
			for k,v in pairs(spaceship:getEntities()) do
				v.parentSpaceship = nil
				v:SetNoDraw( false )
			end
			
			GrandEspace.World.spaceships[ id ] = nil
		end
	end)
end
