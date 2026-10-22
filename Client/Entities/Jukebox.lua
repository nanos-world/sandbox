Jukebox = Prop.Inherit("Jukebox")

Jukebox.name = "Jukebox"
Jukebox.image = "package://sandbox/Client/Media/Entities/Jukebox.webp"
Jukebox.category = "devices"

-- Context Menu Items when selecting this Entity
Jukebox.selected_context_menu_items = {
	{
		id = "jukebox_playlist",
		type = "select",
		label = "playlist",
		options = JUKEBOX_PLAYLISTS,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetPlaylist", Reliability.Reliable, value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("Playlist")
		end,
	},
	{
		id = "jukebox_song",
		type = "select",
		label = "song",
		options = JUKEBOX_SONGS,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetSong", Reliability.Reliable, value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("Song")
		end,
	},
	{
		id = "jukebox_playing",
		type = "checkbox",
		label = "playing",
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetPlaying", Reliability.Reliable, value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("Playing")
		end,
	},
	{
		id = "jukebox_shuffle",
		type = "checkbox",
		label = "shuffle",
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetShuffle", Reliability.Reliable, value)
		end,
		value = function()
			return ContextMenu.selected_entity:GetValue("Shuffle")
		end,
	},
	{
		id = "jukebox_volume",
		type = "range",
		label = "volume",
		min = 0,
		max = 100,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetVolume", Reliability.Reliable, value / 100)
		end,
		value = function()
			return math.floor((ContextMenu.selected_entity:GetValue("Volume") or JUKEBOX_VOLUME) * 100 + 0.5)
		end,
	},
	{
		id = "jukebox_distance",
		type = "range",
		label = "max distance (m)",
		min = JUKEBOX_MIN_DISTANCE / 100,
		max = JUKEBOX_MAX_DISTANCE / 100,
		callback = function(value)
			ContextMenu.selected_entity:CallRemoteEvent("SetDistance", Reliability.Reliable, value * 100)
		end,
		value = function()
			return math.floor((ContextMenu.selected_entity:GetValue("Distance") or JUKEBOX_FALLOFF_DISTANCE) / 100 + 0.5)
		end,
	},
}

-- (Re)creates the Sound for the current song, attached to the jukebox and seeked to how long ago the server started it, or removes it when stopped
-- Without restart, a playing Sound keeps going and only takes the new volume and distance
-- It loops on its own unless shuffling, then the server picks the next song when it ends
-- It keeps playing silently out of range, otherwise Unreal would restart it from the beginning (or drop it, when not looping) on coming back
function Jukebox:UpdateSound(restart)
	local song = self:GetValue("Song")
	local is_playing = self:GetValue("Playing")
	local volume = self:GetValue("Volume") or JUKEBOX_VOLUME
	local distance = self:GetValue("Distance") or JUKEBOX_FALLOFF_DISTANCE

	self:SetInteractionToolTipText(is_playing and "stop" or "play")

	if (self.sound and self.sound:IsValid()) then
		if (is_playing and not restart) then
			self.sound:SetVolume(volume)
			self.sound:SetFalloffDistance(distance)
			return
		end

		self.sound:Destroy()
	end

	self.sound = nil

	if (not is_playing or not song) then return end

	local loop_mode = self:GetValue("Shuffle") and SoundLoopMode.Never or SoundLoopMode.Forever
	self.sound = Sound(self:GetLocation(), song, false, false, SoundType.Music, volume, 1, JUKEBOX_INNER_RADIUS, distance, AttenuationFunction.NaturalSound, true, loop_mode, false)
	self.sound:AttachTo(self, AttachmentRule.SnapToTarget, "", 0)

	-- Late joiners and shuffle toggles land where everyone else is; past the end it wraps, as it would have looped
	local elapsed = math.max(0, (Client.GetTime() - (self:GetValue("SongStartedAt") or Client.GetTime())) / 1000)
	local duration = self.sound:GetDuration()
	self.sound:Play(duration > 0 and elapsed % duration or 0)
end

function Jukebox:OnSpawn()
	self:UpdateSound(true)
end

-- Song and Playing (true) are always followed by SongStartedAt, which is what restarts the Sound, so it never plays twice in a row
function Jukebox:OnValueChange(key, value)
	if (key == "SongStartedAt" or key == "Shuffle") then
		self:UpdateSound(true)
	elseif ((key == "Playing" and not value) or key == "Volume" or key == "Distance") then
		self:UpdateSound()
	end

	-- Keeps an open Context Menu in sync (shuffle moving to the next song, someone else changing it), through the item's own value so it shows as the menu does
	if (ContextMenu.selected_entity == self) then
		for _, item in ipairs(Jukebox.selected_context_menu_items) do
			if (item.id == "jukebox_" .. key:lower()) then
				ContextMenu.SetItemValue(item.id, item.value())
			end
		end
	end
end

function Jukebox:OnDestroy()
	if (self.sound and self.sound:IsValid()) then self.sound:Destroy() end
end

Jukebox.Subscribe("Spawn", Jukebox.OnSpawn)
Jukebox.Subscribe("ValueChange", Jukebox.OnValueChange)
Jukebox.Subscribe("Destroy", Jukebox.OnDestroy)
