--> Perfect R6 Ragdoll V2
--> CompletedLoop May 18, 2025
local Ragdoll = {}

------------------------------------------------------------------------------------------------------------
ATTACHMENT_CFRAMES = { --> Specific positions for each constraint
	["Neck"]           = { CFrame.new(0, 1, 0)      , CFrame.new(0, -0.5, 0)    },
	["Left Shoulder"]  = { CFrame.new(-1.3, 0.75, 0), CFrame.new(0.2, 0.75, 0)  },
	["Right Shoulder"] = { CFrame.new(1.3, 0.75, 0) , CFrame.new(-0.2, 0.75, 0) },
	["Left Hip"]       = { CFrame.new(-0.5, -1, 0)  , CFrame.new(0, 1, 0)       },
	["Right Hip"]      = { CFrame.new(0.5, -1, 0)   , CFrame.new(0, 1, 0)       },
}

------------------------------------------------------------------------------------------------------------
function Ragdoll.new(CharacterModel: Model)
	local self = setmetatable({}, Ragdoll)

	--> References
	self.character = CharacterModel
	self.humanoid = CharacterModel:WaitForChild("Humanoid") :: Humanoid
	self.torso = CharacterModel:WaitForChild("Torso") :: Part
	self.root = CharacterModel:WaitForChild("HumanoidRootPart") :: Motor6D
	self.root_joint = self.root:WaitForChild("RootJoint")

	self.humanoid.BreakJointsOnDeath = false --> We want to Ragdoll on death

	--> Keep track of the constraints to enable/disable them
	self.BallSocketConstraints = {}

	--> The Ragdoll attribute is what toggles the Ragdoll
	--> Last Ragdoll is for tracking how long its been since the last Ragdoll
	self.character:SetAttribute("Ragdoll", false)
	self.character:SetAttribute("LastRagdoll", 0)

	--> Bind to attribute
	Ragdoll.BindToRagdoll(self.character, function(value)
		self:_setRagdollState(value)
	end)

	--> Automatically determine if the character is a NPC
	if not game:GetService("Players"):GetPlayerFromCharacter(CharacterModel) then
		Ragdoll.Bind(CharacterModel) --> Update the humanoid state on the server if npc
	end

	--> Create Ragdoll Constraints
	self:_createRagdollConstraints()

	--> Ragdoll when character dies
	self.humanoid.Died:Once(function()
		self.character:SetAttribute("Ragdoll", true)
	end)

	--> Welds the Torso and HumanoidRootPart together when ragdolled thanks to Frowning_Loser606
	self.RootWeld = Instance.new("WeldConstraint")
	self.RootWeld.Part0 = self.character:WaitForChild("HumanoidRootPart")
	self.RootWeld.Part1 = self.torso
	self.RootWeld.Enabled = false
	self.RootWeld.Name = "HRPWeld"
	self.RootWeld.Parent = self.torso

	return self
end

function Ragdoll:_setRagdollState(to: boolean)
	if to then
		self.humanoid.AutoRotate = false
		self.RootWeld.Enabled = true
		self.root_joint.Enabled = false
		self.character:SetAttribute("LastRagdoll", os.clock())

		self:_setMotor6Ds(false)
		self:_setBallSocketConstraints(true)
	else
		if not (self.humanoid.Health == 0) then --> Dead characters shouldnt unragdoll
			self.humanoid.AutoRotate = true
			self.RootWeld.Enabled = false
			self.root_joint.Enabled = true

			self:_setMotor6Ds(true)
			self:_setBallSocketConstraints(false)
		end
	end
end

