ENT.Type = "anim"
ENT.Base = "grandespace_module"
 
ENT.PrintName		= "Module"
ENT.Author			= "Poulpe"

if SERVER then

	AddCSLuaFile()

	function ENT:initModule()

		self.moduleCategory = "Shield"
		self.level = 0

		self:SetColor(Color(5,0,127))
		
	end

else

	function ENT:Draw()

	    self:DrawModel()
	    if LocalPlayer():GetEyeTrace().Entity == self then 
  			AddWorldTip( nil, "Shield module level 0", nil, nil, self  ) 
  		end

  	end
end
 