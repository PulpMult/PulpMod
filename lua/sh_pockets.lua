if CLIENT then return end

pocket = {}

function pocket.allocateContraption( ent )
	
	if not IsValid( ent ) then return false end
	
	local all = constraint.GetAllConstrainedEntities( ent )
	
	local radius = 0
	
	local n
	for k, v in pairs( all ) do
		if IsValid( v ) then
			n = v:GetPos():Distance( ent:GetPos() )
			if radius < n then radius = n end
		end
	end
	
	players = player.GetAll()
	
	for k, v in pairs( players ) do
		if IsValid( v ) and v:IsPlayer() then
			v:SetPos( Vector( 0, 0, 0 ) + v:GetPos() - ent:GetPos() )
		end
	end
	
	for k, v in pairs( all ) do
		if IsValid( ent ) then
			v:SetPos( Vector( 0, 0, 0 ) + v:GetPos() - ent:GetPos() )
			
			local phys = v:GetPhysicsObject()
			
			if IsValid( phys ) then
				phys:EnableMotion( false )
			end
		end
	end
end