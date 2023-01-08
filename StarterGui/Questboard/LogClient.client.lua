-- flower Client

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local flowerSpawns = workspace:WaitForChild("QuestData"):WaitForChild("Lumberjack"):WaitForChild("Logs")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
repeat task.wait() until Player:FindFirstChild("Data")

local PlayerData = Player:WaitForChild("Data")
local PlayerQuests = PlayerData:WaitForChild("Quests")

local ChosenItem = nil
local OnScreen = {}
local DesiredDistance = 7

local function GetClosest()
	local Sorted = {}
	if #flowerSpawns:GetChildren() > 0 then
		for _,item in pairs(flowerSpawns:GetChildren()) do
			if not Character:FindFirstChild("HumanoidRootPart") then
				break
			end

			local Distance = (Character.HumanoidRootPart.Position - item.PrimaryPart.Position).Magnitude

			if Distance <= DesiredDistance then
				table.insert(Sorted, {
					item,
					Distance
				})
			end
		end

		table.sort(Sorted, function(a,b)
			return a[2] < b[2]
		end)

		if #Sorted > 0 then
			return Sorted[1][1]
		end
	end
	return nil
end

RunService.RenderStepped:Connect(function()	
	-- Tweening OnScreen Stuff if too far away
	for _,item in pairs(OnScreen) do
		local a = Character.HumanoidRootPart.Position

		if OnScreen[item].Parent == nil then
			if ChosenItem == item then
				--ChosenItem.Info.Root.Main:TweenPosition(UDim2.new(0.5,0,1.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
				ChosenItem = nil
			end
			OnScreen[item] = nil
			return
		end
		
		local b = item.PrimaryPart.Position

		if (a-b).Magnitude > DesiredDistance then
			OnScreen[item] = nil
			ChosenItem.Info.Root.Main:TweenPosition(UDim2.new(0.5,0,1.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			ChosenItem = nil
		end
	end
	
	local Closest = GetClosest()
	if Closest ~= nil then
		
		if not PlayerQuests:FindFirstChild("log_quest") then
			return -- dont have quest
		end

		if ChosenItem ~= nil and ChosenItem.Parent ~= nil then
			-- Tween Out
			ChosenItem.Info.Root.Main:TweenPosition(UDim2.new(0.5,0,1.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)

			if OnScreen[ChosenItem] then
				OnScreen[ChosenItem] = nil
				ChosenItem = nil
			end
		end
		ChosenItem = Closest
		ChosenItem.Info.Root.Main:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)

		OnScreen[Closest] = Closest
	end
end)

UserInputService.InputBegan:Connect(function(Input, Processed)
	if Processed then
		return
	end
	if Input.KeyCode == Enum.KeyCode.E then
		if ChosenItem ~= nil then
			warn("Collect log: ".. ChosenItem.Name..".")
			Remotes.CollectLog:FireServer(tonumber(ChosenItem.Name))
		end
	end
end)