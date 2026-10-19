InstantCamera = Prop.Inherit("InstantCamera")

InstantCamera.name = "Instant Camera"
InstantCamera.category = "devices"
InstantCamera.image = "package://sandbox/Client/Media/Entities/InstantCamera.webp"

InstantCamera.currently_grabbed = nil
InstantCamera.resolution = 256
-- Material slot of SM_InstantCamera's back screen, it shows the live capture while held
InstantCamera.screen_index = 1
InstantCamera.is_aiming = false
InstantCamera.aiming_old_viewmode = nil

-- Context Menu Items when selecting this Entity
InstantCamera.selected_context_menu_items = {
	{
		id = "instantcamera_takephoto",
		type = "button",
		label = "take photo",
		callback = function()
			ContextMenu.selected_entity:TakePhoto()
		end,
	},
}

-- Input Bindings for this Entity
InstantCamera.input_bindings = {
	{
		label = "activate",
		callback_pressed = function(entity)
			entity:TakePhoto()
		end,
	},
}


function InstantCamera:OnSpawn()
	local location = self:GetLocation()

	self.scene_capture = SceneCapture(location, Rotator(), InstantCamera.resolution, InstantCamera.resolution, -1, 5000, 50, false)
	self.scene_capture:AttachTo(self, AttachmentRule.SnapToTarget, "", 0)

	-- Just in front of the lens
	self.scene_capture:SetRelativeLocation(Vector(0, 8.5, 6.6))
	self.scene_capture:SetRelativeRotation(Rotator(0, 90, 0))

	-- On the flash window
	self.light = Light(location, Rotator(), Color.WHITE, LightType.Spot, 50, 1000, 50, 0, 5000, true, false, false)
	self.light:AttachTo(self, AttachmentRule.SnapToTarget, "", 0)
	self.light:SetRelativeLocation(Vector(-3.6, 4, 12.6))
	self.light:SetRelativeRotation(Rotator(0, 90, 0))

	self.sound = Sound(self:GetLocation(), "package://sandbox/Client/Media/Entities/CameraClick.ogg", false, false, SoundType.SFX, 1, 1, 400, 3600, AttenuationFunction.Logarithmic, false, SoundLoopMode.Never, false)
	self.sound:AttachTo(self, AttachmentRule.SnapToTarget, "", 0)

	self.last_photo_time = 0
end

function InstantCamera:OnTakePhoto()
	self.sound:Play()

	self.light:SetVisibility(true)
	Timer.Bind(Timer.SetTimeout(function()
		self.light:SetVisibility(false)
	end, 100), self)
end

function InstantCamera:TakePhoto()
	-- Cooldown check (1 second cooldown)
	local curr_time = Client.GetTime()
	if (os.difftime(curr_time, self.last_photo_time) < 1000) then
		return
	end

	self.last_photo_time = curr_time

	-- Capture the photo
	self.scene_capture:CaptureScene()
	self.scene_capture:EncodeToBase64Async(ImageFormat.JPEG, function(base64)
		if (not self or not self:IsValid()) then return end
		self:CallRemoteEvent("TakePhoto", Reliability.Reliable, base64)
	end)
end

function InstantCamera.OnLeftClickPressed()
	if (not InstantCamera.currently_grabbed) then return end
	if (Input.IsMouseEnabled()) then return end

	InstantCamera.currently_grabbed:TakePhoto()
	return false
end

function InstantCamera:OnGrab(character)
	local local_player = Client.GetLocalPlayer()
	if (not local_player or local_player:GetControlledCharacter() ~= character) then return end

	InstantCamera.currently_grabbed = self

	Input.Bind("LeftClick", InputEvent.Pressed, InstantCamera.OnLeftClickPressed)

	-- Enables render rate at 30 captures per second
	self.scene_capture:SetRenderRate(0.033)

	-- Shows the live preview on the camera's own back screen, lit like an LCD
	self:SetMaterialFromSceneCapture(self.scene_capture, InstantCamera.screen_index)
	self:SetMaterialColorParameter("Emissive", Color(1.5, 1.5, 1.5), InstantCamera.screen_index)
	self:SetMaterialScalarParameter("Roughness", 0.2, InstantCamera.screen_index)

	-- TODO generic on Grab?
	-- Adds tutorial on screen
	Tutorials.Show("Instant Camera", "Takes photographs and have it printed immediately", {
		{ key = "LeftMouseButton",	text = "takes a photo" },
		{ key = "Undo",				text = "undo last photo" },
		{ key = "MouseScrollUp",	text = "rotate camera" },
		{ key = "RightMouseButton",	text = "change rotation direction" },
	})
end

function InstantCamera:OnUnGrab(character)
	local local_player = Client.GetLocalPlayer()
	if (not local_player or local_player:GetControlledCharacter() ~= character) then return end

	InstantCamera.currently_grabbed = nil

	if (InstantCamera.is_aiming) then
		InstantCamera:OnRightClickReleased()
	end

	-- Disables render rate
	self.scene_capture:SetRenderRate(-1)
	self:ResetMaterial(InstantCamera.screen_index)

	Input.Unbind("LeftClick", InputEvent.Pressed, InstantCamera.OnLeftClickPressed)
	Input.Unbind("Aim", InputEvent.Pressed, InstantCamera.OnRightClickPressed)
	Input.Unbind("Aim", InputEvent.Released, InstantCamera.OnRightClickReleased)

	Tutorials.Hide()

end

InstantCamera.Subscribe("Spawn", InstantCamera.OnSpawn)
InstantCamera.Subscribe("Grab", InstantCamera.OnGrab)
InstantCamera.Subscribe("UnGrab", InstantCamera.OnUnGrab)
InstantCamera.SubscribeRemote("OnTakePhoto", InstantCamera.OnTakePhoto)
InstantCamera.SubscribeRemote("ForceTakePhoto", InstantCamera.TakePhoto)


Photograph = Prop.Inherit("Photograph")

-- Context Menu Items when selecting this Entity
Photograph.selected_context_menu_items = {
	{
		id = "photograph_text",
		type = "button",
		label = "copy base64",
		callback = function()
			Client.CopyToClipboard(ContextMenu.selected_entity:GetMaterialTextureParameter("Texture"))
			Client.ShowNotification("Base64 copied to clipboard!", NotificationType.Success, false, 5)
		end,
	},
}