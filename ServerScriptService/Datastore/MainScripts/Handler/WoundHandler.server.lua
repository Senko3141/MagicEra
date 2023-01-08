-- Wound Handler

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Wounds = ReplicatedStorage.Assets.Wounds

local Character = script.Parent.Parent
local Humanoid: Humanoid = Character:WaitForChild("Humanoid")

local Status = Character:WaitForChild("Status",99)
local CharacterData = Character:WaitForChild("Data",99)

local Configuration = {
	HealthPercentage = .4,
}
local PreviousHealth = Humanoid.Health

Humanoid.HealthChanged:Connect(function()
	local currentHealth = Humanoid.Health
	local maxHealth = Humanoid.MaxHealth

	if currentHealth >= maxHealth*Configuration.HealthPercentage then
		-- More than [HealthPercentage] of health, remove wounds
		for _,v in pairs(Character:GetDescendants()) do
			if v:GetAttribute("Wound") == true then
				v:Destroy()
			end
		end
	else
		if not Status:FindFirstChild("Dead") then
			for _,v in pairs(ReplicatedStorage.Assets.Wounds:GetChildren()) do
				local bodyPart = Character:FindFirstChild(v.Name)
				if bodyPart then
					for _,v2 in pairs(v:GetChildren()) do
						if v2:IsA("Decal") then
							local found = bodyPart:FindFirstChild(v2.Name)
							if found and found:GetAttribute("Wound") == true then
								-- already has a wound
							else
								local Clone = v2:Clone()
								Clone:SetAttribute("Wound", true)
								Clone.Parent = bodyPart
							end
						end
					end
				end
			end
		end
	end

end)