-- Plates a Target can have (its "nanos-world::SM_PG_<id>_Plate" mesh), listed in its Context Menu, with how high the plate's top is above the stand's pivot (cm)
TARGET_STYLES = {
	{ id = "Target",		name = "Paper",		top = 182 },
	{ id = "TargetSteel",	name = "Steel",		top = 171 },
	{ id = "TargetRound",	name = "Gong",		top = 176.5 },
	{ id = "TargetPopper",	name = "Popper",	top = 161 },
}

-- How long a knocked down plate stays down before swinging up again (ms), changeable per target between the min and max
TARGET_RESET_TIME = 7000
TARGET_MIN_RESET_TIME = 1000
TARGET_MAX_RESET_TIME = 30000

-- The clang of a hit, heard up to this far (cm): ranges put targets up to 100 m from the firing line
TARGET_CLANG = "nanos-world::A_Metal_Clang"
TARGET_CLANG_RANGE = 12000

-- Finds a style by id, nil when unknown
function GetTargetStyle(id)
	for _, style in ipairs(TARGET_STYLES) do
		if (style.id == id) then return style end
	end

	return nil
end
