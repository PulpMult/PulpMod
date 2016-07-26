ENT.Type = "anim"
ENT.Base = "grandespace_module"
 
ENT.PrintName		= "Module"
ENT.Author			= "Poulpe"

if SERVER then

	AddCSLuaFile()

	function ENT:initModule()

		self.moduleCategory = "LifeSupport"
		self.level = 0

		self:SetColor(Color(33,255,0))
		
	end

else

	function ENT:Draw()

	    self:DrawModel()
	    if LocalPlayer():GetEyeTrace().Entity == self then 
  			AddWorldTip( nil, "Life support module level 0", nil, nil, self  ) 
  		end

  	end
end
 