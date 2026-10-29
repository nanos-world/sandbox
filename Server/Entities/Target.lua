-- A shooting target: a stand (SM_PG_TargetBase) with a plate hinged on it (SM_PG_<Style>_Plate): a shot knocks the plate back flat with a little bounce,
-- it clangs like steel and swings up again a few seconds later
--
-- The stand simulates physics, but neither it nor the plate is pushed by damage (SetImpulseOnDamage), so shots do not knock it around
--
-- "Down" is a synced value, so other packages can react to hits with the ValueChange event (true when knocked or lowered down, false once it is up again)
--
-- A game can drive it: SetAutoRise(false) keeps a knocked down plate down, Raise and Lower stand it up and drop it without a hit, and an OnKnockedDown
-- function set on the instance is called with the shooter on every hit that knocks it down
Target = Prop.Inherit("Target")

ConfigureSpawnLimits("Target", "Targets", Target.GetCount, "max_targets")

-- The hinge above the stand's pivot, where the plate's pivot sits
local HINGE_Z = 5

-- Rolls about the plate's local X (a negative one lays its top away from the shooters, its front is local +Y) and how long each step takes: falling
-- fast, hitting the ground, bouncing up a little and settling; dropping (lowered without a hit); then swinging up past upright and settling back
-- It never goes past -85: the plate is welded into the stand's body, so reaching into the floor it would lever the whole target over
local FALL = { { -55, 0.08 }, { -85, 0.07 }, { -74, 0.09 }, { -85, 0.1 }, { -81, 0.06 }, { -85, 0.06 } }
local DROP = { { -85, 0.25 } }
local RISE = { { -40, 0.35 }, { 6, 0.3 }, { -3, 0.15 }, { 0, 0.12 } }

-- The plate's front is its local +Y, so rotation is turned +90 yaw to make the plate face along rotation's forward (towards whoever spawned it)
function Target:Constructor(location, rotation, style, reset_time)
	self.Super:Constructor(location or Vector(), (rotation or Rotator()) + Rotator(0, 90, 0), "nanos-world::SM_PG_TargetBase", CollisionType.Auto, true, GrabMode.Enabled, CCDMode.Auto, SpawnMode.Manual)

	-- The Spawn Menu calls it with (location, rotation, tab, id, player), so anything that is not a known style or a number falls back to the defaults
	style = GetTargetStyle(style) and style or TARGET_STYLES[1].id

	self:SetValue("Style", style, true)
	self:SetResetTime(nil, type(reset_time) == "number" and reset_time or TARGET_RESET_TIME)
	self:SetValue("Down", false, true)

	self:FinishSpawn()
	self:SetImpulseOnDamage(false)

	-- The plate rides on the stand, so moving the stand carries it along; it is out of the physics simulation, only the animation moves it
	-- StaticOnly: swinging down it would otherwise push the simulating stand into the floor, shots (traces) still hit it
	self.plate = Prop(self:GetLocation(), self:GetRotation(), "nanos-world::SM_PG_" .. style .. "_Plate", CollisionType.StaticOnly, false, GrabMode.Disabled)
	-- Selecting, grabbing or targeting the plate with a tool acts on the stand (see GetOwnerEntity)
	self.plate:SetValue("OwnerEntity", self, true)
	-- Attached to a simulating stand its body is welded to the stand's, so a push on the plate would move the stand too
	self.plate:SetImpulseOnDamage(false)
	-- Nearly weightless, so lying down it does not shift the welded body's balance and tip the stand over
	self.plate:SetMassOverride(1)
	self.plate:Subscribe("TakeDamage", function(_, damage, bone, type, from_direction, instigator)
		self:KnockDown(instigator)
		return false
	end)
	self.plate:AttachTo(self, AttachmentRule.SnapToTarget, "", 0)
	self.plate:SetRelativeLocation(Vector(0, 0, HINGE_Z))

	self:SetValue("Plate", self.plate, true)
end

-- Steps the plate through frames one after the other (relative to the stand it is attached to, so it follows the stand however it moves), then calls done
-- A new animation cancels the one running, done included
function Target:Animate(frames, done, index)
	index = index or 1
	if (index == 1) then self.animation = (self.animation or 0) + 1 end

	local animation = self.animation
	if (not self.plate:IsValid()) then return end

	local frame = frames[index]
	if (not frame) then
		if (done) then done() end
		return
	end

	self.plate:RotateRelativeTo(Rotator(0, 0, frame[1]), frame[2])
	Timer.Bind(Timer.SetTimeout(function()
		if (self.animation == animation) then self:Animate(frames, done, index + 1) end
	end, math.floor(frame[2] * 1000)), self)
end

-- Whether a knocked down plate swings up again by itself after its ResetTime (on by default, a game turns it off and calls Raise itself)
function Target:SetAutoRise(auto_rise)
	self.auto_rise = auto_rise
	if (not auto_rise) then self:CancelRise() end
end

function Target:CancelRise()
	if (self.rise_timer) then
		Timer.ClearTimeout(self.rise_timer)
		self.rise_timer = nil
	end
end

-- A hit while it is up: it falls, clangs and pops a "+1" on every client, and instigator (the player who shot it, optional) hears the hit marker sound, 2D and only for them
function Target:KnockDown(instigator)
	if (self:GetValue("Down")) then return end

	self.rising = false
	self:SetValue("Down", true, true)
	self:Animate(FALL)
	self:BroadcastRemoteEvent("KnockDown")

	if (instigator and instigator:IsValid()) then
		Events.CallRemote("SpawnSound", instigator, Reliability.Unreliable, Vector(), TARGET_HIT_SOUND, true, 1, 1)
	end

	if (self.auto_rise ~= false) then
		self.rise_timer = Timer.SetTimeout(function()
			self.rise_timer = nil
			self:Raise()
		end, self:GetValue("ResetTime") or TARGET_RESET_TIME)

		Timer.Bind(self.rise_timer, self)
	end

	if (self.OnKnockedDown) then self:OnKnockedDown(instigator) end
end

-- Stands the plate up again, "Down" turns false immediately so hits count while it rises
function Target:Raise()
	self:CancelRise()
	if (not self:GetValue("Down") or self.rising) then return end

	self.rising = true
	self:SetValue("Down", false, true)
	self:Animate(RISE, function()
		self.rising = false
	end)
end

-- Drops the plate without a hit (no clang, no "+1"), also halfway through rising
function Target:Lower()
	self:CancelRise()
	if (self:GetValue("Down") and not self.rising) then return end

	self.rising = false
	self:SetValue("Down", true, true)
	self:Animate(DROP)
end

function Target:SetStyle(player, style)
	if (not GetTargetStyle(style)) then
		Console.Warn("Target: unknown style '%s'", tostring(style))
		return
	end

	self:SetValue("Style", style, true)
	self.plate:SetMesh("nanos-world::SM_PG_" .. style .. "_Plate")
end

function Target:SetResetTime(player, reset_time)
	self:SetValue("ResetTime", math.max(TARGET_MIN_RESET_TIME, math.min(TARGET_MAX_RESET_TIME, tonumber(reset_time) or TARGET_RESET_TIME)), true)
end

function Target:OnDestroy()
	if (self.plate and self.plate:IsValid()) then self.plate:Destroy() end
end

Target.Subscribe("Destroy", Target.OnDestroy)
Target.SubscribeRemote("SetStyle", Target.SetStyle)
Target.SubscribeRemote("SetResetTime", Target.SetResetTime)
