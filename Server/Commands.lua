-- Console commands and commands requested by clients

function GetPlayerByNameOrID(key)
	for _, player in pairs(Player.GetPairs()) do
		if (player:GetName() == key or player:GetID() == tonumber(key)) then
			return player
		end
	end

	return nil
end

-- TP console command
Console.RegisterCommand("tp", function(player1, player2)
	if (not player1 or not player2) then
		Console.Error("Invalid parameters passed to 'tp' command!")
		return
	end

	local p1 = GetPlayerByNameOrID(player1)
	local p2 = GetPlayerByNameOrID(player2)

	if (not p1) then Console.Error("Invalid Player 1 name or ID provided!") return end
	if (not p2) then Console.Error("Invalid Player 2 name or ID provided!") return end

	local char1 = p1:GetControlledCharacter()
	local char2 = p2:GetControlledCharacter()

	if (not char1) then Console.Error("Player 1 does not have a controlled Character!") return end
	if (not char2) then Console.Error("Player 2 does not have a controlled Character!") return end

	char1:ResetVelocity()
	char1:SetLocation(char2:GetLocation())

	Console.Log("Teleporting '%s (Player#%d)' to '%s (Player#%d)'.", p1:GetName(), p1:GetID(), p2:GetName(), p2:GetID())
end, "teleports a player to another", { "player1", "player2" })

-- Client Commands
Events.SubscribeRemote("ClientCommand", function(player, command)
	if (command == "reset") then
		Console.Log("The Player '%s' has requested to reset the package.", player:GetName())

		if (Player.GetCount() > 1) then
			Events.CallRemote("AddNotification", player, Reliability.Reliable, NotificationType.Error, "CANT_RESET", "you cannot reset the server while other players are connected", 3, 0, true)
			return
		end

		Sandbox.Reset(player)

		return
	end
end)
