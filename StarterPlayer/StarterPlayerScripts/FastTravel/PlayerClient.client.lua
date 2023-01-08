-- Fast Travel Client

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlayerData = Player:WaitForChild("Data", 99)
local UnlockedFastTravels = PlayerData:WaitForChild("UnlockedFastTravels")
local Traits = PlayerData:WaitForChild("Traits", 99)

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local FastTravelLocations = workspace:WaitForChild("FastTravels")

local Configuration = {
	ClaimedColor = Color3.fromRGB(125, 191, 181),
	LockedColor = Color3.fromRGB(217, 74, 76)
}

local function UpdateClaimed()
	for _,v in pairs(FastTravelLocations:GetChildren()) do
		if UnlockedFastTravels:FindFirstChild(v.Name) then
			-- Change to Blue
			for _,object in pairs(v:GetDescendants()) do
				if object:GetAttribute("CanChangeColor") == true then
					if object.ClassName == "MeshPart" then
						-- Change Color
						object.Color = Configuration.ClaimedColor
					elseif object.ClassName == "PointLight" then
						-- Change light Color
						object.Color = Configuration.ClaimedColor
					elseif object.ClassName == "ParticleEmitter" then
						object.Color = ColorSequence.new(Configuration.ClaimedColor)
					end
				end
			end
		else
			-- Change to Red
			for _,object in pairs(v:GetDescendants()) do
				if object:GetAttribute("CanChangeColor") == true then
					if object.ClassName == "MeshPart" then
						-- Change Color
						object.Color = Configuration.LockedColor
					elseif object.ClassName == "PointLight" then
						-- Change light Color
						object.Color = Configuration.LockedColor
					elseif object.ClassName == "ParticleEmitter" then
						object.Color = ColorSequence.new(Configuration.LockedColor)
					end
				end
			end
		end
	end
end

UpdateClaimed()

UnlockedFastTravels.ChildAdded:Connect(function(Child)
	UpdateClaimed()
	
	pcall(function()
		Player.PlayerGui.Notifications.Notify:Fire("Unlocked ["..Child.Name.."] Travel Waypoint!", 4, {
			Sound = "NotifyCorrect"
		})
	end)
end)
UnlockedFastTravels.ChildRemoved:Connect(function()
	UpdateClaimed()
end)

-- Main Interaction
for _,TravelArea in pairs(FastTravelLocations:GetChildren()) do
	local Prompt: ProximityPrompt = nil
	for _,v in pairs(TravelArea:GetDescendants()) do
		if v.Name == "TravelPrompt" and v:IsA("ProximityPrompt") then
			Prompt = v
			break
		end
	end
	
	if Prompt then
		Prompt.Triggered:Connect(function(PlayerTriggered)
			if PlayerTriggered == Player then
				local Location = TravelArea
				if Location then
					
					if not Traits:FindFirstChild("Shards Heart") then
						pcall(function()
						Player.PlayerGui.Notifications.Notify:Fire("Unable to unlock [Fast Travel] point.", 4, {
								Sound = "NotifyWrong"
							})
						end)
						return
					else
						-- Has Trait
						if not UnlockedFastTravels:FindFirstChild(TravelArea.Name) then
							-- Unlock
							Remotes.FastTravel:FireServer("Unlock", {
								["Location"] = Location.Name
							})
							return
						end
					end
					
					-- Unlocked Already, checking if [InCombat]
					if Player:FindFirstChild("InCombat") then
						return
					end
					
					pcall(function()
						Player.PlayerGui.FastTravel.ToggleGui:Fire(true)
					end)
				end
			end
		end)
	end
end