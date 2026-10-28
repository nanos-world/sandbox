-- Resets every loaded package in load order, including the map that restores its own entities
local resetting = false
local auto_reset_timer = nil
local auto_reset_minutes = SANDBOX_CUSTOM_SETTINGS.auto_reset_minutes or 0

local function CancelAutoReset()
	if (not auto_reset_timer) then return end

	Timer.ClearTimeout(auto_reset_timer)
	auto_reset_timer = nil
end

function Sandbox.Reset()
	if (resetting) then return end
	resetting = true

	CancelAutoReset()

	for _, package in ipairs(Server.GetPackages(true)) do
		Server.ReloadPackage(package.name)
	end
end

Player.Subscribe("Spawn", CancelAutoReset)

Player.Subscribe("Destroy", function(player)
	if (auto_reset_minutes <= 0 or auto_reset_timer or resetting) then return end

	-- The departing player can still be in GetPairs while its Destroy event runs
	for _, other in pairs(Player.GetPairs()) do
		if (other ~= player) then return end
	end

	local timer_id
	timer_id = Timer.SetTimeout(function()
		if (auto_reset_timer ~= timer_id) then return end
		auto_reset_timer = nil

		if (Player.GetCount() ~= 0) then return end

		Console.Log("Resetting all packages after the server stayed empty for %d minutes.", auto_reset_minutes)
		Sandbox.Reset()
	end, auto_reset_minutes * 60000)

	auto_reset_timer = timer_id
end)

Package.Subscribe("Unload", CancelAutoReset)
