HFG = Weapon.Inherit("HFG")

function HFG:Constructor(location, rotation)
	self.Super:Constructor(location or Vector(), rotation or Rotator(), "nanos-world::SK_HFG", CollisionType.Auto, true, SpawnMode.AfterConstructor)

	self:SetAmmoSettings(1024, 0)
	self:SetDamage(0)
	self:SetSpread(30)
	self:SetSightTransform(Vector(-10, 0, -15), Rotator(0, 0, 0))
	self:SetLeftHandTransform(Vector(30, -3, 2), Rotator(-30, 60, 90))
	self:SetRightHandOffset(Vector(0, 0, -15))
	self:SetHandlingMode(HandlingMode.DoubleHandedWeapon)
	self:SetCadence(0.2)
	self:SetSoundDry("nanos-world::A_Pistol_Dry")
	self:SetSoundZooming("nanos-world::A_AimZoom")
	self:SetSoundAim("nanos-world::A_Rattle")
	self:SetSoundFire("nanos-world::A_ShotgunBlast_Shot")
	self:SetAnimationCharacterFire("nanos-world::AM_Mannequin_Sight_Fire")
	self:SetParticlesBarrel("nanos-world::P_Weapon_BarrelSmoke")
	self:SetCrosshairMaterial("nanos-world::MI_Crosshair_Square")
	self:SetUsageSettings(true, false)
end

function HFG:OnFire(character)
	local control_rotation = character:GetControlRotation()
	local forward_vector = control_rotation:GetForwardVector()
	local spawn_location = self:GetLocation() + Vector(0, 0, 25) + forward_vector * 85

	local grenade = Grenade(spawn_location, Rotator(), "nanos-world::SM_Grenade_G67", "nanos-world::P_Explosion_Dirt", "nanos-world::A_Explosion_Large")
	grenade:SetScale(Vector(3, 3, 3))
	grenade:SetPickable(false)

	local trail_particle = Particle(spawn_location, Rotator(), "nanos-world::P_Ribbon", false, true)
	trail_particle:SetParameterColor("Color", Color.RandomPalette())
	trail_particle:SetParameterFloat("LifeTime", 1)
	trail_particle:SetParameterFloat("SpawnRate", 30)
	trail_particle:SetParameterFloat("Width", 1)
	trail_particle:AttachTo(grenade)
	grenade:SetValue("Particle", trail_particle)

	-- The shooter owns the explosion, so it respects Teams (PVP off) like a shot does
	local instigator = character:GetPlayer()

	grenade:Subscribe("Hit", function(self)
		self:Explode((instigator and instigator:IsValid()) and instigator or nil)
	end)

	grenade:Subscribe("Destroy", function(self)
		self:GetValue("Particle"):SetLifeSpan(1)
	end)

	grenade:AddImpulse(forward_vector * 3000, true)
end

HFG.Subscribe("Fire", HFG.OnFire)