-- Wall Slam

local AerialLift = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Modules = ReplicatedStorage:WaitForChild("Modules")

return function(Data)
	local Character = Data.Character

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {Character, workspace.Visuals}
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.IgnoreWater = true

	local result = workspace:Raycast(
		Character.HumanoidRootPart.Position,
		Character.HumanoidRootPart.CFrame.upVector*-15,
		params
	)

	if result then
		for i = 1,1 do
			local Lift = script.Lift:Clone()

			Lift.Parent = workspace.Visuals
			Lift.Position = result.Position
			Lift.Parent = workspace.Visuals
			Lift.Anchored = true
			Lift.CanCollide = false

			TweenService:Create(Lift, TweenInfo.new(.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				Size = Lift.Size + Vector3.new(Lift.Size.X*1.2, -Lift.Size.Y, Lift.Size.Z*1.2),
				Transparency = 1
			}):Play()

			Debris:AddItem(Lift, .5)
			wait(.05)
		end
	end	
end