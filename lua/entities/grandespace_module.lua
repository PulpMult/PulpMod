ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName		= "Module"
ENT.Author			= "Poulpe"

if SERVER then
	AddCSLuaFile()
	 
	function ENT:initModule() -- TO OVERRIDE
		self.moduleCategory = ""
		self.moduleType = ""
	end

	function ENT:Initialize()
	 
		self:SetModel( "models/props_combine/combine_mine01.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS ) 
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS ) 
	 
	    local phys = self:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
		end

		self:SetUseType( SIMPLE_USE )

		self:initModule()

	end

	function GrandEspace.isModule( e )
		return IsValid(e) and e.Base == "grandespace_module"
	end

	function ENT:Use()

		if self.moduleReceptacle then
			self.moduleReceptacle:ejectModule()
		end

	end

end