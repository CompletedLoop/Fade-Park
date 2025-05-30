local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

local player = Players.LocalPlayer

local Ragdoll = require(StarterPlayer.StarterPlayerScripts.Client.ClientModules.Ragdoll)

local CharacterClient = {} :: { player: Player, character: Model}
CharacterClient.__index = CharacterClient

local WALK_SPEED = 12.5

------------------------------------------------------------------------------------------------------------
function CharacterClient.new()
	local self = setmetatable({}, CharacterClient)

	self.player = Players.LocalPlayer
	self.character = self.player.Character or self.player.CharacterAdded:Wait()
	self.humanoid = self.character:WaitForChild("Humanoid") :: Humanoid
	self.root = self.character:WaitForChild("HumanoidRootPart") :: Part

	self:InitializeCharacter()

	RunService.Heartbeat:Connect(function(delta) self:Tick(delta) end)
	
	print(`Created CharacterClient Object for {player.Name}`)
	return self
end

function CharacterClient:InitializeCharacter()
	Ragdoll.new(self.character)
end

function CharacterClient:Tick(delta: number)
	--> do something to check the current state of the character
	self.humanoid.WalkSpeed = WALK_SPEED
end

function CharacterClient:destroy()
	
end

------------------------------------------------------------------------------------------------------------
return CharacterClient