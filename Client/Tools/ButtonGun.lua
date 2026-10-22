ButtonGun = ToolGunSingleTarget.Inherit("ButtonGun")

-- Tool Info
ButtonGun.name = "Button Gun"
ButtonGun.image = "package://sandbox/Client/Media/Entities/ButtonPushButton.webp"
ButtonGun.category = "spawners"
ButtonGun.description = "Spawns a Button attached to objects"

-- Tool Tutorials
ButtonGun.tutorials = {
	{ key = "LeftClick",	text = "spawn Button" },
	{ key = "Undo",			text = "undo last spawn" },
	{ key = "ContextMenu",	text = "button style" },
}

-- Button Configuration
ButtonGun.configs = {
	style =	PersistentConfigSystem.GetConfig("ButtonGun", "style") or BUTTON_STYLES[1].id,
}

local function GetStyleMesh(style_id)
	return (GetButtonStyle(style_id) or BUTTON_STYLES[1]).base
end

-- Tool Trace Debug Settings
ButtonGun.debug_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	show_crosshair = false,
	show_preview_mesh = true,
	preview_mesh = GetStyleMesh(ButtonGun.configs.style),
	preview_mesh_offset = Vector(0, 0, 0),
	preview_mesh_rotation = Rotator(90, 0, 180),
}


-- Context Menu Items when picking up this Tool
ButtonGun.picked_context_menu_items = {
	{
		label = "style",
		type = "select_image",
		options = BUTTON_STYLES,
		callback = function(value)
			ButtonGun.configs.style = value
			ButtonGun.debug_trace.preview_mesh = GetStyleMesh(value)
			PersistentConfigSystem.SaveConfig("ButtonGun", "style", value)
		end,
		value = function()
			return ButtonGun.configs.style
		end,
	},
}

-- Overrides ToolGunSingleTarget method
function ButtonGun:OnLocalPlayerTarget(location, relative_location, relative_rotation, normal, entity)
	-- Call remote event to spawn the Button
	self:CallRemoteEvent("SpawnButton", Reliability.Reliable, location, relative_location, relative_rotation, normal, entity, ButtonGun.configs.style)
end