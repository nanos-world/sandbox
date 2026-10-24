-- Door styles, listed in its Context Menu: a frame (the Door entity itself) and a leaf hinged in it, both made for a 100 x 210 opening
-- The sounds play as it starts opening and as it shuts, at that pitch
DOOR_STYLES = {
	{
		id = "Wood",
		name = "Wooden",
		image = "package://sandbox/Client/Media/Entities/DoorWood.webp",
		frame = "nanos-world::SM_PG_DoorFrame_Wood",
		leaf = "nanos-world::SM_PG_Door_Wood",
		sound = "nanos-world::A_Vehicle_Door",
		pitch = 0.75
	},
	{
		id = "Glass",
		name = "Glass",
		image = "package://sandbox/Client/Media/Entities/DoorGlass.webp",
		frame = "nanos-world::SM_PG_DoorFrame_Glass",
		leaf = "nanos-world::SM_PG_Door_Glass",
		sound = "nanos-world::A_Vehicle_Door",
		pitch = 1.1
	},
	{
		id = "Metal",
		name = "Metal",
		image = "package://sandbox/Client/Media/Entities/DoorMetal.webp",
		frame = "nanos-world::SM_PG_DoorFrame_Metal",
		leaf = "nanos-world::SM_PG_Door_Metal",
		sound = "nanos-world::A_Vehicle_Door",
		pitch = 0.9
	},
}

-- Where the leaf's pivot (its hinge, at the bottom) sits in the frame, which is centred on the opening with its pivot on the floor
DOOR_HINGE = Vector(-49.5, 0, 0.5)

-- How far the leaf swings open (degrees, away from whoever opens it) and how long the swing takes (s)
DOOR_OPEN_ANGLE = 95
DOOR_SWING_TIME = 0.6
-- After a toggle it takes no other for this long (ms), like a LogicButton's cooldown: one swing ends before the next starts
DOOR_COOLDOWN = 600

-- Finds a style by id, nil when unknown
function GetDoorStyle(id)
	for _, style in ipairs(DOOR_STYLES) do
		if (style.id == id) then return style end
	end
end
