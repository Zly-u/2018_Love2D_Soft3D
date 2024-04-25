local v3d       = require("libs/vectorial/vectorial3");
local matrix = {}

--MAIN FUNCTIONS
function matrix:new()
    local mat = {
        m = {},
    };

    setmetatable(mat, self);
    self.__index = self;
    return mat;
end

function matrix.fromValues(...)
    local args = {...};
    if #args < 16 or #args > 16 then
        error("wrong number of arguments for matrix.fromValues, 16 needed");
    end
    local result = matrix:new();
    result.m = args;

    return result;
end

function matrix.zero()
    return matrix.fromValues(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
end

function matrix.identity()
    return matrix.fromValues(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);
end

--ROTATIONS
function matrix:rotationX(angle)
    local result = matrix.zero();
    local s = math.sin(angle);
    local c = math.cos(angle);

    result.m[1]  = 1;
    result.m[16] = 1;
    result.m[6]  = c;
    result.m[11] = c;
    result.m[10] = -s;
    result.m[7]  = s;

    return result;
end

function matrix:rotationY(angle)
    local result = matrix.zero();
    local s = math.sin(angle);
    local c = math.cos(angle);

    result.m[6]  = 1;
    result.m[16] = 1;
    result.m[1]  = c;
    result.m[3]  = -s;
    result.m[9]  = s;
    result.m[11] = c;

    return result;
end

function matrix:rotationZ(angle)
    local result = matrix.zero();
    local s = math.sin(angle);
    local c = math.cos(angle);

    result.m[11] = 1;
    result.m[16] = 1;
    result.m[1]  = c;
    result.m[2]  = s;
    result.m[5]  = -s;
    result.m[6]  = c;

    return result;
end

function matrix:RotationYawPitchRoll(yaw,pitch,roll)
    return self:rotationZ(roll):mult(self:rotationX(pitch)):mult(self:rotationY(yaw));
end

function matrix:translation(x,y,z)
    local result = matrix.identity();
    result.m[13] = x;
    result.m[14] = y;
    result.m[15] = z;
    return result;
end

--VIEWS
function matrix:PerspectiveFovLH(fov, aspect, znear, zfar)
    local matrix = matrix.zero();
    local tan = 1/math.tan(fov*0.5);

	matrix.m[1] = tan / aspect;
	matrix.m[2] = 0.0;
	matrix.m[3] = 0.0;
	matrix.m[4] = 0.0;
	matrix.m[5] = 0;
	matrix.m[6] = tan;
	matrix.m[7] = 0;
	matrix.m[8] = 0;
	matrix.m[9] = 0;
	matrix.m[10] = 0;
	matrix.m[11] = -zfar / (znear - zfar);
	matrix.m[12] = 1;
	matrix.m[13] = 0;
	matrix.m[14] = 0;
	matrix.m[15] = (znear * zfar) / (znear - zfar);
	matrix.m[16] = 0;

    return matrix;
end

function matrix:LookAtLH(eye, target, up)
    local zAxis = target - eye;
    zAxis:normalize();

    local xAxis = v3d.cross(up, zAxis);
    xAxis:normalize();

    local yAxis = v3d.cross(zAxis, xAxis);
    yAxis:normalize();

    local ex = -v3d.dot(xAxis, eye);
    local ey = -v3d.dot(yAxis, eye);
    local ez = -v3d.dot(zAxis, eye);

    return matrix.fromValues(
        xAxis:getX(), yAxis:getX(), zAxis:getX(), 0,
        xAxis:getY(), yAxis:getY(), zAxis:getY(), 0,
        xAxis:getZ(), yAxis:getZ(), zAxis:getZ(), 0,
        ex, ey, ez, 1
    );
end

--ARIFMETICS
--Multiplication operator
function matrix:mult(other)
    local result = matrix:new();
    result.m[1]  = self.m[1]  * other.m[1] + self.m[2]  * other.m[5] + self.m[3]  * other.m[9]  + self.m[4]  * other.m[13];
    result.m[2]  = self.m[1]  * other.m[2] + self.m[2]  * other.m[6] + self.m[3]  * other.m[10] + self.m[4]  * other.m[14];
    result.m[3]  = self.m[1]  * other.m[3] + self.m[2]  * other.m[7] + self.m[3]  * other.m[11] + self.m[4]  * other.m[15];
    result.m[4]  = self.m[1]  * other.m[4] + self.m[2]  * other.m[8] + self.m[3]  * other.m[12] + self.m[4]  * other.m[16];

    result.m[5]  = self.m[5]  * other.m[1] + self.m[6]  * other.m[5] + self.m[7]  * other.m[9]  + self.m[8]  * other.m[13];
    result.m[6]  = self.m[5]  * other.m[2] + self.m[6]  * other.m[6] + self.m[7]  * other.m[10] + self.m[8]  * other.m[14];
    result.m[7]  = self.m[5]  * other.m[3] + self.m[6]  * other.m[7] + self.m[7]  * other.m[11] + self.m[8]  * other.m[15];
    result.m[8]  = self.m[5]  * other.m[4] + self.m[6]  * other.m[8] + self.m[7]  * other.m[12] + self.m[8]  * other.m[16];

    result.m[9]  = self.m[9]  * other.m[1] + self.m[10] * other.m[5] + self.m[11] * other.m[9]  + self.m[12] * other.m[13];
    result.m[10] = self.m[9]  * other.m[2] + self.m[10] * other.m[6] + self.m[11] * other.m[10] + self.m[12] * other.m[14];
    result.m[11] = self.m[9]  * other.m[3] + self.m[10] * other.m[7] + self.m[11] * other.m[11] + self.m[12] * other.m[15];
    result.m[12] = self.m[9]  * other.m[4] + self.m[10] * other.m[8] + self.m[11] * other.m[12] + self.m[12] * other.m[16];

    result.m[13] = self.m[13] * other.m[1] + self.m[14] * other.m[5] + self.m[15] * other.m[9]  + self.m[16] * other.m[13];
    result.m[14] = self.m[13] * other.m[2] + self.m[14] * other.m[6] + self.m[15] * other.m[10] + self.m[16] * other.m[14];
    result.m[15] = self.m[13] * other.m[3] + self.m[14] * other.m[7] + self.m[15] * other.m[11] + self.m[16] * other.m[15];
    result.m[16] = self.m[13] * other.m[4] + self.m[14] * other.m[8] + self.m[15] * other.m[12] + self.m[16] * other.m[16];
    return result;
end

return matrix;