AddCSLuaFile()

VECTOR2 = {}
VECTOR2.__index = VECTOR2

debug.getregistry().Vector2 = VECTOR2

function isvector2( v )
	return v and istable(v) and getmetatable(v) == VECTOR2
end

_TypeID = _TypeID or TypeID

function TypeID( ... )
	local args = {...}
	if args[1] and istable(args[1]) and isvector2(args[1]) then
		return 254
	end
	return _TypeID(...)
end

net.WriteVars[254] = function( t, v ) 
	net.WriteUInt( t, 8 )
	net.WriteVector2( v )
end

net.ReadVars[254] = function() 
	return net.ReadVector2()
end


function VECTOR2.new( x, y )
	local self = {}
	setmetatable( self, VECTOR2 )
	
	self.x = x or 0
	self.y = y or 0
	
	return self
end

local function Vector2( x, y )

	x = x or 0
	y = y or 0	
	if isnumber(x) and isnumber(y) then
		return VECTOR2.new( x, y )
	elseif isvector2(x) or isvector(x) then
		return VECTOR2.new(x.x, x.y)
	end
end
GrandEspace.Vector2 = Vector2

function net.WriteVector2( v )
	assert(isvector2(v))
	net.WriteDouble(v.x)
	net.WriteDouble(v.y)
end

function net.ReadVector2( )
	local x = net.ReadDouble()
	local y = net.ReadDouble()
	return Vector2(x,y)
end




function VECTOR2:__tostring()
	return tostring(self.x) .. " " .. tostring(self.y)
end

function VECTOR2.__unm( self )
	return Vector2( -self.x, -self.y )
end

function VECTOR2.__add( a1, a2 )
	return Vector2( a1.x + a2.x, a1.y + a2.y )
end

function VECTOR2.__sub( a1, a2 )
	return a1 + (-a2)
end

function VECTOR2.__mul( a1, a2 )
	if isnumber(a2) then
		a1, a2 = a2, a1
	end
	if not isnumber(a1) or not isvector2(a2) then
		error("VECTOR2 can only be multiplied by a number.")
	end 
	return Vector2( a2.x*a1, a2.y*a1 )
end

function VECTOR2.__div( a1, a2 )
	if not isnumber(a2) or not isvector2(a1) then
		error("VECTOR2 can only be divided by a number.")
	end
	return a1 * (1/a2)
end

function VECTOR2.__eq( a1, a2 )
	return a1.x == a2.x and a1.y == a2.y
end

function VECTOR2:LengthSqr()
	return self.x * self.x + self.y * self.y
end

function VECTOR2:Length()
	return math.sqrt( self:LengthSqr() )
end

function VECTOR2:Distance( a )
	assert(isvector2(a))
	return (self-a):Length()
end

function VECTOR2:Set( a )
	self.x = a.x
	self.y = a.y 
end

function VECTOR2:GetNormalized( )
	return self/self:Length()
end