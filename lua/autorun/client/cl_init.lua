local memoryUsage = {} 

local lastTime = 0
local cursor = 0
local NUM = 100

local timeToRunHUD = {}
local memUsedByHUD = {}
local lastUpdateHUD = 0

local cursorHUD = 1

function hud_usageInfo( time, mem )

	timeToRunHUD[cursorHUD] = time
	memUsedByHUD[cursorHUD] = mem
	lastUpdateHUD = SysTime()

	cursorHUD = (cursorHUD + 1)%20



end

local valueToDisplay = 0
local memHUDToDisplay = 0
local timeHUDToDisplay = 0
timer.Create("refreshMemCount",0.1,0, function()
	
	local a = 0
	for k,v in pairs(memoryUsage) do
		a = a + v
	end
	a = a / NUM
	--a = a /(CurTime()-lastTime)
	valueToDisplay = a

	local timeHUD = 0
	local memHUD = 0
	for k,v in pairs(timeToRunHUD) do
		timeHUD = timeHUD + v
		memHUD = memHUD + memUsedByHUD[k]
	end

	timeHUD = timeHUD / #timeToRunHUD
	memHUD = memHUD / #memUsedByHUD

	memHUDToDisplay = memHUD
	timeHUDToDisplay = timeHUD

end)


local lastMem = 0
hook.Add("HUDPaint", "Mem counter", function()

		local mem = collectgarbage("count")
		local a = 0
		cursor = (cursor + 1)%NUM+1
		memoryUsage[cursor] = (-lastMem+mem)/(SysTime()-lastTime)
		

		local a = valueToDisplay


		draw.DrawText("Memory eating speed: "..tostring(a).." kb/s", "Trebuchet24", 100, 100-25, Color(255,255,255), TEXT_ALIGN_LEFT  ) 
		draw.DrawText("Memory usage: ".. tostring(mem).."kb", "Trebuchet24", 100, 100-50, Color(255,255,255), TEXT_ALIGN_LEFT  ) 

		lastMem = mem
		lastTime = SysTime()


		local col = Color(0,255,0)
		if SysTime()-lastUpdateHUD > 0.1 then
			col = Color(255,0,0)
		end

		if #timeToRunHUD > 0 then

			draw.DrawText("Delta Memory usage: ".. tostring(math.Round(memHUDToDisplay,1)).."kb/s", "Trebuchet24", 100, 100, col, TEXT_ALIGN_LEFT  ) 
			draw.DrawText("Time to run: ".. tostring(math.Round(timeHUDToDisplay*1000*1000,1)).."us", "Trebuchet24", 100, 125, col, TEXT_ALIGN_LEFT  ) 

		end

end)
