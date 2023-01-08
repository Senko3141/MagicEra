--|| Services ||--
local ImpactLines = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--|| Imports ||--

--|| Variables ||--
local RNG = Random.new()
local TI2 = TweenInfo.new(.15,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0)

return function(Data)
	local Character = Data.Character
	local Amount = Data.Amount
	local Type = Data.Type
	if Character then
		coroutine.resume(coroutine.create(function()
			for Index = 1,Amount do
				coroutine.resume(coroutine.create(function()
					local Part = Instance.new("Part")
					Part.Anchored = true
					Part.CanCollide = false
					Part.Material = "Neon"
					Part.Name = "ImpactLines"
					if Type == "aerial_up" then
						Part.BrickColor = math.random(1,2) == 1 and BrickColor.new("Institutional white") or BrickColor.new("Black")
					else
						Part.BrickColor = Data.Color or BrickColor.new("Institutional white")
					end
					Part.Transparency = RNG:NextNumber(0.2,0.5)
					Part.Size = Vector3.new(0.11,0.11,RNG:NextNumber(5,7.5))
					Part.Position = Character.HumanoidRootPart.Position + Vector3.new(0,0,0) + Vector3.new(RNG:NextNumber(-3,3),RNG:NextNumber(-5,-3),RNG:NextNumber(-3,3))
					Part.Orientation = Vector3.new(90,90,90)
					--Part.CFrame = CFrame.new(Part.Position, Character.PrimaryPart.Position + Character.PrimaryPart.Velocity * 100)
					Part.Parent = workspace.Visuals

					local Tween = TweenService:Create(Part,TI2,{
						Position = Part.Position + Part.CFrame.lookVector * - RNG:NextNumber(-.5,3),
						Transparency = 1;
						Size = Part.Size/2})
					Tween:Play()
					Tween:Destroy()

					Debris:AddItem(Part,.8)
				end))
				wait(Data.Delay or 0)
			end	
		end))
	end		
end