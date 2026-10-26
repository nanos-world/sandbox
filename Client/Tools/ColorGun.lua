ColorGun = ToolGunSingleTarget.Inherit("ColorGun")

-- Tool Info
ColorGun.name = "Color"
ColorGun.image = "package://sandbox/Client/Media/Tools/ColorGun.webp"
ColorGun.description = "Paint props and objects with a selected color"

-- Tool Tutorials
ColorGun.tutorials = {
	{ key = "LeftClick", text = "paint object" },
	{ key = "ContextMenu", text = "color gun settings" },
}

-- Color Gun Configuration
ColorGun.configs = {
	color = Color.RandomPalette(),
	index = MATERIAL_INDEX_OPTIONS[1].id,
}

-- Tool Trace Debug Settings
ColorGun.debug_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	show_crosshair = true,
}

-- Context Menu Items when picking up this Tool
ColorGun.picked_context_menu_items = {
	{
		id = "color_gun_color",
		type = "color",
		label = "color",
		callback = function(value)
			ColorGun.configs.color = Color.FromHEX(value)
		end,
		value = function()
			return ColorGun.configs.color:ToHex(false)
		end
	},
	{
		id = "color_gun_index",
		type = "select",
		label = "index",
		options = MATERIAL_INDEX_OPTIONS,
		callback = function(value)
			ColorGun.configs.index = value
		end,
		value = function()
			return ColorGun.configs.index
		end
	},
}


-- Overrides ToolGunSingleTarget method
function ColorGun:OnLocalPlayerTarget(location, relative_location, relative_rotation, normal, entity)
	if (not entity) then
		SoundInvalidAction:Play()
		return
	end

	Events.CallRemote("ColorObject", Reliability.Reliable, entity, location, normal, ColorGun.configs.color, GetMaterialIndexFromOption(ColorGun.configs.index))
end