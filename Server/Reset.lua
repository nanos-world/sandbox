-- Resets every loaded package in load order, including the map that restores its own entities
local RESET_COOLDOWN_SECONDS = 3
local resetting = false
local reset_timer = nil
local auto_reset_timer = nil
local auto_reset_minutes = SANDBOX_CUSTOM_SETTINGS.auto_reset_minutes or 0

local function CancelAutoReset()
	if (not auto_reset_timer) then return end

	Timer.ClearTimeout(auto_reset_timer)
	auto_reset_timer = nil
end

local function ClearResetTimer()
	if (not reset_timer) then return end

	Timer.ClearInterval(reset_timer)
	reset_timer = nil
end

local function ReloadPackages()
	if (resetting) then return end
	resetting = true

	ClearResetTimer()

	CancelAutoReset()

	for _, package in ipairs(Server.GetPackages(true)) do
		Server.ReloadPackage(package.name)
	end
end

-- Ignores further requests while the shared countdown is running
function Sandbox.Reset(player)
	if (resetting or reset_timer) then return end
	if (player and not player:IsValid()) then return end

	CancelAutoReset()

	Chat.BroadcastMessage(string.format("%s requested a server reset.", player and player:GetName() or "Server"))

	local remaining = RESET_COOLDOWN_SECONDS
	local function NotifyCountdown()
		Events.BroadcastRemote("AddNotification", Reliability.Reliable, NotificationType.Info, "RESET_COUNTDOWN", string.format("server resetting in %d...", remaining), 1, 0, true)
	end

	NotifyCountdown()
	reset_timer = Timer.SetInterval(function()
		remaining = remaining - 1
		if (remaining == 0) then
			ReloadPackages()
			return
		end

		NotifyCountdown()
	end, 1000)
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
		ReloadPackages()
	end, auto_reset_minutes * 60000)

	auto_reset_timer = timer_id
end)

Package.Subscribe("Unload", function()
	ClearResetTimer()
	CancelAutoReset()
end)
