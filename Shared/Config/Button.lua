-- Button styles: a fixed base (the Button entity itself) and optionally a moving part attached to it at offset (in the base's axes, its up is +Z)
-- The part is pushed in by push (cm along the base's up) or tilted about its X between the off and on angles (degrees), taking time (s) to move
-- tint_slot is the material slot the activated/deactivated colors go on (of the part, or of the base when there is no part), nil for every slot
BUTTON_STYLES = {
	{
		id = "Classic",
		name = "Classic",
		image = "package://sandbox/Client/Media/Entities/ButtonClassic.webp",
		base = "nanos-world::SM_PushButton",
		sound = "nanos-world::A_Switch_Button_01"
	},
	{
		id = "PushButton",
		name = "Push Button",
		image = "package://sandbox/Client/Media/Entities/ButtonPushButton.webp",
		base = "nanos-world::SM_PG_PushButton_Base",
		part = "nanos-world::SM_PG_PushButton_Cap",
		offset = Vector(0, 0, 4),
		push = 2,
		time = 0.06,
		tint_slot = 0,
		sound = "nanos-world::A_Switch_Button_01"
	},
	{
		id = "Switch",
		name = "Switch",
		image = "package://sandbox/Client/Media/Entities/ButtonSwitch.webp",
		base = "nanos-world::SM_PG_Switch_Plate",
		part = "nanos-world::SM_PG_Switch_Toggle",
		offset = Vector(0, 0, 1.6),
		off = -22,
		on = 22,
		time = 0.1,
		tint_slot = 0,
		sound = "nanos-world::A_Switch_Button_01"
	},
	{
		id = "Lever",
		name = "Lever",
		image = "package://sandbox/Client/Media/Entities/ButtonLever.webp",
		base = "nanos-world::SM_PG_Lever_Base",
		part = "nanos-world::SM_PG_Lever_Handle",
		offset = Vector(0, 0, 10),
		off = -35,
		on = 35,
		time = 0.2,
		tint_slot = 1,
		sound = "nanos-world::A_Switch_Button_01",
		cooldown = 700
	},
}

-- How long a push part stays in before springing back, when the button is not switchable (ms)
BUTTON_PUSH_RELEASE = 180

-- Finds a style by id, nil when unknown
function GetButtonStyle(id)
	for _, style in ipairs(BUTTON_STYLES) do
		if (style.id == id) then return style end
	end
end
