CCTV = Prop.Inherit("CCTV")

ConfigureSpawnLimits("CCTV", "CCTVs", CCTV.GetCount, "max_cctvs")

function CCTV:Constructor(location, rotation)
	-- Spawns a TV prop
	self.Super:Constructor(location, rotation + Rotator(0, 90, 0), "nanos-world::SM_TV", nil, nil, nil, nil, SpawnMode.Manual)

	-- Spawns the Camera Prop, floating where it is put so it can go on a wall or a ceiling
	local camera_type = CCTV_CAMERAS[1]
	self.camera = Prop(location + rotation:RotateVector(Vector(50, 0, 75)), rotation + Rotator(0, 180, 0), camera_type.id)
	self.camera:SetGravityEnabled(false)

	-- Sets this so we can access through Client ("CameraModel" tells it where the lens is)
	self:SetValue("Camera", self.camera, true)
	self:SetValue("CameraModel", camera_type.id, true)

	self:FinishSpawn()

	-- Publish the reverse link after the monitor exists so the client can initialize from either entity
	-- TODO Camera entity?
	self.camera:SetValue("Monitor", self, true)

	-- Spawns a Cable
	self.cable = Cable(location, true, SpawnMode.Manual)
	self.cable:SetLinearLimits(ConstraintMotion.Limited, ConstraintMotion.Limited, ConstraintMotion.Limited, 10000, 0, true, 10000, 100)
	self.cable:SetMaterial("nanos-world::M_Default_Masked_Lit")
	self.cable:SetMaterialColorParameter("Tint", Color.BLACK)
	self.cable:SetRenderingSettings(5, 4, 1)
	self.cable:FinishSpawn()

	-- From the camera's mount
	self.cable:AttachStartTo(self.camera, camera_type.mount)
	self.cable:AttachEndTo(self, Vector(0, 0, 10))
end

-- Swaps the camera for another of CCTV_CAMERAS, its mount kept where the old one's was (still on the wall); its clients move the picture's
-- capture to the new lens when "CameraModel" changes
function CCTV:SetCamera(player, mesh)
	local camera_type = GetCCTVCamera(mesh)
	local camera_prop = self.camera
	if (not camera_type or not camera_prop or not camera_prop:IsValid() or mesh == camera_prop:GetMesh()) then return end

	local old_type = GetCCTVCamera(camera_prop:GetMesh()) or CCTV_CAMERAS[1]
	camera_prop:SetLocation(camera_prop:GetLocation() + camera_prop:GetRotation():RotateVector(old_type.mount - camera_type.mount))
	camera_prop:SetMesh(mesh)
	self.cable:AttachStartTo(camera_prop, camera_type.mount)
	self:SetValue("CameraModel", mesh, true)

	-- Overrides the last owner
	if (player) then SpawnHistory.UpdateItemOwnership(player, self) end
end

-- Hides or shows the cable to the camera, it keeps working either way
function CCTV:SetCableVisible(player, visible)
	if (not self.cable or not self.cable:IsValid()) then return end

	self.cable:SetVisibility(visible)
	self:SetValue("CableVisible", visible, true)

	-- Overrides the last owner
	if (player) then SpawnHistory.UpdateItemOwnership(player, self) end
end

function CCTV:OnDestroy()
	-- Destroys the Camera when I get destroyed
	local camera_prop = self.camera
	if (camera_prop and camera_prop:IsValid()) then
		camera_prop:Destroy()
	end
end

CCTV.Subscribe("Destroy", CCTV.OnDestroy)
CCTV.SubscribeRemote("SetModel", function(self, player, mesh) SetTVModel(self, player, mesh) end)
CCTV.SubscribeRemote("SetCamera", CCTV.SetCamera)
CCTV.SubscribeRemote("SetCableVisible", function(self, player, visible) self:SetCableVisible(player, visible == true) end)
