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
	self.worldPos  = Vector()

	self.bb_pos = Vector()
	self.bb_size = Vector()

	self.entities = {}

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

	-- Calculate the bounding box limits
	local minV = Vector()
	local maxV = Vector()


	if e[1] then
		minV, maxV = e[1]:WorldSpaceAABB()
	end

	for k,v in pairs(e) do

		v.parentSpaceship = self

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

	self.bb_pos = (minV+maxV)/2
	self.bb_size = (maxV-minV)
	self.entities = e

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

function Spaceship:getWorldPos()

	return self.worldPos

end

function Spaceship:setGridPos( pos )

	assert( pos )
	self.gridPos = pos

end

function Spaceship:setGalaxyPos( pos )

	assert( pos )
	self.galaxyPos = pos

end


function Spaceship:setWorldPos( pos )

	assert( pos )
	
	if CLIENT then return end
	
	if not self.entities then return end
	
	self.worldPos = pos

	local relative = self:getAABB()
	
	for k, v in pairs( self.entities ) do
		local phys = v:GetPhysicsObject()
			
		if IsValid( phys ) then
			phys:EnableMotion( false )
		end
		
		v:SetPos( pos + v:GetPos() - relative )
	end
	
	players = player.GetAll()
	
	for k, v in pairs( players ) do
		if IsValid( v ) and v:IsPlayer() then
			if self:isIn( v:GetPos() ) then
				v:SetPos( v:GetPos() - relative )
			end
		end
	end
	
end

function Spaceship:isIn( pos )

	local p = pos - self.bb_pos
	local s = self.bb_size / 2

	return math.max( p.x/s.x, p.y/s.y, p.z/s.z  ) <= 1

end

hook.Add( "EntityRemoved", "Grand_Espace - Remove removed props from ships", function(e) 

	if e.parentSpaceship then
		
		table.RemoveByValue( e.parentSpaceship.entities, e )

	end

end)

