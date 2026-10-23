Lamp = Prop.Inherit("Lamp")

Lamp.name = "Lamp"
Lamp.image = "assets://nanos-world/Thumbnails/SM_Lamp_Bulb.jpg"
Lamp.category = "objects"

-- Context Menu Items when selecting this Entity
Lamp.selected_context_menu_items = {
	{
		id = "lamp_type",
		type = "select_image",
		label = "type",
		options = LAMP_TYPES,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetType", Reliability.Reliable, value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("Type") or LAMP_TYPES[1].id
		end,
	},
	{
		id = "lamp_color",
		type = "color",
		label = "color",
		callback = function(color)
			ContextMenu.selected_entity:CallRemoteEvent("SetColor", Reliability.Reliable, Color.FromHEX(color))
		end,
		value = function()
			return Color.ToHex(ContextMenu.selected_entity:GetValue("Light"):GetColor(), false)
		end
	},
	{
		id = "lamp_intensity",
		type = "range",
		label = "intensity",
		min = 0,
		max = 100,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetIntensity", Reliability.Reliable, value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("Light"):GetIntensity()
		end
	},
	{
		id = "lamp_active",
		type = "checkbox",
		label = "active",
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetActive", Reliability.Reliable, value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("Light"):IsVisible()
		end
	},
}

-- Input Bindings for this Entity
Lamp.input_bindings = {
	{
		label = "toggle",
		callback_pressed = function(entity)
			entity:CallRemoteEvent("SetActive", Reliability.Reliable, not entity:GetValue("Light"):IsVisible())
		end,
	},
}

-- The Light Gun's hanging bulb (Server/Entities/RopeLight.lua), kept out of the Spawn Menu
RopeLight = Lamp.Inherit("RopeLight")
RopeLight.category = "hidden"
RopeLight.selected_context_menu_items = Lamp.selected_context_menu_items
RopeLight.input_bindings = Lamp.input_bindings
