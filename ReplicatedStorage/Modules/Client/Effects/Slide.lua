local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local ImpactLines = require(ReplicatedStorage:WaitForChild("Modules").Client.Effects.ImpactLines)

return function(Data)	
	local Target = Data.Target
	local Root = Target.Character.HumanoidRootPart

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {workspace.Effects, workspace.Live, Target.Character}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

	local DirtStep = Assets.Particles.Dirt:Clone()
	DirtStep.ParticleEmitter.Enabled = true
	DirtStep.CFrame = Root.CFrame * CFrame.new(0,-3.4,.225)
	DirtStep.Parent = Root
	
	--ImpactLines({Character = Target, Amount = 8})
	
	local WeldConstraint = Instance.new("WeldConstraint"); 
	WeldConstraint.Part0 = Root
	WeldConstraint.Part1 = DirtStep;
	WeldConstraint.Parent = DirtStep

	local connection = nil;
	connection = RunService.RenderStepped:Connect(function(dt)
		if not DirtStep.Parent then
			connection:Disconnect()
			connection = nil
			return
		end
		if not Target.Character.Status:FindFirstChild("Slidinng") then
			connection:Disconnect()
			connection = nil
			DirtStep.ParticleEmitter.Enabled = false
			return
		end

		local result = workspace:Raycast(Root.Position, Root.CFrame.upVector * -30, raycastParams)
		if result then
			DirtStep.ParticleEmitter.Color = ColorSequence.new(result.Instance.Color)
		end
	end)

	task.delay(.8, 
		function() 
			if DirtStep.Parent then
				DirtStep.ParticleEmitter.Enabled = false 
			end
		end
	)
	Debris:AddItem(DirtStep, 2)
end