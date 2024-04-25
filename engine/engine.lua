--my other stuff
local tablePrint = require("scr/tablePrint");
local import 	 = require("scr/objImporters");

--OtherShits
local json = require("libs/json");

--3D math
local v2d       = require("libs/vectorial/vectorial2");
local v3d       = require("libs/vectorial/vectorial3");
local matrix    = require("libs/matrix");

--3D shits
local camera    = require("engine/camera");
local mesh      = require("engine/mesh");
local renderer  = require("engine/renderer");

local engine = {};

local cam1 = camera:new();
local cam2 = camera:new();
local rend1 = renderer:new(240/2, 135/2, false);
local rend2 = renderer:new(240/2, 135/2, true);

local meshes = {};
local initMeshes = {};

local cube 		= json.decode("models/cube.babylon");
--[[
local sumMesh 	= json.decode("models/sumMesh.babylon");
local grid 		= json.decode("models/grid.babylon");
local testObj 	= json.decode("models/monkey.babylon");
--]]

--tablePrint(cube)
function engine:init()
	local size = 1;
	initMeshes = {
		--cube1 = mesh:new(cube.meshes[1].vertices, cube.meshes[1].indices),
		cube1 = import:createMeshFromJSON(cube),
		--grid = mesh:new(grid.vertices, grid.faces),
		--obj1 = mesh:new(testObj.vertices, testObj.faces),
		--sumMesh = mesh:new(sumMesh.vertices, sumMesh.faces),
	};
	for i, v in pairs(initMeshes) do
		table.insert(meshes, v);
	end

	cam1:setPos(0, 0, 10);
	cam2:setPos(0, 10, 10);
end

local timer = 0;
function engine:update(dt)
	timer = timer + dt*60;
	--preMeshes.cube1.rot:setX(preMeshes.cube1.rot:getX()+1*dt);
	--preMeshes.cube1.rot:setY(preMeshes.cube1.rot:getY()+1.5*dt);

	local cam1X = math.cos(math.rad(timer))*10;
	local cam1Z = math.sin(math.rad(timer))*10;

	local cam2X = math.sin(math.rad(timer))*20;
	local cam2Y = math.cos(math.rad(timer))*10;

	cam1:setPos(cam1X, math.sin(math.rad(timer*2))*5, cam1Z);
	cam2:setPos(cam2X, cam2Y, 10);
end

function engine:draw()
	rend1:clear({0,0,0,1});
	rend1:render(0, 0, cam1, meshes, false, false, true);

	rend2:clear({0,0,0,1});
	rend2:render(240/2, 135/2, cam2, meshes, false, false, true);
end

return engine;