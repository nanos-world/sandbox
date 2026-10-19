Target = Prop.Inherit("Target")

Target.name = "Target"
Target.image = "package://sandbox/Client/Media/Entities/Target.webp"
Target.category = "devices"

-- Context Menu Items when selecting this Entity
Target.selected_context_menu_items = {
	{
		id = "target_style",
		type = "select",
		label = "plate",
		options = TARGET_STYLES,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetStyle", Reliability.Reliable, value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("Style")
		end,
	},
	{
		id = "target_reset_time",
		type = "range",
		label = "reset time (s)",
		min = TARGET_MIN_RESET_TIME / 1000,
		max = TARGET_MAX_RESET_TIME / 1000,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetResetTime", Reliability.Reliable, value * 1000)
		end,
		value = function()
			return math.floor((ContextMenu.selected_entity:GetValue("ResetTime") or TARGET_RESET_TIME) / 1000 + 0.5)
		end,
	},
}

local SCORE_COLOR = Color(1, 0.8, 0.1)

-- A hit clangs from the plate's middle (each client plays it so it carries the whole range) and pops a "+1" over the plate that rises and fades
function Target:OnValueChange(key, value)
	if (key ~= "Down" or not value) then return end

	local style = GetTargetStyle(self:GetValue("Style")) or TARGET_STYLES[1]
	local up = self:GetRotation():GetUpVector()

	Sound(self:GetLocation() + up * style.top * 0.8, TARGET_CLANG, false, true, SoundType.SFX, 1, 2, 400, TARGET_CLANG_RANGE)

	local score_location = self:GetLocation() + up * (style.top + 20)
	local score = TextRender(score_location, Rotator(), "+1", 50, SCORE_COLOR, TextRenderRenderingType.UnlitCameraAligned)
	score:TranslateTo(score_location + Vector(0, 0, 80), 0.9)
	score:SetLifeSpan(1)
end

Target.Subscribe("ValueChange", Target.OnValueChange)
