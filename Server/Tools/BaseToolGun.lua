ToolGun = Weapon.Inherit("ToolGun")

ToolGun.tab = "tools" -- Overrides the tab (so it won't get at 'weapons' tab)

function ToolGun.GetTotalCount()
	local count = 0

	local inherited_tool_guns = ToolGun.GetInheritedClasses(true)
	for k, v in pairs(inherited_tool_guns) do
		count = count + v.GetCount()
	end

	return count
end


function ToolGun:Constructor(location, rotation, color, mesh)
	self.Super:Constructor(location, rotation, mesh or "nanos-world::SK_ToolGun", CollisionType.Auto, true, SpawnMode.Manual)

	self:SetAmmoSettings(10000000, 0)
	self:SetDamage(0)
	self:SetSpread(0)
	self:SetRecoil(0)
	-- Sight line passes just over the screen, so it stays in view below the crosshair while aiming
	self:SetSightTransform(Vector(0, 0, -9.5), Rotator(0, 0, 0))
	self:SetLeftHandTransform(Vector(-1, 1, -2), Rotator(0, 60, 100))
	self:SetRightHandOffset(Vector(-25, -5, 0))
	self:SetHandlingMode(HandlingMode.SingleHandedWeapon)
	self:SetCadence(0.1)
	self:SetSoundDry("nanos-world::A_Pistol_Dry")
	self:SetSoundZooming("nanos-world::A_AimZoom")
	self:SetSoundAim("nanos-world::A_Rattle")
	self:SetSoundFire("nanos-world::A_Simulate_Start")
	self:SetCrosshairMaterial("nanos-world::MI_Crosshair_Dot")
	self:SetUsageSettings(false, false)

	self:SetMaterialColorParameter("Emissive", color * 100)

	-- We need to spawn it before attaching
	self:FinishSpawn()

	-- ToolGun label, shown on the Tool Gun screen (tools with their own mesh have no screen, so no label)
	if (not mesh) then
		self.text_render = TextRender(location, Rotator(), self:GetName(), 1.4, color, TextRenderRenderingType.Unlit, TextRenderHorizontalAlignment.Center, TextRenderVerticalAlignment.Center, "nanos-world::Font_BoldPixels_DistanceField")
		self.text_render:AttachTo(self, AttachmentRule.SnapToTarget, "screen", 0)
		-- Faces the player, matching the 20 degrees the screen is tipped up
		self.text_render:SetRelativeRotation(Rotator(20, 180, 0))
		self.text_render:SetRenderCullDistance(1000)
	end
end

function ToolGun:OnPickUp(character)
	local player = character:GetPlayer()
	if (not player) then return end

	-- Triggers the PickUp on the client which picked up it
	self:CallRemoteEvent("LocalPlayerPickUp", player, Reliability.Reliable, character)
end

function ToolGun:OnDrop(character)
	local player = character:GetPlayer()
	if (not player) then return end

	if (player:IsBeingDestroyed()) then return end

	-- Triggers the Drop on the client which dropped up it
	self:CallRemoteEvent("LocalPlayerDrop", player, Reliability.Reliable, character)
end

ToolGun.Subscribe("PickUp", ToolGun.OnPickUp)
ToolGun.Subscribe("Drop", ToolGun.OnDrop)


ToolGunSingleTarget = ToolGun.Inherit("ToolGunSingleTarget")
ToolGunDoubleTarget = ToolGun.Inherit("ToolGunDoubleTarget")