local engine = require("engine/engine");

local shader = love.graphics.newShader("shaders/pTest.glsl");
local curvedLine = love.graphics.newShader("shaders/curvedLine.glsl");
function love.load()
	engine:init();
end

function love.update(dt)
	engine:update(dt);
end

function love.draw()
	--[[
	shader:send("point", {10, 10});
	love.graphics.setShader(shader);
	shader:send("point", {10, 10});
	
	love.graphics.setShader(curvedLine);
		love.graphics.rectangle("fill", 0, 0, 500, 500);
	love.graphics.setShader();
	--]]

	engine:draw();
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 0, 0)
end

function love.keypressed(key, a)
	if key == "r" then
		love.event.quit("restart");
	end
end









































