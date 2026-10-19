Jukebox = Prop.Inherit("Jukebox")

Jukebox.name = "Jukebox"
Jukebox.image = "package://sandbox/Client/Media/Entities/Jukebox.webp"
Jukebox.category = "devices"

-- Context Menu Items when selecting this Entity
Jukebox.selected_context_menu_items = {
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

-- (Re)creates the looping Sound for the current song, attached to the jukebox, or removes it when stopped; a volume or distance change keeps the song where it is
function Jukebox:UpdateSound()
	local song = self:GetValue("Song")
	local is_playing = self:GetValue("Playing")
	local volume = self:GetValue("Volume") or JUKEBOX_VOLUME
	local distance = self:GetValue("Distance") or JUKEBOX_FALLOFF_DISTANCE

	self:SetInteractionToolTipText(is_playing and "stop" or "play")

	if (self.sound and self.sound:IsValid()) then
		if (is_playing and self.sound_song == song) then
			self.sound:SetVolume(volume)
			self.sound:SetFalloffDistance(distance)
			return
		end

		self.sound:Destroy()
	end

	self.sound, self.sound_song = nil, nil

	if (not is_playing or not song) then return end

	self.sound = Sound(self:GetLocation(), song, false, false, SoundType.Music, volume, 1, JUKEBOX_INNER_RADIUS, distance, AttenuationFunction.NaturalSound, false, SoundLoopMode.Forever)
	self.sound:AttachTo(self, AttachmentRule.SnapToTarget, "", 0)
	self.sound_song = song
end

function Jukebox:OnSpawn()
	self:UpdateSound()
end

function Jukebox:OnValueChange(key)
	if (key == "Song" or key == "Playing" or key == "Volume" or key == "Distance") then
		self:UpdateSound()
	end
end

function Jukebox:OnDestroy()
	if (self.sound and self.sound:IsValid()) then self.sound:Destroy() end
end

Jukebox.Subscribe("Spawn", Jukebox.OnSpawn)
Jukebox.Subscribe("ValueChange", Jukebox.OnValueChange)
Jukebox.Subscribe("Destroy", Jukebox.OnDestroy)
