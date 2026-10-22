CCTV = Prop.Inherit("CCTV")

CCTV.name = "CCTV"
CCTV.image = "package://sandbox/Client/Media/Entities/CCTV.webp"
CCTV.category = "devices"


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
}

function CCTV:OnSpawn()
	local camera = self:GetValue("Camera")
	-- 30 captures per second, at the monitor's 16:9
	self.scene_capture = SceneCapture(camera:GetLocation(), Rotator(), 640, 360, 0.033)
	self.scene_capture:AttachTo(camera, AttachmentRule.SnapToTarget, "", 0)

	self:ShowCapture()
end

function CCTV:ShowCapture()
	self:SetMaterialFromSceneCapture(self.scene_capture, 1)
	self:SetMaterialColorParameter("Emissive", Color(2, 2, 2))
	self:SetMaterialScalarParameter("Roughness", 0.25)
end

-- A new monitor mesh comes without the screen's material
function CCTV:OnValueChange(key)
	if (key == "Model" and self.scene_capture and self.scene_capture:IsValid()) then
		self:ShowCapture()
	end
end

CCTV.Subscribe("Spawn", CCTV.OnSpawn)
CCTV.Subscribe("ValueChange", CCTV.OnValueChange)