local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packets = require(ReplicatedStorage.Shared.Packets)

local player = Players.LocalPlayer
local playerGui = player.PlayerGui
local playerScripts = player.PlayerScripts

------------------------------------------------------------------------------------------------------------
InputController = {
	OnStart = function()
		playerScripts:WaitForChild("Inputs").Ragdoll.Pressed:Connect(function()
			Packets.Ragdoll:Fire()
		end)
	end;

	OnTick = function(delta: number)
		
	end;
}

------------------------------------------------------------------------------------------------------------
return InputController