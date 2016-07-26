AddCSLuaFile()

ENT.PrintName = "Teleporter"
ENT.Author = "Doctor Who"

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

function ENT:Initialize()
	if CLIENT then return end
	
	self:SetModel( "models/mechanics/wheels/wheel_speed_72.mdl" )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:PhysicsInit( SOLID_VPHYSICS )

	local phys = self:GetPhysicsObject()
	if IsValid( phys ) then
		phys:Wake()
	end
end

function ENT:Think()
	if self.parentSpaceship then
		local ship = self.parentSpaceship
		
		if not ship.telepad then ship.telepad = self end -- I guess I could move it into a hook later on.
	end
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:RetrievePlayer( ply )
	ply:SetPos( self:GetPos() )
end

if SERVER then
	hook.Add( "PostPlayerDeath", "GrandEspace - Handle player's death.", function( ply )
		local ship = ply:getSpaceship()
		
		if ship and IsValid( ship.telepad ) then
			ply.returnShip = ship
		end
	end	)
	
	hook.Add( "PlayerSpawn", "GrandEspace - Handle player's respawn.", function( ply )
		if ply.returnShip and IsValid( ply.returnShip.telepad ) then
			ply.returnShip.telepad:RetrievePlayer( ply )
			ply.returnShip = nil
		end
	end	)
end