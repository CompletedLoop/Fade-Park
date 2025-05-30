local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Classes = ServerScriptService.Server.Classes
local Packets = require(ReplicatedStorage.Shared.Packets)

------------------------------------------------------------------------------------------------------------
PlayerService = {

	OnStart = function()
		Players.PlayerAdded:Connect(PlayerService.PlayerAdded)
		Players.PlayerRemoving:Connect(PlayerService.PlayerRemoving)

		Packets.SamplePing.OnServerInvoke = function() return "Sample" end

		Packets.Ragdoll.OnServerEvent:Connect(function(player: Player)
			local player_character = player.Character
			player_character:SetAttribute("Ragdoll", not player_character:GetAttribute("Ragdoll"))
		end)
	end;

	PlayerAdded = function(player: Player)
		--> Get Player Profile


	end;

	PlayerRemoving = function(player: Player)
		

	end;

}

------------------------------------------------------------------------------------------------------------

return PlayerService