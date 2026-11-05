-- Per-server limits for every spawnable entity type, configured from the custom settings

-- Configured limits for spawned items per player
SANDBOX_LIMITS = {
	-- ["ID"] = { max_count = 0, label = "Label", func_check = function() }
}

-- TODO store limits per player?
--	 weak table k, store per [player][id] = { item, item } (weak v)
function ConfigureSpawnLimits(ID, label, func_check, setting_override)
	local max_count = SANDBOX_CUSTOM_SETTINGS[setting_override]

	if (not max_count) then
		Console.Warn("No setting found to configure '%s' (%s) limits as '%s'", ID, label, setting_override)
		return
	end

	Console.Debug("Configuring '%s' (%s) limits: %d", ID, label, max_count)

	SANDBOX_LIMITS[ID] = { max_count = max_count, label = label, func_check = func_check }
end

-- Whether one more item with this limit ID fits under the server's configured limit (an item without a limit always does)
-- Exported in Sandbox, so other packages spawning sandbox entities themselves can keep to the same limits
function Sandbox.IsUnderSpawnLimit(ID)
	local limit_data = SANDBOX_LIMITS[ID]

	-- No limits for this item
	if (not limit_data or limit_data.max_count == 0 or not limit_data.func_check) then
		return true
	end

	return limit_data.func_check() < limit_data.max_count
end

-- Validates if a player can spawn an item
function Sandbox.ValidateSpawnLimits(player, ID)
	if (Sandbox.IsUnderSpawnLimit(ID)) then
		return true
	end

	local limit_data = SANDBOX_LIMITS[ID]

	-- Can't spawn
	Events.CallRemote("AddNotification", player, Reliability.Reliable, NotificationType.Warning, "SPAWN_LIMIT_" .. ID, "the server have reached the configured limit of " .. limit_data.max_count .. " " .. limit_data.label .. ".", 3, 0, true)

	return false
end
