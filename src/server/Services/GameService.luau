local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Packets = require(ReplicatedStorage.Shared.Packets)
local Dummy = require(ServerScriptService.Server.Classes.Dummy)

------------------------------------------------------------------------------------------------------------
GameService = {

	OnStart = function()
		--> Remotes
		GameService.SetupRemotes()

		--> Dummies
		GameService.SetupDummies()
	end;

	SetupDummies = function()
		local dummy_spawners = CollectionService:GetTagged("DummySpawner") :: { Part }
		
		for _, spawner in dummy_spawners do
			spawner.Transparency = 1
			spawner.Locked = true

			GameService.SpawnDummy(spawner:GetPivot())
		end
	end;
	
	SpawnDummy = function(at: CFrame)
		local dummy = ServerStorage.Dummy:Clone()
		dummy.Parent = workspace.Characters.Dummies
		dummy:PivotTo(at)

		Dummy.new(dummy)

		dummy.Humanoid.Died:Connect(function()
			task.delay(5, function()
				GameService.SpawnDummy(at)
				dummy:Destroy()
			end)
		end)
	end;

	SetupRemotes = function()
		--> Ping
		Packets.SamplePing.OnServerInvoke = function() return "Sample" end

		--> Ragdoll
		Packets.Ragdoll.OnServerEvent:Connect(function(player: Player)
			local player_character = player.Character
			player_character:SetAttribute("Ragdoll", not player_character:GetAttribute("Ragdoll"))
		end)
	end;

}

------------------------------------------------------------------------------------------------------------
return GameService