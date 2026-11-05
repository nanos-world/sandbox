-- Global table to store Sandbox related functions and variables, exposed to other packages
Sandbox = {}

-- Exposes Sandbox to other packages, this will contain all subsystems as well
Package.Export("Sandbox", Sandbox)

-- List of Spawn Locations
SPAWN_POINTS = Server.GetMapSpawnPoints()

-- Custom Settings
SANDBOX_CUSTOM_SETTINGS = Server.GetCustomSettings()

Package.Subscribe("Unload", function()
	-- When Package unloads, stores the characters locations to respawn them at the same position if the package is being reloaded
	for _, player in pairs(Player.GetPairs()) do
		local cha = player:GetControlledCharacter()
		if (cha) then
			player:SetValue("last_position", { location = cha:GetLocation(), rotation = Rotator(0, cha:GetRotation().Yaw, 0) })
		end
	end
end)

Package.Subscribe("Load", function()
	for _, player in pairs(Player.GetPairs()) do
		SpawnPlayerCharacter(player)
	end

	Chat.BroadcastMessage("The package <cyan>Sandbox</> has been reloaded!")
end)

Package.Require("SpawnLimits.lua")
Package.Require("Players.lua")
Package.Require("Commands.lua")
Package.Require("Reset.lua")
Package.Require("SpawnMenu.lua")
Package.Require("SpawnHistory.lua")
Package.Require("Sky.lua")
