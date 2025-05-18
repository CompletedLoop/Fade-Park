local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

local player = Players.LocalPlayer

local Controllers = script.Parent.Controllers
local Classes = script.Parent.Classes

local Loader = require(ReplicatedStorage.Shared.Modules.Loader)
local Packets = require(ReplicatedStorage.Shared.Packets)

local CharacterClient = require(Classes.CharacterClient)

------------------------------------------------------------------------------------------------------------
--> Load Controllers
Loader(Controllers)


