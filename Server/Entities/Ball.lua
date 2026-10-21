-- A ball characters play with by running into it: it never blocks them (no collision with pawns), and a character coming within reach of it kicks it
-- along the way it runs, harder the faster it goes. Its style (BALL_STYLES: football, basketball...) changes its look, size, bounce and weight
Ball = Prop.Inherit("Ball")

ConfigureSpawnLimits("Ball", "Balls", Ball.GetCount, "max_balls")

-- The Spawn Menu calls it with (location, rotation, tab, id, player), style is one of BALL_STYLES' ids (Soccer when nil or unknown)
-- Its pivot is its centre, so it is lifted to rest on the point it is spawned at
function Ball:Constructor(location, rotation, tab, id, player, style)
	style = GetBallStyle(style) or BALL_STYLES[1]

	self.Super:Constructor((location or Vector()) + Vector(0, 0, BALL_RADIUS * style.scale + 1), rotation or Rotator(), "nanos-world::SM_PG_Ball", CollisionType.IgnoreOnlyPawn, true, GrabMode.Auto, CCDMode.Enabled, SpawnMode.Manual)
	self:FinishSpawn()

	self.last_kick = 0
	self.kick_enabled = true

	-- A pawn coming within reach kicks it (a sphere, so the ball rolling does not turn it)
	self.trigger = Trigger(self:GetLocation(), Rotator(), Vector(BALL_KICK_RADIUS), TriggerType.Sphere, false, Color.GREEN, { "Character", "CharacterSimple", "VehicleWheeled" })
	self.trigger:AttachTo(self, AttachmentRule.SnapToTarget, "", 0)
	self.trigger:Subscribe("BeginOverlap", function(_, pawn)
		if (not (pawn.IsDead and pawn:IsDead())) then self:Kick(pawn) end
	end)

	self:SetStyle(player, style.id)
end

function Ball:SetStyle(player, style_id)
	local style = GetBallStyle(style_id)
	if (not style) then
		Console.Warn("Ball: unknown style '%s'", tostring(style_id))
		return
	end

	self.style = style
	self:SetValue("Style", style.id, true)
	self:SetMaterial(style.material)
	self:SetScale(Vector(style.scale))
	self:SetPhysicalMaterial(style.physical_material)
	self:SetMassOverride(style.mass)
end

-- Whether characters running into it kick it (a game can freeze a ball that scored until it is put back)
function Ball:SetKickEnabled(enabled)
	self.kick_enabled = enabled
end

-- Sends the ball along the way kicker runs (a little towards the ball, so hitting it from the side angles the kick), replacing its rolling speed
-- A slow or standing kicker only nudges it away, so a ball rolling into someone bounces off them
function Ball:Kick(kicker)
	if (not self.kick_enabled or self:GetHandler() or self:GetAttachedTo()) then return end

	local now = Server.GetTime()
	if (now - self.last_kick < 150) then return end
	self.last_kick = now

	local ball_location = self:GetLocation()
	local away = ball_location - kicker:GetLocation()
	away = Vector(away.X, away.Y, 0):GetSafeNormal()

	local velocity = kicker:GetVelocity()
	local run = Vector(velocity.X, velocity.Y, 0)
	local speed = run:Size()

	local push
	if (speed < BALL_KICK_MIN_SPEED) then
		push = away * BALL_NUDGE
	else
		local direction = (run:GetSafeNormal() * 0.7 + away * 0.3):GetSafeNormal()
		local power = speed * self.style.kick
		push = direction * power + Vector(0, 0, power * BALL_KICK_LIFT)
	end

	local current = self:GetVelocity()
	self:AddImpulse(push - Vector(current.X, current.Y, math.min(current.Z, 0)), true)

	Events.BroadcastRemote("SpawnSound", Reliability.Unreliable, ball_location, BALL_KICK_SOUND, false, math.min(1, 0.3 + speed / 800), 1.1 / self.style.scale ^ 0.3)
end

function Ball:OnDestroy()
	if (self.trigger and self.trigger:IsValid()) then self.trigger:Destroy() end
end

Ball.Subscribe("Destroy", Ball.OnDestroy)
Ball.SubscribeRemote("SetStyle", Ball.SetStyle)
