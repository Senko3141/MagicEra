local Ragdoller = { }

local IntNew = Instance.new

Joints = {}

local HeadSocket = Instance.new("BallSocketConstraint")
HeadSocket.Name = "Neck"
HeadSocket.LimitsEnabled = true
HeadSocket.Restitution = 0
HeadSocket.TwistLimitsEnabled = true
HeadSocket.UpperAngle = 60
HeadSocket.TwistUpperAngle = -40
HeadSocket.TwistLowerAngle = 40
HeadSocket.Parent = script.Constraints

local LeftHip = Instance.new("BallSocketConstraint")
LeftHip.Name = "Left Hip"
LeftHip.LimitsEnabled = true
LeftHip.Restitution = 0
LeftHip.TwistLimitsEnabled = true
LeftHip.UpperAngle = 70
LeftHip.TwistUpperAngle = -5
LeftHip.TwistLowerAngle = 80
LeftHip.Parent = script.Constraints

local RightHip = Instance.new("BallSocketConstraint")
RightHip.Name = "Right Hip"
RightHip.LimitsEnabled = true
RightHip.Restitution = 0
RightHip.TwistLimitsEnabled = true
RightHip.UpperAngle = 70
RightHip.TwistUpperAngle = -5
RightHip.TwistLowerAngle = 80
RightHip.Parent = script.Constraints

local LeftShoulder = Instance.new("BallSocketConstraint")
LeftShoulder.Name = "Left Shoulder"
LeftShoulder.LimitsEnabled = true
LeftShoulder.Restitution = 0
LeftShoulder.TwistLimitsEnabled = true
LeftShoulder.UpperAngle = 140
LeftShoulder.TwistUpperAngle = -85
LeftShoulder.TwistLowerAngle = 85
LeftShoulder.Parent = script.Constraints

local RightShoulder = Instance.new("BallSocketConstraint")
RightShoulder.Name = "Right Shoulder"
RightShoulder.LimitsEnabled = true
RightShoulder.Restitution = 0
RightShoulder.TwistLimitsEnabled = true
RightShoulder.UpperAngle = 140
RightShoulder.TwistUpperAngle = -85
RightShoulder.TwistLowerAngle = 85
RightShoulder.Parent = script.Constraints

