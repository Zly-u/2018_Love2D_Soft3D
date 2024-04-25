--[[   
   vectorial3.lua ver 0.2 - A library for 3D vectors.
   Copyright (C) 2015 Leo Tindall

   ---
    All operators work as expected except modulo (%) which is vector distance and concat (..) which is linear distance.
   ---

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software Foundation,
   Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
]]
local module = {}
module.Vector3D = function(ix, iy, iz)
	local v3d = {}
	v3d.v = {}
	v3d.v.x = ix
	v3d.v.y = iy
	v3d.v.z = iz
	mt = {} --Metatable

	function v3d:deepcopy(orig) --Deeply copy a table. This is for the operation metatables.
		local orig_type = type(orig)
		local copy
		if orig_type == 'table' then
			copy = {}
			for orig_key, orig_value in next, orig, nil do
				copy[self:deepcopy(orig_key)] = self:deepcopy(orig_value)
			end
			setmetatable(copy, self:deepcopy(getmetatable(orig)))
		else -- number, string, boolean, etc
			copy = orig
		end
		return copy
	end

	--Vector Specific Math

	function v3d:getAngle() --Return the 3D angle (heading, carom) of the vector IN RADIANS!.
		hdg = math.atan2(self:getY(), self:getX())
		crm = math.atan2(self:getZ(), 0)
		return hdg, crm
	end

	--[[
	function v3d:getLength() --Return the length of the vector (i.e. the distance from (0,0), see README.md for examples of using this)
		local origin = self:deepcopy(self) --Get a new vector to work with
		origin:setX(0) --Set the origin equal to the geometric origin
		origin:setY(0)
		origin:setZ(0)
		return self..origin --Linear distance from us to the origin
	end
	--]]

	--Modded part for matrixes by Zly(me)
	--Same shit as getLength()
	function v3d:getLength()
		return math.sqrt(self:getX()^2 + self:getY()^2 + self:getZ()^2);
	end

	function v3d:TransformCoordinates(vector, transformation)
		local x = (vector:getX() * transformation.m[1]) + (vector:getY() * transformation.m[5]) + (vector:getZ() * transformation.m[9])  + transformation.m[13];
		local y = (vector:getX() * transformation.m[2]) + (vector:getY() * transformation.m[6]) + (vector:getZ() * transformation.m[10]) + transformation.m[14];
		local z = (vector:getX() * transformation.m[3]) + (vector:getY() * transformation.m[7]) + (vector:getZ() * transformation.m[11]) + transformation.m[15];
		local w = (vector:getX() * transformation.m[4]) + (vector:getY() * transformation.m[8]) + (vector:getZ() * transformation.m[12]) + transformation.m[16];
		return module.Vector3D(x/w, y/w, z/w);
	end

	function v3d:normalize()
		local len = self:getLength();
		if len == 0 then
			return;
		end
		local num = 1/len;
		self:setX(self:getX()*num);
		self:setY(self:getY()*num);
		self:setZ(self:getZ()*num);
	end

	function module.dot(v1, v2)
		return v1:getX() * v2:getX() + v1:getY() * v2:getY() + v1:getZ() * v2:getZ();
	end

	function module.cross(v1,v2)
		local x = v1:getY()*v2:getZ() - v1:getZ()*v2:getY();
		local y = v1:getZ()*v2:getX() - v1:getX()*v2:getZ();
		local z = v1:getX()*v2:getY() - v1:getY()*v2:getX();
		return module.Vector3D(x, y, z);
	end

	function module.vectorUp()
		return module.Vector3D(0, 1, 0);
	end
	--END OF MODDED PART

	function module.average(vectors)
		local n = #vectors
		local tmp = module.Vector3D(0, 0, 0)
		local j = 1 --Position in new_vectors
		if n == 0 then
			error("average() called with 0 inputs!")
		end
		for i, vector in ipairs(vectors) do
			tmp = tmp + vector
		end
		return tmp / module.Vector3D(n, n, n)
	end



	--Comparisons
	mt.__eq = function(lhs, rhs)
		--Equal To operator for Vector3Ds
		return (lhs.getX() == rhs.getX()) and (lhs.getY() == rhs.getY()) and (lhs.getZ() == rhs.getZ())
	end

	mt.__lt = function(lhs, rhs)
		--Less Than operator for Vector3Ds
		return sqrt((lhs.getX()^2) + (lhs.getY()^2) + (lhs.getZ()^2)) < sqrt((rhs.getX()^2) + (rhs.getY()^2) + (lhs.getZ()^2)) --We do this to compute the linear value of the vector so that, for example, (a % b) < (c % d) will not be broken.
	end

	mt.__le = function(lhs, rhs)
		--Less Than Or Equal To operator for Vector3Ds
		return sqrt((lhs.getX()^2) + (lhs.getY()^2) + (lhs.getZ()^2)) <= sqrt((rhs.getX()^2) + (rhs.getY()^2) + (lhs.getZ()^2)) --We do this to compute the linear value of the vector so that, for example, (a % b) < (c % d) will not be broken.
	end

	--Operations

	function v3d:setX(x)
		self.v.x = x
	end

	function v3d:setY(y)
		self.v.y = y
	end

	function v3d:setZ(z)
		self.v.z = z
	end

	function v3d:getX()
		return self.v.x
	end

	function v3d:getY()
		return self.v.y
	end

	function v3d:getZ()
		return self.v.z
	end

	mt.__unm = function(rhs)
		--Unary Minus (negation) operator for Vector3Ds
		out = rhs:deepcopy(rhs) --Copy the operand for the output (else the output won't have metamethods)
		out:setX(-rhs:getX()) --Operate on the X property
		out:setY(-rhs:getY()) --Operate on the Y property
		out:setY(-rhs:getZ()) --Operate on the Z property
		return out
	end

	mt.__add = function(lhs, rhs)
		--Addition operator for Vector3Ds
		out = lhs:deepcopy(lhs)--Copy the operand for the output (else the output won't have metamethods)
		out:setX(lhs:getX() + rhs:getX()) --Operate on the X property
		out:setY(lhs:getY() + rhs:getY()) --Operate on the Y property
		out:setZ(lhs:getZ() + rhs:getZ()) --Operate on the Z property
		return out
	end

	--[[
	Vector3.prototype.subtract = function (otherVector) {
		return new Vector3(this.x - otherVector.x, this.y - otherVector.y, this.z - otherVector.z);
		};
	--]]
	mt.__sub = function(lhs, rhs)
		--Subtraction operator for Vector3Ds

		---[[
		out = lhs:deepcopy(lhs)--Copy the operand for the output (else the output won't have metamethods)
		out:setX(lhs:getX() - rhs:getX()) --Operate on the X property
		out:setY(lhs:getY() - rhs:getY()) --Operate on the Y property
		out:setZ(lhs:getZ() - rhs:getZ()) --Operate on the Z property
		return out;
		--]]
		--return module.Vector3D(lhs:getX() - rhs:getX(), lhs:getY() - rhs:getY(), lhs:getZ() - rhs:getZ());
	end

	mt.__mul = function(lhs, rhs)
		--Multiplication operator for Vector3Ds
		out = lhs:deepcopy(lhs)--Copy the operand for the output (else the output won't have metamethods)
		out:setX(lhs:getX() * rhs:getX()) --Operate on the X property
		out:setY(lhs:getY() * rhs:getY()) --Operate on the Y property
		out:setZ(lhs:getZ() * rhs:getZ()) --Operate on the Z property
		return out
	end

	mt.__div = function(lhs, rhs)
		--Division operator for Vector3Ds
		out = lhs:deepcopy(lhs)--Copy the operand for the output (else the output won't have metamethods)
		out:setX(lhs:getX() / rhs:getX()) --Operate on the X property
		out:setY(lhs:getY() / rhs:getY()) --Operate on the Y property
		out:setZ(lhs:getZ() / rhs:getZ()) --Operate on the Z property
		return out
	end
	
	mt.__mod = function(lhs, rhs)
		--Vector distance operator for Vector3Ds. Denoted by modulo (%)
		out = lhs:deepcopy(lhs)		--Copy the operand for the output (else the output won't have metamethods)
		out:setX(math.abs(rhs:getX() - lhs:getX())) --Operate on the X property
		out:setY(math.abs(rhs:getY() - lhs:getY())) --Operate on the Y property
		out:setZ(math.abs(rhs:getZ() - lhs:getZ())) --Operate on the Z property
		return out	
	end

	mt.__concat = function(lhs, rhs)
		--Linear distance operator for Vector3Ds. Denoted by concat (..)
		out = 0		--This is a linear operation, so no deepcopy. 
		out = math.sqrt(((rhs:getX() - lhs:getX())^2) + (((rhs:getY() - lhs:getY())^2) + ((rhs:getZ() - lhs:getZ())^2))) --Distance formula
		return out
	end

	mt.__tostring = function(s)
		--tostring handler for Vector3D
		out = ""	--This is a string operation, so no deepcopy.
		out = "[(X:"
		out = out .. s:getX() 
		out = out .. "),(Y:" 
		out = out .. s:getY() 
		out = out .. "),(Z:" 
		out = out .. s:getZ() 
		out = out .. ")]"
		return out
	end
	
	setmetatable(v3d, mt)

	return v3d
end
return module
