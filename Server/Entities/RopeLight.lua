Package.Require("Lamp.lua")

-- A Bulb Lamp hanging on a cable, with a random color: kept with its old arguments for the packages that spawn it (the Playground map)
RopeLight = Lamp.Inherit("RopeLight")

ConfigureSpawnLimits("RopeLight", "Rope Lights", RopeLight.GetCount, "max_rope_lights")

-- cable_length defaults to 100
function RopeLight:Constructor(spawn_location, relative_location, relative_rotation, direction, attach_to_entity, cable_length)
	Lamp.Constructor(self, spawn_location, direction:ToOrientationRotator() + Rotator(90, 0, 0), nil, nil, nil, "Bulb", Color.RandomPalette(false))

	self:Hang(attach_to_entity, relative_location, cable_length)
end
