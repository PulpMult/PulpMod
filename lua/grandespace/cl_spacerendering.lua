local math = math

local warpMaterial = Material("warp")
local starMaterial = Material( "sprites/light_ignorez" )
local backgroundMaterial = Material("materials/stars.png")
local bubble
local white = Color(255,255,255,255)
local black = Color(0,0,0,255)
local starColor = Color(255,255,255,200)
local maxDuration = 10
local stars = {}
local angBubble = Angle(90,0,0)
local lastHyperSpace

local function newStar( pos, radius )

	local startPos0 = pos + Vector(radius*20,0,0)

	local ang = math.random(0,360)
	local x = Vector(0,math.sin(ang),math.cos(ang))
	local startPos = startPos0 + radius/5*x
	local endPos = pos + radius * x

	local st = CurTime() - math.random()*maxDuration	
	return {startPos, endPos, st , st + math.random()*maxDuration}
end

local function drawHyperSpace( pos, radius )
	
	-- Draw the hyperspace bubble (blue thing)
	bubble:SetRenderOrigin(pos)
	bubble:SetRenderAngles(angBubble)
	bubble:SetNoDraw(true)

 	render.SetBlend( 0.2 ) 
	render.ModelMaterialOverride( warpMaterial )
	render.SuppressEngineLighting(true)
	bubble:DrawModel()
	render.SuppressEngineLighting(false)
	render.ModelMaterialOverride()
	render.SetBlend( 1 )

	-- Draw the moving stars.
	render.SetMaterial( starMaterial )
	local curtime = CurTime()

	local startPos, endPos, startTime, endTime, ratio
	local vec1, vec2 = Vector(), Vector() -- Temp vectors so we don't recreate one for each star (mem optimization)
	local me = LocalPlayer()

	for k, star in pairs(stars) do

		startPos = star[1]
		endPos = star[2]
		startTime = star[3]
		endTime = star[4]
		ratio = (curtime-startTime)/(endTime-startTime)
		
		if ratio >= 2 then
			stars[k] =  newStar(me:getSpaceship():getPocketPos(), me:getSpaceship():getPocketSize():Length() )
		end

		if ratio > 0 then

			s = 128/(endTime - startTime)
			starColor.a = math.Clamp(s*2,0,255)

			-- Avoids creating a vector for each of the star 
			vec1:Set(startPos)
			vec1:Mul(1-ratio)
			vec2:Set(endPos)
			vec2:Mul(ratio)
			vec1:Add(vec2)

			-- does the same thing as LerpVector: vec1 = startPos * (1-ratio) + endPos * ratio
			render.DrawSprite( vec1, s, s, starColor )
		end
	end
end

hook.Add("GrandEspace - Draw space around ships", "DrawSpace&Hyperspace", function()

	local ship = LocalPlayer():getSpaceship()
	local pos, ang = WorldToLocal(EyePos(), EyeAngles(), ship:getPocketPos(), Angle())
	local pos2, ang2 = LocalToWorld(pos, ang, ship:getGridPosLerp(), ship:getGridAngleLerp())

	if lastHyperSpace ~= GrandEspace.inHyperSpace then

		for i=1, 500 do
			stars[i] = newStar(ship:getPocketPos(), ship:getPocketSize():Length() )
		end
		lastHyperSpace = GrandEspace.inHyperSpace


		if GrandEspace.inHyperSpace and not bubble then
			bubble = ClientsideModel("models/holograms/hq_icosphere.mdl")
			local m = Matrix()
			m:Scale(-Vector(5,5,100)*16384/100)
			bubble:EnableMatrix( "RenderMultiply", m )
			bubble:SetColor(Color(255,255,255,0))
			bubble:SetNoDraw(true)
		end
		
		if not GrandEspace.inHyperSpace and bubble then
			bubble:Remove()
			bubble = nil
		end

	end

	render.OverrideDepthEnable(true, false)
	render.DepthRange( 0, 0 ) 

	cam.Start3D( EyePos(),  ang2)
		if LocalPlayer():getSpaceship() and GrandEspace.inHyperSpace then
			render.SetColorMaterial()
			render.DrawSphere( EyePos(), -16384, 50, 50, black, false)
		else
			render.SetMaterial( backgroundMaterial )
			render.DrawSphere( EyePos(), -16384, 50, 50, white, false)
		end
	cam.End3D()	

	if LocalPlayer():getSpaceship() and GrandEspace.inHyperSpace then
		drawHyperSpace( LocalPlayer():getSpaceship():getPocketPos(), LocalPlayer():getSpaceship():getPocketSize():Length())
	end

	render.DepthRange( 0, 1 )
	render.OverrideDepthEnable(false, false)

end)