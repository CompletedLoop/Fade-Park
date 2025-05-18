local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

local Packets = require(ReplicatedStorage.Shared.Packets)
local Icon = require(StarterPlayer.StarterPlayerScripts.Client.ClientModules.Icon)
local SamplePing = require(StarterPlayer.StarterPlayerScripts.Client.ClientModules.SamplePing)
local TimedConnection = require(ReplicatedStorage.Shared.Modules.TimedConnection)
local SettingsController = require(StarterPlayer.StarterPlayerScripts.Client.Controllers.UI.SettingsController)

------------------------------------------------------------------------------------------------------------
TopbarController = {

	OnStart = function()
		--> Create Icons
		Icon.new():setImage("13612120903"):oneClick(true):bindEvent("selected", SettingsController.ToggleSettingsPanel)

		TopbarController.PingIcon = Icon.new():setEnabled(true):lock()

		TimedConnection.new(RunService.Stepped, TopbarController.UpdatePing, .2)
	end;

	UpdatePing = function()
		local ping = SamplePing()
		local IconTextLabel = TopbarController.PingIcon:getInstance("IconLabel") :: TextLabel

		if (ping < 75) then IconTextLabel.TextColor3 = Color3.fromRGB(73, 255, 131)
        elseif (ping < 150) then IconTextLabel.TextColor3 = Color3.fromRGB(255, 214, 74)
        elseif (ping > 150) then IconTextLabel.TextColor3 = Color3.fromRGB(255, 74, 74) end

		TopbarController.PingIcon:setLabel(`{ping}ms`)
	end;

}

------------------------------------------------------------------------------------------------------------

return TopbarController