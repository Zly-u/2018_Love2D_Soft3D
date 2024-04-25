--All credits to Lilla Oshisaure for this module:
--https://twitter.com/oshisaure

local module = {};

local function tablePrint(table, tabulation)
	local tbe = tabulation;
	if type(table) ~= "table" then
		return;
	end
	if tbe == nil then
		tbe = "";
	end

	for i,v in pairs(table) do
		print(tbe..tostring(i), v);
		if type(v) == "table" then
			local tab = tbe.."\t"
			tablePrint(v, tab);
		end
	end
end

function module:convertJSON(input_file)
	local file = io.open(input_file)
	local chr = " "
	local luaResult = "return "
	file:seek("set")
	local state = "     "
	while chr and chr ~= "" do
		if state:sub(-5) ~= "strng" then
			if chr == "{" then
				state = state..".table"
			elseif chr == "[" then
				state = state..".array"
				chr = "{"
			elseif chr == "}" then
				state = state:sub(1, -7)
			elseif chr == "]" then
				chr = "}"
				state = state:sub(1, -7)
			elseif chr == "\"" then
				if state:sub(-5) == "table" then
					chr = ""
				else
					state = state..".strng"
				end
			elseif chr == ":" then
				chr = "="
			elseif chr == "/" and luaResult:sub(-1) == "/" then
				file:read("*l")
				luaResult = luaResult:sub(1, -2)
				chr = "\n"
			end
		elseif chr == "\"" and luaResult:sub(-1) ~= "\\" then
			state = state:sub(1, -7)
		end
		luaResult = luaResult..chr
		chr = file:read(1)
	end
	file:close()
	local name = math.random()..".temporary_file"
	file = io.open(name, "w")
	file:write(luaResult)
	file:flush()
	file:close()
	luaResult = dofile(name)
	os.remove(name)
	local result = {}
	for k, v in pairs(luaResult) do
		result[k] = v
	end
	--tablePrint(result);
	return result
end

return module;