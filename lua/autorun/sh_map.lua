if SERVER then

	util.AddNetworkString("Grand_Espace - Show map")

	hook.Add("ShowSpare1", "Grand_Espace - Show map", function( ply )

		if not IsValid(ply) then return end

		net.Start("Grand_Espace - Show map")
		net.Send(ply)

	end)

else

	local surface = surface

	local GALAXY_SIZE = 10
	local MAX_ZOOM_COEF = 3
	---local IMAGE_SIZE  = 1000

	local function drawGrid( w, h, window, gridSpace, gridColor)
	
		surface.SetDrawColor( gridColor )

		local pxPerUnit = window.pixelPerUnit

		local lineCountX = math.floor(w / pxPerUnit / gridSpace)
		lineCountX = lineCountX + lineCountX%2
		local offsetX0 = (-window.pos.x % gridSpace) * pxPerUnit

		for i=-lineCountX/2, lineCountX/2 do
			
			local offset = w/2 + offsetX0 + i * gridSpace * pxPerUnit 
			surface.DrawLine(offset, 0, offset, h )

		end

		local lineCountY = math.floor(h / pxPerUnit / gridSpace)
		lineCountY = lineCountY + lineCountY%2
		local offsetY0 = (-window.pos.y % gridSpace) * pxPerUnit

		for i=-lineCountY/2, lineCountY/2 do
			
			local offset = h/2 + offsetY0 + i * gridSpace * pxPerUnit
			surface.DrawLine(0, offset, w, offset )

		end

		surface.DrawLine(-5+w/2,-5+h/2,5+w/2,5+h/2)
		surface.DrawLine(-5+w/2,5+h/2,5+w/2,-5+h/2)


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

	local material_map = {}
	for zoomCoef=0, MAX_ZOOM_COEF do

		local zoom = math.pow(2, zoomCoef)
		material_map[zoomCoef+1] = {}

		for x=0, zoom-1 do

			material_map[zoomCoef+1][x+1] = {}
			for y=0, zoom-1 do
				local path = "data/zoom" .. tostring(zoom) .. "/map" .. tostring(x) .. "x" .. tostring(y) .. ".png"
				material_map[zoomCoef+1][x+1][y+1] = Material( path )
			end
		end
		
	end 


	local function drawImages( w, h, window, zoom )

		assert(w and h and window and zoom)

		local nbRowImages = math.pow(2, zoom-1)

		local pos1 = Vector(w, h) / 2
		local size1 = Vector(w,h) / 2

		local size2 = Vector(1,1) * GALAXY_SIZE / nbRowImages * window.pixelPerUnit
		local posOriginToScreen = pos1 + size2 - nbRowImages*size2 + (Vector()-window.pos)*window.pixelPerUnit


		for x=0, nbRowImages-1 do

			for y=0, nbRowImages-1 do

				local pos2 = posOriginToScreen + Vector(x,y) * size2 * 2

				if isRectInRect( pos1, size1, pos2, size2 ) then
				
					--zmath.randomseed(1000*x+y)
					--surface.SetDrawColor(Color(math.random(0,255),math.random(0,255),math.random(0,255)))
					
					surface.SetMaterial( material_map[zoom][x+1][y+1] )
					surface.DrawTexturedRect( pos2.x - size2.x, pos2.y - size2.y, size2.x*2, size2.y*2 )

					--[[
					surface.SetFont( "DermaLarge" )
					surface.SetTextColor( 255, 255, 255, 255 )
					surface.SetTextPos( pos2.x, pos2.y )
					surface.DrawText( tostring(x) .."x" .. tostring(y) )
					]]

				end
			end
		end

		--surface.SetDrawColor(Color(255,0,0))
		--surface.DrawRect(10+50,50,100,100)

	end

	local function drawStars( w, h, window )

		assert(w and h and window)

		local zoom = math.log( 10 / (h / window.pixelPerUnit), 2 ) + 1

		local zoom1 = math.floor(zoom)
		local zoom2 = zoom1 + 1

		local coef = zoom%1

		surface.SetDrawColor( Color(255,255,255,255 * (1-coef) ) )
		drawImages( w, h, window, math.Clamp(zoom1, 1, 4) )

		surface.SetDrawColor( Color(255,255,255,255 * coef) )
		drawImages( w, h, window, math.Clamp(zoom2, 1, 4) )

	end


	local PANEL = {}

	function PANEL:Init( )

		self.grabbed = false
		self.grabPosX, self.grabPosY = 0,0
		self.grabInitPos = Vector()

		self.window = { 
			pixelPerUnit = 80*0+200, -- Px*GalaxyUnit⁻¹
			pos = Vector() 
		}

		self.gridSpace = 1 -- In GalaxyUnit

	end

	function PANEL:setGalaxyPos( p )

		self.window.pos = assert( p )

	end

	local vertices = {{}, {}, {}, {}}

	function PANEL:Paint( w, h )

		local startTime = SysTime()
		local startMem = collectgarbage("count")

		local pxPerUnit = self.window.pixelPerUnit
		local windowPos = self.window.pos
		
		surface.SetDrawColor( 25, 25, 25, 255 )
		surface.DrawRect(0,0,w,h)

		
		drawStars( w, h, self.window )
		drawGrid( w, h, self.window, self.gridSpace, Color(100,100,100))

		local a,b = self:LocalCursorPos()
		local cursorPos = ( Vector(a,b) - Vector(w,h)/2) / pxPerUnit + windowPos


		local result = sql.Query("SELECT * FROM " .. Grand_Espace_TABLE_NAME .. " WHERE ((X-(" .. cursorPos.x .."))*(X-(" .. cursorPos.x .."))+(Y-(" .. cursorPos.y .."))*(Y-(" .. cursorPos.y .."))) <= " .. math.pow(20/pxPerUnit,2) .. " ORDER BY ((X-(" .. cursorPos.x .."))*(X-(" .. cursorPos.x .."))+(Y-(" .. cursorPos.y .."))*(Y-(" .. cursorPos.y .."))) LIMIT 1")
		if result then

			draw.NoTexture()

			local posStar = Vector(result[1].x, result[1].y)
			local posStarScreen = Vector(w,h)/2 + (posStar - windowPos) * pxPerUnit

			local str = tostring(result[1].id) 
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
		--print(result2)

		local dt = SysTime() - startTime
		hud_usageInfo(dt, (collectgarbage("count") - startMem)/dt)



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



		self.window.pos = self.grabInitPos + Vector(x,y) / self.window.pixelPerUnit

	end

	function PANEL:Think()

		--local t = CurTime()
		--*self:setGalaxyPos( LocalPlayer():getGalaxyPos() )

	end

	vgui.Register( "Grand_Espace - MapPanel", PANEL, "Panel" )

	local w,h = surface.ScreenWidth(), surface.ScreenHeight()

	local function showMap( )

		local scale = 0.80

		local mapFrame = vgui.Create( "DFrame" )
		mapFrame:SetPos( (w*(1-scale))/2, (h*(1-scale))/2 +100)
		mapFrame:SetSize( w*scale, h*scale )
		mapFrame:SetTitle( "MAP" )
		mapFrame:MakePopup()

		local mapPanel = mapFrame:Add("Grand_Espace - MapPanel")
		mapPanel:SetPos(2,24)
		mapPanel:SetSize(w*scale - 4, h*scale - 26)


	end

	net.Receive("Grand_Espace - Show map", function()
		showMap()
		
	end)

end



