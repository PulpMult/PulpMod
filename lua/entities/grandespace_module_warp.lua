ENT.Type = "anim"
ENT.Base = "grandespace_module"
 
ENT.PrintName		= "Module"
ENT.Author			= "Poulpe"

if SERVER then

	AddCSLuaFile()

	function ENT:initModule()

		self.moduleCategory = "WarpDrive"
		self.level = 0

		self:SetColor(Color(60,110,255))

	end

else

	function ENT:Draw()

	    self:DrawModel()
	    if LocalPlayer():GetEyeTrace().Entity == self then 
  			AddWorldTip( nil, "Warp drive module level 0", nil, nil, self  ) 
  		end

  	end
end
 