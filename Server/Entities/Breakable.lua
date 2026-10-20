-- Every Prop whose mesh is in BREAKABLE_PROPS breaks (or leaks and blows up) when hit hard or damaged, whoever spawned it and whenever: these are the
-- Prop class events, so nothing has to register a prop. A prop with the server value "Unbreakable" set (prop:SetValue("Unbreakable", true)) is left alone
local function GetBreakableData(prop)
	local breakable_data = BREAKABLE_PROPS[prop:GetMesh()]
	if (not breakable_data or prop:GetValue("Unbreakable")) then return nil end
	return breakable_data
end

Prop.Subscribe("Hit", function(prop, intensity)
	if (GetBreakableData(prop)) then
		BreakProp(prop, intensity)
	end
end)

Prop.Subscribe("TakeDamage", function(prop, damage)
	local breakable_data = GetBreakableData(prop)
	if (not breakable_data) then return end

	-- An inflammable one first ignites, then explodes
	if (breakable_data.explosive and breakable_data.explosive.inflammable) then
		InflameProp(prop)
	else
		BreakProp(prop, damage * 50)
	end
end)

-- This will trigger "Inflame" in a inflammable Prop - I.e. make it fire for some seconds then explode
function InflameProp(prop)
	local breakable_data = BREAKABLE_PROPS[prop:GetMesh()]

	if (not breakable_data) then
		Console.Warn("Failed to find Breakable data for Prop '" .. prop:GetMesh() .."'. Maybe missed configuration?")
		return
	end

	if (prop:GetValue("IsLeaking")) then
		local location = prop:GetLocation()
		local scale = prop:GetScale()
		prop:Destroy()

		ExplodeProp(location, breakable_data.explosive, scale.X)
		return
	end

	prop:SetValue("IsLeaking", true)
	prop:SetForce(Vector(0, 0, breakable_data.explosive.inflammable.force or -100000), true)

	local gas_leak_sounds = {
		"nanos-world::A_Gas_Leak_Loop_01",
		"nanos-world::A_Gas_Leak_Loop_02",
		"nanos-world::A_Gas_Leak_Loop_03",
	}

	Events.BroadcastRemote("SpawnSoundAttached", Reliability.Reliable, prop, gas_leak_sounds[math.random(#gas_leak_sounds)], false, false, 0.5, math.random(9, 11) / 10)

	local particle = Particle(prop:GetLocation(), Rotator(), "nanos-world::P_LeadersRing", false, true)
	particle:AttachTo(prop, AttachmentRule.SnapToTarget, "", 0.05)
	particle:SetRelativeLocation(breakable_data.explosive.inflammable.relative_particle or Vector())
	particle:SetRelativeRotation(Rotator(90, 0, 0))
	particle:SetScale(Vector(0.25))

	Timer.Bind(Timer.SetTimeout(function(explosible)
		local location = explosible:GetLocation()
		local scale = explosible:GetScale()
		explosible:Destroy()

		ExplodeProp(location, breakable_data.explosive, scale.X)
	end, (breakable_data.explosive.inflammable.duration or 5000) * math.random(75, 125) / 100, prop), prop)
end

-- This will "Break" a breakable prop into several Debris
function BreakProp(prop, intensity)
	local breakable_data = BREAKABLE_PROPS[prop:GetMesh()]

	if (not breakable_data) then
		Console.Warn("Failed to find Breakable data for Prop '" .. prop:GetMesh() .."'. Maybe missed configuration?")
		return
	end

	-- Checks if intensity is enough to break
	if (intensity < (breakable_data.weakness or 500)) then
		return
	end

	-- Stores object data
	local parent_location = prop:GetLocation()
	local parent_scale = prop:GetScale()
	local override_lifespan = prop:GetValue("DebrisLifeSpan")

	-- Explosives may have no debris
	for _, debris_data in ipairs(breakable_data.debris or {}) do
		-- Chance to spawn, 0 means no chance, 1 means 100% chance of spawning
		if (not debris_data.randomness or debris_data.randomness >= math.random()) then
			-- Spawns the Debris on the client (better performance for server)
			Events.BroadcastRemote("SpawnDebris", Reliability.Reliable,
				prop,
				debris_data.offset,
				debris_data.rotation,
				debris_data.mesh,
				override_lifespan or debris_data.lifespan or 10
			)
		end
	end

	-- Destroy main prop
	prop:Destroy()

	if (breakable_data.explosive) then
		ExplodeProp(parent_location, breakable_data.explosive, parent_scale.X)
	end
end

-- This will "explode" a Explodable Prop
function ExplodeProp(location, explosive_data, scale)
	-- Spawns a Grenade to explode it immediately
	local grenade = Grenade(location, Rotator(), "nanos-world::SM_None", "nanos-world::P_Grenade_Special", "nanos-world::A_Explosion_Large", CollisionType.StaticOnly, false)

	-- Configures the Damage
	grenade:SetDamage(
		(explosive_data.base_damage or 50) * (scale or 1),
		explosive_data.minimum_damage or 0,
		(explosive_data.damage_inner_radius or 200) * (scale or 1),
		(explosive_data.damage_outer_radius or 1000) * (scale or 1),
		explosive_data.damage_falloff or 1
	)

	-- Explodes it!
	grenade:Explode()
end

-- Makes every Prop of mesh break (or blow up), see Shared/Config/Breakable.lua for the fields
function Sandbox.SetBreakableProp(mesh, weakness, debris, explosive)
	BREAKABLE_PROPS[mesh] = { weakness = weakness, debris = debris, explosive = explosive }
end

-- The breakable config of mesh, nil when it does not break
function Sandbox.GetBreakableProp(mesh)
	return BREAKABLE_PROPS[mesh]
end
