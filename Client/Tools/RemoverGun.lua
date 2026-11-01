RemoverGun = ToolGun.Inherit("RemoverGun")

-- Tool Info
RemoverGun.name = "Remover Gun"
RemoverGun.image = "package://sandbox/Client/Media/Tools/RemoverGun.webp"
RemoverGun.description = "Destroys entities from the world"

-- Tool Tutorials
RemoverGun.tutorials = {
	{ key = "LeftClick", text = "remove object" },
}

-- Tool Crosshair Trace Debug Settings
RemoverGun.debug_trace = {
	collision_channel = CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.PhysicsBody | CollisionChannel.Vehicle | CollisionChannel.Pawn,
	show_crosshair = true,
}


-- Overrides ToolGun method
function RemoverGun:OnLocalPlayerFire(shooter)
	-- Makes a trace 10000 units ahead
	local trace_result = TraceFor(10000, RemoverGun.debug_trace.collision_channel)

	local entity = trace_result.Entity

	-- If hit an object (or an NPC, never a player character), calls the server to destroy it
	if (trace_result.Success and entity and not entity:HasAuthority() and not ((entity:IsA(Character) or entity:IsA(CharacterSimple)) and entity:GetPlayer() ~= nil)) then
		Events.CallRemote("DestroyItem", Reliability.Reliable, entity)
	else
		-- If didn't hit anything, plays a negative sound
		SoundInvalidAction:Play()
	end
end