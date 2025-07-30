local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packets = require(ReplicatedStorage.Shared.Packets)

local player = Players.LocalPlayer
local playerGui = player.PlayerGui
local playerScripts = player.PlayerScripts

------------------------------------------------------------------------------------------------------------
InputController = {
	OnStart = function()
		ContextActionService:BindAction("Ragdoll", function(action, state)
			if state == Enum.UserInputState.Begin then
				Packets.Ragdoll:Fire()
			end
		end, true, Enum.KeyCode.R)

		-- playerScripts:WaitForChild("Inputs").Ragdoll.Pressed:Connect(function()
		-- end)
	end;

	OnTick = function(delta: number)
		
	end;
}

------------------------------------------------------------------------------------------------------------
return InputController