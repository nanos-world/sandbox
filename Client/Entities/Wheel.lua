Wheel = Prop.Inherit("Wheel")

-- Context Menu Items when selecting this Entity
Wheel.selected_context_menu_items = {
	{
		label = "force",
		type = "range",
		min = 0,
		max = 10000,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetCustomAngularForce", Reliability.Reliable, value * 1000)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("AngularForce") / 1000
		end,
	},
	{
		label = "is active",
		type = "checkbox",
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetActive", Reliability.Reliable, value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("Active")
		end
	},
	{
		label = "is reversed",
		type = "checkbox",
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetDirection", Reliability.Reliable, value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("Reversed")
		end
	},
}

-- Input Bindings for this Entity
Wheel.input_bindings = {
	{
		label = "accelerate",
		callback_pressed = function(entity)
			-- Note: if we press the accelerate then reverse, then release accelerate, it will stop moving
			entity:CallRemoteEvent("SetActive", Reliability.Reliable, true)
		end,
		callback_released = function(entity)
			entity:CallRemoteEvent("SetActive", Reliability.Reliable, false)
		end,
	},
	{
		label = "reverse",
		callback_pressed = function(entity)
			entity:CallRemoteEvent("SetActive", Reliability.Reliable, true, true)
		end,
		callback_released = function(entity)
			entity:CallRemoteEvent("SetActive", Reliability.Reliable, false)
		end,
	},
	{
		label = "toggle",
		callback_pressed = function(entity)
			entity:CallRemoteEvent("SetActive", Reliability.Reliable, not entity:GetValue("Active"))
		end,
	},
}