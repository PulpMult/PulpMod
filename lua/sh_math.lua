AddCSLuaFile()

Vec2 = {}
Vec2.__index = Vec2

Vec2.__call = function( self, x, y )
	return self.new( x, y )
end

Vec2.__unm = function( self )
	return Vec2( -self.x, -self.y )
end

Vec2.__add = function( a1, a2 )
	return Vec2( a1.x + a2.x, a1.y + a2.y )
end

Vec2.__sub = function( a1, a2 )
	return Vec2( a1.x - a2.x, a1.y - a2.y )
end

Vec2.__mul = function( a1, a2 )
	
end

function Vec2.new( x, y )
	self = setmetatable( {}, Vec2 )
	
	self.x = x or 0
	self.y = y or 0
	
	return self
end