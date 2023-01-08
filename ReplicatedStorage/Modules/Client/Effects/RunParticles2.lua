local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

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
		Debris:AddItem(Clone, 2.5)
		Clone.Parent = workspace.Effects
		
		for _,v in pairs(Clone.MovementParticles:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v.Color = ColorSequence.new(Result.Instance.Color)
			end
		end
		
		local connection = nil;
		connection = RunService.RenderStepped:Connect(function(dt)
			if not Clone.Parent then
				connection:Disconnect()
				connection = nil
				return
			end

			local result = workspace:Raycast(Character.HumanoidRootPart.Position, Character.HumanoidRootPart.CFrame.upVector * -30, Params)
			if result then
				for _,v in pairs(Clone.MovementParticles:GetChildren()) do
					if v:IsA("ParticleEmitter") then
						v.Color = ColorSequence.new(Result.Instance.Color)
					end
				end
			end
		end)

		Clone.CFrame = Parent.CFrame * CFrame.new(math.random(-.9,.9), -2.4, -1.5)

		for _,v in pairs(Clone.MovementParticles:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(2)
			end
		end

		task.delay(.5, function()
			for _,v in pairs(Clone.MovementParticles:GetChildren()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = false
				end
			end
		end)		
	end
end

return function(Data)
	local Character = Data.Character
	local Parent = Data.Parent
	
	doEffect(Character, Parent)
end