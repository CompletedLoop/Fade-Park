local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Packets = require(ReplicatedStorage.Shared.Packets)
local Ragdoll = require(StarterPlayer.StarterPlayerScripts.Client.ClientModules.Ragdoll)

local CharacterServer = {} :: { player: Player, character: Model}
CharacterServer.__index = CharacterServer

------------------------------------------------------------------------------------------------------------
function CharacterServer.new(player: Player)
	local self = setmetatable({}, CharacterServer)

	self.player = player
	self.character = player.Character or player.CharacterAdded:Wait()

	--> Check if there is already a CharacterServer Object
	if self.character:HasTag("LoadedCharacter") then
		warn(`A CharacterServer Object has already been created for {self.Character.Name}`)
		self:destroy()
		return
	end

	self:InitializeCharacter()

	print(`Created CharacterServer Object for {player.Name}`)

	
	return self
end

function CharacterServer:InitializeCharacter()
	self.character.Parent = workspace.Characters
	
	self.character:AddTag("LoadedCharacter")

	Ragdoll.new(self.character)

	if workspace.DEBUG.Value then
		require(ServerStorage.VisualDelay)(`{self.player.Name}`)
	end
end

function CharacterServer:destroy()
	self = {}
	return
end

------------------------------------------------------------------------------------------------------------
return CharacterServer
