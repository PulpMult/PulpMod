ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName		= "Module receptacle"
ENT.Author			= "Poulpe"

if SERVER then
	AddCSLuaFile()

	local grabRadius = 20

	local grabRadiusSqr = grabRadius*grabRadius
	 
	function ENT:Initialize()
	 
		self:SetModel( "models/props_combine/combine_mortar01b.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS ) 
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS ) 
		self:SetUseType( SIMPLE_USE )
	 
	    local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
		end
		
	end


	function GrandEspace.isModuleReceptacle( e )
		return IsValid(e) and e.ClassName == "grandespace_module_receptacle"
	end

	function ENT:ejectModule()

		if IsValid(self.currentModule) then

			self.ignoredModule = self.currentModules
			self.currentModule.moduleReceptacle = nil
			self.currentModule = nil

			local a = self.ignoredModule

			timer.Simple(1, function()
				if IsValid(self) and self.ignoredModule == a then
					self.ignoredModule = nil
				end
			end)

		else
			self.currentModule = nil
		end

		if IsValid(self.currentModuleWeld) then
			self.currentModuleWeld:Remove()
		end

		if self.parentSpaceship and self.parentSpaceship.changedModule then
			self.parentSpaceship:changedModule()
		end
	end

	function ENT:attachModule( mod )

		self:ejectModule()
		self.currentModule = mod
		self.currentModule.moduleReceptacle = self

		self.currentModule:SetAngles( self:GetAngles() )
		self.currentModule:SetPos( self:GetPos() )
		self.currentModuleWeld = constraint.Weld( self, self.currentModule, 0, 0, 0, true, false )

		if self.parentSpaceship then
			self.parentSpaceship:changedModule()
		end

	end

	function ENT:Think()

		local curPos = self:GetPos()

		if not self.currentModule then
			
			self:SetColor(Color(255,0,0,255))

			self:NextThink(CurTime() + 0.25)
			
			for k,v in pairs(ents.GetAll()) do
				if v != self.ignoredModule and GrandEspace.isModule( v ) and v:GetPos():DistToSqr(curPos) <= grabRadiusSqr then
					
					self:attachModule(v)			

					self:NextThink(CurTime())
				end
			end
		else	

			self:SetColor(Color(255,255,255,255))

			if not IsValid(self.currentModule) or self.currentModule:GetPos():DistToSqr(curPos) > grabRadiusSqr then
				self:ejectModule()
			else

				
			end

			self:NextThink(CurTime())
		end

		return true 

	end

	function ENT:Use(_,_,use)
		if use == 1 and self.currentModule then
			self:ejectModule(nil)
		end
		
	end

	function ENT:getModules()

		return {self.currentModule}

	end

end