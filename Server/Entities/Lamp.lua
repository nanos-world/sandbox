-- A light fixture: its type (LAMP_TYPES) sets the mesh and its Light, a Point or a Spot. Buttons wired to it turn it on and off
-- The Light Gun spawns it hanging on a cable (Hang)
Lamp = Prop.Inherit("Lamp")

ConfigureSpawnLimits("Lamp", "Lamps", Lamp.GetCount, "max_lamps")

-- The Spawn Menu calls it with (location, rotation, tab, id, player), type is one of LAMP_TYPES' ids (Bulb when nil or unknown), color is LAMP_COLOR when nil
function Lamp:Constructor(location, rotation, tab, id, player, type_id, color)
	local lamp_type = GetLampType(type_id) or LAMP_TYPES[1]

	self.Super:Constructor(location or Vector(), rotation or Rotator(), lamp_type.mesh, CollisionType.Auto, true, GrabMode.Enabled, CCDMode.Auto, SpawnMode.Manual)
	self:FinishSpawn()

	self.color = color or LAMP_COLOR
	self.is_on = true

	self:SetType(player, lamp_type.id)
end

function Lamp:SetType(player, type_id)
	local lamp_type = GetLampType(type_id)
	if (not lamp_type) then
		Console.Warn("Lamp: unknown type '%s'", tostring(type_id))
		return
	end

	self.lamp_type = lamp_type
	self:SetValue("Type", lamp_type.id, true)
	if (self:GetMesh() ~= lamp_type.mesh) then self:SetMesh(lamp_type.mesh) end

	-- A Light can't turn from Point to Spot, so every type gets a new one (with the type's intensity)
	if (self.light and self.light:IsValid()) then self.light:Destroy() end

	local config = lamp_type.light
	self.light = Light(Vector(), Rotator(), self.color, config.type, config.intensity, config.radius, config.cone or 44, config.inner_cone or 0, LAMP_DRAW_DISTANCE, true, true, self.is_on, config.source_radius or 2, SpawnMode.Manual)
	self.light:FinishSpawn()

	self.light:AttachTo(self, AttachmentRule.SnapToTarget, "", 0)
	self.light:SetRelativeLocation(config.offset)
	self.light:SetRelativeRotation(config.rotation or Rotator())

	-- Sets light to sync
	self:SetValue("Light", self.light, true)

	self:UpdateGlow()

	-- A hanging one hangs from its new point
	if (self.cable and self.cable:IsValid()) then
		self.cable:AttachEndTo(self, lamp_type.hang)
	end
end

-- Lights up (or puts out) the type's glowing slot with the light's color
function Lamp:UpdateGlow()
	local glow = self.lamp_type.glow
	if (not glow) then return end

	self:SetMaterialColorParameter(glow.parameter, self.is_on and self.color * glow.scale or Color.BLACK, glow.slot)

	if (glow.scalar) then
		self:SetMaterialScalarParameter(glow.scalar, self.is_on and glow.scalar_value or 0, glow.slot)
	end
end

-- Hangs it on a cable cable_length long (100 when nil) from attach_to_entity at relative_location, or from where it is in the world when there is no entity
-- Hanging, it only collides with static things and can't be picked up, the cable holds it
function Lamp:Hang(attach_to_entity, relative_location, cable_length)
	self:SetCollision(CollisionType.StaticOnly)
	self:SetGrabMode(GrabMode.Disabled)

	local cable = Cable(self:GetLocation())

	cable_length = cable_length or 100
	cable:SetLinearLimits(ConstraintMotion.Limited, ConstraintMotion.Limited, ConstraintMotion.Limited, cable_length, 0, true, 10000, 100)
	cable:SetRenderingSettings(3, 4, 1)
	cable:SetCableSettings(cable_length / 4, 10, 2)

	if (attach_to_entity) then
		cable:AttachStartTo(attach_to_entity, relative_location)
	end

	cable:AttachEndTo(self, self.lamp_type.hang)

	self.cable = cable
end

function Lamp:SetLightEnabled(is_on)
	self.is_on = is_on
	self.light:SetVisibility(is_on)
	self:UpdateGlow()
end

function Lamp:SetColor(player, color)
	self.color = color
	self.light:SetColor(color)
	self:UpdateGlow()
end

function Lamp:SetIntensity(player, intensity)
	self.light:SetIntensity(intensity)
end

function Lamp:SetActive(player, active)
	self:SetLightEnabled(active)
end

function Lamp:ToggleLight()
	self:SetLightEnabled(not self.is_on)
end

-- From a button wired to it (LogicButton passes itself as the causer): a switchable button turns it on and off with its state, a plain one toggles it
function Lamp:Activate(player_instigator, causer)
	if (causer and causer.switchable == false) then
		self:ToggleLight()
	else
		self:SetLightEnabled(true)
	end
end

function Lamp:Deactivate(player_instigator, causer)
	self:SetLightEnabled(false)
end

function Lamp:OnDestroy()
	if (self.cable and self.cable:IsValid()) then self.cable:Destroy() end
end

Lamp.Subscribe("Destroy", Lamp.OnDestroy)
Lamp.SubscribeRemote("SetType", Lamp.SetType)
Lamp.SubscribeRemote("SetColor", Lamp.SetColor)
Lamp.SubscribeRemote("SetIntensity", Lamp.SetIntensity)
Lamp.SubscribeRemote("SetActive", Lamp.SetActive)
