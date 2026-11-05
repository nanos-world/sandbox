-- Cached sounds and sounds spawned on request of the server

-- Hit Taken Feedback Sound Cached
SoundHitTakenFeedback = Sound(Vector(), "nanos-world::A_HitTaken_Feedback", true, false, SoundType.SFX, 1, 1, 400, 3600, 0, false, 0, false)

Events.SubscribeRemote("SpawnSound", function(location, sound_asset, is_2D, volume, pitch)
	Sound(location, sound_asset, is_2D, true, SoundType.SFX, volume or 1, pitch or 1)
end)

Events.SubscribeRemote("SpawnSoundAttached", function(object, sound_asset, is_2D, auto_destroy, volume, pitch)
	local sound = Sound(object:GetLocation(), sound_asset, is_2D, auto_destroy ~= false, SoundType.SFX, volume or 1, pitch or 1)
	sound:AttachTo(object, AttachmentRule.SnapToTarget, "", 0)
end)
