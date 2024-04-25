--my other stuff
local tablePrint = require("scr/tablePrint");
local deepcopy 	 = require("scr/deepcopy");

local v3d = require("libs/vectorial/vectorial3");

local camera = {
    pos     = v3d.Vector3D(0, 0, 0),
    target  = v3d.Vector3D(0, 0, 0)
};

function camera:setPos(x, y, z)
	self.pos:setX(x);
	self.pos:setY(y);
	self.pos:setZ(z);
end

function camera:setTarget(x, y, z)
	self.target:setX(x);
	self.target:setY(y);
	self.target:setZ(z);
end

function camera:new(o)
    local newCam = o or {};
	newCam = deepcopy(self);
    setmetatable(newCam, self);
    --self.__index = self;
    return newCam;
end

return camera;