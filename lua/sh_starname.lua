AddCSLuaFile()

local nextLetter = {}
local memoryLen = 3

local function generateName( length )
    local last = ""
    local name = ""
    for i=1, length do
        r = math.random()
        local stop = false
        if nextLetter[last] then
            for c,_ in pairs(nextLetter[last]) do
                if not stop then
                    r = r-nextLetter[last][c]
                    if r < 0 then
                        name = name .. c
                        last = last .. c
                        if #last > memoryLen then
                            last = string.sub(last, 2, #last)
                        end
                        stop = true
                    end
                end
            end
        elseif nextLetter["BEGIN"] and last == "" then
        	
			for c,_ in pairs(nextLetter["BEGIN"]) do
                if not stop then
                    r = r-nextLetter["BEGIN"][c]
                    if r < 0 then
                        name = name .. c
                        last = last .. c
                        if #last > memoryLen then
                            last = string.sub(last, 2, #last)
                        end
                        stop = true
                    end
                end
            end
        else
            c = string.char(math.random(97,122))
            name = name .. c
            last = last .. c
            if #last > memoryLen then
                last = string.sub(last, 2, #last)
            end
        end
    end
     
                
                
    return string.upper(name[1]) .. string.sub(name, 2, #name)
end

local forcedNames = {}
forcedNames[0] = "Solar"

function GrandEspace.getStarName( id )

    id = tonumber(id)
    if forcedNames[id] then
        return forcedNames[id]
    end

    math.randomseed(id)
    local name = generateName(math.random(5,10))
    math.randomseed(SysTime())

    return name
end

http.Fetch("https://dl.dropboxusercontent.com/u/47284930/jsonnames.txt", function(str, len)
	nextLetter =  util.JSONToTable(str)
end)