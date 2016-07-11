local PlayerObj = FindMetaTable("Player")

function PlayerObj:assignToSpaceship( s )

	self.currentShip = s

end

function PlayerObj:getSpaceship( )

	return self.currentShip 

end

function PlayerObj:getGalaxyPos( )

	if not self.currentShip then 
		return Vector()
	end
	
	return self.currentShip:getGalaxyPos()

end


if SERVER then
	

	local hyperspace_jumps = {}

	concommand.Add("forcemove", function( ply, cmd, args )

		local id = tonumber(args[1])
		local dest = tonumber(args[2])

		local result = assert(sql.Query("SELECT * FROM " .. Grand_Espace_TABLE_NAME .. " WHERE id=" .. tostring(dest)))

		local ship = assert(World.spaceships[id])

		local jump = {
			ship = ship,
			originalPos = ship:getGalaxyPos(), 
			destinationPos = Vector(result[1].x, result[1].y, 0),
			startTime = CurTime()
		}
		jump.endTime = CurTime() + jump.originalPos:Distance(jump.destinationPos)*2
		table.insert(hyperspace_jumps, jump)
		

	end)

	hook.Add("Think", "Grand_Espace - Hyperespace travel", function()

		for k,v in pairs(hyperspace_jumps) do
			
			local coef = math.Clamp( (CurTime() - v.startTime)/(v.endTime - v.startTime), 0, 1)

			v.ship:setGalaxyPos( (1-coef) * v.originalPos + coef * v.destinationPos )

			if coef == 1 then
				hyperspace_jumps[k] = nil
			end


		end

	end)
end