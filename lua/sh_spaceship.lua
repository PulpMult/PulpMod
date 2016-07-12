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

	minV:Set(self.worldPos)
	maxV:Set(self.worldPos)


	for k,v in pairs(e) do

		v.parentSpaceship = self

		if IsValid(v) then

			local p = v:GetPos()
			local maxSizeBB = (v:OBBMaxs()-v:OBBMins()):Length()

			if minV.x > p.x-maxSizeBB then
				minV.x = p.x-maxSizeBB
			end
			if minV.y > p.y-maxSizeBB then
				minV.y = p.y-maxSizeBB
			end
			if minV.z > p.z-maxSizeBB then
				minV.z = p.z-maxSizeBB
			end
			if maxV.x < p.x+maxSizeBB then
				maxV.x = p.x+maxSizeBB
			end
			if maxV.y < p.y+maxSizeBB then
				maxV.y = p.y+maxSizeBB
			end
			if maxV.z < p.z+maxSizeBB then
				maxV.z = p.z+maxSizeBB
			end

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
		return self.galaxyPos + Vector(math.cos(CurTime()), math.sin(CurTime()),0)
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

