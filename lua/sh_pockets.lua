AddCSLuaFile()

-- Doctor, pocketize a spaceship. You will have to fix the obvious issue you will see :P
-- If you could modify the spaceship class so it destroys itself and the pocket, it would be nice!

if CLIENT then 

	hook.Add("PostDrawOpaqueRenderables", "Grand_Espace - Draw pockets", function()

		for id, ship in pairs(World.spaceships) do
			render.DrawWireframeBox(ship:getPocketPos(), Angle(), -ship:getPocketSize()/2, ship:getPocketSize()/2, Color(255,255,255,255), 0 )
			--local p, s = ship:getAABB()
			--render.DrawWireframeBox( p, Angle(), -s/2, s/2, Color(255,255,255,255), 0 )
		end
	end)

else
	local pocket = {}
	--local pockets = {} No need to store the pockets in a array, we will just iterate through the spaceships
	-- We cannot store half the things in the array and half the things in the spaceships
	-- It's way easier to put in in spaceship because all spaceships will automaticly have a pocket


	local function isIn( bbpos, bbsize, pos )
		local p = pos - bbpos
		
		return math.max( p.x/(bbsize.x/2), p.y/(bbsize.y/2), p.z/(bbsize.z/2)  ) <= 1
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

	local function collideWithOtherPockets( entryPos, size )
		for k, v in pairs( World.spaceships ) do

			local pocketPos = v:getPocketPos()
			local pocketSize = v:getPocketSize()

			if pocketPos and pocketSize then
				if isIn( pocketPos, pocketSize, entryPos - size / 2 ) or isIn( pocketPos, pocketSize, entryPos + size / 2 ) then
					return true
				end
			end
		end
		return false

	end

	local function isSomethingThere( entryPos, size )
		local tr = util.TraceHull( {
			start = entryPos,
			endpos = entryPos,
			mins = entryPos - size/2,
			maxs = entryPos + size/2,
			mask = MASK_SHOT_HULL
		} )
		return tr.Hit
	end

	function pocket.allocate( spaceship )

		local pos, size = spaceship:getAABB()
		local offset = 100
		size = size + Vector( offset, offset, offset )
		
		local found = false
		local entryPos = Vector()
		local attempts = 100

		while not found and attempts > 0 do
			--entryPos = VectorRand() * math.pow(2,13)
			entryPos = Vector(math.random(-12000,12000),math.random(-12000,12000),math.random(0,7000))
			found = true
			attempts = attempts - 1
			
			--[[ Not needed, weird behaviours....
			if not util.IsInWorld( entryPos - size / 2 ) or not util.IsInWorld( entryPos + size / 2 ) then
				found = false
				print("Not in the world.", entryPos)
				continue
			end
			]]
			if collideWithOtherPockets( entryPos, size ) then
				found = false
				continue
			end
			if isSomethingThere( entryPos, size ) then
				found = false
				continue
			end
		end

		if not found then
			print("The position could not be found.")
		else
			spaceship:setPocketPos( entryPos )
			spaceship:setPocketSize( size )
		end
	end

	GrandEspace.pocket = pocket
end