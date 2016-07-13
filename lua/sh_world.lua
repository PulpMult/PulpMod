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

if CLIENT then
	-- Utility functions
	local function vecToTbl(vec)
		if not vec then return end
		return { vec.x, vec.y, vec.z }
	end

	local function tblToVec(tbl)
		if not tbl then return end
		return Vector(tbl[1], tbl[2], tbl[3])
	end

	net.Receive("Grand_Espace - Synchronize the world", function( len )

		local curtime = SysTime()
		local t = net.ReadTable()
		
		for _,v in pairs(t) do

			local id, galaxyPos, gridPos, pocketPos, pocketSize, gridAngle, e = v[1], tblToVec(v[2]), tblToVec(v[3]), tblToVec(v[4]), v[5], v[6], v[7]

			if not World.spaceships[id] then
				World.spaceships[id] = Spaceship.new()
			end

			local s = World.spaceships[id]
			
			if galaxyPos then
				s.velocity = (galaxyPos-s:getGalaxyPos()) / (curtime-(s.lastUpdate or 0))*1e6
				s:setGalaxyPos( galaxyPos )
			end

			if gridPos then s:setGridPos( gridPos ) end
			if pocketPos then s:setPocketPos( pocketPos ) end
			if pocketSize then s:setPocketSize( pocketSize ) end
			if gridAngle then s:setGridAngle( gridAngle ) end

			s.lastUpdate = curtime

			s.id = id

			if e then
				local entities = {}
				for _,ent in pairs(e) do
					entities[#entities+1] = Entity(ent)
				end

				s:setEntities( entities ) -- Will recalculate the bounding box each time O(n)
			end

		end
	end)

	-- Request sync
	hook.Add("InitPostEntity", "PulpMod_SyncSpaceships", function()
		net.Start("Grand_Espace - Synchronize the world")
		net.SendToServer()
	end)
else -- SERVER

	util.AddNetworkString("Grand_Espace - Synchronize the world")

	local lastShipListing = CurTime()

	local function syncSpaceships(players, force)
		local t = {}

		-- TODO: Optimize this function so it sends only the required data
		for k,v in pairs(assert(World.spaceships)) do
			local spaceshipTable = v:getUpdateTable(force)

			if spaceshipTable then
				t[#t+1] = spaceshipTable
			end

		end

		net.Start("Grand_Espace - Synchronize the world")
			net.WriteTable(t)
		net.Broadcast(players)
	end

	hook.Add("Tick", "Grand_Espace - Synchronize the world", function()
		syncSpaceships(player.GetAll(), false)
	end)

	net.Receive("Grand_Espace - Synchronize the world", function(len, ply)
		syncSpaceships(ply, true)
	end)
end
