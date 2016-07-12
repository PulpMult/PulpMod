if CLIENT then return end

local pocket = {}
local pockets = {}

local function isIn( bbpos, bbsize, pos )
	local p = pos - bbpos
	return math.max( p.x/bbsize.x, p.y/bbsize.y, p.z/bbsize.z  ) <= 1
end

function pocket.allocate( spaceship )
	local pos, size = spaceship:getAABB()
	local offset = 100
	
	size = size + Vector( offset, offset, offset )
	
	local found = false
	local entryPos = Vector()
	
	while not found do
		found = true
		
		if not util.IsInWorld( entryPos - size / 2 ) or not util.IsInWorld( entryPos + size / 2 ) then
			found = false
		end
		
		for k, v in pairs( pockets ) do
			if isIn( v.pos, v.size, entryPos - size / 2 ) or isIn( v.pos, v.size, entryPos + size / 2 ) then
				found = false
			end
		end
		
		entryPos = Vector( math.random( -1000, 1000 ), math.random( -1000, 1000 ), math.random( -1000, 1000 ) )
	end
	
	local p = { pos = pos, size = size, ship = spaceship }
	
	table.insert( pockets, p )
	
	spaceship:setWorldPos( entryPos )
	spaceship.pocket = p
end

GrandEspace.pocket = pocket