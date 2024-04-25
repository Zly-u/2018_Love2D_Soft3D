require("love.graphics");
--my other stuff
local tablePrint = require("scr/tablePrint");
local deepcopy 	 = require("scr/deepcopy");
local xyzIter 	 = require("scr/xyzIter");

--3D Shits
local v3d       = require("libs/vectorial/vectorial3");
local v2d       = require("libs/vectorial/vectorial2");
local matrix    = require("libs/matrix");
local mesh      = require("engine/mesh");

---My shitty class.
---@class renderer idk, renderingthing shits I guess
local renderer = {
    width  = 0,
    height = 0,
    fov    = 0.78,
	isCanvased = false,

	backBuffer = {},
	depthBuffer = {},
};
--[[==================================]]--
--[[====SOME RANDOM MATH FUNCTIONS====]]--
--[[==================================]]--
local function clamp(val, min, max)
	return math.max(min, math.min(val, max));
end

local function interpolate(min, max, grad)
	return min + (max - min) * clamp(grad, 0, 1);
end

function renderer:processScanLine(y, pa, pb, pc, pd, color)
	local grad1 = pa:getY() ~= pb:getY() and (y-pa:getY())/(pb:getY()-pa:getY()) or 1;
	local grad2 = pc:getY() ~= pd:getY() and (y-pc:getY())/(pd:getY()-pc:getY()) or 1;

	local sx = math.ceil(interpolate(pa:getX(), pb:getX(), grad1));
	local ex = math.ceil(interpolate(pc:getX(), pd:getX(), grad2));

	local z1 = interpolate(pa:getZ(), pb:getZ(), grad1);
	local z2 = interpolate(pc:getZ(), pd:getZ(), grad2);

	for x = sx, ex do
		local grad = (x-sx)/(ex-sx);
		local z = interpolate(z1, z2, grad);

		self:drawPixel(v3d.Vector3D(x, y, z), color);
	end
end

--[[======================]]--
--[[====DRAW FUNCTIONS====]]--
--[[======================]]--
function renderer:clear(color)
	for i = 1, self.width*self.height*4 do
		self.backBuffer[i],self.backBuffer[i+1],self.backBuffer[i+2],self.backBuffer[i+3] = unpack(color);
	end
	for i = 1, self.width*self.height do
		self.depthBuffer[i] = math.huge;
	end
end

---Pixel putter xd
---@see renderer#drawPixel
---@param x value
---@param y value
---@param z value
---@param color table
function renderer:putPixel(x, y, z, color)
	local i = math.ceil(x)+math.ceil(y)*self.width;
	local i4 = i*4;

	if self.depthBuffer[i] == nil or self.depthBuffer[i] < z then
		return;
	end
	self.depthBuffer[i] = z;

	self.backBuffer[i4],self.backBuffer[i4+1],self.backBuffer[i4+2],self.backBuffer[i4+3] = unpack(color)

    love.graphics.setColor(unpack(color));
    love.graphics.points(x, y);
    love.graphics.setColor(1,1,1,1);
end

---That's the MAIN way of how to render pixels
---@see renderer#putPixel
---@param coord Vector3D
---@param color table
function renderer:drawPixel(coord, color)
	local xComp = coord:getX() >= 0 and coord:getX() <= self.width;
	local yComp = coord:getY() >= 0 and coord:getY() <= self.height;
    if xComp and yComp then
        self:putPixel(coord:getX(), coord:getY(), coord:getZ(), color);
    end
end

---Function for drawing Vertexes obvsly
---@see renderer#putPixel
---@param coord Vector2D
---@param color table
---@param size value
function renderer:drawVertex(coord, color, size)
	local xComp = coord:getX() >= 0 and coord:getX() <= self.width;
	local yComp = coord:getY() >= 0 and coord:getY() <= self.height;
	if xComp and yComp then
		love.graphics.setPointSize(size);
		self:putPixel(coord:getX(), coord:getY(), -3, color);
		love.graphics.setPointSize(1);
	end
end

---Bresenham's line algorithm
---@see renderer#putPixel
---@param point1 Vector2D
---@param point2 Vector2D
---@param color table
function renderer:drawBline(point1, point2, color)
	local x1, x2 = math.ceil(point1:getX()), math.ceil(point2:getX());
	local y1, y2 = math.ceil(point1:getY()), math.ceil(point2:getY());
	local dx = math.abs(x2 - x1);
	local dy = math.abs(y2 - y1);
	local sx = (x1 < x2) and 1 or -1;
	local sy = (y1 < y2) and 1 or -1;
	local err = dx - dy;

	while not((x1 == x2) and (y1 == y2)) do
		self:putPixel(x1, y1, -2, color);

		local e2 = err*2;
		if e2 > -dy then
			err = err - dy;
			x1 = x1 + sx;
		end
		if e2 < dx then
			err = err + dx;
			y1 = y1 + sy;
		end
	end
end

---MAIN way of how to draw lines.
---@see renderer#drawBline
---@param p1 Vector2D
---@param p2 Vector2D
---@param color table
function renderer:drawEdge(p1, p2, color)
	love.graphics.setLineStyle("rough");
	self:drawBline(p1, p2, color);
end

