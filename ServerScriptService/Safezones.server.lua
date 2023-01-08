-- "Safezones", BlackBox

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules
local ZoneService = require(Modules.Shared.Zone)

local Safezones = workspace:WaitForChild("Safezones")
local DelayBeforeRemovingFF = 3

local Zones = {}

for _,safezone in pairs(Safezones:GetChildren()) do
	local zone = ZoneService.new(safezone)
	zone.playerEntered:Connect(function(Player: Player)
		-- Creating ForceField
		local Character = Player.Character or Player.CharacterAdded:Wait()
		if Character then
			
			print(Character.Name.." has entered a safezone.")
			
			local ForceField = Instance.new("ForceField")
			ForceField.Name = "Safezone_ForceField"
			ForceField.Parent = Character
		end
		
	end)
	zone.playerExited:Connect(function(Player: Player)
		local Character = Player.Character or Player.CharacterAdded:Wait()
		if Character then
			task.wait(DelayBeforeRemovingFF) -- Delaying before removing
			local ForceField = Character:FindFirstChild("Safezone_ForceField")
			if ForceField then
				ForceField:Destroy()
			end
			local FF2 = Character:FindFirstChild("ForcefieldHighlight")
			if FF2 then
				FF2:Destroy()
			end
		end
	end)	
end