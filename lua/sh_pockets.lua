AddCSLuaFile()

if CLIENT then 

	local function fromGridToWorld( myShip, pos, ang )

		local a,b = WorldToLocal( pos or Vector(), ang or Vector(), myShip:getGridPos(), myShip:getGridAngle() )
		return LocalToWorld( a, b, myShip:getPocketPos(), Angle() )
	end
	



	hook.Add("PostDrawTranslucentRenderables", "Grand_Espace - Render other ships", function()

		local ship = LocalPlayer():getSpaceship()
		if not ship then return end

		local gridPos = ship:getGridPos()
		local gridAng = ship:getGridAngle()

		local pocketPos = ship:getPocketPos()
		local pocketSize = ship:getPocketSize()
		local shootPos = LocalPlayer():GetShootPos()

		for k,v in pairs(World.spaceships) do

			if ship ~= v and ship:getGalaxyPos() == v:getGalaxyPos() then
			
				for _,ent in pairs(v.entities) do


					-- TT = TargetShip
					-- S  = Our ship

					local pos_TT, ang_TT = WorldToLocal( ent:GetPos(), ent:GetAngles(), v:getPocketPos(), Angle() )
					local pos_grid,  ang_grid  = LocalToWorld( pos_TT, ang_TT, v:getGridPos(), v:getGridAngle())

					local targetPos, targetAngle = fromGridToWorld( ship, pos_grid, ang_grid )

					local boxPos, norm, fraction = util.IntersectRayWithOBB( targetPos, shootPos-targetPos, pocketPos, Angle(), -pocketSize, pocketSize)


					if boxPos then

						local scaleDist = boxPos:Distance(shootPos)/targetPos:Distance(shootPos)
						

						local p = ent:GetPos()
						local a = ent:GetAngles()
						local scale = ent:GetModelScale()

	
						ent:SetPos(boxPos)
						ent:SetAngles(targetAngle)
						ent:SetModelScale(scale * scaleDist)

						ent:DrawModel()

						ent:SetModelScale(scale)
						ent:SetAngles(a)
						ent:SetPos(p)

					end


				end

			end

		end

	end)


	local mat = Material("materials/stars2.png")

	hook.Add("PostDrawTranslucentRenderables", "Grand_Espace - Draw pockets", function()

		local ship = LocalPlayer():getSpaceship()

		if ship then
			
				render.SetColorMaterial()

				render.SetStencilEnable(true)
				render.ClearStencil()
				render.SetStencilWriteMask(5)
				render.SetStencilTestMask(5)
				render.SetStencilReferenceValue(5)
				render.SetStencilFailOperation(STENCILOPERATION_KEEP)
				render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
				render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
				render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)

				render.DrawBox(ship:getPocketPos(), Angle(), ship:getPocketSize()/2, -ship:getPocketSize()/2, Color(0,255,0,255*0), 1 )
			
				render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)

				render.SetMaterial(mat)
				cam.Start3D( EyePos(), ship:getGridAngle() + EyeAngles() )
					
					render.DepthRange( 0, 0 ) 
					render.DrawSphere( ship:getPocketPos(), -16384, 50, 50, Color(255,255,255,255), false)
					render.DepthRange( 0, 1 ) 

				cam.End3D()	
				

				render.SetStencilReferenceValue(1)	-- Fix the holo bug with the physgun
				render.ClearStencil()
				render.SetStencilEnable(false)

			
		else

			for _, v in pairs(World.spaceships) do
				render.DrawWireframeBox(v:getPocketPos(), Angle(), -v:getPocketSize()/2, v:getPocketSize()/2, Color(255,255,255,255), 1 )
			end

		end

	end)

	local blacklist = { player=true, viewmodel=true, physgun_beam=true}

	hook.Add("Grand_Espace - LocalPlayer changed ship", "Do not render outside the ship", function( ship, lastship )
		
		for k,v in pairs( ents.GetAll() ) do
			if IsValid(v) and not blacklist[v:GetClass()] then
				v:SetNoDraw(v.parentSpaceship ~= ship)
			end
		end

	end)

else
	local pocket = {}

	local function isIn( bbpos, bbsize, pos )
		local p = pos - bbpos
		local s = bbsize / 2

		return math.max( math.abs(p.x/s.x), math.abs(p.y/s.y), math.abs(p.z/s.z)  ) <= 1
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
					v:assignToSpaceship( ship )
				end
			end
		end

		ship.bb_pos = self:getPocketPos()
		ship:setOriginalPos( relative )
	end
	
	function pocket.moveShipFromPocket( ship )
		ship:delete()
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
			entryPos = Vector(math.random(-12000,12000),math.random(-12000,12000),math.random(0,7000))
			found = true
			attempts = attempts - 1

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
			spaceship:setGridPos( Vector( math.random( -10000, 10000 ), math.random( -10000, 10000 ), math.random( -10000, 10000 ) ) )
		end
	end

	GrandEspace.pocket = pocket
end