-- Chair styles, listed in its Context Menu: the mesh, which way its front faces (local yaw, so a spawned chair faces whoever spawned it) and its seats
-- Each seat is where a seated character's pivot (its capsule middle) goes relative to the chair's pivot, and which way it faces (local yaw); a bench has several
-- A seat's offset starts about 2 cm past the seat's front edge and 45 cm above its top, for CHAIR_ANIMATION (measured on SM_WoodenChair: seat 57 high, front edge at Y 14),
-- then moves forward until the back rests on the backrest in game (an upright one like SM_PG_Chair's needs about 14 cm more)
-- The Playground ones are also what the Playground map spawns on its chair and bench stand-ins (its Server/Zones/Seats.lua)
CHAIR_STYLES = {
	{ id = "Wooden",			name = "Wooden Chair",		image = "assets://nanos-world/Thumbnails/SM_WoodenChair.jpg",				mesh = "nanos-world::SM_WoodenChair",	front = 90,	seats = { { offset = Vector(0, 16, 102), yaw = 90 } } },
	{ id = "Rocking",			name = "Rocking Chair",		image = "assets://nanos-world/Thumbnails/SM_RockingChair.jpg",			mesh = "nanos-world::SM_RockingChair",	front = 90,	seats = { { offset = Vector(0, 27, 88), yaw = 90 } } },
	{ id = "Stool",				name = "Stool",				image = "assets://nanos-world/Thumbnails/SM_Stool.jpg",				mesh = "nanos-world::SM_Stool",			front = 90,	seats = { { offset = Vector(-20, -10, 112), yaw = 90 } } },
	{ id = "Bench",				name = "Bench",				image = "assets://nanos-world/Thumbnails/SM_Bench.jpg",				mesh = "nanos-world::SM_Bench",			front = 90,	seats = { { offset = Vector(-165, 64, 98), yaw = 90 }, { offset = Vector(-100, 64, 98), yaw = 90 }, { offset = Vector(-35, 64, 98), yaw = 90 } } },
	{ id = "PlaygroundChair",	name = "Playground Chair",	image = "assets://nanos-world/Thumbnails/SM_PG_Chair.jpg",			mesh = "nanos-world::SM_PG_Chair",		front = 90,	seats = { { offset = Vector(0, 38.5, 93), yaw = 90 } } },
	{ id = "PlaygroundBench",	name = "Playground Bench",	image = "assets://nanos-world/Thumbnails/SM_PG_Bench.jpg",	mesh = "nanos-world::SM_PG_Bench",		front = 90,	seats = { { offset = Vector(-64, 32.5, 93), yaw = 90 }, { offset = Vector(0, 32.5, 93), yaw = 90 }, { offset = Vector(64, 32.5, 93), yaw = 90 } } },
}

-- The looping animation a seated character plays (every client plays it from the character's synced "SittingAnimation" value)
CHAIR_ANIMATION = "nanos-world::A_Mannequin_Sit_Bench"

-- Standing up puts the character this far (cm) in front of its seat, its pivot this high above the chair's pivot
CHAIR_EXIT_DISTANCE = 70
CHAIR_EXIT_HEIGHT = 100

-- Finds a style by id, nil when unknown
function GetChairStyle(id)
	for _, style in ipairs(CHAIR_STYLES) do
		if (style.id == id) then return style end
	end
end
