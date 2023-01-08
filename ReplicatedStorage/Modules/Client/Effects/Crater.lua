local Crater = {};
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets.Sounds

function CastRay(Orgin,Direction,List)
	table.insert(List, workspace.Visuals)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = List

	return workspace:Raycast(Orgin,Direction,raycastParams)
end

function Crater.new(data)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local tweenService = game:GetService("TweenService")
	local runService = game:GetService("RunService")

	local model = Instance.new("Model",workspace.Visuals)
	for i = 1, data.points do
		local Angle = ((2 * math.pi) / data.points) * i
		local x = math.cos(Angle) * data.radius
		local z = math.sin(Angle) * data.radius 
		local determinedPos = data.position + Vector3.new(x,0,z)
		local tween,moving = nil,true

		local Part = Instance.new("Part")
		Part.Orientation = Vector3.new(math.random(-90,90),math.random(-90,90),math.random(-90,90))
		Part.Anchored = true;
		Part.Size = Vector3.new(data.size,data.size,data.size) + Vector3.new(math.random(10,40)/100,math.random(10,40)/100,math.random(10,40)/100)
		Part.CanCollide = false;

		if data.movement then
			Part.Position = data.position;
			tween = tweenService:Create(Part,TweenInfo.new(data.speed,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position = determinedPos})
			tween:Play()
			local connection; connection = tween.Completed:connect(function() 
				moving = false
				connection:Disconnect()
				connection = nil
			end)
			coroutine.wrap(function()
				while moving do
					local rayCheck = CastRay(Part.Position+Vector3.new(0,data.size,0),Vector3.new(0,-10,0),data.blacklist)
					if rayCheck then
						Part.Material = rayCheck.Instance.Material 
						Part.Color	= rayCheck.Instance.Color
					end
					runService.Heartbeat:wait()
				end
			end)()
		else
			local rayCheck = CastRay(Part.Position+Vector3.new(0,data.size,0),Vector3.new(0,-10,0),data.blacklist)
			if rayCheck then
				Part.Material = rayCheck.Instance.Material 
				Part.Color	= rayCheck.Instance.Color
			end
			Part.Position = determinedPos;
		end

		Part.Parent = model;	
		coroutine.wrap(function()
			if tween then
				tween.Completed:wait()
			end

			if data.yield then
				wait(data.yield)
			end

			if not data.domino then
				warn("wat")
				tween = tweenService:Create(Part,TweenInfo.new(1,Enum.EasingStyle.Sine,Enum.EasingDirection.Out),{Transparency = 1, Size = Vector3.new(0,0,0),Orientation = Vector3.new(math.random(-90,90),math.random(-90,90),math.random(-90,90))})
				tween:Play()
				game.Debris:AddItem(Part,1)
			end

		end)()
	end


	if data.yield then
		wait(data.yield)
	end
	coroutine.wrap(function()
		if data.domino then
			local trueAmount = model:GetChildren()
			Debris:AddItem(model, data.clearSpeed+.5)
			
			for i,v in ipairs(model:GetChildren()) do
				local t = tweenService:Create(v,TweenInfo.new(data.clearSpeed,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{
					Transparency = 1, 
					Size = Vector3.new(0,0,0),
					--CFrame = v.CFrame * CFrame.new(0,-2,0)
				})
				t:Play()
				
				Debris:AddItem(v, data.clearSpeed)
			end			
		end
	end)()


end

return Crater