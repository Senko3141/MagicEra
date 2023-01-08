-- Daily Quest Displayer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local QuestsModule = require(Modules.Shared.QuestsModule)

local Player = Players.LocalPlayer
local PlayerData = Player:WaitForChild("Data", 99)

local QuestCooldowns = PlayerData:WaitForChild("QuestCooldowns", 99)
local NPCs = workspace:WaitForChild("NPCs")

local function UpdateDisplay()
	for _,v in pairs(NPCs:GetDescendants()) do
		if v:IsA("BillboardGui") and v.Name == "DailyQuestIndicator" then
			local quest_id = v:GetAttribute("QuestName")
			
			local data = QuestsModule.Quests[quest_id]
			if data then
				if QuestCooldowns:FindFirstChild(quest_id) then
					-- disable
					
					local obj = QuestCooldowns[quest_id]
					if os.time() - (obj.Value) >= data.Cooldown then
						-- off cooldown
						if not v.Enabled then
							v.Enabled = true
						end
					else
						if v.Enabled then
							v.Enabled = false
						end
					end
				else
					-- None
					if not v.Enabled then
						v.Enabled = true
					end
				end
			end
		end
	end
	--print("Updated Daily Quest Indicators")
end

QuestCooldowns.ChildAdded:Connect(function(c)
	UpdateDisplay()
end)
QuestCooldowns.ChildRemoved:Connect(function(c)
	UpdateDisplay()
end)

UpdateDisplay()