LightGun = ToolGunSingleTarget.Inherit("LightGun")

-- Tool Info
LightGun.name = "Light"
LightGun.category = "spawners"
LightGun.image = "package://sandbox/Client/Media/Tools/LightGun.webp"
LightGun.description = "Spawns a Lamp on a surface: wall lamps fixed on it, the others hanging on a cable. Customize its type and cable length"

-- Tool Tutorials
LightGun.tutorials = {
	{ key = "LeftClick",	text = "spawn light" },
	{ key = "Undo",			text = "undo last spawn" },
	{ key = "ContextMenu",	text = "light settings" },
}

-- Tool Tips
LightGun.tips = {
	"too many lights can cause severe lag",
	"wire a Button to a lamp to turn it on and off",
}

-- Light Configuration
LightGun.configs = {
	type =			PersistentConfigSystem.GetConfig("LightGun",	"type")			or LAMP_TYPES[1].id,
	cable_length =	PersistentConfigSystem.GetConfig("LightGun",	"cable_length")	or 100,
}

-- A type saved by an older version may be gone
if (not GetLampType(LightGun.configs.type)) then
	LightGun.configs.type = LAMP_TYPES[1].id
end

-- How the preview sits on the surface: a wall lamp's front (+Y) along its normal, a hanging one's top on it (as the server spawns them)
local function GetPreviewRotation(type_id)
	return GetLampType(type_id).wall and Rotator(0, -90, 0) or Rotator(90, 0, 0)
end

-- Tool Trace Debug Settings
LightGun.debug_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle,
	show_crosshair = false,
	show_preview_mesh = true,
	preview_mesh = GetLampType(LightGun.configs.type).mesh,
	preview_mesh_scale = Vector(1, 1, 1),
	preview_mesh_offset = Vector(0, 0, 0),
	preview_mesh_rotation = GetPreviewRotation(LightGun.configs.type),
}

-- Context Menu Items when picking up this Tool
LightGun.picked_context_menu_items = {
	{
		label = "type",
		type = "select_image",
		options = LAMP_TYPES,
		callback = function(value)
			LightGun.configs.type = value
			LightGun.debug_trace.preview_mesh = GetLampType(value).mesh
			LightGun.debug_trace.preview_mesh_rotation = GetPreviewRotation(value)
			PersistentConfigSystem.SaveConfig("LightGun", "type", value)
		end,
		value = function()
			return LightGun.configs.type
		end,
	},
	{
		label = "cable length",
		type = "range",
		min = 10,
		max = 500,
		callback = function(value)
			LightGun.configs.cable_length = value
			PersistentConfigSystem.SaveConfig("LightGun", "cable_length", value)
		end,
		value = function()
			return LightGun.configs.cable_length
		end,
	},
}


-- Overrides ToolGunSingleTarget method
function LightGun:OnLocalPlayerTarget(location, relative_location, relative_rotation, normal, entity)
	-- Calls remote to spawn the Light
	self:CallRemoteEvent("SpawnLight", Reliability.Reliable, location, relative_location, relative_rotation, normal, entity, LightGun.configs)
end
