AddCSLuaFile()

Spaceship = {}
Spaceship.__index = Spaceship

--[[
	SH: Constructor of Spaceship
]]
function Spaceship.new()

	self = setmetatable( {}, Spaceship)

	self.galaxyPos = Vector()
	self.gridPos   = Vector()
	self.pocketPos  = Vector()
	
	self.originalPos = Vector()

	self.bb_pos = Vector()
	self.bb_size = Vector()

	self.entities = {}

	self.id = 0

	return self

end

--[[
	SH: Will destroy the spaceship from a contraption without touching it.
]]

function Spaceship:delete()
	if not self.id or self.id == 0 then return end
	World.spaceships[ self.id ] = nil
	
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
	
	self = nil
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

function Spaceship:getOriginalPos()
	return self.originalPos
end

function Spaceship:setGridPos( pos )

	assert( pos )
	self.gridPos = pos

end

function Spaceship:setGalaxyPos( pos )

	assert( pos )
	self.galaxyPos = pos

end


function Spaceship:setPocketPos( pos )

	assert( pos )
	self.pocketPos = pos

end

function Spaceship:setPocketSize( size )

	self.pocketSize = size

end

function Spaceship:setOriginalPos( pos )
	self.originalPos = pos
end

function Spaceship:isIn( pos )

	local p = pos - (self.bb_pos or self:getPocketPos())
	local s = (self:getPocketSize() or self.bb_size) / 2

	return math.max( math.abs(p.x/s.x), math.abs(p.y/s.y), math.abs(p.z/s.z) ) <= 1
end


hook.Add( "EntityRemoved", "Grand_Espace - Remove removed props from ships", function(e) 
	e:SetNoDraw( false )
	
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

