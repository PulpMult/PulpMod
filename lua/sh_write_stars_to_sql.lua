AddCSLuaFile()

Grand_Espace_TABLE_NAME = "GrandEspace_stars"
local TABLE_NAME = Grand_Espace_TABLE_NAME

if sql.TableExists(TABLE_NAME) then
	print("The star table already exists.")
	--return
end

local startTime = SysTime() 

http.Fetch("https://dl.dropboxusercontent.com/u/47284930/galaxy.txt", function(str, len)

	print("Downloaded " ..tostring(len) .. " bytes of data.")

	sql.Begin()
	sql.Query("DROP TABLE IF EXISTS "..TABLE_NAME)
	sql.Query("CREATE TABLE "..TABLE_NAME.."(id INTEGER, x FLOAT, y FLOAT)")


	local t = string.Split(str, "\n")
	local stars = {}

	for k,v in pairs( t ) do
		if v == "" then
			continue
		end
		local data = string.Split(v, ",")

		sql.Query("INSERT INTO "..TABLE_NAME.." VALUES ("..data[1]..","..data[3]..","..data[2]..")")
	    
	end
	sql.Commit()



	print("Wrote the stars in the SQL table in " .. tostring(SysTime()-startTime) .."s")

end,
function()
	print("Could not download the star map.")

end)