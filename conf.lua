function love.conf(t)
	t.window.title  = "Love3D";
	t.console       = true;
	t.version = "11.1"

	---[[
	t.window.width     = 1280/2;
	t.window.height    = 720/2;
	--]]
	t.window.resizable = false;
	t.window.icon = nil;
	t.window.fullscreen = false;
	t.window.vsync = false;
	t.window.msaa = 0;
end