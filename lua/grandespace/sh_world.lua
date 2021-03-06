AddCSLuaFile()

GrandEspace.World = {}
local World = GrandEspace.World

World.__index = World

World.spaceships = {}
World.spaceTime = SysTime()		-- This time is sent by the server at each frame for precise physics simulations
World.prevSpaceTime = SysTime()	-- Used to smooth rendering
World.renderingStart = 0		-- When did we receive info for the last time (for lerp)

function World.addSpaceship( s )

	assert( s and istable(s) )
	
	print("Adding a spaceship to the world:")
	print(" - Galaxy position: "..tostring(s:getGalaxyPos()))
	print(" - Grid position: "..tostring(s:getGridPos()))
	print(" - Pocket position: "..tostring(s:getPocketPos()))

	s.id = table.insert( World.spaceships, s )

	return s.id

end

local maxSpeed = 1000
local maxAngSpeed = 25

local function simulatePhysics()
	for k, v in pairs( World.spaceships ) do
		local dt = World.spaceTime - v.lastSimulation
		local velocity = v:getVelocity() + v:getAcceleration() * dt
		local angularVelocity = v:getAngularVelocity() + v:getAngularAcceleration() * dt
		
		v:setVelocity( velocity:GetNormalized() * math.min( velocity:Length(), maxSpeed ) )
		v:setAngularVelocity(Angle( math.Clamp( angularVelocity.x, -maxAngSpeed, maxAngSpeed ), math.Clamp( angularVelocity.y, -maxAngSpeed, maxAngSpeed ), math.Clamp( angularVelocity.z, -maxAngSpeed, maxAngSpeed ) ))
		
		v:setGridPos(v:getGridPos() + v:getVelocity() * dt)	-- Set noSync to true, don't send the position, the clients compute it

		local _, newAngle = LocalToWorld(Vector(), angularVelocity * dt, v:getGridPos(), v:getGridAngle())
		v:setGridAngle(newAngle)
		
		v.lastSimulation = World.spaceTime
	end
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

	net.Receive("GrandEspace - Synchronize the world", function( len )

		World.prevSpaceTime = World.spaceTime
		World.spaceTime = net.ReadDouble()
		World.renderingStart = SysTime()

		if len > 64 then	-- if the table was sent by the server
			local t = net.ReadTable()
			local curtime = SysTime()
			
			for _,v in pairs(t) do

				-- Convert table back to vectors
				for k,vec in pairs(v) do
					if type(vec) == "table" and #vec == 3 and type(vec[1]) == "number" and type(vec[2]) == "number" and type(vec[3]) == "number" then
						v[k] = tblToVec(vec)
					end
				end

				if not World.spaceships[v.id] then
					World.spaceships[v.id] = Spaceship.new()
				end

				local s = World.spaceships[v.id]
				
				if v.galaxyPos then
					--s:setVelocity((v.galaxyPos-s:getGalaxyPos()) / (curtime-(s.lastUpdate or 0))*1e6)
					s:setGalaxyPos( v.galaxyPos )
				end

				-- TODO: Improve this ugly thing...
				if v.gridPos then s:setGridPos( v.gridPos ) end
				if v.pocketPos then s:setPocketPos( v.pocketPos ) end
				if v.pocketSize then s:setPocketSize( v.pocketSize ) end
				if v.gridAngle then s:setGridAngle( v.gridAngle ) end
				if v.acceleration then s:setAcceleration(v.acceleration) end
				if v.velocity then s:setVelocity(v.velocity) end
				if v.angularAcceleration then s:setAngularAcceleration(v.angularAcceleration) end
				if v.angularVelocity then s:setAngularVelocity(v.angularVelocity) end

				s.lastUpdate = curtime

				s.id = v.id

				if v.entities then
					local entities = {}
					for _,ent in pairs(v.entities) do
						entities[#entities+1] = ent
					end

					s:setEntities( entities ) -- Will recalculate the bounding box each time O(n)
				end

			end
		end

		simulatePhysics()
	end)

	-- Request sync
	hook.Add("InitPostEntity", "PulpMod_SyncSpaceships", function()
		net.Start("GrandEspace - Synchronize the world")
		net.SendToServer()
	end)
else -- SERVER

	util.AddNetworkString("GrandEspace - Synchronize the world")

	local function syncSpaceships(players, force)
		local t = {}

		-- TODO: Optimize this function so it sends only the required data
		for k,v in pairs(assert(World.spaceships)) do
			local spaceshipTable = v:getUpdateTable(force)

			if spaceshipTable then
				t[#t+1] = spaceshipTable
			end

		end

		net.Start("GrandEspace - Synchronize the world")
			net.WriteDouble(World.spaceTime)

			if next(t) then		-- if table is not empty
				net.WriteTable(t)
			end
		net.Broadcast(players)
	end
	
	hook.Add("PlayerSpawn", "GrandEspace - Sync on initial spawn", function()
		syncSpaceships(player.GetAll(), true)
	end)

	hook.Add("Tick", "GrandEspace - Synchronize the world", function()
		World.spaceTime = SysTime()
		syncSpaceships(player.GetAll(), false)
		simulatePhysics()
	end)

	net.Receive("GrandEspace - Synchronize the world", function(len, ply)
		syncSpaceships(ply, true)
	end)
end