local Dict = {
	["Neck"] = function(Character)
		if not Character:FindFirstChild'Torso' then return end
		if not Character.Torso:FindFirstChild'Neck' then return end
		if not Character:FindFirstChild'Head' then return end

		local Scale = Character:FindFirstChild'rs' and (Character.HumanoidRootPart.Size.Y / 2) or 1

		Character.Torso.Neck.Part0 = nil

		local A0 = Instance.new("Attachment")
		A0.Position = Vector3.new(0, 1, 0) * Scale
		A0.Orientation = Vector3.new(-90, -180, 0)
		A0.Name = "RagdollAttachment"
		A0.Parent = Character["Torso"]

		local A1 = Instance.new("Attachment")
		A1.Position = Vector3.new(0, -0.5, 0) * Scale
		A1.Orientation = Vector3.new(-90, -180, 0)
		A1.Name = "RagdollAttachment"
		A1.Parent = Character.Head

		local Constraint = HeadSocket:Clone()
		Constraint.Name = "ConstraintJoint"
		Constraint.Attachment0 = A0
		Constraint.Attachment1 = A1
		Constraint.Parent = Character.Torso

		local Collider = Instance.new("Part")
		Collider.Size = Vector3.new(1, 0.5, 0.5) * Scale
		Collider.Shape = "Block"
		Collider.Massless = false -- Massless = true
		Collider.TopSurface = "Smooth"
		Collider.BottomSurface = "Smooth"
		Collider.formFactor = "Symmetric"
		Collider.Transparency = 1
		Collider.Name = "Collision"
		Collider.Parent = Character.Head

		local Weld = Instance.new("Weld")
		Weld.Part0 = Character.Head
		Weld.Part1 = Collider
		Weld.Parent = Collider
	end,
	["Left Hip"] = function(Character)
		if not Character:FindFirstChild'Torso' then return end
		if not Character.Torso:FindFirstChild'Left Hip' then return end
		if not Character:FindFirstChild'Left Leg' then return end

		local Scale = Character:FindFirstChild'rs' and (Character.HumanoidRootPart.Size.Y / 2) or 1

		Character.Torso["Left Hip"].Part0 = nil

		local A0 = Instance.new("Attachment")
		A0.Position = Vector3.new(-1, -1, 0) * Scale
		A0.Orientation = Vector3.new(0, -90, 0)
		A0.Name = "RagdollAttachment"
		A0.Parent = Character["Torso"]

		local A1 = Instance.new("Attachment")
		A1.Position = Vector3.new(-0.5, 1, 0) * Scale
		A1.Orientation = Vector3.new(0, -90, 0)
		A1.Name = "RagdollAttachment"
		A1.Parent = Character["Left Leg"]

		local Constraint = LeftHip:Clone()
		Constraint.Name = "ConstraintJoint"
		Constraint.Attachment0 = A0
		Constraint.Attachment1 = A1
		Constraint.Parent = Character.Torso

		local Collider = Instance.new("Part")
		Collider.Size = Vector3.new(0.5, 1, 0.5) * Scale
		Collider.Shape = "Block"
		Collider.Massless = false -- Massless = true
		Collider.TopSurface = "Smooth"
		Collider.BottomSurface = "Smooth"
		Collider.formFactor = "Symmetric"
		Collider.Transparency = 1
		Collider.Name = "Collision"
		Collider.Parent = Character["Left Leg"]

		local Weld = Instance.new("Weld")
		Weld.Part0 = Character["Left Leg"]
		Weld.Part1 = Collider
		Weld.C0 = CFrame.new(0,-0.2,0) * CFrame.fromEulerAnglesXYZ(0, 0, math.pi/2)
		Weld.Parent = Collider
	end,

	["Right Hip"] = function(Character)
		if not Character:FindFirstChild'Torso' then return end
		if not Character.Torso:FindFirstChild'Right Hip' then return end
		if not Character:FindFirstChild'Right Leg' then return end

		local Scale = Character:FindFirstChild'rs' and (Character.HumanoidRootPart.Size.Y / 2) or 1

		Character.Torso["Right Hip"].Part0 = nil

		local A0 = Instance.new("Attachment")
		A0.Position = Vector3.new(1, -1, 0) * Scale
		A0.Orientation = Vector3.new(0, 90, 0)
		A0.Name = "RagdollAttachment"
		A0.Parent = Character["Torso"]

		local A1 = Instance.new("Attachment")
		A1.Position = Vector3.new(0.5, 1, 0) * Scale
		A1.Orientation = Vector3.new(0, 90, 0)
		A1.Name = "RagdollAttachment"
		A1.Parent = Character["Right Leg"]

		local Constraint = RightHip:Clone()
		Constraint.Name = "ConstraintJoint"
		Constraint.Attachment0 = A0
		Constraint.Attachment1 = A1
		Constraint.Parent = Character.Torso

		local Collider = Instance.new("Part")
		Collider.Size = Vector3.new(0.5, 1, 0.5) * Scale
		Collider.Shape = "Block"
		Collider.Massless = false -- Massless = true
		Collider.TopSurface = "Smooth"
		Collider.BottomSurface = "Smooth"
		Collider.formFactor = "Symmetric"
		Collider.Transparency = 1
		Collider.Name = "Collision"
		Collider.Parent = Character["Right Leg"]

		local Weld = Instance.new("Weld")
		Weld.Part0 = Character["Right Leg"]
		Weld.Part1 = Collider
		Weld.C0 = CFrame.new(0,-0.2,0) * CFrame.fromEulerAnglesXYZ(0, 0, math.pi/2)
		Weld.Parent = Collider
	end,

	["Left Shoulder"] = function(Character)
		if not Character:FindFirstChild'Torso' then return end
		if not Character.Torso:FindFirstChild'Left Shoulder' then return end
		if not Character:FindFirstChild'Left Arm' then return end

		local Scale = Character:FindFirstChild'rs' and (Character.HumanoidRootPart.Size.Y / 2) or 1

		Character.Torso["Left Shoulder"].Part0 = nil

		local A0 = Instance.new("Attachment")
		A0.Position = Vector3.new(-1, 0.5, 0) * Scale
		A0.Orientation = Vector3.new(0, -90, 0)
		A0.Name = "RagdollAttachment"
		A0.Parent = Character["Torso"]

		local A1 = Instance.new("Attachment")
		A1.Position = Vector3.new(0.5, 0.5, 0) * Scale
		A1.Orientation = Vector3.new(0, -90, 0)
		A1.Name = "RagdollAttachment"
		A1.Parent = Character["Left Arm"]

		local Constraint = LeftShoulder:Clone()
		Constraint.Name = "ConstraintJoint"
		Constraint.Attachment0 = A0
		Constraint.Attachment1 = A1
		Constraint.Parent = Character.Torso

		local Collider = Instance.new("Part")
		Collider.Size = Vector3.new(0.5, 1, 0.5) * Scale
		Collider.Shape = "Block"
		Collider.Massless = false -- Massless = true
		Collider.TopSurface = "Smooth"
		Collider.BottomSurface = "Smooth"
		Collider.formFactor = "Symmetric"
		Collider.Transparency = 1
		Collider.Name = "Collision"
		Collider.Parent = Character["Left Arm"]

		local Weld = Instance.new("Weld")
		Weld.Part0 = Character["Left Arm"]
		Weld.Part1 = Collider
		Weld.C0 = CFrame.new(0,-0.2,0) * CFrame.fromEulerAnglesXYZ(0, 0, math.pi/2)
		Weld.Parent = Collider
	end,

	["Right Shoulder"] = function(Character)
		if not Character:FindFirstChild'Torso' then return end
		if not Character.Torso:FindFirstChild'Right Shoulder' then return end
		if not Character:FindFirstChild'Right Arm' then return end

		local Scale = Character:FindFirstChild'rs' and (Character.HumanoidRootPart.Size.Y / 2) or 1

		Character.Torso["Right Shoulder"].Part0 = nil

		local A0 = Instance.new("Attachment")
		A0.Position = Vector3.new(1, 0.5, 0) * Scale
		A0.Orientation = Vector3.new(0, 90, 0)
		A0.Name = "RagdollAttachment"
		A0.Parent = Character["Torso"]

		local A1 = Instance.new("Attachment")
		A1.Position = Vector3.new(-0.5, 0.5, 0) * Scale
		A1.Orientation = Vector3.new(0, 90, 0)
		A1.Name = "RagdollAttachment"
		A1.Parent = Character["Right Arm"]

		local Constraint = RightShoulder:Clone()
		Constraint.Name = "ConstraintJoint"
		Constraint.Attachment0 = A0
		Constraint.Attachment1 = A1
		Constraint.Parent = Character.Torso

		local Collider = Instance.new("Part")
		Collider.Size = Vector3.new(0.5, 1, 0.5) * Scale
		Collider.Shape = "Block"
		Collider.Massless = false -- Massless = true
		Collider.TopSurface = "Smooth"
		Collider.BottomSurface = "Smooth"
		Collider.formFactor = "Symmetric"
		Collider.Transparency = 1
		Collider.Name = "Collision"
		Collider.Parent = Character["Right Arm"]

		local Weld = Instance.new("Weld")
		Weld.Part0 = Character["Right Arm"]
		Weld.Part1 = Collider
		Weld.C0 = CFrame.new(0,-0.2,0) * CFrame.fromEulerAnglesXYZ(0, 0, math.pi/2)
		Weld.Parent = Collider
	end,
}

