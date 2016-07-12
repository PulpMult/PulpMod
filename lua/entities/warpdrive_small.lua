AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.PrintName = "Warp Drive (small)"
ENT.Author = "Marmotte"

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

--[[---------------------------------------------------------
	Name: Initialize
-----------------------------------------------------------]]
function ENT:Initialize()
	if CLIENT then return end

	self:SetModel("models/props_combine/combine_intmonitor003.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
	end

	self:SetAngles(self:GetAngles() + Angle(-90, 0, 0))
end

-- CLIENT
if SERVER then return end

surface.CreateFont("WarpDriveConsole", {
	font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 48,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

local scale, sizex, sizey
function ENT:Draw()
	self:DrawModel()

	-- Draw the map
	scale = 0.1
	sizex = 14*3.5*(1/scale)
	sizey = 9*3.5*(1/scale)
	cam.Start3D2D(self:GetPos() + self:GetForward()*27 + self:GetUp()*49 - self:GetRight()*15, self:LocalToWorldAngles(Angle(90, 0, 0)), scale)
		surface.SetDrawColor(Color(0, 0, 0, 255))
		surface.DrawRect(0, 0, sizex, sizey)
		draw.SimpleText("OFFLINE", "WarpDriveConsole", sizex/2, sizey/2, Color(204, 0, 0, math.abs(math.sin(CurTime()))*255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		surface.SetDrawColor(Color(0, 0, 0, 240))
		surface.DrawRect(4.5*(1/scale), 38.5*(1/scale), 13*(1/scale), 5*(1/scale))
		surface.DrawRect(30*(1/scale), 38.5*(1/scale), 13*(1/scale), 5*(1/scale))
		draw.SimpleText("<Prev", "WarpDriveConsole", 11*(1/scale), 41*(1/scale), Color(150, 150, 150, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("Next>", "WarpDriveConsole", 36.5*(1/scale), 41*(1/scale), Color(150, 150, 150, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()

	-- Draw the location or jump drive bar
	scale = 0.1
	sizex = 45*(1/scale)
	sizey = 14*(1/scale)
	cam.Start3D2D(self:GetPos() + self:GetForward()*32.55 + self:GetUp()*49 - self:GetRight()*31, self:LocalToWorldAngles(Angle(90, -19, 0)), scale)
		surface.SetDrawColor(Color(0, 0, 0, 255))
		surface.DrawRect(0, 0, sizex, sizey)

		draw.SimpleText("[Unknown location]", "WarpDriveConsole", sizex/2, sizey/2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end