---Love2D line draw implementation
---NOT RECOMMENDED
---@param p1 Vector2D
---@param p2 Vector2D
---@param color table
function renderer:drawLine(p1, p2, size, color)
	love.graphics.setColor(unpack(color));
	love.graphics.setLineWidth(size);
	love.graphics.setLineStyle("rough");
	love.graphics.line(p1:getX(), p1:getY(), p2:getX(), p2:getY());
	love.graphics.setLineWidth(1);
	love.graphics.setColor(1,1,1,1);
end

function renderer:drawTriangle(p1, p2, p3, color)
	if p1:getY() > p2:getY() then
		p2,p1 = p1,p2;
	end
	if p2:getY() > p3:getY() then
		p2,p3 = p3, p2;
	end
	if p1:getY() > p2:getY() then
		p2,p1 = p1, p2;
	end

	local dP1P2, dP1P3;

	if p2:getY() - p1:getY() > 0 then
		dP1P2 = (p2:getX()-p1:getX())/(p2:getY()-p1:getY());
	else
		dP1P2 = 0;
	end
	if p3:getY() - p1:getY() > 0 then
		dP1P3 = (p3:getX()-p1:getX())/(p3:getY()-p1:getY());
	else
		dP1P3 = 0;
	end

	if dP1P2 > dP1P3 then
		for y = math.ceil(p1:getY()), math.ceil(p3:getY()) do
			if y < p2:getY() then
				self:processScanLine(y, p1, p3, p1, p2, color);
			else
				self:processScanLine(y, p1, p3, p2, p3, color);
			end
		end
	else
		for y = math.ceil(p1:getY()), math.ceil(p3:getY()) do
			if y < p2:getY() then
				self:processScanLine(y, p1, p2, p1, p3, color);
			else
				self:processScanLine(y, p2, p3, p1, p3, color);
			end
		end
	end
end

--[[=====================]]--
--[[====MAIN 3D STUFF====]]--
--[[=====================]]--

---3D projection on 2D space
---@param coords Vector3D x, y, z coordinates
---@param transMat Matrix
---@return Vector2D of projected 3D space.
function renderer:project(coords, transMat)
	local point = v3d.Vector3D(0,0,0):TransformCoordinates(coords, transMat);
    local x = point:getX()*self.width+self.width/2;
    local y = point:getY()*self.height+self.height/2;
    return v3d.Vector3D(x, y, point:getZ());
end

---RENDERING
---@param x value
---@param y value
---@param camera Camera
---@param meshes table
---@param drawVert boolean
---@param drawEdges boolean
---@param drawFaces boolean
function renderer:render(x, y, camera, meshes, drawVert, drawEdges, drawFaces)
	local viewport;
	if self.isCanvased then
		viewport = love.graphics.newCanvas(self.width, self.height);
		love.graphics.setCanvas(viewport);
		love.graphics.clear();
	end
		local viewMatrix 		= matrix:LookAtLH(camera.pos, camera.target, v3d.Vector3D(0, -1, 0));
		local projectionMatrix 	= matrix:PerspectiveFovLH(self.fov, self.width/self.height, 0.01, 1.0);
		for i, mesh in ipairs(meshes) do
			local worldMatrix = matrix:RotationYawPitchRoll(
				mesh.rot:getY(), mesh.rot:getX(), mesh.rot:getZ()
			):mult(
				matrix:translation(mesh.pos:getX(), mesh.pos:getY(), mesh.pos:getZ())
			);
			local transformMatrix = worldMatrix:mult(viewMatrix):mult(projectionMatrix);

			if drawEdges or drawFaces then
				for i, A, B, C in xyzIter(mesh.faces) do
					local vA = mesh.vertices[A];
					local vB = mesh.vertices[B];
					local vC = mesh.vertices[C];

					local pA = self:project(vA, transformMatrix);
					local pB = self:project(vB, transformMatrix);
					local pC = self:project(vC, transformMatrix);

					if drawFaces then
						local color = 1;
						if (i % 2) == 1 then
							color = 0.5;
						else
							color = 1;
						end
						local color = 0.25 + ((i % #mesh.faces) / #mesh.faces) * 0.75;

						self:drawTriangle(pA, pB, pC, {color,color,color,1});
					end
					if drawEdges then
						local color = {1,0.4,0.2,1};
						self:drawEdge(pA, pB, color);
						self:drawEdge(pB, pC, color);
						self:drawEdge(pC, pA, color);
					end
				end
			end
			if drawVert then
				for n, vert in ipairs(mesh.vertices) do
					local projectedPoint = self:project(vert, transformMatrix);
					self:drawVertex(projectedPoint, {255, 100, 0, 255}, 3);
				end
			end
		end
	if self.isCanvased then
		love.graphics.setCanvas();
		love.graphics.draw(viewport, x, y);
	end

	love.graphics.setColor(1,0,0,1);
	love.graphics.rectangle("line", x, y, self.width, self.height);
	love.graphics.setColor(1,1,1,1);
end

function renderer:new(w, h, isCanvased, o)
    local newDev = o or {};
	newDev = deepcopy(self);
    setmetatable(newDev, self);
    --self.__index = self;

    newDev.width  = w;
    newDev.height = h;
    newDev.isCanvased = isCanvased or false;

    return newDev;
end

return renderer;
































