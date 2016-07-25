AddCSLuaFile()

VECTOR3 = {}
VECTOR3.__index = VECTOR3

debug.getregistry().Vector3 = VECTOR3

function isvector3( v )
	return v and istable(v) and getmetatable(v) == VECTOR3
end

_TypeID = _TypeID or TypeID

function TypeID( ... )
	local args = {...}
	if args[1] and istable(args[1]) and isvector3(args[1]) then
		return 253
	end
	return _TypeID(...)
end

net.WriteVars[253] = function( t, v ) 
	net.WriteUInt( t, 8 ) -- Is this length, if so, probably a good idea to increase it.
	net.WriteVector3( v )
end

net.ReadVars[253] = function() 
	return net.ReadVector3()
end


function VECTOR3.new( x, y, z )
	local self = {}
	setmetatable( self, VECTOR3 )
	
	self.x = x or 0
	self.y = y or 0
	self.z = z or 0
	
	return self
end

local function Vector3( x, y, z )

	x = x or 0
	y = y or 0	
	z = z or 0
	
	if isnumber(x) and isnumber(y) and isnumber(z) then
		return VECTOR3.new( x, y, z )
	elseif isvector3(x) or isvector(x) then
		return VECTOR3.new(x.x, x.y, x.z)
	end
end
GrandEspace.Vector3 = Vector3

function net.WriteVector3( v )
	assert(isvector3(v))
	net.WriteDouble(v.x)
	net.WriteDouble(v.y)
	net.WriteDouble(v.z)
end

function net.ReadVector3( )
	local x = net.ReadDouble()
	local y = net.ReadDouble()
	local z = net.ReadDouble()
	return Vector3(x,y,z)
end




function VECTOR3:__tostring()
	return tostring(self.x) .. " " .. tostring(self.y) .. " " .. tostring(self.z)
end

function VECTOR3.__unm( self )
	return Vector3( -self.x, -self.y, -self.z )
end

function VECTOR3.__add( a1, a2 )
	return Vector3( a1.x + a2.x, a1.y + a2.y, a1.z + a2.z )
end

function VECTOR3.__sub( a1, a2 )
	return a1 + (-a2)
end

function VECTOR3.__mul( a1, a2 )
	if isnumber(a2) then
		a1, a2 = a2, a1
	end
	if not isnumber(a1) or not isvector3(a2) then
		error("VECTOR3 can only be multiplied by a number.")
	end 
	return Vector3( a2.x*a1, a2.y*a1, a2.z*a1 )
end

function VECTOR3.__div( a1, a2 )
	if not isnumber(a2) or not isvector3(a1) then
		error("VECTOR3 can only be divided by a number.")
	end
	return a1 * (1/a2)
end

function VECTOR3.__eq( a1, a2 )
	return a1.x == a2.x and a1.y == a2.y and a1.z == a2.z
end

function VECTOR3:LengthSqr()
	return self.x * self.x + self.y * self.y + self.z * self.z
end

function VECTOR3:Length()
	return math.sqrt( self:LengthSqr() )
end

function VECTOR3:Distance( a )
	assert(isvector3(a))
	return (self-a):Length()
end

function VECTOR3:Set( a )
	self.x = a.x
	self.y = a.y 
	self.z = a.z
end

function VECTOR3:GetNormalized( )
	return self/self:Length()
end