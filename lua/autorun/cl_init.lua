if SERVER then return end

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

GrandEspace = {}

include("grandespace/cl_thirdperson.lua")
include("grandespace/cl_spacerendering.lua")
include("grandespace/shared.lua")
include("grandespace/cl_hud.lua")