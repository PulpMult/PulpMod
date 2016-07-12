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

-- Taken from https://maurits.tv/data/garrysmod/wiki/wiki.garrysmod.com/indexedb0.html
local function worldToScreen(vWorldPos,vPos,vScale,aRot)
    local vWorldPos=vWorldPos-vPos
    vWorldPos:Rotate(Angle(0,-aRot.y,0))
    vWorldPos:Rotate(Angle(-aRot.p,0,0))
    vWorldPos:Rotate(Angle(0,0,-aRot.r))
    return vWorldPos.x/vScale,(-vWorldPos.y)/vScale
end

local function getScreenCursorPos(tr, vPos, vScale, aRot)
	local n = aRot:Up()
	local ray = tr.HitPos - tr.StartPos
	local u = n:Dot(vPos - tr.StartPos)/n:Dot(ray)
	return worldToScreen(tr.StartPos + u*ray, vPos, vScale, aRot)
end

local function isCursorOnButton(curX, curY, x, y, w, h)
	return curX > x and curX < x + w and curY > y and curY < y + h
end

-- Compute and define variables only once when possible
local black = Color(0, 0, 0, 255)
local black2 = Color(0, 0, 0, 240)
local black3 = Color(50, 50, 50, 240)
local gray = Color(150, 150, 150, 255)
local white = Color(255, 255, 255, 255)
local red2 = Color(100, 0, 0, 240)
local red3 = Color(150, 0, 0, 240)

local scrScale = 0.05
local scrSizeX = 14*3.5*(1/scrScale)
local scrSizeY = 9*3.5*(1/scrScale)
local scrCenterX = scrSizeX/2
local scrCenterY = scrSizeY/2

local button1W = 10.5/scrScale
local button1H = 3.5/scrScale
local button1X = 8/scrScale
local button1Y = 37.5/scrScale

local button2W = 10.5/scrScale
local button2H = 3.5/scrScale
local button2X = 29/scrScale
local button2Y = 37.5/scrScale

local button3W = 16/scrScale
local button3H = 4/scrScale
local button3X = (button1X + button1W/2 + button2X + button2W/2)/2 - button3W/2
local button3Y = 42/scrScale

local button1TextX = button1X + button1W/2
local button1TextY = button1Y + button1H/2

local button2TextX = button2X + button2W/2
local button2TextY = button2Y + button2H/2

local button3TextX = button3X + button3W/2
local button3TextY = button3Y + button3H/2

local titleScale = 0.05
local titleSizeX = 35/titleScale
local titleSizeY = 7/titleScale
local titleCenterX = titleSizeX/2
local titleCenterY = titleSizeY/2

function ENT:Draw()
	self:DrawModel()

	-- Draw the map and buttons
	local camPos = self:GetPos() + self:GetForward()*27 + self:GetUp()*49 - self:GetRight()*15
	local camAngle = self:LocalToWorldAngles(Angle(90, 0, 0))
	local curX, curY = getScreenCursorPos(LocalPlayer():GetEyeTrace(), camPos, scrScale, camAngle)
	cam.Start3D2D(camPos, camAngle, scrScale)
		surface.SetDrawColor(black)
		surface.DrawRect(0, 0, scrSizeX, scrSizeY)
		draw.SimpleText("WARP DRIVE OFFLINE", "WarpDriveConsole", scrCenterX, scrCenterY, Color(204, 0, 0, math.abs(math.sin(CurTime()))*255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		-- <Prev button
		surface.SetDrawColor(black2)
		if isCursorOnButton(curX, curY, button1X, button1Y, button1W, button1H) then
			surface.SetDrawColor(black3)
		end
		surface.DrawRect(button1X, button1Y, button1W, button1H)
		draw.SimpleText("<Prev", "WarpDriveConsole", button1TextX, button1TextY, gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		-- Next> button
		surface.SetDrawColor(black2)
		if isCursorOnButton(curX, curY, button2X, button2Y, button2W, button2H) then
			surface.SetDrawColor(black3)
		end
		surface.DrawRect(button2X, button2Y, button2W, button2H)
		draw.SimpleText("Next>", "WarpDriveConsole", button2TextX, button2TextY, gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		-- JUMP! button
		surface.SetDrawColor(red2)
		if isCursorOnButton(curX, curY, button3X, button3Y, button3W, button3H) then
			surface.SetDrawColor(red3)
		end
		surface.DrawRect(button3X, button3Y, button3W, button3H)
		draw.SimpleText("JUMP!", "WarpDriveConsole", button3TextX, button3TextY, gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	cam.End3D2D()

	-- Draw the location or jump drive bar
	cam.Start3D2D(self:GetPos() + self:GetForward()*31.8 + self:GetUp()*45 - self:GetRight()*28.5, self:LocalToWorldAngles(Angle(90, -19, 0)), titleScale)
		surface.SetDrawColor(black2)
		surface.DrawRect(0, 0, titleSizeX, titleSizeY)

		draw.SimpleText("[Unknown location]", "WarpDriveConsole", titleCenterX, titleCenterY, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end
