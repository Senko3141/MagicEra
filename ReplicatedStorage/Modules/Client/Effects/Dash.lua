local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local ImpactLines = require(ReplicatedStorage:WaitForChild("Modules").Client.Effects.ImpactLines)

--[[
return function(Data)	
	local Target = Data.Target
	local Root = Target.Character.HumanoidRootPart

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {workspace.Effects, workspace.Live, Target.Character}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

	local DirtStep = Assets.Particles.Dirt:Clone()
	DirtStep.ParticleEmitter.Enabled = true
	DirtStep.CFrame = Root.CFrame * CFrame.new(0,-2.55,.225)
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

		local result = workspace:Raycast(Root.Position, Root.CFrame.upVector * -30, raycastParams)
		if result then
			DirtStep.ParticleEmitter.Color = ColorSequence.new(result.Instance.Color)
		end
	end)

	task.delay(.3, 
		function() 
			DirtStep.ParticleEmitter.Enabled = false 
		end
	)
	Debris:AddItem(DirtStep, 1)
end
]]--

local function doEffect(Character, Parent)
	local Origin = Character.HumanoidRootPart.Position
	local Direction = Character.HumanoidRootPart.CFrame.UpVector*-5
	local Params = RaycastParams.new()
	Params.FilterDescendantsInstances = {workspace.Place}
	Params.FilterType = Enum.RaycastFilterType.Whitelist
	Params.IgnoreWater = true

	local Result = workspace:Raycast(Origin, Direction, Params)
	if Result then
		--
		local Clone = script.RunParticle:Clone()
		Debris:AddItem(Clone, 1)
		Clone.Parent = workspace.Effects
		Clone.MovementParticles.Run.Color = ColorSequence.new(Result.Instance.Color)

		local connection = nil;
		connection = RunService.RenderStepped:Connect(function(dt)
			if not Clone.Parent then
				connection:Disconnect()
				connection = nil
				return
			end

			local result = workspace:Raycast(Character.HumanoidRootPart.Position, Character.HumanoidRootPart.CFrame.upVector * -30, Params)
			if result then
				Clone.MovementParticles.Run.Color = ColorSequence.new(result.Instance.Color)
			end
		end)

		Clone.CFrame = Parent.CFrame * CFrame.new(math.random(-.7,.7), -2.5, 2)

		Clone.MovementParticles.Run:Emit(1)

		task.delay(.5, function()
			Clone.MovementParticles.Run.Enabled = false
		end)		
	end
end

return function(Data)
	local Character = Data.Character
	local Parent = Data.Parent

	doEffect(Character, Parent)
end