Door = Prop.Inherit("Door")

Door.name = "Door"
Door.image = "package://sandbox/Client/Media/Entities/DoorWood.webp"
Door.category = "logic"

-- Context Menu Items when selecting this Entity
Door.selected_context_menu_items = {
	{
		id = "door_style",
		type = "select_image",
		label = "style",
		options = DOOR_STYLES,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetStyle", Reliability.Reliable, value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("Style") or DOOR_STYLES[1].id
		end,
	},
	{
		id = "door_toggle",
		type = "button",
		label = "open / close",
		callback = function()
			ContextMenu.selected_entity:CallRemoteEvent("Toggle")
		end,
	},
}

-- Only the leaf is interacted with, its tooltip is what the next press does
function Door:OnUpdateLabel()
	local text = self:GetValue("Open") and "close" or "open"

	local leaf = self:GetValue("Leaf")
	if (leaf and leaf:IsValid()) then
		leaf:SetInteractionToolTipText(text)
	end
end

function Door:OnValueChange(key, value)
	if (key == "Open" or key == "Leaf") then
		self:OnUpdateLabel()
	end
end

Door.Subscribe("Spawn", Door.OnUpdateLabel)
Door.Subscribe("ValueChange", Door.OnValueChange)