function Ragdoller:Ragdoll(Character)
	if not Character:FindFirstChildOfClass("Humanoid") or Character:GetAttribute('Ragdolled') == true or Character:GetAttribute('Carrier') ~= nil then -- (Character:GetAttribute('Carrier') ~= nil and Character:GetAttribute('Restoring') ~= true) then
		return
	end

	local Humanoid = Character:FindFirstChildOfClass("Humanoid")

	Character:SetAttribute('Ragdolled', true)

	--if not(player.Data.Skills.Value:find("Deepknight_Helmet")) and not(table.find(bald, player.Data.Race.Value)) then

	--game.ServerScriptService.Iceyware.GiveNoclipImmunity:Invoke(game:GetService("Players"):GetPlayerFromCharacter(Character), 1)
	
	repeat wait() 
		Humanoid.PlatformStand = true 
		Humanoid.AutoRotate = false
		Humanoid.RequiresNeck = false
	until Humanoid.PlatformStand == true and Humanoid.AutoRotate == false and Humanoid.RequiresNeck == false

	for i, v in pairs(Character:GetDescendants()) do
		--if v:IsA'BasePart' then
		--	v:SetNetworkOwner(nil)
		--end
		if (v:IsA'Motor6D' or v:IsA'Weld') and v:GetAttribute'C0Position' == nil then
			local X0, Y0, Z0 = v.C0:ToEulerAnglesXYZ()
			local X1, Y1, Z1 = v.C1:ToEulerAnglesXYZ()

			v:SetAttribute('C0Position', Vector3.new(v.C0.X, v.C0.Y, v.C0.Z))
			v:SetAttribute('C0Angle', Vector3.new(X0, Y0, Z0))

			v:SetAttribute('C1Position', Vector3.new(v.C1.X, v.C1.Y, v.C1.Z))
			v:SetAttribute('C1Angle', Vector3.new(X1, Y1, Z1))
		end

		if v:IsA("Motor6D") then
			if v.Name == "Right Shoulder" or v.Name == "Left Shoulder" or v.Name == "Right Hip" or v.Name == "Left Hip" or v.Name == 'Neck' then
				Dict[v.Name](Character)
			end
		end
	end
