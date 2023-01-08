local SlamDown = {};
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets.Sounds

local Crater = require(ReplicatedStorage:WaitForChild("Modules").Client.Effects.CoolerCrater)

return function(Data)	
	local Character = Data.Character
	local Target = Data.Target
		
	local pp = RaycastParams.new()
	pp.FilterDescendantsInstances = {Character, workspace.Visuals, workspace.Effects}
	pp.FilterType = Enum.RaycastFilterType.Blacklist
	pp.IgnoreWater = true
	
	local ray = Ray.new(Character.HumanoidRootPart.Position, Vector3.new(0,-1000,0))
	local partHit,pos = workspace:FindPartOnRayWithIgnoreList(ray, {Character, workspace.Visuals, Target}, false, false)
	local result = workspace:Raycast(Character.HumanoidRootPart.Position, Vector3.new(0,-1000,0), pp)
	
	if partHit and result then
		--[[
		for _ = 1,10 do
			local Block = script.Block:Clone()
			Block.Size = Vector3.new(2.434, 1.32, 2.719)
			Block.Rotation = Vector3.new(math.random(-360,360),math.random(-360,360),math.random(-360,360))
			Block.BrickColor = partHit.BrickColor
			Block.Material = partHit.Material
			Block.Position = target.HumanoidRootPart.Position
			Block.Velocity = Vector3.new(math.random(-80,80),math.random(80,100),math.random(-80,80))
			Block.Parent = workspace.Visuals
			delay(.25,function() Block.CanCollide = true end)

			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			BodyVelocity.Velocity = Vector3.new(math.random(-23,23),math.random(28,28),math.random(-23,23))
			BodyVelocity.P = 5
			BodyVelocity.Parent = Block

			game.Debris:AddItem(BodyVelocity, .1)
			game.Debris:AddItem(Block , 3)	
		end	
		]]--
		
		task.spawn(function()
			Crater({
				Angle = 20,
				HoldTime = 4,
				Origin = CFrame.new(Target.HumanoidRootPart.Position),
				PartCount = 11,
				Radius = 4,
				Range = 15,
				Rotation = false,
				SizeY = 1,
				SizeZ = 2
			})			
		end)
		
		task.spawn(function()
			for i = 1,1 do
				local Ring = script.Ring:Clone()
				Ring.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0,5,0)
				Ring.Orientation = Vector3.new(0,0,0)
				Ring.Size = Vector3.new(15,.05,15)
				Ring.Transparency = .25
				Ring.Material = "Neon"
				Ring.BrickColor = BrickColor.new("Institutional white")
				Ring.Parent = workspace.Visuals

				local duration = .3

				game.Debris:AddItem(Ring,duration)

				game.TweenService:Create(Ring, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					["Transparency"] = 1; 
					["Size"] = Vector3.new(25,.05,25); 
					--["CFrame"] = Ring.CFrame * CFrame.new(0,8,0),
				}):Play()

				wait(.1)
			end
		end)
		
		local CrashSmoke = script.CrashSmoke:Clone()
		CrashSmoke.Size = Vector3.new(15, 2, 15)
		CrashSmoke.Position = Target.HumanoidRootPart.Position
	--	CrashSmoke.Smoke.Color = ColorSequence.new(result.Instance.Color)
		
		CrashSmoke.Smoke:Emit(50)
		CrashSmoke.Parent = workspace.Visuals
		delay(1,function() CrashSmoke.Smoke.Enabled = false  end)
		game.Debris:AddItem(CrashSmoke,3)
	end
end