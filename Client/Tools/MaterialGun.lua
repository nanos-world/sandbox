MaterialGun = ToolGunSingleTarget.Inherit("MaterialGun")

-- Tool Info
MaterialGun.name = "Material"
MaterialGun.image = "package://sandbox/Client/Media/Tools/MaterialGun.webp"
MaterialGun.description = "Changes the material of props and objects"

-- Tool Tutorials
MaterialGun.tutorials = {
	{ key = "LeftClick", text = "apply material" },
	{ key = "R", text = "reset material" },
	{ key = "ContextMenu", text = "material gun settings" },
}

-- Material Gun Configuration
MaterialGun.weapon = nil
MaterialGun.configs = {
	preset = MATERIAL_GUN_PRESETS[1].id,
	index = MATERIAL_INDEX_OPTIONS[1].id,
}

-- Tool Trace Debug Settings
MaterialGun.debug_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Pawn,
	show_crosshair = true,
}

-- Context Menu Items when picking up this Tool
MaterialGun.picked_context_menu_items = {
	{
		id = "material_gun_preset",
		type = "select_image",
		label = "material",
		options = MATERIAL_GUN_PRESETS,
		callback = function(value)
			MaterialGun.configs.preset = value
		end,
		value = function()
			return MaterialGun.configs.preset
		end
	},
	{
		id = "material_gun_slot",
		type = "select",
		label = "index",
		options = MATERIAL_INDEX_OPTIONS,
		callback = function(value)
			MaterialGun.configs.index = value
		end,
		value = function()
			return MaterialGun.configs.index
		end
	},
}


-- Overrides ToolGunSingleTarget method
function MaterialGun:OnLocalPlayerTarget(location, relative_location, relative_rotation, normal, entity)
	if (not entity) then
		SoundInvalidAction:Play()
		return
	end

	self:CallRemoteEvent("ApplyMaterial", Reliability.Reliable, entity, location, normal, MaterialGun.configs.preset, GetMaterialIndexFromOption(MaterialGun.configs.index))
end

-- Overrides Tool Gun's OnLocalPlayerPickUp
function MaterialGun:OnLocalPlayerPickUp(character)
	MaterialGun.weapon = self
	Input.Subscribe("KeyPress", MaterialGunKeyPress)
end

-- Overrides Tool Gun's OnLocalPlayerDrop
function MaterialGun:OnLocalPlayerDrop(character)
	MaterialGun.weapon = nil
	Input.Unsubscribe("KeyPress", MaterialGunKeyPress)
end

function MaterialGunKeyPress(key_name)
	if (key_name ~= "R" or not MaterialGun.weapon) then return end

	-- Resets the material of whatever is under the crosshair
	local trace_result = TraceFor(10000, MaterialGun.debug_trace.collision_channel)
	if (not trace_result.Success or not trace_result.Entity or trace_result.Entity:HasAuthority()) then
		SoundInvalidAction:Play()
		return
	end

	MaterialGun.weapon:CallRemoteEvent("ResetMaterial", Reliability.Reliable, trace_result.Entity, trace_result.Location, trace_result.Normal, GetMaterialIndexFromOption(MaterialGun.configs.index))
end
