--|| Services ||--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

--|| Variables ||--
local RNG = Random.new()
local TI2 = TweenInfo.new(.3,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0)

return function(Data)
	local Character = Data.Character
	
	for _,v in ipairs(Character:GetDescendants()) do
		if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("Part")  or v:IsA("Decal") and v.Name ~= "FakeHead" then
			if v.Transparency == 0 then
				v.Transparency = 1
				task.delay(Data.Duration, function()
					v.Transparency = 0
				end)
			end
		end
	end
end