function Ragdoll:_setBallSocketConstraints(to: boolean)
	for _, BallSocket: BallSocketConstraint in self.BallSocketConstraints do
		if not BallSocket then continue end
			
		--> Update attachments according to character scale
		local AttachmentCFrame = ATTACHMENT_CFRAMES[BallSocket:GetAttribute("Motor")]
		BallSocket.Attachment0.CFrame = CFrame.new(AttachmentCFrame[1].Position * self.character:GetScale())
		BallSocket.Attachment1.CFrame = CFrame.new(AttachmentCFrame[2].Position * self.character:GetScale())

		BallSocket.Enabled = to
	end
end

function Ragdoll:_setMotor6Ds(to: boolean)
	for _, Motor: Motor6D in self.character:GetDescendants() do
		if Motor:IsA("Motor6D") then
			Motor.Enabled = to
		end
	end
end

function Ragdoll:_createRagdollConstraints()
	for _, Motor: Motor6D in self.character:GetDescendants() do
		--> Checks
		if     not Motor:IsA("Motor6D")           then continue
		elseif not ATTACHMENT_CFRAMES[Motor.Name] then continue end

		local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
		a0.CFrame = ATTACHMENT_CFRAMES[Motor.Name][1]
		a1.CFrame = ATTACHMENT_CFRAMES[Motor.Name][2]

		a0.Name = "RagdollAttachment"
		a1.Name = "RagdollAttachment"

		self:_createColliderPart(Motor.Part1)

		local BallSocketConstraint = Instance.new("BallSocketConstraint")
		BallSocketConstraint.Attachment0 = a0
		BallSocketConstraint.Attachment1 = a1
		BallSocketConstraint.Enabled = false
		BallSocketConstraint.Name = "RagdollConstraint"

		BallSocketConstraint:SetAttribute("Motor", Motor.Name)

		table.insert(self.BallSocketConstraints, BallSocketConstraint)

		BallSocketConstraint.Radius = 0.15
		BallSocketConstraint.LimitsEnabled = true
		BallSocketConstraint.TwistLimitsEnabled = false
		BallSocketConstraint.MaxFrictionTorque = 0
		BallSocketConstraint.Restitution = 0
		BallSocketConstraint.UpperAngle = 120
		BallSocketConstraint.TwistLowerAngle = -45
		BallSocketConstraint.TwistUpperAngle = 45

		if Motor.Name == "Neck" then
			BallSocketConstraint.TwistLimitsEnabled = true
			BallSocketConstraint.UpperAngle = 45
			BallSocketConstraint.TwistLowerAngle = -70
			BallSocketConstraint.TwistUpperAngle = 70
		end

		a0.Parent = Motor.Part0
		a1.Parent = Motor.Part1
		BallSocketConstraint.Parent = Motor.Parent
	end
end

function Ragdoll:_createColliderPart(BodyPart: Part) --> Prevents limbs from clipping through the character
	if not BodyPart:IsDescendantOf(workspace) then return end

	--> Invisible Part that does the colliding
	local ColliderPart = Instance.new("Part")
	ColliderPart.Name = "ColliderPart"
	ColliderPart.Size = BodyPart.Size/1.7
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

	-- ColliderPart:SetNetworkOwner(self.player)
end

------------------------------------------------------------------------------------------------------------
function Ragdoll.BindToRagdoll(character: Model, callback: (value: boolean) -> ()) --> Helper function
	character:GetAttributeChangedSignal("Ragdoll"):Connect(function()
		callback(character:GetAttribute("Ragdoll"))
	end)
end

function Ragdoll.Bind(character: Model) --> If the character is a player then the client should bind
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	Ragdoll.BindToRagdoll(character, function(value)
		Ragdoll.UpdateHumanoidState(humanoid, value)
	end)
end

function Ragdoll.UpdateHumanoidState(humanoid: Humanoid, to: boolean)
	if humanoid.Health == 0 then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
	else
		if humanoid.Parent:GetAttribute("Ragdoll") then
			humanoid:ChangeState(Enum.HumanoidStateType.Physics)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		else
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end
end

------------------------------------------------------------------------------------------------------------
Ragdoll.__index = Ragdoll
return Ragdoll