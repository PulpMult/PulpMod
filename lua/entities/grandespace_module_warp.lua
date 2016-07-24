ENT.Type = "anim"
ENT.Base = "grandespace_module"
 
ENT.PrintName		= "Module"
ENT.Author			= "Poulpe"

ENT.Spawnable       = true
ENT.Category		= "GrandEspace"

if SERVER then

	AddCSLuaFile()

	function ENT:initModule()

		self.moduleCategory = "WarpDrive"

		if math.random() < 0.5 then 


			self.moduleType = "ExtendedJump"
			self.warpRadius = math.random(10,100)/10

			self:SetNWInt("ModuleWarpDriveType", 0)
			self:SetNWInt("warpRadius", self.warpRadius)

		else

			self.moduleType = "ReducedCooldown"
			self.reduceCooldown = math.random(10,70)/10

			self:SetNWInt("ModuleWarpDriveType", 1)
			self:SetNWInt("reduceCooldown", self.reduceCooldown)
		end


	end

else

	function ENT:Draw()

	    self:DrawModel()
	    if LocalPlayer():GetEyeTrace().Entity == self then 

	    	if self:GetNWInt("ModuleWarpDriveType") == 0 then
  				AddWorldTip( nil, "Warp drive module\n=================\nIncrease the range of the warp drive by " .. tostring(math.Round(self:GetNWInt("warpRadius"),1)) .. "pc", nil, nil, self  ) 
  			else
  				AddWorldTip( nil, "Warp drive module\n=================\nDecrease the cooldown of the warp drive by " .. tostring(math.Round(self:GetNWInt("reduceCooldown"),1)) .. "s", nil, nil, self  ) 
  			end
  		end

  	end
end
 