local FloorBlocks = {}
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {workspace.Effects, workspace.Live, workspace.Visuals}
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

local function CreateRock(Result)
	local Size = 2 + 1 * math.random()

	local Rock = Instance.new("Part")
	Rock.Material = Result.Material
	Rock.Size = Vector3.new(1,1,1) * Size

	Rock.Anchored = true
	Rock.CanCollide = false
	Rock.Position = Result.Position - Vector3.new(0,Rock.Size.Y,0)

	Rock.Color = Result.Instance.Color
	Rock.Orientation = Vector3.new(math.random(-100,100), math.random(-100,100), math.random(-100,100))

	Rock.Parent = workspace.Effects
	Debris:AddItem(Rock, 3)

	local Tween = TweenService:Create(Rock, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {Position = Result.Position})
	Tween:Play()
	Tween:Destroy()
	
	task.delay(1, function()
		local Tween = TweenService:Create(Rock, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {Position = Result.Position - Vector3.new(0,Rock.Size.Y,0),Size = Vector3.new(0,0,0)})
		Tween:Play()
		Tween:Destroy()
	end)
end


return function(Data)
	local Position = Data.Position
	local Direction = Data.Direction
	
	task.spawn(function()
		local RaycastResult = workspace:Raycast(Position, Vector3.new(0,-15,0), raycastParams)
		if RaycastResult and RaycastResult.Instance then
			local Clone = script.P:Clone()
			Clone.Transparency = 1
			Clone.Position = Position

			Clone.Anchored = true
			Clone.CanCollide = false

			Clone.Smoke:Emit(15)
			Clone.Smoke.Color = ColorSequence.new(RaycastResult.Instance.Color) 
			Clone.Parent = workspace.Effects
			
			Debris:AddItem(Clone,3)
		end
	end)
	
	local plus = 3 -- 3
	local args = RaycastParams.new()
	args.FilterType = Enum.RaycastFilterType.Blacklist
	args.FilterDescendantsInstances = {workspace.Effects, workspace.Live, workspace.Visuals}
		
	local cf = CFrame.new(Position, Position + Direction)
	coroutine.resume(coroutine.create(function()
		for _ = 1, 8 do
	--		cf = Character.PrimaryPart.CFrame

			local ray1 = workspace:Raycast(cf * CFrame.new(-3.8,0,-plus).Position, Vector3.new(0,-35,0), args)
			local ray2 = workspace:Raycast(cf * CFrame.new(5,0,-plus).Position, Vector3.new(0,-35,0), args)
			
		--	VisualizeRay(cf * CFrame.new(-3.8,0,-plus).Position, ray1, 10)
		--	VisualizeRay(cf * CFrame.new(5,0,-plus).Position, ray2, 10)
			
			if ray1 then
				CreateRock(ray1)
			end

			if ray2 then
				CreateRock(ray2)
			end

			plus += 4.5
			wait()
		end
	end))
end