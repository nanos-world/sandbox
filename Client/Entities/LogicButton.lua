LogicButton = Prop.Inherit("LogicButton")

LogicButton.name = "Button"
LogicButton.image = "package://sandbox/Client/Media/Entities/ButtonClassic.webp"
LogicButton.category = "logic"

-- Context Menu Items when selecting this Entity
LogicButton.selected_context_menu_items = {
	{
		id = "button_style",
		type = "select_image",
		label = "style",
		options = BUTTON_STYLES,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetStyle", Reliability.Reliable, value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("Style") or BUTTON_STYLES[1].id
		end,
	},
	{
		id = "button_switchable",
		type = "checkbox",
		label = "switchable",
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetSwitchable", Reliability.Reliable, value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("Switchable")
		end
	},
	{
		id = "button_activated_color",
		type = "color",
		label = "activated color",
		callback = function(color)
			ContextMenu.selected_entity:CallRemoteEvent("SetActivatedColor", Reliability.Reliable, Color.FromHEX(color))
		end,
		value = function()
			return Color.ToHex(ContextMenu.selected_entity:GetValue("ActivatedColor") or Color.GREEN, false)
		end
	},
	{
		id = "button_activate_tooltip",
		type = "text",
		label = "activate text",
		callback = function(text)
			ContextMenu.selected_entity:CallRemoteEvent("SetActivateLabel", Reliability.Reliable, text)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("ActivateLabel") or "activate"
		end
	},
	{
		id = "button_deactivated_color",
		type = "color",
		label = "deactivated color",
		callback = function(color)
			ContextMenu.selected_entity:CallRemoteEvent("SetDeactivatedColor", Reliability.Reliable, Color.FromHEX(color))
		end,
		value = function()
			return Color.ToHex(ContextMenu.selected_entity:GetValue("DeactivatedColor") or Color.RED, false)
		end
	},
	{
		id = "button_deactivate_tooltip",
		type = "text",
		label = "deactivate text",
		callback = function(text)
			ContextMenu.selected_entity:CallRemoteEvent("SetDeactivateLabel", Reliability.Reliable, text)

			if (ContextMenu.selected_entity.is_active) then
				ContextMenu.selected_entity:SetToolTip(text)
			end
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("DeactivateLabel") or "deactivate"
		end
	},
	{
		id = "button_press",
		type = "button",
		label = "force press",
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("Press")
		end,
	}
}
-- The moving part is interacted with as well, so it shows the same tooltip
function LogicButton:SetToolTip(text)
	self:SetInteractionToolTipText(text)

	local part = self:GetValue("Part")
	if (part and part:IsValid()) then
		part:SetInteractionToolTipText(text)
	end
end

function LogicButton:PlaySound(pitch)
	local style = GetButtonStyle(self:GetValue("Style")) or BUTTON_STYLES[1]
	Sound(self:GetLocation(), style.sound, false, true, SoundType.SFX, 1, pitch, nil, nil, AttenuationFunction.NaturalSound)
end

function LogicButton:OnSpawn()
	self:OnUpdateLabel()
end

function LogicButton:OnActivated()
	if (self:GetValue("Switchable")) then
		self.is_active = true
		self:OnUpdateLabel()
	end

	self:PlaySound(1.1)
end

function LogicButton:OnDeactivated()
	self.is_active = false
	self:OnUpdateLabel()

	self:PlaySound(0.9)
end

-- The label of what the next press does
function LogicButton:GetLabel()
	if (self:GetValue("Active")) then
		return self:GetValue("DeactivateLabel") or "deactivate"
	end

	return self:GetValue("ActivateLabel") or "activate"
end

function LogicButton:OnUpdateLabel()
	self:SetToolTip(self:GetLabel())
end

-- A new part (the style changed) needs the tooltip too, and so does the state the server keeps
function LogicButton:OnValueChange(key, value)
	if (key == "Part" or key == "Active") then
		self:OnUpdateLabel()
	end
end

-- A late joiner may get the base before its part, so the base's "Part" value resolves to nil and the part shows the default "grab": the part asks its owner once it exists
local function UpdatePartLabel(part)
	local owner = part:GetValue("OwnerEntity")
	if (owner and owner:IsValid() and owner:IsA(LogicButton)) then
		part:SetInteractionToolTipText(owner:GetLabel())
	end
end

Prop.Subscribe("Spawn", UpdatePartLabel)
Prop.Subscribe("ValueChange", function(part, key)
	if (key == "OwnerEntity") then UpdatePartLabel(part) end
end)

LogicButton.Subscribe("Spawn", LogicButton.OnSpawn)
LogicButton.Subscribe("ValueChange", LogicButton.OnValueChange)
LogicButton.SubscribeRemote("OnActivated", LogicButton.OnActivated)
LogicButton.SubscribeRemote("OnDeactivated", LogicButton.OnDeactivated)
LogicButton.SubscribeRemote("UpdateLabel", LogicButton.OnUpdateLabel)
