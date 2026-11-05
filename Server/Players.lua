-- Player and Character lifecycle: spawning, death and respawn, PvP, NoClip, Ragdoll and Character changes

function GetRandomSpawnPoint()
	return #SPAWN_POINTS > 0 and SPAWN_POINTS[math.random(#SPAWN_POINTS)] or { location = Vector(), rotation = Rotator() }
end

-- Handles Characters Death, to auto respawn after a time
function OnPlayerCharacterDeath(character, last_damage_taken, last_bone_damaged, damage_reason, hit_from, instigator)
	local controller = character:GetPlayer()

	-- Was it supposed to happen? Maybe I was unpossessed
	if (not controller) then return end

	-- Outputs a message when dying
	if (instigator) then
		if (instigator == controller) then
			Chat.BroadcastMessage("<cyan>" .. instigator:GetName() .. "</> committed suicide")
		else
			Chat.BroadcastMessage("<cyan>" .. instigator:GetName() .. "</> killed <cyan>" .. controller:GetName() .. "</>")
		end
	else
		Chat.BroadcastMessage("<cyan>" .. controller:GetName() .. "</> died")
	end

	-- Respawn the Character after 5 seconds, we Bind the Timer to the Character, this way if the Character gets destroyed in the meanwhile, this Timer never gets destroyed
	Timer.Bind(
		Timer.SetTimeout(function()
			-- If he is not dead anymore after 5 seconds, ignores it
			if (not character:IsDead()) then return end

			Sandbox.RespawnCharacter(character)
		end, 5000),
		character
	)
end

-- Respawns a dead player's Character at a random spawn point, after the death delay or when they ask for it
function Sandbox.RespawnCharacter(character)
	local spawn_point = GetRandomSpawnPoint()
	character:Respawn(spawn_point.location, spawn_point.rotation)
end

-- With the "enable_pvp" setting off every player is on Team 1, which cannot hurt itself; one on Team 0 hurts and is hurt by anyone, so damage between players only lands when both have PvP on (OnPlayerTakeDamage)
function Sandbox.SetCharacterPvPEnabled(character, enabled)
	if (SANDBOX_CUSTOM_SETTINGS.enable_pvp) then return end

	character:SetTeam(enabled and 0 or 1)
end

function Sandbox.IsCharacterPvPEnabled(character)
	return SANDBOX_CUSTOM_SETTINGS.enable_pvp or character:GetTeam() ~= 1
end

