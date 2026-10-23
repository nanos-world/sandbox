LightGun = ToolGunSingleTarget.Inherit("LightGun")

function LightGun:Constructor(location, rotation)
	-- Calls parent ToolGun constructor
	ToolGunSingleTarget.Constructor(self, location, rotation, Color.YELLOW)
end

function LightGun:OnSpawnLight(player, spawn_location, relative_location, relative_rotation, direction, entity, configs)
	-- Refuse to attach a light to a player
	if (entity and entity:IsA(Character) and entity:GetPlayer()) then
		return
	end

	if (not ValidateSpawnLimits(player, "Lamp")) then
		return
	end

	configs = configs or {}
	local cable_length = math.max(10, math.min(tonumber(configs.cable_length) or 100, 500))

	local lamp_type = GetLampType(configs.type) or LAMP_TYPES[1]
	local lamp = nil

	-- A random color each
	if (lamp_type.wall) then
		-- Fixed on the surface like a Button: its front (+Y) along the surface's normal
		local rotation = (direction:ToOrientationRotator():Quaternion() * Rotator(0, -90, 0):Quaternion()):Rotator()
		lamp = Lamp(spawn_location, rotation, nil, nil, player, lamp_type.id, Color.RandomPalette(false))

		if (entity and entity:IsValid()) then
			lamp:AttachTo(entity, AttachmentRule.KeepWorld, "", 0)
		else
			lamp:SetGravityEnabled(false)
		end
	else
		-- Hangs from the surface
		lamp = Lamp(spawn_location, direction:ToOrientationRotator() + Rotator(90, 0, 0), nil, nil, player, lamp_type.id, Color.RandomPalette(false))
		lamp:Hang(entity, relative_location, cable_length)
	end

	-- Updates the client's spawn history
	SpawnHistory.AddItemToHistory(player, lamp)

	Particle(spawn_location, direction:ToOrientationRotator(), "nanos-world::P_DirectionalBurst"):SetParameterColor("Color", lamp.light:GetColor())
end

LightGun.SubscribeRemote("SpawnLight", LightGun.OnSpawnLight)
