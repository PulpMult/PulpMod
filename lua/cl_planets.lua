AddCSLuaFile()

if SERVER then return end

local Vector2 = GrandEspace.Vector2

local planets = {}
local ship

planets["earth"] = { 
	galaxyPos = Vector2(0, 5e-6),
	gridPos = Vector(1000000000, 0, 0),
	gridAngle = Angle(180, 0, 180),
	shadowAngle = Angle(0, 0, 95),
	atmosphereSize = 0.004,
	atmosphereColor = Color(152, 206, 252, 50),
	material = Material("marmotte/earth.png"),
	colorModulation = { 0.8, 0.8, 0.8 },
	rotationAxis = Vector(0, 0, 1),
	rotationSpeed = 0.1,
	radius = 482000000
}

local entities = {}
local shadows = {}

for k,v in pairs(planets) do
	entities[k] = ClientsideModel("models/holograms/hq_sphere.mdl")
	entities[k]:SetLOD(0)
	entities[k]:SetPos(Vector(0, 0, -10000000))

	shadows[k] = {}
	for i = 1,10 do
		shadows[k][i] = ClientsideModel("models/holograms/hq_hdome_thin.mdl")
		shadows[k][i]:SetLOD(0)
		shadows[k][i]:SetMaterial("models/debug/debugwhite")
		shadows[k][i]:SetColor(Color(0, 0, 0, 100))
		shadows[k][i]:SetPos(Vector(0, 0, -10000000))
	end
end

local function enableStencil()
	render.SetStencilEnable(true)
	render.ClearStencil()
	render.SetStencilWriteMask(255)
	render.SetStencilTestMask(255)
	render.SetStencilReferenceValue(192)
	render.SetStencilFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
end

local function switchStencil()
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
end

local function disableStencil()
	render.SetStencilEnable(false)
end

local fogMode, orpos, orang, ent, dir, pos, ang, shadang, dt, scale, renderDist, rel, gridPos, gridAngle, shadoff, _
local lastRender = CurTime()
local renderMat = CreateMaterial("earth2", "VertexLitGeneric")
local min = math.min
local pow = math.pow
local maxDraw = 1000000
local shipPos, shipAng, pocketPos
local defAngle = Angle()

local poss, angs, shadangs, scales = {}, {}, {}, {}

hook.Add("InitPostEntity", "GrandEspace - Planets", function()
	hook.Add("Tick", "GrandEspace - Planets", function()
		ship = LocalPlayer():getSpaceship()
		if not ship then return end

		shipPos = ship:getGridPosLerp()
		shipAng = ship:getGridAngleLerp()
		pocketPos = ship:getPocketPos()

		fogMode = render.GetFogMode()
		dt = CurTime() - lastRender
		lastRender = CurTime()

		for k,v in pairs(planets) do
			v.gridAngle:RotateAroundAxis(v.rotationAxis, v.rotationSpeed*dt)

			gridPos = v.gridPos
			gridAngle = v.gridAngle

			rel = gridPos - shipPos
			l = rel:Length()
			renderDist = min(l, maxDraw)
			scales[k] = renderDist/l

			if scales[k] < 1 then
				gridPos = shipPos + rel*scale
			end

			pos, ang= WorldToLocal(gridPos, gridAngle, shipPos, shipAng)
			poss[k], angs[k] = LocalToWorld(pos, ang, pocketPos, defAngle)

			_, shadang = WorldToLocal(gridPos, v.shadowAngle, shipPos, shipAng)
			_, shadangs[k] = LocalToWorld(_, shadang, pocketPos, defAngle)
		end
	end)
end)

hook.Add("PostDrawOpaqueRenderables", "GrandEspace - Planets", function()
	ship = LocalPlayer():getSpaceship()
	if not ship or not next(poss) then return end

	shipPos = ship:getGridPosLerp()
	shipAng = ship:getGridAngleLerp()
	pocketPos = ship:getPocketPos()

	fogMode = render.GetFogMode()

	render.SuppressEngineLighting(true)
	render.FogMode(MATERIAL_FOG_NONE)

	for k,v in pairs(planets) do
		if v.galaxyPos == ship:getGalaxyPos() then
			ent = entities[k]
			renderMat:SetTexture("$basetexture", v.material:GetTexture("$basetexture"))

			gridPos = v.gridPos
			gridAngle = v.gridAngle
			scale = scales[k]
			pos = poss[k]
			ang = angs[k]
			shadang = shadangs[k]
			
			enableStencil()

			-- Draw atmosphere
			render.SetColorMaterial()
			render.DrawSphere(pos, scale*(1+v.atmosphereSize)*v.radius, 50, 50, v.atmosphereColor)

			-- Draw planet
			orpos = ent:GetRenderOrigin()
			orang = ent:GetRenderAngles()

			render.SetColorModulation(v.colorModulation[1], v.colorModulation[2], v.colorModulation[3])
			render.MaterialOverride(renderMat)
			
			ent:SetRenderOrigin(pos)
			ent:SetRenderAngles(ang)
			ent:SetModelScale(scale*v.radius/ent:GetModelRadius())
			
			ent:DrawModel()
			
			ent:SetModelScale(1)
			ent:SetRenderOrigin(orpos)
			ent:SetRenderAngles(orang)

			render.MaterialOverride()

			switchStencil()

			-- Draw shadow
			dir = shadang:Up()
			--shadoff = renderDist*0.0000019/(1-scale)
			--shadoff = 1 + (l-v.radius/ent:GetModelRadius())*0.000000000075
			shadoff = 1 + (l-v.radius)*0.000000001

			render.SetColorMaterial()
			render.SetColorModulation(0, 0, 0)
			
			for i,s in ipairs(shadows[k]) do
				orpos = s:GetRenderOrigin()
				orang = s:GetRenderAngles()
				
				render.SetBlend(0.75/((pow(i, 0.9))*0.92))
				s:SetRenderOrigin(pos - scale*dir*(i*v.radius/1000))
				s:SetRenderAngles(shadang)
				s:SetModelScale(scale*shadoff*v.radius/s:GetModelRadius())

				s:DrawModel()

				s:SetModelScale(1)
				s:SetRenderOrigin(orpos)
				s:SetRenderAngles(orang)
			end

			disableStencil()
		end
	end

	render.FogMode(fogMode)
	render.SuppressEngineLighting(false)
end)