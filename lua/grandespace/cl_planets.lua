AddCSLuaFile()

if SERVER then return end

local Vector2 = GrandEspace.Vector2

local planets = {}
local planetsRender = {}
local ship

planets["earth"] = { 
	galaxyPos = Vector2(0, 5e-6),
	gridPos = Vector(1000000000, 0, 0),
	gridAngle = Angle(180, 0, 180),
	shadowAnglele = Angle(0, 0, 95),
	atmosphereSize = 0.006,
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
	entities[k] = ClientsideModel("models/holograms/hq_sphere.mdl", RENDERGROUP_OTHER)
	entities[k]:SetLOD(0)
	entities[k]:SetPos(Vector(0, 0, -100000000))
	entities[k]:SetNoDraw(true)

	shadows[k] = ClientsideModel("models/holograms/hq_sphere.mdl", RENDERGROUP_OTHER)
	shadows[k]:SetLOD(0)
	shadows[k]:SetPos(Vector(0, 0, -100000000))
	shadows[k]:SetNoDraw(true)

	planetsRender[k] = {}
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

local defAngle = Angle()
local defVec = Vector()
local _, res

local function LocalToWorldAngle(ang, base)
	_, res = LocalToWorld(defVec, ang, defVec, base)
	return res
end

local function LocalToWorldPos(pos, base)
	res = LocalToWorld(pos, defAngle, base, defAngle)
	return res
end

local function WorldToLocalAngle(ang, base)
	_, res = WorldToLocal(defVec, ang, defVec, base)
	return res
end

local function WorldToLocalPos(pos, base)
	res = WorldToLocal(pos, defAngle, base, defAngle)
	return res
end

local lastPlanetUpdate = CurTime()
local min = math.min
local pow = math.pow
local maxDraw = 1000000
local shipPos, shipAng, pocketPos, dt, relative, pos, ang, planetRender, renderPos

hook.Add("InitPostEntity", "GrandEspace - Planets", function()
	hook.Add("Tick", "GrandEspace - Planets", function()
		ship = LocalPlayer():getSpaceship()
		if not ship then return end

		shipPos = ship:getGridPosLerp()
		shipAngle = ship:getGridAngleLerp()
		pocketPos = ship:getPocketPos()

		dt = CurTime() - lastPlanetUpdate
		lastPlanetUpdate = CurTime()

		for k,v in pairs(planets) do
			planetRender = planetsRender[k]

			-- Planet rotation
			v.gridAngle:RotateAroundAxis(v.rotationAxis, v.rotationSpeed*dt)
			
			-- Compute render position
			relative = v.gridPos - shipPos
			planetRender.dist = relative:Length()
			planetRender.scale = min(planetRender.dist, maxDraw)/planetRender.dist

			renderPos = shipPos + relative*planetRender.scale
			pos, ang = WorldToLocal(renderPos, v.gridAngle, shipPos, shipAngle)
			planetRender.pos, planetRender.ang = LocalToWorld(pos, ang, pocketPos, defAngle)

			-- Compute shadow angle
			planetRender.shadowAngle = LocalToWorldAngle(WorldToLocalAngle(v.shadowAnglele, shipAngle), defAngle)
		end
	end)
end)

local renderMat = CreateMaterial("planet_texture", "VertexLitGeneric")
local shadowMat = Material("marmotte/planet_shadow")
local fogMode, ent, planetPos, planetAng, planetScale, planetDist, shadowDir, shadowAngle, shadowOffset, planetRender, shadow

hook.Add("PreDrawTranslucentRenderables", "GrandEspace - Planets", function()
	if not ship or not LocalPlayer() then return end

	fogMode = render.GetFogMode()

	render.SuppressEngineLighting(true)
	render.FogMode(MATERIAL_FOG_NONE)

	for k,v in pairs(planets) do
		if v.galaxyPos == ship:getGalaxyPos() then
			renderMat:SetTexture("$basetexture", v.material:GetTexture("$basetexture"))

			planetRender = planetsRender[k]
			planetScale = planetRender.scale
			planetPos = planetRender.pos
			planetAng = planetRender.ang
			planetDist = planetRender.dist
			shadowAngle = planetRender.shadowAngle
			shadowDir = shadowAngle:Up()
			
			ent = entities[k]
			ent:SetRenderOrigin(planetPos)
			ent:SetRenderAngles(planetAng)

			shadow = shadows[k]
			shadow:SetRenderOrigin(planetPos)
			shadow:SetAngles(shadowAngle)

			enableStencil()

			-- Draw atmosphere
			render.SetColorMaterial()
			render.DrawSphere(planetPos, planetScale*(1+v.atmosphereSize)*v.radius, 50, 50, v.atmosphereColor)

			-- Draw planet
			render.SetColorModulation(v.colorModulation[1], v.colorModulation[2], v.colorModulation[3])
			render.MaterialOverride(renderMat)
			
			ent:SetModelScale(planetScale*v.radius/ent:GetModelRadius())
			ent:DrawModel()

			switchStencil()

			-- Draw shadow
			render.SetColorModulation(1, 1, 1)
			render.MaterialOverride(shadowMat)
			render.SetBlend(0.97)
			render.DepthRange(0, 0)

			shadow:SetModelScale((1.01 + v.atmosphereSize)*planetScale*v.radius/ent:GetModelRadius())
			shadow:DrawModel()

			render.DepthRange(0, 1)
			render.MaterialOverride()

			disableStencil()
		end
	end

	render.FogMode(fogMode)
	render.SuppressEngineLighting(false)
end)
