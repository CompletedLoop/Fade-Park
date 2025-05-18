local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Loader = require(ReplicatedStorage.Shared.Modules.Loader)
local Packets = require(ReplicatedStorage.Shared.Packets)

local Services = script.Parent.Services

------------------------------------------------------------------------------------------------------------
--> Load Services
Loader(Services)
