if CLIENT then return end

local pocket = {}
--local pockets = {} No need to store the pockets in a array, we will just iterate through the spaceships
-- We cannot store half the things in the array and half the things in the spaceships
-- It's way easier to put in in spaceship because all spaceships will automaticly have a pocket
local function isIn( bbpos, bbsize, pos )
	local p = pos - bbpos
	return math.max( p.x/bbsize.x, p.y/bbsize.y, p.z/bbsize.z  ) <= 1
end

function pocket.moveShipToPocket( ship )

	assert(ship)

	local relative = ship:getAABB()

	
	for k, v in pairs( ship.entities ) do
		local phys = v:GetPhysicsObject()
			
		if IsValid( phys ) then
			phys:EnableMotion( false )
		end
		
		v:SetPos( ship:getPocketPos() + v:GetPos() - relative )
	end
	
	players = player.GetAll()
	
	for k, v in pairs( players ) do
		if IsValid( v ) then
			if ship:isIn( v:GetPos() ) then
				v:SetPos( ship:getPocketPos() + v:GetPos() - relative )
			end
		end
	end

	ship.bb_pos = self:getPocketPos() -- Now it moved...

end

function pocket.allocate( spaceship )

	local pos, size = spaceship:getAABB()
	local offset = 100
	
	size = size + Vector( offset, offset, offset )
	
	local found = false
	local entryPos = VectorRand() * 1000
	
	while not found do
		found = true
		
		if not util.IsInWorld( entryPos - size / 2 ) or not util.IsInWorld( entryPos + size / 2 ) then
			found = false
		end
		
		for k, v in pairs( World.spaceships ) do

			local pocketPos = v:getPocketPos()
			local pocketSize = v:getPocketSize()

			if pocketPos and pocketSize then
				if isIn( pocketPos, pocketSize, entryPos - size / 2 ) or isIn( pocketPos, pocketSize, entryPos + size / 2 ) then
					found = false
					break
				end
			end
		end
		
		entryPos = VectorRand() * 1000
	end
	
	--local p = { pos = pos, size = size, ship = spaceship }
	
	--table.insert( pockets, p )
	
	spaceship:setPocketPos( entryPos )
	spaceship:setPocketSize( entryPos )

	--spaceship.pocket = p

end



GrandEspace.pocket = pocket
