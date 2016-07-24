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
		self.moduleType = "ExtendedJump"
		self.warpRadius = math.random(10,100)/10

		self:SetNWInt("warpRadius", self.warpRadius)

	end

else

	function ENT:Draw()

	    self:DrawModel()
	    if LocalPlayer():GetEyeTrace().Entity == self then 
  			AddWorldTip( nil, "Warp drive module\n=================\nIncrease the range of the warp drive by " .. tostring(math.Round(self:GetNWInt("warpRadius"),1)) .. "pc", nil, nil, self  ) 
  		end

  	end
end
 