---Main Iterator for xyz coordinates
---@param t table of coordinates
---@return i x y z
local function mainXyzIter(T, i)
	i = i + 1;
	local t = T[i];
	if t then
		return i, t:getX(), t:getY(), t:getZ();
	end
end
---Iterator for xyz coordinates
---@param t table of coordinates
local function xyzIter(t)
	return mainXyzIter, t, 0;
end

return xyzIter;