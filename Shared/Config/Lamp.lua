-- Lamp types, listed in its Context Menu and the Light Gun's: the mesh, the Light it shines with and how the Light Gun puts it up
-- light: its kind (a Point shines all around, a Spot along its rotation), where it sits and which way it points (in the mesh's axes) and its defaults
-- glow: the material slot that lights up with it, the color parameter that does it and how much the light's color is scaled for it (nil when nothing glows);
-- scalar, when set, is also put to 0 when it is off (back to scalar_value when on)
-- wall: the Light Gun fixes it on the surface like a Button, its back on it and its front (+Y) facing out; the others hang on a cable
-- hang: where a cable holds it (in the mesh's axes): the hanging ones have their pivot there, the wall ones hang from the middle of their top
LAMP_TYPES = {
	{
		id = "Bulb",
		name = "Bulb",
		image = "assets://nanos-world/Thumbnails/SM_Lamp_Bulb.jpg",
		mesh = "nanos-world::SM_Lamp_Bulb",
		hang = Vector(0, 0, 0),
		light = {
			type = LightType.Point,
			offset = Vector(0, 0, -20),
			intensity = 10,
			radius = 250,
			source_radius = 10
		},
		glow = {
			slot = 1,
			parameter = "Emissive",
			scale = 100
		}
	},
	{
		id = "Lantern",
		name = "Lantern",
		image = "assets://nanos-world/Thumbnails/SM_Lamp_Lantern.jpg",
		mesh = "nanos-world::SM_Lamp_Lantern",
		hang = Vector(0, 0, 0),
		light = {
			type = LightType.Point,
			offset = Vector(0, 0, -33),
			intensity = 5,
			radius = 400,
			source_radius = 10
		},
		glow = {
			slot = 1,
			parameter = "Emissive",
			scale = 20
		}
	},
	{
		id = "Bulkhead",
		name = "Bulkhead",
		image = "assets://nanos-world/Thumbnails/SM_Lamp_Bulkhead.jpg",
		mesh = "nanos-world::SM_Lamp_Bulkhead",
		hang = Vector(0, 7, 9.9),
		wall = true,
		light = {
			type = LightType.Spot,
			offset = Vector(0, 10, 0),
			rotation = Rotator(0, 90, 0),
			intensity = 10,
			radius = 600,
			cone = 75,
			inner_cone = 0.2,
			source_radius = 15
		},
		glow = {
			slot = 1,
			parameter = "Illum_Color",
			scale = 1,
			scalar = "Illum_Intensity",
			scalar_value = 100
		}
	},
	{
		id = "LED",
		name = "LED Panel",
		image = "assets://nanos-world/Thumbnails/SM_Lamp_LED.jpg",
		mesh = "nanos-world::SM_Lamp_LED",
		hang = Vector(0, 2.35, 7),
		wall = true,
		light = {
			type = LightType.Spot,
			offset = Vector(0, 3, 0),
			rotation = Rotator(0, 90, 0),
			intensity = 15,
			radius = 800,
			cone = 80,
			inner_cone = 0.3,
			source_radius = 12
		},
		glow = {
			slot = 1,
			parameter = "Illum_Color",
			scale = 1,
			scalar = "Illum_Intensity",
			scalar_value = 100
		}
	},
}

-- A lamp spawned without a color shines warm white
LAMP_COLOR = Color(1, 0.75, 0.45)

-- Its Light stops being drawn this far away (cm)
LAMP_DRAW_DISTANCE = 2000

-- Finds a type by id, nil when unknown
function GetLampType(id)
	for _, lamp_type in ipairs(LAMP_TYPES) do
		if (lamp_type.id == id) then return lamp_type end
	end
end
