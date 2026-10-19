InstantCamera = Prop.Inherit("InstantCamera")

ConfigureSpawnLimits("InstantCamera", "Instant Cameras", InstantCamera.GetCount, "max_instant_cameras")

function InstantCamera:Constructor(location, rotation)
	self.Super:Constructor(location or Vector(), (rotation or Rotator()) + Rotator(0, 90, 0), "nanos-world::SM_InstantCamera", CollisionType.Auto, true, GrabMode.Auto, CCDMode.Auto, SpawnMode.AfterConstructor)
	self:SetScale(Vector(1.25))
end

function InstantCamera:OnTakePhoto(player, base64)
	if (not ValidateSpawnLimits(player, "InstantCamera")) then
		return
	end

	self:BroadcastRemoteEvent("OnTakePhoto")

	-- Prints the photo a few ms later
	Timer.SetTimeout(function()
		if (not self or not self:IsValid()) then return end
		local rotation = self:GetRotation()
		local right_vector = rotation:GetRightVector()
		local up_vector = rotation:GetUpVector()
		local instant_camera_scale = self:GetScale().X

		-- Scales photograph by the camera scale
		local location = self:GetLocation() + up_vector * 2 * instant_camera_scale + right_vector * 25 * instant_camera_scale
		local impulse = right_vector * 100 + self:GetVelocity()

		local photograph = Photograph(location, rotation, base64, instant_camera_scale)
		photograph:AddImpulse(impulse, true)

		-- Adds to player's history
		if (player and player:IsValid()) then
			SpawnHistory.AddItemToHistory(player, photograph)
		end
	end, 300)
end

function InstantCamera:Activate(player_instigator, causer)
	self:CallRemoteEvent("ForceTakePhoto", player_instigator)
end

InstantCamera.SubscribeRemote("TakePhoto", InstantCamera.OnTakePhoto)



Photograph = Prop.Inherit("Photograph")

ConfigureSpawnLimits("Photograph", "Photograph", Photograph.GetCount, "max_photographs")

function Photograph:Constructor(location, rotation, base64, scale)
	self.Super:Constructor(location or Vector(), rotation or Rotator(), "nanos-world::SM_Plane")
	self:SetScale(Vector(0.2 * (scale or 1)))
	self:SetMaterialTextureParameter("Texture", base64)
	self:SetMaterialScalarParameter("Roughness", 0.25)
	self:SetMaterialScalarParameter("Specular", 0.25)
end