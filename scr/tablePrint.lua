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

return tablePrint;