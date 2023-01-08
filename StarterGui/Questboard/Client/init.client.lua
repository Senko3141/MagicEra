-- Questboard Client

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Quests = require(Modules.Shared.QuestsModule)

repeat task.wait() until Player:GetAttribute("DataLoaded") == true
local PlayerData = Player:WaitForChild("Data")

local Character = Player.Character or Player.CharacterAdded:Wait()
local StatusFolder = Character:WaitForChild("Status")
local Humanoid = Character:WaitForChild("Humanoid")

local Root = script.Parent:WaitForChild("Root")
local Tooltip = Root:WaitForChild("Tooltip").Main
local NotifyEvent = script.Parent.Parent:WaitForChild("Notifications"):WaitForChild("Notify")

local PlayerQuests = PlayerData:WaitForChild("Quests")
local CachedModules = {}

for _,v in pairs(script:WaitForChild("Modules"):GetChildren()) do
	if v:IsA("ModuleScript") then
		CachedModules[v.Name] = require(v)
	end
end

-- Init
local CurrentTarget = nil

Remotes.RenderQuest.OnClientEvent:Connect(function(Name, Data)
	local Found = CachedModules[Name]	
	if Found and Found[Data.Action] then
		Found[Data.Action](Data)
	end
end)

local function update_gui(DataFolder, DataTable)
	Tooltip.Main.Title.Text = DataTable.Name
	Tooltip.Main.Description.Text = DataTable.Description
	
	if DataTable.ExtraData.RankRequirement then
		Tooltip.Type.Text = "["..DataTable.ExtraData.RankRequirement.."-Class Quest]"
	else
		Tooltip.Type.Text = "NO CLASS REQUIREMENT"
	end

	-- Clearing Children
	for _,v in pairs(Tooltip.Main.Rewards.Main:GetChildren()) do
		if v:IsA("TextLabel") then
			v:Destroy()
		end
	end

	local Rewards = DataTable.Rewards	
	for name,value in pairs(DataTable.Rewards) do
		local Clone = script.RewardTemplate:Clone()
		Clone.Name = name
		Clone.Text = "+"..value.. " ".. name
		Clone.Parent = Tooltip.Main.Rewards.Main
	end
end

Mouse.Button1Down:Connect(function()
	if CurrentTarget then
		local ModuleData = Quests.GetQuestFromId(CurrentTarget.QuestData.QuestID.Value)
		
		if ModuleData then
			local CanTake, Str = ModuleData:CanTake({
				["Player"] = Player
			})
			
			if CanTake then	
				if PlayerQuests:FindFirstChildOfClass("Folder") then
					NotifyEvent:Fire("[Quest System] You already have a quest.", 3)
					return -- already has quest
				end
				
				-- Checking for Cooldown
				local FoundQuest = PlayerData.QuestCooldowns:FindFirstChild(CurrentTarget.QuestData.QuestID.Value)
				if FoundQuest then
					if os.time() - (FoundQuest.Value or 0) < ModuleData.Cooldown then
						local TimeLeft = ModuleData.Cooldown - (os.time() - (FoundQuest.Value or 0))
						TimeLeft = string.format("%0.1f", TimeLeft)
						
						NotifyEvent:Fire("[Quest System] Please wait ".. TimeLeft.."s before doing this quest again.")
						return
					end
				end
			
				
				Remotes.Quest:FireServer("Start", {
					["Name"] = CurrentTarget.QuestData.QuestID.Value
				}, CurrentTarget)
				
				Tooltip:TweenPosition(UDim2.new(0.5,0,2,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.2, true)

			else
				NotifyEvent:Fire("[Quest System] ".. Str, 4)
			end
		end
	end
end)

local Connection = nil
Connection = Mouse.Move:Connect(function()
	if StatusFolder:FindFirstChild("Dead") then
		-- Tween Out
		CurrentTarget = nil
		Tooltip:TweenPosition(UDim2.new(0.5,0,2,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.2, true)
		Connection:Disconnect() Connection = nil
		return
	end
	local Target = Mouse.Target
	if Target and Target:FindFirstChild("QuestData") then
		local QuestData = Target:FindFirstChild("QuestData")
		if QuestData:FindFirstChild("QuestID") and QuestData.Parent.Transparency ~= 1 then
			QuestData = Quests.GetQuestFromId(QuestData.QuestID.Value)

			if QuestData then
				-- Checking Distance
				local A = Character.HumanoidRootPart.Position
				local B = Target.Position
				if (A-B).Magnitude <= 8 then
					-- Checking if same Target
					if not CurrentTarget then
						-- Tween In
						Tooltip.Parent.Position = UDim2.new(0, Mouse.X+10, 0, Mouse.Y+5)

						Tooltip:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.2, true)
						CurrentTarget = Target

						update_gui(Target.QuestData, QuestData)
					elseif CurrentTarget ~= nil and Target ~= CurrentTarget then
						-- Different Target, Make diff thing
						CurrentTarget = Target
					elseif CurrentTarget ~= nil and Target == CurrentTarget then
						Tooltip.Parent.Position = UDim2.new(0, Mouse.X+10, 0, Mouse.Y+5)
						update_gui(Target.QuestData, QuestData)
					end
				else
					CurrentTarget = nil
					Tooltip:TweenPosition(UDim2.new(0.5,0,2,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.2, true)
				end
			end
		end	
	else
		-- Tween Out
		CurrentTarget = nil
		Tooltip:TweenPosition(UDim2.new(0.5,0,2,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.2, true)
	end
end)