Jukebox = Prop.Inherit("Jukebox")

ConfigureSpawnLimits("Jukebox", "Jukeboxes", Jukebox.GetCount, "max_jukeboxes")

-- The song, whether it plays, its volume and how far it carries are synced values, every client plays the Sound itself
function Jukebox:Constructor(location, rotation, song, is_playing, volume, distance)
	self.Super:Constructor(location or Vector(), rotation or Rotator(), "nanos-world::SM_Gramophone", CollisionType.Auto, true, GrabMode.Enabled, CCDMode.Auto, SpawnMode.Manual)

	-- The Spawn Menu calls it with (location, rotation, tab, id, player), so anything that is not a known song, a boolean or a number falls back to the defaults
	local is_known_song = false
	for _, entry in ipairs(JUKEBOX_SONGS) do
		if (entry.id == song) then is_known_song = true end
	end

	self:SetValue("Song", is_known_song and song or Jukebox.PickRandomSong(), true)
	self:SetValue("Playing", is_playing ~= false, true)
	self:SetVolume(nil, type(volume) == "number" and volume or JUKEBOX_VOLUME)
	self:SetDistance(nil, type(distance) == "number" and distance or JUKEBOX_FALLOFF_DISTANCE)

	self:FinishSpawn()
end

-- Picks a random song, never the same one the previous jukebox got
function Jukebox.PickRandomSong()
	local index = math.random(#JUKEBOX_SONGS)
	if (#JUKEBOX_SONGS > 1 and index == Jukebox.last_random_song) then
		index = index % #JUKEBOX_SONGS + 1
	end

	Jukebox.last_random_song = index
	return JUKEBOX_SONGS[index].id
end

function Jukebox:SetSong(player, song)
	for _, entry in ipairs(JUKEBOX_SONGS) do
		if (entry.id == song) then
			self:SetValue("Song", song, true)
			self:SetValue("Playing", true, true)
			return
		end
	end

	Console.Warn("Jukebox: unknown song '%s'", tostring(song))
end

function Jukebox:SetPlaying(player, is_playing)
	self:SetValue("Playing", is_playing == true, true)
end

function Jukebox:SetVolume(player, volume)
	self:SetValue("Volume", math.max(0, math.min(1, tonumber(volume) or JUKEBOX_VOLUME)), true)
end

function Jukebox:SetDistance(player, distance)
	self:SetValue("Distance", math.max(JUKEBOX_MIN_DISTANCE, math.min(JUKEBOX_MAX_DISTANCE, tonumber(distance) or JUKEBOX_FALLOFF_DISTANCE)), true)
end

-- Interacting plays or stops it instead of picking it up
-- Interacting is disabled for a second afterwards, like the Button
function Jukebox:OnInteract(character)
	local is_playing = not self:GetValue("Playing")
	self:SetPlaying(character:GetPlayer(), is_playing)

	Events.BroadcastRemote("SpawnSound", Reliability.Reliable, self:GetLocation(), "nanos-world::A_Switch_Button_03", false, 0.5, is_playing and 3 or 2)

	self:SetGrabMode(GrabMode.Disabled)
	Timer.Bind(Timer.SetTimeout(function()
		self:SetGrabMode(GrabMode.Enabled)
	end, 1000), self)

	return false
end

-- Shooting it turns it off
function Jukebox:OnTakeDamage(damage, bone, type, from_direction, instigator, causer)
	local is_playing = self:GetValue("Playing")
	if (not is_playing) then return end

	self:SetPlaying(instigator, false)
end

Jukebox.Subscribe("Interact", Jukebox.OnInteract)
Jukebox.Subscribe("TakeDamage", Jukebox.OnTakeDamage)
Jukebox.SubscribeRemote("SetSong", Jukebox.SetSong)
Jukebox.SubscribeRemote("SetPlaying", Jukebox.SetPlaying)
Jukebox.SubscribeRemote("SetVolume", Jukebox.SetVolume)
Jukebox.SubscribeRemote("SetDistance", Jukebox.SetDistance)
