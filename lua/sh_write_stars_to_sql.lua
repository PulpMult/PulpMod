AddCSLuaFile()

GrandEspace.sqlStarTable = "GrandEspace_stars"

GrandEspace.starTable = {}

local TABLE_NAME = GrandEspace.sqlStarTable

if sql.TableExists(TABLE_NAME) then
	print("The star table already exists.")
	--return
end

local startTime = SysTime() 


http.Fetch("https://dl.dropboxusercontent.com/u/47284930/milkyway.txt", function(str, len)

	print("Downloaded " ..tostring(len) .. " bytes of data.")

	sql.Begin()
	sql.Query("DROP TABLE IF EXISTS "..TABLE_NAME)
	sql.Query("CREATE TABLE "..TABLE_NAME.."(id INTEGER, x FLOAT, y FLOAT, z FLOAT)")


	local t = string.Split(str, "\n")
	local stars = {}

	for k,v in pairs( t ) do
		if v == "" then
			continue
		end
		local data = string.Split(v, ",")

		sql.Query("INSERT INTO "..TABLE_NAME.." VALUES ("..data[1]..","..data[3]..","..data[2]..","..data[4]..")")
		GrandEspace.starTable[tonumber(data[1])] = Vector(tonumber(data[3]),tonumber(data[2]),tonumber(data[4]))
	    
	end
	sql.Commit()



	print("Wrote " .. tostring(#t) .. " stars in the SQL table in " .. tostring(SysTime()-startTime) .."s")

end,
function()
	print("Could not download the star map.")

end)