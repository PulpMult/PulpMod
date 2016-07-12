World = {}
World.__index = World

World.spaceships = {}

function World.removeEverything()

	for k,v in pairs(World.spaceships) do
		
		World.removeSpaceshipByID(k)

	end

end

function World.addSpaceship( s )

	assert( s and istable(s) )
	
	print("Adding a spaceship to the world:")
	print(" - Galaxy position: "..tostring(s:getGalaxyPos()))
	print(" - Grid position: "..tostring(s:getGridPos()))
	print(" - Real position: "..tostring(s:getWorldPos()))

	s.id = table.insert( World.spaceships, s )

	return s.id

end

if CLIENT then

	net.Receive("Grand_Espace - Synchronize the world", function( len )

		local t = net.ReadTable()

		for _,v in pairs(t) do

			local id, galaxyPos, gridPos, worldPos, e = v[1], v[2], v[3], v[4], v[5]

			if not World.spaceships[id] then
				World.spaceships[id] = Spaceship.new()
			end

			local s = World.spaceships[id]

			s:setGalaxyPos( galaxyPos )
			s:setGridPos( gridPos )
			s:setWorldPos( worldPos )



			s.id = id

			s.notRemoved = true

			local entities = {}
			for _,ent in pairs(e) do
				entities[#entities+1] = Entity(ent)
			end

			s:setEntities( entities ) -- Will recalculate the bounding box each time O(n)

		end

		for k,v in pairs(World.spaceships) do
			if v.notRemoved then
				v.notRemoved = nil
			else
				World.spaceships[k] = nil
			end
		end


	end)


else 

	util.AddNetworkString("Grand_Espace - Synchronize the world")

	hook.Add("Tick", "Grand_Espace - Synchronize the world", function()

		local t = {}
		-- TODO: Optimize this function so it sends only the required data
		for k,v in pairs(assert(World.spaceships)) do

			local e = {}
			for key,ent in pairs(v:getEntities()) do
				if IsValid(ent) then
					e[#e+1] = ent:EntIndex()
				end
			end
			
			t[#t+1] = { k, v:getGalaxyPos(), v:getGridPos(), v:getWorldPos(), e }

		end

		net.Start("Grand_Espace - Synchronize the world")
			net.WriteTable(t)
		net.Broadcast()

	end)

end

