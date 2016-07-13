AddCSLuaFile()

Spaceship = {}
Spaceship.__index = Spaceship

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

	self.galaxyPos = Vector()
	self.gridPos   = Vector()
	self.pocketPos  = Vector()

	self.bb_pos = Vector()
	self.bb_size = Vector()

	self.entities = {}

	self.dirty = {
		galaxyPos = true,
		gridPos = true,
		pocketPos = true,
		pocketSize = true,
		entities = true
	}

	self.id = 0

	return self

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

	self.dirty.entities = true
end

function Spaceship:getAABB()
	return self.bb_pos, self.bb_size
end

function Spaceship:getGridPos( )

	return self.gridPos

end

function Spaceship:getGalaxyPos( )

	if SERVER then
		return self.galaxyPos 
	end

	return self.galaxyPos

end

function Spaceship:getPocketPos()

	return self.pocketPos

end

function Spaceship:getPocketSize()

	return self.pocketSize

end

function Spaceship:getUpdateTable(force)
	if not next(self.dirty) and not force then return end

	local data = { [1] = self.id }

	-- Synchronize galaxy pos
	if self.dirty.galaxyPos or force then
		data[2] = vecToTbl(self:getGalaxyPos())
	end

	-- Synchronize grid pos
	if self.dirty.gridPos or force then
		data[3] = vecToTbl(self:getGridPos())
	end

	-- Synchronize pocket pos
	if self.dirty.pocketPos or force then
		data[4] = vecToTbl(self:getPocketPos())
	end

	-- Synchronize pocket size
	if self.dirty.pocketSize or force then
		data[5] = self:getPocketSize()
	end

	-- Synchronize entities
	if self.dirty.entities or force then
		local e = {}
		for key,ent in pairs(self:getEntities()) do
			if IsValid(ent) then
				e[#e+1] = ent:EntIndex()
			end
		end
		data[6] = e
	end

	self.dirty = {}

	return data
end

function Spaceship:setGridPos( pos )

	assert( pos )
	self.gridPos = pos
	self.dirty.gridPos = true

end

function Spaceship:setGalaxyPos( pos )

	assert( pos )
	self.galaxyPos = pos
	self.dirty.galaxyPos = true

end


function Spaceship:setPocketPos( pos )

	assert( pos )
	self.pocketPos = pos
	self.dirty.pocketPos = true

end

function Spaceship:setPocketSize( size )

	self.pocketSize = size
	self.dirty.pocketSize = true

end

function Spaceship:isIn( pos )

	local p = pos - (self:getPocketPos() or self.bb_pos)
	local s = (self:getPocketSize() or self.bb_size) / 2

	return math.max( math.abs(p.x/s.x), math.abs(p.y/s.y), math.abs(p.z/s.z)  ) <= 1

end


hook.Add( "EntityRemoved", "Grand_Espace - Remove removed props from ships", function(e) 

	if e.parentSpaceship then
		
		print("Removed " .. tostring(e) .. " from spaceship " .. tostring(e.parentSpaceship.id) )
		table.RemoveByValue( e.parentSpaceship.entities, e )
		
		if table.Count( e.parentSpaceship.entities ) == 0 then
			if not e.parentSpaceship.id or e.parentSpaceship.id == 0 then return end
			print( "Removed spaceship: " .. e.parentSpaceship.id )
			World.spaceships[ e.parentSpaceship.id ] = nil
		end
		
	end

end)
