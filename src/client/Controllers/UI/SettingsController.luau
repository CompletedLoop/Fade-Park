local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Iris = require(StarterPlayer.StarterPlayerScripts.Client.ClientModules.Iris)

------------------------------------------------------------------------------------------------------------
SettingsController = {

	OnStart = function()

	end;

	ToggleSettingsPanel = function()
		print("toggled")
	end
}

------------------------------------------------------------------------------------------------------------

return SettingsController