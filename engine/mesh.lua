--my other stuff
local tablePrint = require("scr/tablePrint");
local deepcopy 	 = require("scr/deepcopy");
local xyzIter 	 = require("scr/xyzIter");

local v3d       = require("libs/vectorial/vectorial3");
local oshison   = require("libs/oshison");

local mesh = {
    name = "",
    vertices = {},
    faces = {},
    pos = v3d.Vector3D(0, 0, 0),
    rot = v3d.Vector3D(0, 0, 0)
};

function mesh:new(verts, faces)
	local newMesh = deepcopy(self);
    setmetatable(newMesh, self);
    newMesh.vertices = deepcopy(verts);
    newMesh.faces    = deepcopy(faces);
    return newMesh;
end

return mesh;