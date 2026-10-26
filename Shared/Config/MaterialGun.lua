-- Material Gun presets, listed in its Context Menu: each one replaces every material of the target (its physical material comes along with it)
-- The MI_Surface_* materials are object space triplanar, so they fit any mesh regardless of its UVs and stick to it when it moves or scales
MATERIAL_GUN_PRESETS = {
	{ id = "WoodPlanks",		name = "Wood Planks",		material = "nanos-world::MI_Surface_WoodPlanks" },
	{ id = "WoodFloor",			name = "Wood Floor",		material = "nanos-world::MI_Surface_WoodFloor" },
	{ id = "WoodDark",			name = "Dark Wood",			material = "nanos-world::MI_Surface_WoodDark" },
	{ id = "WoodSiding",		name = "Wood Siding",		material = "nanos-world::MI_Surface_WoodSiding" },
	{ id = "Brick",				name = "Brick",				material = "nanos-world::MI_Surface_Brick" },
	{ id = "Concrete",			name = "Concrete",			material = "nanos-world::MI_Surface_Concrete" },
	{ id = "ConcreteTiles",		name = "Concrete Tiles",	material = "nanos-world::MI_Surface_ConcreteTiles" },
	{ id = "Stone",				name = "Stone",				material = "nanos-world::MI_Surface_Stone" },
	{ id = "Marble",			name = "Marble",			material = "nanos-world::MI_Surface_Marble" },
	{ id = "Gravel",			name = "Gravel",			material = "nanos-world::MI_Surface_Gravel" },
	{ id = "Dirt",				name = "Dirt",				material = "nanos-world::MI_Surface_Dirt" },
	{ id = "RoofTiles",			name = "Roof Tiles",		material = "nanos-world::MI_Surface_RoofTiles" },
	{ id = "MetalPainted",		name = "Painted Metal",		material = "nanos-world::MI_Surface_MetalPainted" },
	{ id = "MetalDark",			name = "Dark Metal",		material = "nanos-world::MI_Surface_MetalDark" },
	{ id = "MetalCorrugated",	name = "Corrugated Metal",	material = "nanos-world::MI_Surface_MetalCorrugated" },
	{ id = "Wallpaper",			name = "Wallpaper",			material = "nanos-world::MI_Surface_Wallpaper" },
	{ id = "Plastic",			name = "Plastic",			material = "nanos-world::MI_Surface_Plastic" },
	{ id = "Rubber",			name = "Rubber",			material = "nanos-world::MI_Surface_Rubber" },
	{ id = "Chrome",			name = "Chrome",			material = "nanos-world::MI_Surface_Chrome" },
	{ id = "Gold",				name = "Gold",				material = "nanos-world::MI_Surface_Gold" },
	{ id = "Copper",			name = "Copper",			material = "nanos-world::MI_Surface_Copper" },
	{ id = "Neon",				name = "Neon",				material = "nanos-world::MI_Surface_Neon" },
	{ id = "Wireframe",			name = "Wireframe",			material = "nanos-world::M_Wireframe" },
}

-- Thumbnails live in Client/Media/Tools/Materials/<id>.webp
for _, preset in ipairs(MATERIAL_GUN_PRESETS) do
	preset.image = "package://sandbox/Client/Media/Tools/Materials/" .. preset.id .. ".webp"
end

-- Finds a preset by its id
function GetMaterialGunPreset(id)
	for _, preset in ipairs(MATERIAL_GUN_PRESETS) do
		if (preset.id == id) then
			return preset
		end
	end
end
