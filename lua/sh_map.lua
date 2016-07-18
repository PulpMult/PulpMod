if SERVER then

	AddCSLuaFile()

	util.AddNetworkString("GrandEspace - Show map")

	hook.Add("ShowSpare1", "GrandEspace - Show map", function( ply )

		if not IsValid(ply) then return end

		net.Start("GrandEspace - Show map")
		net.Send(ply)

	end)

else

	local Vector2 = GrandEspace.Vector2
	local surface = surface

	local GALAXY_SIZE = 10
	local MAX_ZOOM_COEF = 3

	local material_map = {}
	for zoomCoef=0, MAX_ZOOM_COEF do

		local zoom = math.pow(2, zoomCoef)
		material_map[zoomCoef+1] = {}

		for x=0, zoom-1 do

			material_map[zoomCoef+1][x+1] = {}
			for y=0, zoom-1 do
				local path = "materials/zoom" .. tostring(zoom) .. "/map" .. tostring(x) .. "x" .. tostring(y) .. ".png"
				material_map[zoomCoef+1][x+1][y+1] = Material( path )
			end
		end
		
	end 	

	function GrandEspace.drawGrid ( x0, y0, w, h, window, gridSpace, gridColor)
	
		surface.SetDrawColor( gridColor )

		local pxPerUnit = window.pixelPerUnit

		local lineCountX = math.floor(w / pxPerUnit / gridSpace)
		lineCountX = lineCountX + lineCountX%2
		local offsetX0 = (-window.pos.x % gridSpace) * pxPerUnit

		for i=-lineCountX/2, lineCountX/2 do
			
			local offset = w/2 + offsetX0 + i * gridSpace * pxPerUnit 
			surface.DrawLine(x0+offset, y0, x0+offset, y0+h )

		end

		local lineCountY = math.floor(h / pxPerUnit / gridSpace)
		lineCountY = lineCountY + lineCountY%2
		local offsetY0 = (-window.pos.y % gridSpace) * pxPerUnit

		for i=-lineCountY/2, lineCountY/2 do
			
			local offset = h/2 + offsetY0 + i * gridSpace * pxPerUnit
			surface.DrawLine(x0, y0+offset, x0+w, y0+offset )

		end

		surface.DrawLine(x0-5+w/2,y0-5+h/2,x0+5+w/2,y0+5+h/2)
		surface.DrawLine(x0-5+w/2,y0+5+h/2,x0+5+w/2,y0-5+h/2)

	end

	local function isRectInRect( pos1, size1, pos2, size2)

		assert( pos1 and size1 and pos2 and size2)

		local diff = pos2 - pos1
		local n1 = math.max( math.abs(diff.x) / size1.x, math.abs(diff.y) / size1.y )
		local proj = diff / n1
		local diff2 = proj + pos1 - pos2
		local n2 = math.max( math.abs(diff2.x) / size2.x, math.abs(diff2.y) / size2.y )

		return n1 <= 1 or n2 <= 1

	end

	local function drawImages( x0, y0, w, h, window, zoom )

		assert(w and h and window and zoom)

		local nbRowImages = math.pow(2, zoom-1)

		local pos1 = Vector2(w, h) / 2
		local size1 = Vector2(w,h) / 2

		local size2 = Vector2( 1, 1 ) * GALAXY_SIZE / nbRowImages * window.pixelPerUnit
		
		local posOriginToScreen = pos1 + size2 - nbRowImages * size2 + ( Vector2() - window.pos ) * window.pixelPerUnit

		for x=0, nbRowImages-1 do
			for y=0, nbRowImages-1 do

				local pos2 = posOriginToScreen + Vector2(x,y) * size2.x * 2
				if isRectInRect( pos1, size1, pos2, size2 ) then

					surface.SetMaterial( material_map[zoom][x+1][y+1] )
					surface.DrawTexturedRect( x0+pos2.x - size2.x, y0+pos2.y - size2.y, size2.x*2, size2.y*2 )

				end
			end
		end

	end

	function GrandEspace.drawStars( x0, y0, w, h, window )

		assert(w and h and window)

		local zoom = math.log( 10 / (h / window.pixelPerUnit), 2 ) + 1

		local zoom1 = math.floor(zoom)
		local zoom2 = zoom1 + 1

		local coef = zoom%1

		surface.SetDrawColor( Color(255,255,255,255 * (1-coef) ) )
		drawImages( x0, y0, w, h, window, math.Clamp(zoom1, 1, 4) )

		surface.SetDrawColor( Color(255,255,255,255 * coef) )
		drawImages( x0, y0, w, h, window, math.Clamp(zoom2, 1, 4) )

	end

	local drawStars = function( w, h, window )
		return GrandEspace.drawStars( 0, 0, w, h, window)
	end
	local drawGrid = function( w, h, window, gridSpace, gridColor )
		return GrandEspace.drawGrid( 0, 0, w, h, window, gridSpace, gridColor)
	end
	

	local PANEL = {}

	function PANEL:Init( )

		self.grabbed = false
		self.grabPosX, self.grabPosY = 0,0
		self.grabInitPos = Vector2()

		self.window = { 
			pixelPerUnit = 80*0+200, -- Px*GalaxyUnit⁻¹
			pos = Vector2() 
		}

		self.gridSpace = 1 -- In GalaxyUnit

	end

	function PANEL:setGalaxyPos( p )

		self.window.pos = assert( p )

	end

	local vertices = {{}, {}, {}, {}}

	function PANEL:Paint( w, h )

		local pxPerUnit = self.window.pixelPerUnit
		local windowPos = self.window.pos
		
		surface.SetDrawColor( 25, 25, 25, 255 )
		surface.DrawRect(0,0,w,h)

		drawStars( w, h, self.window )
		drawGrid( w, h, self.window, self.gridSpace, Color(100,100,100))

		local a,b = self:LocalCursorPos()
		local cursorPos = ( Vector2(a,b) - Vector2(w,h)/2) / pxPerUnit + windowPos

		local result = sql.Query("SELECT * FROM " .. GrandEspace.sqlStarTable .. " WHERE ((X-(" .. cursorPos.x .."))*(X-(" .. cursorPos.x .."))+(Y-(" .. cursorPos.y .."))*(Y-(" .. cursorPos.y .."))) <= " .. math.pow(20/pxPerUnit,2) .. " ORDER BY ((X-(" .. cursorPos.x .."))*(X-(" .. cursorPos.x .."))+(Y-(" .. cursorPos.y .."))*(Y-(" .. cursorPos.y .."))) LIMIT 1")
		if result then

			draw.NoTexture()

			local posStar = Vector2(tonumber(result[1].x), tonumber(result[1].y))
	
			local posStarScreen = Vector2(w,h)/2 + (posStar - windowPos) * pxPerUnit

			local str = GrandEspace.getStarName( tonumber(result[1].id) )

			local textw,texth = surface.GetTextSize( str ) 
			local rectW, rectH = 0.05*pxPerUnit, 0.05*pxPerUnit

			surface.SetFont( "TargetID" )
			surface.SetTextColor( 255, 255, 255, 255 )
			surface.SetTextPos( posStarScreen.x - textw/2, posStarScreen.y - texth - rectH )
			surface.DrawText( str )

			vertices[4].x = posStarScreen.x 
			vertices[4].y = posStarScreen.y - rectH

			vertices[3].x = posStarScreen.x - rectW
			vertices[3].y = posStarScreen.y

			vertices[2].x = posStarScreen.x 
			vertices[2].y = posStarScreen.y + rectH

			vertices[1].x = posStarScreen.x + rectW
			vertices[1].y = posStarScreen.y

	
			surface.SetDrawColor( Color(255,255,255,255) )
			surface.DrawPoly(vertices)
			surface.SetDrawColor( Color(255,255,255,255) )
			
			surface.DrawLine(posStarScreen.x-rectW*2, posStarScreen.y,posStarScreen.x+rectW*2, posStarScreen.y)
			surface.DrawLine(posStarScreen.x, posStarScreen.y-rectH*2,posStarScreen.x, rectH*2+posStarScreen.y)

		end

	end

	function PANEL:grab()

		self.grabbed = true		
		self.grabPosX, self.grabPosY = self:LocalCursorPos()	
		self.grabInitPos = self.window.pos
		self:SetCursor("sizeall")

	end

	function PANEL:ungrab()

		self.grabbed = false
		self:SetCursor("user")

	end

	function PANEL:OnMousePressed( keycode )

		if keycode == MOUSE_MIDDLE  then
			self:grab()
		end

	end

	function PANEL:OnMouseReleased( keycode )

		if keycode == MOUSE_MIDDLE  then
			self:ungrab()
		end

	end

	function PANEL:OnCursorExited() 
		self:ungrab()
	end

	function PANEL:OnMouseWheeled( sd )

		self.window.pixelPerUnit = math.Clamp(self.window.pixelPerUnit + sd*10, self:GetTall()/10 , 1200)

	end

	function PANEL:OnCursorMoved( posX, posY )

		if not self.grabbed then return end

		local x = self.grabPosX - posX
		local y = self.grabPosY - posY

		self.window.pos = self.grabInitPos + Vector2(x,y) / self.window.pixelPerUnit

	end

	function PANEL:Think()

		local s = LocalPlayer():getSpaceship()
		if s then 
			self.window.pos = s:getGalaxyPos() --+ (s.velocity or Vector())*(SysTime()-s.lastUpdate)/1e6 
		end
	end

	vgui.Register( "GrandEspace - MapPanel", PANEL, "Panel" )

	local w,h = surface.ScreenWidth(), surface.ScreenHeight()

	local function showMap( )

		local scale = 0.80

		local mapFrame = vgui.Create( "DFrame" )
		mapFrame:SetPos( (w*(1-scale))/2, (h*(1-scale))/2 +100)
		mapFrame:SetSize( w*scale, h*scale )
		mapFrame:SetTitle( "MAP" )
		mapFrame:MakePopup()

		local mapPanel = mapFrame:Add("GrandEspace - MapPanel")
		mapPanel:SetPos(2,24)
		mapPanel:SetSize(w*scale - 4, h*scale - 26)

	end

	net.Receive("GrandEspace - Show map", function()

		showMap()
		
	end)

end