-- Cancels damage from one player to another unless both have PvP on (the attacker's own damage to itself still lands)
local function OnPlayerTakeDamage(character, _, _, _, _, instigator)
	if (SANDBOX_CUSTOM_SETTINGS.enable_pvp or not instigator or not character:GetPlayer() or instigator == character:GetPlayer()) then return end

	local attacker = instigator:GetControlledCharacter()
	if (attacker and Sandbox.IsCharacterPvPEnabled(character) ~= Sandbox.IsCharacterPvPEnabled(attacker)) then return 0 end
end

Character.Subscribe("TakeDamage", OnPlayerTakeDamage)
CharacterSimple.Subscribe("TakeDamage", OnPlayerTakeDamage)

-- Spawns a Character for the Player
function SpawnPlayerCharacter(player)
	-- TODO cache classes?
	local character_classes = {}
	for k, class in pairs(Character.GetInheritedClasses(true)) do
		if (class ~= BaseDefaultCharacter and class ~= BaseDefaultCharacterSimple) then
			table.insert(character_classes, class)
		end
	end

	local character_to_spawn = character_classes[math.random(#character_classes)]

	local location, rotation = nil, nil

	local last_position = player:GetValue("last_position")
	if (last_position) then
		location = last_position.location
		rotation = last_position.rotation
	else
		local spawn_point = GetRandomSpawnPoint()
		location = spawn_point.location
		rotation = spawn_point.rotation
	end

	-- Spawns the Character
	local new_character = character_to_spawn(location, rotation, false)

	-- This will possess, configure Player configs and subscribe to events
	SetupPlayerCharacter(player, new_character)
end

-- Possess, configure Player configs and subscribe to events
function SetupPlayerCharacter(player, character)
	-- Every new Character starts with PvP off, unless the server has it on for everybody
	Sandbox.SetCharacterPvPEnabled(character, false)

	character:SetDimension(player:GetDimension())

	-- Possess the Character
	player:Possess(character)

	-- Subscribe to Death event
	character:Subscribe("Death", OnPlayerCharacterDeath)

	-- Unsubscribe to Death event if unpossessed (in case we got possessed into another Character)
	character:Subscribe("UnPossess", function(self)
		self:Unsubscribe("Death", OnPlayerCharacterDeath)
	end)
end

-- When Player Connects, spawns a new Character and gives it to him
Player.Subscribe("Spawn", function(player)
	Chat.BroadcastMessage("<cyan>" .. player:GetName() .. "</> has joined the server")

	SpawnPlayerCharacter(player)
end)

-- Called when Character respawns
Character.Subscribe("Respawn", function(character)
	-- Resets character's scale to default
	character:SetScale(Vector(1, 1, 1))
end)

-- When Player leaves the server
Player.Subscribe("Destroy", function(player)
	-- Destroy it's Character
	local character = player:GetControlledCharacter()
	if (character) then
		character:Destroy()
	end

	Chat.BroadcastMessage("<cyan>" .. player:GetName() .. "</> has left the server")
end)

Events.SubscribeRemote("ToggleNoClip", function(player)
	if (not SANDBOX_CUSTOM_SETTINGS.enable_noclip) then return end

	local character = player:GetControlledCharacter()
	if (not character) then return end

	local is_noclipping = character:GetValue("NoClip")

	if (is_noclipping) then
		character:SetFlyingMode(false)
		character:SetCollision(CollisionType.Normal)
	else
		character:SetFlyingMode(true)
		character:SetCollision(CollisionType.NoCollision)
	end

	character:SetValue("NoClip", not is_noclipping)
end)

Events.SubscribeRemote("EnterRagdoll", function(player)
	local character = player:GetControlledCharacter()
	if (not character or not character.SetRagdollMode) then return end

	if (not character:IsInputEnabled()) then return end
	if (character:GetVehicle()) then return end

	character:SetRagdollMode(true)
end)

Events.SubscribeRemote("RespawnCharacter", function(player)
	-- Respawn Character or spawn a new one
	local character = player:GetControlledCharacter()
	if (character) then
		Sandbox.RespawnCharacter(character)
	else
		SpawnPlayerCharacter(player)
	end
end)

Events.SubscribeRemote("ChangeCharacter", function(player, class_name)
	local character = player:GetControlledCharacter()

	local class = GetCharacterClasses()[class_name]
	if not class then return end

	local location, rotation, picked_item, view_mode = nil, nil, nil, nil

	if (character) then
		if (character.GetPicked) then
			picked_item = character:GetPicked()
		end

		-- Read before Destroy, as being unpossessed resets the View Mode to TPS2
		if (character.GetViewMode) then
			view_mode = character:GetViewMode()
		end

		location = character:GetLocation()
		rotation = character:GetRotation()

		character:Destroy()
	else
		local spawn_point = GetRandomSpawnPoint()
		location = spawn_point.location
		rotation = spawn_point.rotation
	end

	local new_character = class(location, rotation, false)

	-- This will possess, configure Player configs and subscribe to events
	SetupPlayerCharacter(player, new_character)

	-- Restore the View Mode the player was using
	if (view_mode and new_character.SetViewMode) then
		new_character:SetViewMode(view_mode)
	end

	-- Restore picked up item
	if (picked_item and picked_item:IsValid() and new_character.PickUp) then
		new_character:PickUp(picked_item)
	end
end)
