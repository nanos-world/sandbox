CCTV = Prop.Inherit("CCTV")

CCTV.name = "CCTV"
CCTV.image = "package://sandbox/Client/Media/Entities/CCTV.webp"
CCTV.category = "devices"


-- Only what the Context Menu shows, as the WebUI can't receive the Vectors and Rotators of CCTV_CAMERAS
local camera_options = {}
for _, camera in ipairs(CCTV_CAMERAS) do
	table.insert(camera_options, { id = camera.id, name = camera.name, image = camera.image })
end

-- Context Menu Items when selecting this Entity
CCTV.selected_context_menu_items = {
	{
		id = "cctv_model",
		type = "select",
		label = "monitor",
		options = TV_MODELS,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetModel", Reliability.Reliable, value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetMesh()
		end,
	},
	{
		id = "cctv_camera",
		type = "select_image",
		label = "camera",
		options = camera_options,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetCamera", Reliability.Reliable, value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("CameraModel") or CCTV_CAMERAS[1].id
		end,
	},
	{
		id = "cctv_cable",
		type = "checkbox",
		label = "cable visible",
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetCableVisible", Reliability.Reliable, value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("CableVisible") ~= false
		end,
	},
}

function CCTV:OnSpawn()
	local camera = self:GetValue("Camera")
	-- 30 captures per second, at the monitor's 16:9
	self.scene_capture = SceneCapture(camera:GetLocation(), Rotator(), 640, 360, 0.033)
	self.scene_capture:AttachTo(camera, AttachmentRule.SnapToTarget, "", 0)
	self:PlaceCapture()

	self:ShowCapture()
end

-- Puts the capture at the camera's lens, looking where it points
function CCTV:PlaceCapture()
	local camera_type = GetCCTVCamera(self:GetValue("CameraModel")) or CCTV_CAMERAS[1]
	self.scene_capture:SetRelativeLocation(camera_type.capture.offset)
	self.scene_capture:SetRelativeRotation(camera_type.capture.rotation)
end

function CCTV:ShowCapture()
	self:SetMaterialFromSceneCapture(self.scene_capture, 1)
	self:SetMaterialColorParameter("Emissive", Color(2, 2, 2))
	self:SetMaterialScalarParameter("Roughness", 0.25)
end

-- A new monitor mesh comes without the screen's material; a new camera has its lens somewhere else
function CCTV:OnValueChange(key)
	if (not self.scene_capture or not self.scene_capture:IsValid()) then return end
	if (key == "Model") then
		self:ShowCapture()
	elseif (key == "CameraModel") then
		self:PlaceCapture()
	end
end

CCTV.Subscribe("Spawn", CCTV.OnSpawn)
CCTV.Subscribe("ValueChange", CCTV.OnValueChange)
