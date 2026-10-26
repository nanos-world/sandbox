-- Which material slot a tool (Material Gun, Color Gun) acts on: every slot, or a fixed index (the index SetMaterial takes, 0 is the first slot)
MATERIAL_INDEX_OPTIONS = {
	{ id = "all", name = "all indexes" },
}

for index = 0, 8 do
	table.insert(MATERIAL_INDEX_OPTIONS, { id = tostring(index), name = "index " .. index })
end

-- Material index of an option id, -1 for every slot
function GetMaterialIndexFromOption(option)
	return tonumber(option) or -1
end

-- Material index sent by a client, -1 (every slot) when missing or invalid
function SanitizeMaterialIndex(index)
	if (type(index) ~= "number" or index < 0) then return -1 end

	return math.floor(index)
end
