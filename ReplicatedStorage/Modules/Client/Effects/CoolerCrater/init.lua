local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local IgnoreList = {workspace.Visuals, workspace.Live}
local ParentFolder = workspace.Visuals

Params = RaycastParams.new()
Params.FilterType = Enum.RaycastFilterType.Blacklist
Params.FilterDescendantsInstances = IgnoreList
Params.IgnoreWater = true	

local rayPart = function(CFrameValue, Range, Properties, Rotation)
	if Rotation then
		local Results = workspace:Raycast(CFrameValue.Position + CFrameValue.UpVector, CFrameValue.UpVector * -1 * Range, Params)
		if Results then
			local Part = Instance.new('Part')
			Part.Parent = ParentFolder
			Part.Anchored = true
			Part.CanCollide = false
			Part.Massless = true
			Part.Material = Results.Material
			Part.Color = Results.Instance.Color
			Part.CFrame = CFrame.new(Results.Position)
			Part.Reflectance = Results.Instance.Reflectance
			Part.Transparency = Results.Instance.Transparency
			if Properties then
				for property, value in next, Properties do
					if Part[property] ~= nil then
						Part[property] = value
					end
				end
			end

			return Part, Results
		else
			return false
		end
	else
		local Results = workspace:Raycast(CFrameValue.Position, Vector3.new(0,-1,0) * Range, Params)
		if Results then
			local Part = Instance.new('Part')
			Part.Parent = ParentFolder
			Part.Anchored = true
			Part.CanCollide = false
			Part.Massless = true
			Part.Material = Results.Material
			Part.Color = Results.Instance.Color
			Part.CFrame = CFrame.new(Results.Position)
			Part.Reflectance = Results.Instance.Reflectance
			Part.Transparency = Results.Instance.Transparency
			if Properties then
				for property, value in next, Properties do
					if Part[property] ~= nil then
						Part[property] = value
					end
				end
			end

			return Part, Results
		else
			return false
		end
	end
end

return function(settings)
	local fullCircle = 2 * math.pi
	local partCount = settings['PartCount'] or 5
	local Radius = settings['Radius'] or 5
	local Range = settings['Range'] or 5
	local Angle = 360/partCount

	local Center, Results = rayPart(settings.Origin,  Range, nil, settings.Rotation)
	if Center then
		Center.Parent = nil
		Center.Size = Vector3.new(1,1,1)
		Center.Material = "Neon"
		Center.Color = Color3.fromRGB(255,255,255)
		Center.CFrame = CFrame.new(Center.Position, Center.Position +  Results.Normal) * CFrame.Angles(math.rad(90),0,0)
		
		Center.CFrame *= CFrame.Angles(0,math.rad(math.random(-360,360)),0)
		

		coroutine.wrap(function()
			local A = Center.CFrame * CFrame.Angles(0,math.rad(1 * Angle),0) * CFrame.new(0,0,-(Radius))
			local B = Center.CFrame * CFrame.Angles(0,math.rad(2 * Angle),0) * CFrame.new(0,0,-(Radius))
			local Dist = (A.Position - B.Position).magnitude

			local Rocks = {}

			for i = 1, partCount do
				local Frame = Center.CFrame * CFrame.Angles(0,math.rad(i * Angle),0) * CFrame.new(0,0,-((Radius) + math.random(-50,50)/100))
				Frame *= CFrame.Angles(0,0,math.rad(180))


				local Part, Results = rayPart(Frame, 15, {Color = Color3.fromRGB(215, 197, 154); Material = "Slate"}, true)

				local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = Frame:components()

				if Part then
					table.insert(Rocks, Part)

					local x1, y1, z1 = Part.CFrame:components()

					Part.Size = Vector3.new(Dist, settings.SizeY, settings.SizeZ)
					Part.CFrame = CFrame.new(x1,y1,z1,r00,r01,r02,r10,r11,r12,r20,r21,r22) * CFrame.new(0,-1.5,0)

					local Top = Instance.new("Part", Part)
					Top.Size = Vector3.new(Dist + 0.1, settings.SizeY * .2, settings.SizeZ + 0.1)
					Top.CFrame = Part.CFrame * CFrame.new(0,Part.Size.Y/2,0)
					Top.Material = Results.Material
					Top.Color = Results.Instance.Color

					local Weld = Instance.new("WeldConstraint", Top)
					Weld.Part0 = Top
					Weld.Part1 = Part

					TweenService:Create(
						Part,
						TweenInfo.new(math.random(100,300)/1000),
						{CFrame = Part.CFrame * CFrame.new(0,1.5,0) * CFrame.Angles(math.rad(settings.Angle + (math.random(-15,15))), 0, math.rad(math.random(-15,15)))}
					):Play()
				end
			end

			task.wait(settings.HoldTime)

			for _, Part in pairs(Rocks) do
				TweenService:Create(
					Part,
					TweenInfo.new(math.random(100,300)/1000),
					{CFrame = Part.CFrame * CFrame.new(0,-2,0)}
				):Play()
				Debris:AddItem(Part, .3)
			end
		end)()

		coroutine.wrap(function()
			local A = Center.CFrame * CFrame.Angles(0,math.rad(1 * Angle),0) * CFrame.new(0,0,-(Radius + settings.SizeZ * 1.2))
			local B = Center.CFrame * CFrame.Angles(0,math.rad(2 * Angle),0) * CFrame.new(0,0,-(Radius + settings.SizeZ * 1.2))
			local Dist = (A.Position - B.Position).magnitude

			local Rocks = {}

			for i = 1, partCount do
				local Frame = Center.CFrame * CFrame.Angles(0,math.rad(i * Angle),0) * CFrame.new(0,0,-((Radius + settings.SizeZ *1.2) + math.random(-50,50)/100))
				Frame *= CFrame.Angles(0,0,math.rad(180))


				local Part, Results = rayPart(Frame, 15, {Color = Color3.fromRGB(215, 197, 154); Material = "Slate"}, true)

				local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = Frame:components()


				if Part then
					table.insert(Rocks, Part)

					local x1, y1, z1 = Part.CFrame:components()

					Part.Size = Vector3.new(Dist, settings.SizeY * .8, settings.SizeZ + settings.SizeZ/2)
					Part.CFrame = CFrame.new(x1,y1,z1,r00,r01,r02,r10,r11,r12,r20,r21,r22) * CFrame.new(0,-1.5,0)


					local Top = Instance.new("Part", Part)
					Top.Size = Vector3.new(Dist + 0.1, settings.SizeY * .2, settings.SizeZ + settings.SizeZ/2 + 0.1)
					Top.CFrame = Part.CFrame * CFrame.new(0,Part.Size.Y/2,0)
					Top.Material = Results.Material
					Top.Color = Results.Instance.Color

					local Weld = Instance.new("WeldConstraint", Top)
					Weld.Part0 = Top
					Weld.Part1 = Part

					TweenService:Create(
						Part,
						TweenInfo.new(math.random(100,300)/1000),
						{CFrame = Part.CFrame * CFrame.new(0,1.5,0) * CFrame.Angles(math.rad(-settings.Angle + (math.random(-15,15))), 0, math.rad(math.random(-15,15)))}
					):Play()
				end
			end

			task.wait(settings.HoldTime)

			for _, Part in pairs(Rocks) do
				TweenService:Create(
					Part,
					TweenInfo.new(math.random(100,300)/1000),
					{CFrame = Part.CFrame * CFrame.new(0,-2,0)}
				):Play()
				Debris:AddItem(Part, .3)
			end
		end)()
	end
end
