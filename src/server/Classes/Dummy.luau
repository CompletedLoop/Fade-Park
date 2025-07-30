local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Ragdoll = require(ReplicatedStorage.Shared.Modules.Ragdoll)

local Dummy = {}

local DummyDragger = ReplicatedStorage:WaitForChild("DummyDragger")

------------------------------------------------------------------------------------------------------------
function Dummy.new(dummy: Model)
	local self = setmetatable({}, Dummy)
	self.dummy = dummy

	--> Setup Ragdoll
	Ragdoll.new(self.dummy)
	self.dummy:SetAttribute("Ragdoll", true)

	self:_setupDraggers()
	
	return self
end

function Dummy:_setupDraggers()
	for _, BodyPart: Part in self.dummy:GetDescendants() do
		if BodyPart:IsA("Part") then
			local dragger = DummyDragger:Clone()
			dragger.Parent = BodyPart
		end
	end
end

------------------------------------------------------------------------------------------------------------
Dummy.__index = Dummy
return Dummy