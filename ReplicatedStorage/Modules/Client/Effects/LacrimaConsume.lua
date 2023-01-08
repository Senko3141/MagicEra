local Crater = {};
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Sounds = Assets.Sounds

return function(data)
	local character = data.Character
	if character then
		for _,v in pairs(character:GetChildren()) do
			if v.Name == "Left Arm" or v.Name == "Right Arm" or v.Name == "Right Leg" or v.Name == "Left Leg" or v.Name == "Torso" or v.Name == "Head" then
				for _,v2 in pairs(script:GetChildren()) do
					if v2:IsA("ParticleEmitter") then
						local clone = v2:Clone()
						clone.Parent = v

						if clone.Name == "Blue Explosion" then
							clone:Emit(math.random(2,9))
						elseif clone.Name == "Glow" then
							clone:Emit(math.random(8,18))
						elseif clone.Name == "FireAura" then
							clone:Emit(math.random(2,5))
						elseif clone.Name == "White Explosion" then
							clone:Emit(math.random(15,30))
						elseif clone.Name == "Floating Flame" then
							clone:Emit(math.random(2,5))
						end
						task.delay(1, function()
							clone.Enabled = false
						end)
						task.delay(2, function()
							clone:Destroy()
						end)
					end
				end
			end
		end
	end
end