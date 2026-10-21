-- A door: a frame with a leaf hinged in it, opening away from whoever presses interact on the leaf and closing again on the next press
-- Wired to a button (Wire Gun) it opens when the button activates and closes when it deactivates; a button that is not switchable toggles it
-- The frame floats where it is put (no gravity, heavily damped) so walking into the leaf does not shove it around; its style (DOOR_STYLES) changes both meshes
--
-- "Open" is a synced value, so other packages can react with the ValueChange event
Door = Prop.Inherit("Door")

ConfigureSpawnLimits("Door", "Doors", Door.GetCount, "max_doors")

-- The Spawn Menu calls it with (location, rotation, tab, id, player), style is one of DOOR_STYLES' ids (Wood when nil or unknown)
-- The frame's front is its local +Y, so rotation is turned +90 yaw to make it face whoever spawned it
function Door:Constructor(location, rotation, tab, id, player, style)
	style = GetDoorStyle(style) or DOOR_STYLES[1]

	-- Only the leaf is pressed (interact), the frame is not
	self.Super:Constructor(location or Vector(), (rotation or Rotator()) + Rotator(0, 90, 0), style.frame, CollisionType.Auto, false, GrabMode.Disabled, CCDMode.Auto, SpawnMode.Manual)
	self:FinishSpawn()

	self:SetPhysicsDamping(1000, 1000)
	self:SetImpulseOnDamage(false)

	-- Rides on the frame, only the swing animation moves it; it blocks characters like the frame does
	self.leaf = Prop(self:GetLocation(), self:GetRotation(), style.leaf, CollisionType.Normal, false, GrabMode.Enabled)
	-- Selecting, grabbing or targeting the leaf with a tool acts on the door (see GetOwnerEntity)
	self.leaf:SetValue("OwnerEntity", self, true)
	self.leaf:SetImpulseOnDamage(false)
	-- Nearly weightless, so swinging it does not shift the welded body's balance
	self.leaf:SetMassOverride(1)
	self.leaf:Subscribe("Interact", function(_, character)
		self:Toggle(character)
		return false
	end)
	self.leaf:AttachTo(self, AttachmentRule.SnapToTarget, "", 0)
	self.leaf:SetRelativeLocation(DOOR_HINGE)
	self.leaf:SetRelativeRotation(Rotator())

	self:SetValue("Leaf", self.leaf, true)
	self:SetValue("Open", false, true)
	self:SetStyle(player, style.id)
end

function Door:SetStyle(player, style_id)
	local style = GetDoorStyle(style_id)
	if (not style) then
		Console.Warn("Door: unknown style '%s'", tostring(style_id))
		return
	end

	self.style = style
	self:SetValue("Style", style.id, true)
	if (self:GetMesh() ~= style.frame) then self:SetMesh(style.frame) end
	if (self.leaf:GetMesh() ~= style.leaf) then self.leaf:SetMesh(style.leaf) end
end

function Door:PlaySound(volume)
	Events.BroadcastRemote("SpawnSound", Reliability.Unreliable, self.leaf:GetLocation() + Vector(0, 0, 100), self.style.sound, false, volume, self.style.pitch)
end

-- Swings the leaf open, away from opener when there is one (to the frame's +Y side otherwise)
function Door:Open(opener)
	if (self:GetValue("Open")) then return end

	local side = 1
	if (opener and opener.GetLocation) then
		local relative = self:GetRotation():UnrotateVector(opener:GetLocation() - self:GetLocation())
		side = relative.Y > 0 and -1 or 1
	end

	self:SetValue("Open", true, true)
	self.leaf:RotateRelativeTo(Rotator(0, side * DOOR_OPEN_ANGLE, 0), DOOR_SWING_TIME)
	self:PlaySound(0.5)
end

function Door:Close()
	if (not self:GetValue("Open")) then return end

	self:SetValue("Open", false, true)
	self.leaf:RotateRelativeTo(Rotator(), DOOR_SWING_TIME)

	-- The thud as it shuts
	Timer.Bind(Timer.SetTimeout(function()
		if (not self:GetValue("Open")) then self:PlaySound(0.8) end
	end, math.floor(DOOR_SWING_TIME * 900)), self)
end

function Door:Toggle(opener)
	local now = Server.GetTime()
	if (now - (self.last_toggle_time or 0) < DOOR_COOLDOWN) then return end
	self.last_toggle_time = now

	if (self:GetValue("Open")) then self:Close() else self:Open(opener) end
end

-- From a button wired to it (LogicButton passes itself as the causer): a switchable button opens and closes it with its state, a plain one toggles it
function Door:Activate(player_instigator, causer)
	if (causer and causer.switchable == false) then
		self:Toggle()
	else
		self:Open()
	end
end

function Door:Deactivate(player_instigator, causer)
	self:Close()
end

function Door:OnForceToggle(player)
	self:Toggle(player and player:GetControlledCharacter())
end

function Door:OnDestroy()
	if (self.leaf and self.leaf:IsValid()) then self.leaf:Destroy() end
end

Door.Subscribe("Destroy", Door.OnDestroy)
Door.SubscribeRemote("SetStyle", Door.SetStyle)
Door.SubscribeRemote("Toggle", Door.OnForceToggle)
