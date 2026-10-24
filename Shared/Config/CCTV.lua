-- Cameras a CCTV can film with, listed in its Context Menu; the first is the default. All look along +X
-- capture: where its SceneCapture sits and which way it looks, in the mesh's axes (at the lens, along the housing's tilt)
-- mount: the point that goes on the wall or ceiling, where the cable to the monitor also leaves (the pivot of all but the classic one)
CCTV_CAMERAS = {
	{
		id = "nanos-world::SM_Camera_Security",
		name = "Security",
		image = "assets://nanos-world/Thumbnails/SM_Camera_Security.jpg",
		capture = {
			offset = Vector(36, 0, 4),
			rotation = Rotator(-15, 0, 0)
		},
		mount = Vector(0, 0, 0)
	},
	{
		id = "nanos-world::SM_Camera_Surveillance",
		name = "Surveillance",
		image = "assets://nanos-world/Thumbnails/SM_Camera_Surveillance.jpg",
		capture = {
			offset = Vector(48.5, 0, 20),
			rotation = Rotator(0, 0, 0)
		},
		mount = Vector(0, 0, 0)
	},
	{
		id = "nanos-world::SM_Camera_Housing",
		name = "Housing",
		image = "assets://nanos-world/Thumbnails/SM_Camera_Housing.jpg",
		capture = {
			offset = Vector(40.5, 0, 13.7),
			rotation = Rotator(0, 0, 0)
		},
		mount = Vector(0, 0, 0)
	},
	{
		id = "nanos-world::SM_Camera_CCTV",
		name = "Ceiling",
		image = "assets://nanos-world/Thumbnails/SM_Camera_CCTV.jpg",
		capture = {
			offset = Vector(39, 0, -27),
			rotation = Rotator(0, 0, 0)
		},
		mount = Vector(0, 0, 0)
	},
	{
		id = "nanos-world::SM_Camera",
		name = "Classic",
		image = "assets://nanos-world/Thumbnails/SM_Camera.jpg",
		capture = {
			offset = Vector(6, 0, 0),
			rotation = Rotator(0, 0, 0)
		},
		mount = Vector(-85, 0, 0)
	},
}

-- Finds a camera by its mesh, nil when unknown
function GetCCTVCamera(mesh)
	for _, camera in ipairs(CCTV_CAMERAS) do
		if (camera.id == mesh) then return camera end
	end
end
