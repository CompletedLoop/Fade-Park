--> Perfect R6 Ragdoll V2
--> CompletedLoop May 18, 2025

local Ragdoll = {}

------------------------------------------------------------------------------------------------------------
local ATTACHMENT_CFRAMES = { --> Specific positions for each constraint
	["Neck"]           = {CFrame.new(0, 1, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1), CFrame.new(0, -0.5, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1)},
	["Left Shoulder"]  = {CFrame.new(-1.3, 0.75, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1), CFrame.new(0.2, 0.75, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1)},
	["Right Shoulder"] = {CFrame.new(1.3, 0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1), CFrame.new(-0.2, 0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)},
	["Left Hip"]       = {CFrame.new(-0.5, -1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1), CFrame.new(0, 1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1)},
	["Right Hip"]      = {CFrame.new(0.5, -1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1), CFrame.new(0, 1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1)},
}

------------------------------------------------------------------------------------------------------------
--> Main
function Ragdoll.new(CharacterModel: Model, NoRagdollOnDeath: boolean?)
	local self = setmetatable({}, Ragdoll)

	--> Get References
	self.character = CharacterModel
	self.humanoid = CharacterModel:WaitForChild("Humanoid") :: Humanoid
	self.torso = CharacterModel:WaitForChild("Torso") :: Part

	self.humanoid.BreakJointsOnDeath = false

	--> The Ragdoll attribute is what toggles the Ragdoll
	--> Last Ragdoll is for tracking how long its been since the last Ragdoll
	self.character:SetAttribute("Ragdoll", false)
	self.character:SetAttribute("LastRagdoll", 0)

	--> Bind to attribute
	self.character:GetAttributeChangedSignal("Ragdoll"):Connect(function()
		self:SetRagdollState(self:_getRagdollState())
		self:_updateHumanoidState()
	end)

	--> Ragdoll when character dies
	if not NoRagdollOnDeath then
		self.humanoid.Died:Once(function()
			self.character:SetAttribute("Ragdoll", false)
			self:cleanup()
		end)
	end

	--> Welds the Torso and HumanoidRootPart together when ragdolled thanks to Frowning_Loser606
	self.RootWeld = Instance.new("WeldConstraint")
	self.RootWeld.Part0 = self.character:WaitForChild("HumanoidRootPart")
	self.RootWeld.Part1 = self.torso
	self.RootWeld.Enabled = false
	self.RootWeld.Name = "HRPWeld"
	self.RootWeld.Parent = self.torso

	return self
end

function Ragdoll:SetRagdollState(to: boolean)
	if to then
		self:_convertJoints()

		self.humanoid.AutoRotate = false
		self.RootWeld.Enabled = true
		self.character:SetAttribute("LastRagdoll", os.clock())
	else
		-- if not self.humanoid.Health == 0 then --> Dead characters shouldnt unragdoll
			self:_resetJoints()
			self.humanoid.AutoRotate = true
			self.RootWeld.Enabled = false
		-- end
	end
end

function Ragdoll:_createColliderPart(BodyPart: Part)
	if not BodyPart:IsDescendantOf(workspace) then return end

	--> Invisible Part that does the colliding
	local ColliderPart = Instance.new("Part")
	ColliderPart.Name = "ColliderPart"
	ColliderPart.Size = BodyPart.Size/1.75
	ColliderPart.Massless = true
	ColliderPart.CFrame = BodyPart.CFrame
	ColliderPart.Transparency = 1

	--> Weld the BodyPart to the ColliderPart
	local Weld = Instance.new("WeldConstraint")
	Weld.Name = "RagdollWeld"
	Weld.Part0 = ColliderPart
	Weld.Part1 = BodyPart

	Weld.Parent = ColliderPart
	ColliderPart.Parent = BodyPart
end

function Ragdoll:_updateHumanoidState()
	if self.humanoid.Health == 0 then
		self.humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
	else
		if self:_getRagdollState() then
			self.humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
			self.humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		else
			self.humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end
end

function Ragdoll:_convertJoints()
	for _, Motor: Motor6D in self.character:GetDescendants() do
		--> Checks
		if     not Motor:IsA("Motor6D")           then continue
		elseif Motor.Name == "RootJoint"          then Motor.Enabled = false continue
		elseif not ATTACHMENT_CFRAMES[Motor.Name] then continue end
			
		Motor.Enabled = false

		local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
		a0.CFrame = ATTACHMENT_CFRAMES[Motor.Name][1]
		a1.CFrame = ATTACHMENT_CFRAMES[Motor.Name][2]

		a0.Name = "RagdollAttachment"
		a1.Name = "RagdollAttachment"

		self:_createColliderPart(Motor.Part1)

		local BallSocket = Instance.new("BallSocketConstraint")
		BallSocket.Attachment0 = a0
		BallSocket.Attachment1 = a1
		BallSocket.Name = "RagdollConstraint"

		BallSocket.Radius = 0.15
		BallSocket.LimitsEnabled = true
		BallSocket.TwistLimitsEnabled = false
		BallSocket.MaxFrictionTorque = 0
		BallSocket.Restitution = 0
		BallSocket.UpperAngle = 90
		-- BallSocket.TwistLowerAngle = -45
		-- BallSocket.TwistUpperAngle = 45

		if Motor.Name == "Neck" then
			BallSocket.TwistLimitsEnabled = true
			BallSocket.UpperAngle = 45
			BallSocket.TwistLowerAngle = -70
			BallSocket.TwistUpperAngle = 70
		end

		a0.Parent = Motor.Part0
		a1.Parent = Motor.Part1
		BallSocket.Parent = Motor.Parent
	end
end

function Ragdoll:_resetJoints()
	for _, instance: Part | WeldConstraint | BallSocketConstraint | Motor6D in self.character:GetDescendants() do
		if instance.Name == "ColliderPart" or
		instance.Name == "RagdollWeld" or
		instance.Name == "RagdollConstraint" or
		instance.Name == "RagdollAttachment" then
			instance:Destroy()
		elseif instance:IsA("Motor6D") then
			instance.Enabled = true
		end
	end
end

function Ragdoll:_getRagdollState(): boolean
	return self.character:GetAttribute("Ragdoll")
end

function Ragdoll:cleanup()
	self = nil
	return
end

------------------------------------------------------------------------------------------------------------
Ragdoll.__index = Ragdoll
return Ragdoll