-- Global table to store Sandbox related functions and variables, exposed to other packages
Sandbox = {}

-- Spawns Sandbox HUD
Sandbox.HUD = Sandbox.HUD or WebUI("Sandbox HUD", "file:///UI/index.html")

-- Exposes Sandbox to other packages, this will contain all subsystems as well
Package.Export("Sandbox", Sandbox)

-- Returns where the local player is aiming (camera location, aim direction, aim rotation), using the control rotation
function Sandbox.GetCameraAim()
	local local_player = Client.GetLocalPlayer()
	if (not local_player) then return nil end

	local camera_rotation = local_player:GetCameraRotation()
	return local_player:GetCameraLocation(), camera_rotation:GetForwardVector(), camera_rotation
end

-- Configures Keybindings Inputs
Input.Register("NoClip", "B", "Toggles the No Clip mode")
Input.Register("Scoreboard", "Tab", "Toggles the Scoreboard")
Input.Register("Ragdoll", "J", "Enters Ragdoll Mode")
Input.Register("SpawnMenu", "Q", "Toggles the Spawn Menu")
Input.Register("ContextMenu", "C", "Toggles the Context Menu")
Input.Register("Undo", "Z", "Destroy last spawned Item")

-- Text shown in the escape menu
Client.SetEscapeMenuText([[
<h1>Sandbox</>

The official nanos world Sandbox game-mode. Spawn props, weapons, vehicles and NPCs, build contraptions with physics tools and play freely with your friends.

<h2>Features</>
- <strong>Spawn Menu</> (`Q`): every Prop, Weapon, Vehicle and Character from every loaded package, searchable and split by tabs and categories
- <strong>Context Menu</> (`C`): select any entity in the world and tweak it (tint, gravity, custom per-entity options)
- <strong>Tool Guns</>: Physics Gun, Weld, Rope, Elastic, Spring, Slider, Ball Socket, Thruster, Wheel, Balloon, Light, Lamp, Trail, Button, Wire, Color, Resizer, Remover and more
- <strong>Entities</>: TVs, CCTVs, Instant Cameras, Targets, Jukebox, Buttons, Photo Frames, Signs, Floating Texts, Rope Lights, Flashlights, Bouncy Balls, Balloons...
- <strong>Dynamic sky and weather</> powered by Ultra Dynamic Sky
- <strong>Undo</> (`Z`) and a spawn history
- <strong>Noclip</> (`B`), <strong>Ragdoll</> (`J`) and a <strong>Scoreboard</> (`Tab`)
- Per-server spawn limits for every entity type
- Extensible: other packages can add items, context menu options and notifications
]])

-- Loads Package Files
Package.Require("EntityInputSystem.lua")
Package.Require("PersistentConfigSystem.lua")
Package.Require("Notifications.lua")
Package.Require("ContextMenu.lua")
Package.Require("SpawnMenu.lua")
Package.Require("SpawnHistory.lua")
Package.Require("Scoreboard.lua")
Package.Require("Sky.lua")
Package.Require("Nametags.lua")
Package.Require("Tutorials.lua")
Package.Require("HUD.lua")
Package.Require("Sounds.lua")

-- When package loads, verify if LocalPlayer already exists (eg. when reloading the package), then try to get and store it's controlled character
Package.Subscribe("Load", function()
	Input.SetMouseEnabled(false)
	Input.SetInputEnabled(true)

	local local_player = Client.GetLocalPlayer()

	if (local_player ~= nil) then
		UpdateLocalCharacter(local_player:GetControlledCharacter())
		SetupLocalPlayer(local_player)
	end
end)

Input.Bind("NoClip", InputEvent.Pressed, function()
	Events.CallRemote("ToggleNoClip")
end)

Input.Bind("Ragdoll", InputEvent.Pressed, function()
	Events.CallRemote("EnterRagdoll")
end)

Input.Subscribe("KeyPress", function(key_name, delta)
	-- Closes Spawn Menu or Context Menu if opened when Escape is pressed
	if (key_name == "Escape") then
		if (ContextMenu.is_opened) then
			ContextMenu.Close()
			return false
		end

		if (SpawnMenu.is_opened) then
			SpawnMenu.Close()
			return false
		end
	end
end)

-- Client Console Commands
Console.RegisterCommand("reset", function()
	Events.CallRemote("ClientCommand", Reliability.Reliable, "reset")
end, "resets the server if you are the only player")
