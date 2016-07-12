if CLIENT then return end

local pocket = {}
local pockets = {}

function pocket.allocate( spaceship )
	local pos, size = spaceship:getAABB()
	local offset = 100
	
	size = size + Vector( offset, offset, offset )
	
	local found = false
	local entryPos = Vector()
	
	while not found do
		found = true
		
		if util.IsInWorld( entryPos - size / 2 ) or util.IsInWorld( entryPos + size / 2 ) then
			found = false
		end
		
		for k, v in pairs( pockets ) do
			if isIn( v.pos, v.size, entryPos - size / 2 ) or isIn( v.pos, v.size, entryPos + size / 2 ) then
				found = false
			end
		end
		
		entryPos = Vector( math.random( -10000, 10000 ), math.random( -10000, 10000 ), math.random( -10000, 10000 ) )
	end
	
	local p = { pos = pos, size = size, ship = spaceship }
	
	table.insert( pockets, p )
	
	spaceship:setWorldPos( entryPos )
	spaceship.pocket = p
end

local function isIn( bbpos, bbsize, pos )
	local p = pos - bbpos
	return math.max( p.x/bbsize.x, p.y/bbsize.y, p.z/bbsize.z  ) <= 1
end

GrandEspace.pocket = pocket