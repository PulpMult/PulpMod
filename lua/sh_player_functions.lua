AddCSLuaFile()

local PlayerObj = FindMetaTable("Player")

function PlayerObj:assignToSpaceship( s )

	self.currentShip = s

end

function PlayerObj:getSpaceship( )

	return self.currentShip 

end

if CLIENT then

	hook.Add("FinishMove", "Grand_Espace - Detection whether the player is in a ship", function(ply, mv)

		if ply == LocalPlayer() then

			local pos = mv:GetOrigin()

			local lastShip = ply:getSpaceship()
			local currentShip = nil
			
			for k,v in pairs( World.spaceships ) do
				
				if v:isIn(pos) then
					currentShip = v
					break
				end

			end


			if currentShip ~= lastShip then
				
				ply:assignToSpaceship( currentShip )

				if not lastShip then
					print("LocalPlayer entered the ship ["..tostring(ply:getSpaceship()) .. " (" .. tostring(ply:getSpaceship().id).. ")" .."]")
				else
					print("LocalPlayer exited the ship ["..tostring(lastShip).. " (" .. tostring(lastShip.id) .. ")" .."]")
				end

				hook.Call("Grand_Espace - LocalPlayer changed ship", {}, ply:getSpaceship(), lastShip)
				

			end

		end

	end)

end