end

function Ragdoller:UnRagdoll(Character)
	if not Character:FindFirstChildOfClass("Humanoid") then
		return
	end

	if Character:SetAttribute('Ragdolled') ~= nil then return end

	Character:SetAttribute('Ragdolled', nil)

	local Player = game:GetService("Players"):GetPlayerFromCharacter(Character)
	local Humanoid = Character.Humanoid

	for i, v in pairs(Character:GetDescendants()) do
		--if v:IsA'BasePart' then
		--	v:SetNetworkOwner(Player)
		--end

		if v:IsA("Motor6D") then
			if v.Name == "Right Shoulder" or v.Name == "Right Hip" or v.Name == "Left Shoulder" or v.Name == "Left Hip" or v.Name == 'Neck' then
				v.Part0 = Character.Torso
			end
		elseif v.Name == "RagdollAttachment" then
			v:Destroy()
		elseif v.Name == "ConstraintJoint" then
			v:Destroy()
		elseif v.Name == "Collision" then
			v:Destroy()
		end

		if (v:IsA'Motor6D' or v:IsA'Weld') and v:GetAttribute'C0Position' ~= nil then
			local C0Position = v:GetAttribute'C0Position'
			local C1Position = v:GetAttribute'C1Position'
			local C0Angle = v:GetAttribute'C0Angle'
			local C1Angle = v:GetAttribute'C1Angle'

			v.C0 = CFrame.new(C0Position.X, C0Position.Y, C0Position.Z) * CFrame.Angles(C0Angle.X, C0Angle.Y, C0Angle.Z)
			v.C1 = CFrame.new(C1Position.X, C1Position.Y, C1Position.Z) * CFrame.Angles(C1Angle.X, C1Angle.Y, C1Angle.Z)
		end
	end

	Humanoid.PlatformStand = false
	Humanoid.AutoRotate = true
	--[[local preventFling = Instance.new("AlignPosition")
	preventFling.Name = "preventFling"
	preventFling.Attachment0 = Character["HumanoidRootPart"].RootAttachment
	preventFling.Mode = Enum.PositionAlignmentMode.OneAttachment
	preventFling.Position = Character["HumanoidRootPart"].Position
	preventFling.Enabled = true
	preventFling.Parent = Character["HumanoidRootPart"]
	
	task.delay(.1, function()
		preventFling:Destroy()
	end)]]
	
	repeat wait() 
		Humanoid.PlatformStand = false 
		Humanoid.AutoRotate = true
	until Humanoid.PlatformStand == false and Humanoid.AutoRotate == true
	
	--[[
	local GotUp = Instance.new("Folder")
	GotUp.Name = "GotUp"
	GotUp.Parent = workspace.AliveData[Character.Name].Status
	workspace.Debris:Fire(GotUp,0.5)
	]]--

	task.delay(1, function() Humanoid.RequiresNeck = true end)

	-- weird offset limb bug fix

	pcall(function()
		local Scale = Character:FindFirstChild'rs' and (Character.HumanoidRootPart.Size.Y / 2) or 1

		Character.HumanoidRootPart.RootJoint.C0 = CFrame.Angles(-math.pi / 2, 0, -math.pi)
		Character.HumanoidRootPart['Root Hip'].C0 = CFrame.Angles(-math.pi / 2, 0, -math.pi)
		Character.HumanoidRootPart['Root Hip'].C1 = CFrame.Angles(-math.pi / 2, 0, -math.pi)
		Character.Torso['Right Hip'].C0      = CFrame.new(1 * Scale, -1 * Scale, 0) * CFrame.Angles(0, math.pi / 2, 0)
		Character.Torso['Left Hip'].C0       = CFrame.new(-1 * Scale, -1 * Scale, 0) * CFrame.Angles(0, -math.pi / 2, 0)
		Character.Torso['Right Shoulder'].C0 = CFrame.new(1 * Scale, 0.5 * Scale, 0) * CFrame.Angles(0, math.pi / 2, 0)
		Character.Torso['Left Shoulder'].C0  = CFrame.new(-1 * Scale, 0.5 * Scale, 0) * CFrame.Angles(0, -math.pi / 2, 0)
		Character.Torso['Neck'].C0           = CFrame.new(0, 1 * Scale, 0) * CFrame.Angles(-math.pi / 2, 0, -math.pi)
		
	end)
end

return Ragdoller