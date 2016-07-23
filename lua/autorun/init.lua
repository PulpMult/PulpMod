if CLIENT then return end

local banner = [[           _____                     _ ______                          
          / ____|                   | |  ____|                         
         | |  __ _ __ __ _ _ __   __| | |__   ___ _ __   __ _  ___ ___ 
         | | |_ | '__/ _` | '_ \ / _` |  __| / __| '_ \ / _` |/ __/ _ \
         | |__| | | | (_| | | | | (_| | |____\__ \ |_) | (_| | (_|  __/
          \_____|_|  \__,_|_| |_|\__,_|______|___/ .__/ \__,_|\___\___|
                                                 | |                   
                                                 |_|                   
]]
print(banner)

local function addCSLuaFileRecursive( path )

	local f, d = file.Find( path .. "*", "LUA")
	for k,v in pairs(f) do
		local prefix = string.sub(v,1,2)
		if prefix == "sh" or prefix == "cl" then
			print(" - " .. path .. v)
			AddCSLuaFile(path..v)
		end
	end
	for k,v in pairs(d) do
		explore(path .. v .. "/")
	end
	
end

GrandEspace = {}

print("AddCSLuaFile:")
print(" - cl_init.lua")
AddCSLuaFile("cl_init.lua")
print(" - grandespace/shared.lua")
AddCSLuaFile("grandespace/shared.lua")
addCSLuaFileRecursive("grandespace/")


include("grandespace/shared.lua")
include("grandespace/sv_resources.lua")





