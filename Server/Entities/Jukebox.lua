Jukebox = Prop.Inherit("Jukebox")

ConfigureSpawnLimits("Jukebox", "Jukeboxes", Jukebox.GetCount, "max_jukeboxes")

-- The playlist, song, when it started, whether it plays, shuffles, its volume and how far it carries are synced values, every client plays the Sound itself
-- With shuffle on, the server moves to a random song of the playlist when the current one ends (by its duration in JUKEBOX_SONGS)
-- song can also be a playlist id, to start on a random song of it
function Jukebox:Constructor(location, rotation, song, is_playing, volume, distance, shuffle)
	self.Super:Constructor(location or Vector(), rotation or Rotator(), "nanos-world::SM_Gramophone", CollisionType.Auto, true, GrabMode.Enabled, CCDMode.Auto, SpawnMode.Manual)

	-- The Spawn Menu calls it with (location, rotation, tab, id, player), so anything that is not a known song or playlist, a boolean or a number falls back to the defaults
	local playlist = Jukebox.FindPlaylist(song) or Jukebox.FindPlaylistOf(song) or JUKEBOX_PLAYLISTS[1]
	if (not Jukebox.FindSong(song)) then song = Jukebox.PickRandomSong(playlist.id) end

	self:SetValue("Playlist", playlist.id, true)
	self:SetValue("Shuffle", shuffle ~= false, true)
	self:SetVolume(nil, type(volume) == "number" and volume or JUKEBOX_VOLUME)
	self:SetDistance(nil, type(distance) == "number" and distance or JUKEBOX_FALLOFF_DISTANCE)
	self:PlaySong(song, is_playing ~= false)

	self:FinishSpawn()
end

-- Picks a random song of the playlist, never the one passed (the song that just ended) nor the same one the previous jukebox got
function Jukebox.PickRandomSong(playlist_id, current_song)
	local songs = (Jukebox.FindPlaylist(playlist_id) or JUKEBOX_PLAYLISTS[1]).songs

	local candidates = {}
	for _, song in ipairs(songs) do
		if (song ~= current_song and song ~= Jukebox.last_random_song) then
			table.insert(candidates, song)
		end
	end

	local song = #candidates > 0 and candidates[math.random(#candidates)] or songs[math.random(#songs)]
	Jukebox.last_random_song = song
	return song
end

-- The song's entry in JUKEBOX_SONGS, nil when it is not a known song
function Jukebox.FindSong(song)
	for _, entry in ipairs(JUKEBOX_SONGS) do
		if (entry.id == song) then return entry end
	end
end

-- The playlist's entry in JUKEBOX_PLAYLISTS, nil when it is not a known playlist
function Jukebox.FindPlaylist(playlist_id)
	for _, playlist in ipairs(JUKEBOX_PLAYLISTS) do
		if (playlist.id == playlist_id) then return playlist end
	end
end

function Jukebox.PlaylistHas(playlist, song)
	for _, playlist_song in ipairs(playlist and playlist.songs or {}) do
		if (playlist_song == song) then return true end
	end

	return false
end

-- The first playlist that has the song, nil when none does
function Jukebox.FindPlaylistOf(song)
	for _, playlist in ipairs(JUKEBOX_PLAYLISTS) do
		if (Jukebox.PlaylistHas(playlist, song)) then return playlist end
	end
end

-- Starts a song from the beginning (or just sets it, when not playing)
-- "SongStartedAt" is always set last: clients restart the Sound when it changes, by then the song and playing are already up to date
function Jukebox:PlaySong(song, is_playing)
	self:SetValue("Song", song, true)
	self:SetValue("Playing", is_playing, true)
	self:SetValue("SongStartedAt", Server.GetTime(), true)
	self:ScheduleNextSong()
end

-- (Re)starts the timer that moves to a random song when the current one ends, only while playing with shuffle on
function Jukebox:ScheduleNextSong()
	if (self.next_song_timer) then
		Timer.ClearTimeout(self.next_song_timer)
		self.next_song_timer = nil
	end

	local entry = Jukebox.FindSong(self:GetValue("Song"))
	local duration = entry and entry.duration
	if (not duration or not self:GetValue("Playing") or not self:GetValue("Shuffle")) then return end

	-- Shuffle can be turned on mid song, so it counts from when the song started
	local remaining = duration * 1000 - (Server.GetTime() - self:GetValue("SongStartedAt"))

	self.next_song_timer = Timer.SetTimeout(function()
		self.next_song_timer = nil
		self:PlaySong(Jukebox.PickRandomSong(self:GetValue("Playlist"), self:GetValue("Song")), true)
	end, math.max(0, remaining))

	Timer.Bind(self.next_song_timer, self)
end

-- A song outside the current playlist moves the jukebox to the first playlist that has it
function Jukebox:SetSong(player, song)
	if (not Jukebox.FindSong(song)) then
		Console.Warn("Jukebox: unknown song '%s'", tostring(song))
		return
	end

	if (not Jukebox.PlaylistHas(Jukebox.FindPlaylist(self:GetValue("Playlist")), song)) then
		self:SetValue("Playlist", (Jukebox.FindPlaylistOf(song) or JUKEBOX_PLAYLISTS[1]).id, true)
	end

	self:PlaySong(song, true)
end

-- Switching playlist plays a random song of it
function Jukebox:SetPlaylist(player, playlist_id)
	if (not Jukebox.FindPlaylist(playlist_id)) then
		Console.Warn("Jukebox: unknown playlist '%s'", tostring(playlist_id))
		return
	end

	self:SetValue("Playlist", playlist_id, true)
	self:PlaySong(Jukebox.PickRandomSong(playlist_id, self:GetValue("Song")), true)
end

-- Playing again starts the song over
function Jukebox:SetPlaying(player, is_playing)
	self:PlaySong(self:GetValue("Song"), is_playing == true)
end

function Jukebox:SetShuffle(player, shuffle)
	self:SetValue("Shuffle", shuffle == true, true)
	self:ScheduleNextSong()
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
Jukebox.SubscribeRemote("SetPlaylist", Jukebox.SetPlaylist)
Jukebox.SubscribeRemote("SetPlaying", Jukebox.SetPlaying)
Jukebox.SubscribeRemote("SetShuffle", Jukebox.SetShuffle)
Jukebox.SubscribeRemote("SetVolume", Jukebox.SetVolume)
Jukebox.SubscribeRemote("SetDistance", Jukebox.SetDistance)
