--my other stuff
local tablePrint = require("scr/tablePrint");
local deepcopy 	 = require("scr/deepcopy");
local xyzIter 	 = require("scr/xyzIter");

local v3d       = require("libs/vectorial/vectorial3");
local oshison   = require("libs/oshison");

local module = {};

function module:createMeshFromJSON(jsonObject)
	local newMesh = {
		name = "",
		vertices = {},
		faces = {},
		pos = nil,
		rot = nil
	};

	for _, mesh in ipairs(jsonObject.meshes) do
		local vertArray = mesh.vertices;
		local faceArray = mesh.indices;
		local uvCount   = mesh.uvCount;
		local vertStep  = 1;

		if uvCount == 0 then
			vertStep  = 6;
		elseif uvCount == 1 then
			vertStep  = 8;
		elseif uvCount == 2 then
			vertStep  = 10;
		end

		local vertCount  = #vertArray/vertStep;
		local facesCount = #faceArray/3;

		for i = 0, vertCount-1 do
			local x = vertArray[i*vertStep+1];
			local y = vertArray[i*vertStep+2];
			local z = vertArray[i*vertStep+3];
			newMesh.vertices[i+1] = v3d.Vector3D(x, y, z);
		end

		for i = 0, facesCount-1 do
			local a = faceArray[i*3+1]+1;
			local b = faceArray[i*3+2]+1;
			local c = faceArray[i*3+3]+1;
			newMesh.faces[i+1] = v3d.Vector3D(a, b, c);
		end

		local pos = mesh.position;
		local rot = mesh.rotation;
		newMesh.pos = v3d.Vector3D(unpack(pos));
		newMesh.rot = v3d.Vector3D(unpack(rot));
	end
	return newMesh;
end

function module:loadJSONMesh(filename) --"models/monkey.babylon"
	local jsonObject = oshison:convertJSON(filename);
	return self:createMeshFromJSON(jsonObject);
end

return module;