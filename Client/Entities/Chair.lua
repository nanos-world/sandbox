Chair = Prop.Inherit("Chair")

Chair.name = "Chair"
Chair.image = "assets://nanos-world/Thumbnails/SM_WoodenChair.jpg"
Chair.category = "objects"

-- Context Menu Items when selecting this Entity
Chair.selected_context_menu_items = {
	{
		id = "chair_style",
		type = "select_image",
		label = "style",
		options = CHAIR_STYLES,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetStyle", Reliability.Reliable, value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("Style") or CHAIR_STYLES[1].id
		end,
	},
}

function Chair:OnSpawn()
	self:SetInteractionToolTipText("sit")
end

Chair.Subscribe("Spawn", Chair.OnSpawn)

Input.Register("StandUp", "SpaceBar", "Stands up from a Chair")

Input.Bind("StandUp", InputEvent.Pressed, function()
	local character = Client.GetLocalPlayer():GetControlledCharacter()
	if (not character or not character:GetValue("SittingAnimation")) then return end

	local chair = character:GetAttachedTo()
	if (chair and chair:IsA(Chair)) then chair:CallRemoteEvent("StandUp") end
end)

-- Plays (or stops) the sitting animation a character carries; stopping first, as replaying a looping animation stacks a second one on older game builds
local function UpdateSittingAnimation(character, animation)
	if (character.sitting_animation) then character:StopAnimation(character.sitting_animation) end
	character.sitting_animation = animation

	if (animation) then character:PlayAnimation(animation, AnimationSlotType.FullBody, true) end
end

Character.Subscribe("ValueChange", function(character, key, value)
	if (key == "SittingAnimation") then UpdateSittingAnimation(character, value) end
end)

Character.Subscribe("Spawn", function(character)
	local animation = character:GetValue("SittingAnimation")
	if (animation) then UpdateSittingAnimation(character, animation) end
end)

-- Characters already seated when the package loads
for _, character in ipairs(Character.GetAll()) do
	local animation = character:GetValue("SittingAnimation")
	if (animation) then UpdateSittingAnimation(character, animation) end
end
