PhotoFrame = Prop.Inherit("PhotoFrame")

ConfigureSpawnLimits("PhotoFrame", "Photo Frames", PhotoFrame.GetCount, "max_photo_frames")

-- Frames a PhotoFrame can be built with (constructor style), by style name (PHOTO_FRAME_STYLES)
PhotoFrame.styles = {}
for _, frame in ipairs(PHOTO_FRAME_STYLES) do
	PhotoFrame.styles[frame.style] = frame.id
end

function PhotoFrame:Constructor(location, rotation, tab, id, player, style, image)
	self.Super:Constructor(location or Vector(), (rotation or Rotator()) + Rotator(0, 90, 0), PhotoFrame.styles[style] or PhotoFrame.styles.default)

	if (image ~= nil and image ~= "") then
		self:SetPhoto(image)
	end

	if (player) then
		Events.CallRemote("AddNotification", player, Reliability.Reliable, NotificationType.Info, "PHOTO_FRAME_TUTORIAL", "you can change the Photo Frame image by selecting it in the Context Menu", 10, 5)
	end
end

function PhotoFrame:SetPhoto(image)
	self:SetMaterialTextureParameter("Texture", image, 1)
end

function PhotoFrame:OnSetPhoto(player, image)
	self:SetPhoto(image)

	-- Overrides the last owner
	SpawnHistory.UpdateItemOwnership(player, self)
end

-- Swaps the frame for one of PHOTO_FRAME_STYLES, keeping the picture
function PhotoFrame:OnSetFrame(player, mesh)
	local is_known = false
	for _, frame in ipairs(PHOTO_FRAME_STYLES) do
		if (frame.id == mesh) then is_known = true break end
	end
	if (not is_known or mesh == self:GetMesh()) then return end

	local image = self:GetMaterialTextureParameter("Texture", 1)
	self:SetMesh(mesh)
	self:ResetMaterial()
	if (image and image ~= "") then self:SetPhoto(image) end

	-- Overrides the last owner
	SpawnHistory.UpdateItemOwnership(player, self)
end

PhotoFrame.SubscribeRemote("SetPhoto", PhotoFrame.OnSetPhoto)
PhotoFrame.SubscribeRemote("SetFrame", PhotoFrame.OnSetFrame)
