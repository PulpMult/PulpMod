AddCSLuaFile()

World = {}
World.__index = World

World.spaceships = {}

function World.addSpaceship( s )

	assert( s and istable(s) )
	
	print("Adding a spaceship to the world:")
	print(" - Galaxy position: "..tostring(s:getGalaxyPos()))
	print(" - Grid position: "..tostring(s:getGridPos()))
	print(" - Pocket position: "..tostring(s:getPocketPos()))

	s.id = table.insert( World.spaceships, s )

	return s.id

end

local function vecToTbl(vec)
	return { vec.x, vec.y, vec.z }
end

local function tblToVec(tbl)
	return Vector(tbl[1], tbl[2], tbl[3])
end

if CLIENT then

	net.Receive("Grand_Espace - Synchronize the world", function( len )

		local curtime = SysTime()
		local t = net.ReadTable()
		
		for _,v in pairs(t) do

			local id, galaxyPos, gridPos, pocketPos, pocketSize, e = v[1], tblToVec(v[2]), tblToVec(v[3]), tblToVec(v[4]), v[5], v[6]

			if not World.spaceships[id] then
				World.spaceships[id] = Spaceship.new()
			end

			local s = World.spaceships[id]
			
			s.velocity = (galaxyPos-s:getGalaxyPos()) / (curtime-(s.lastUpdate or 0))*1e6

			s:setGalaxyPos( galaxyPos )
			s:setGridPos( gridPos )
			s:setPocketPos( pocketPos )
			s:setPocketSize( pocketSize )

			s.lastUpdate = curtime

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
			
			-- Convert vectors to table, because net.WriteVector has a huge precision loss. Numbers in tables are sent using
			-- net.WriteDouble when calling net.WriteTable.
			t[#t+1] = { k, vecToTbl(v:getGalaxyPos()), vecToTbl(v:getGridPos()), vecToTbl(v:getPocketPos()), v:getPocketSize(), e }

		end

		net.Start("Grand_Espace - Synchronize the world")
			net.WriteTable(t)
		net.Broadcast()

	end)

end
