local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local DefaultTI = TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

return function(Data)
	local Parent = Data.Parent
	local Type = Data.Type
	
	if Data.Type == "Magic" or Data.Type == "Normal" or Data.Type == "TravelPointUnlocked" or Data.Type == "Custom" then
		local Clone = script.LevelUp:Clone()
		Clone.Weld.Part1 = Parent
		
		if Data.Type == "TravelPointUnlocked" or Data.Type == "Custom" then
			-- removing [LevelUp!]
			for _,v in pairs(Clone:GetDescendants()) do
				if v.Name == "LevelUp!" then
					v:Destroy()
				end
			end
		end
		
		Clone.Parent = workspace.Visuals
		for _,v in pairs(Clone:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				if Data.Type == "Magic" then
					v.Color = Data.Color or ColorSequence.new(Color3.fromRGB(155, 33, 255))
				end
				if Data.Type == "TravelPointUnlocked" then
					v.Color = Data.Color or ColorSequence.new(Color3.fromRGB(73, 255, 249))
				end
				if Data.Type == "Custom" then
					v.Color = Data.Color or ColorSequence.new(Color3.fromRGB(255,255,255))
				end
				
				v:Emit(v:GetAttribute("EmitCount") or 15)
			end
		end
		game.Debris:AddItem(Clone, 3)
	else
		local Clone = script.LevelUpFX:Clone()
		local Clone2 = script["2nd"]:Clone()

		if Data.Type == "HealthPack" then
			for _,v in pairs(Clone:GetDescendants()) do
				if v:IsA("ParticleEmitter") and v.Name ~= "Smoke" then
					v.Color = ColorSequence.new(Color3.fromRGB(255, 38, 41))
				end
			end
			for _,v in pairs(Clone2:GetDescendants()) do
				if v:IsA("ParticleEmitter") and v.Name ~= "Smoke" then
					v.Color = ColorSequence.new(Color3.fromRGB(255, 73, 76))
				end
			end
		end
		if Data.Type == "ImbueMagic" then
			for _,v in pairs(Clone:GetDescendants()) do
				if v:IsA("ParticleEmitter") and v.Name ~= "Smoke" then
					v.Color = ColorSequence.new(Color3.fromRGB(26, 26, 26))
				end
			end
			for _,v in pairs(Clone2:GetDescendants()) do
				if v:IsA("ParticleEmitter") and v.Name ~= "Smoke" then
					v.Color = ColorSequence.new(Color3.fromRGB(25, 25, 25))
				end
			end
		end

		Clone.Parent = Parent
		Clone2.Parent = Parent

		Clone2.Anchored = false
		Clone.Anchored = false

		Clone2.HumanoidRootPart.Part1 = Parent
		Clone["HumanoidRootPart"].Part1 = Parent

		for _,v in pairs(Clone:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(15)
			end
		end
		for _,v in pairs(Clone2:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(15)
			end
		end
		task.wait(.5)
		for _,v in pairs(Clone:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = false
			end
		end
		for _,v in pairs(Clone2:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = false
			end
		end
		task.wait(2)
		Clone:Destroy()
		Clone2:Destroy()	
	end
	
end