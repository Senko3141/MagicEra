-- Chest Client

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
repeat task.wait() until Player:FindFirstChild("Data")

local PlayerData = Player:WaitForChild("Data")
local PlayerQuests = PlayerData:WaitForChild("Quests")

local ChosenItem = nil
local OnScreen = {}
local DesiredDistance = 7





RunService.RenderStepped:Connect(function()	
	local Closest

	if workspace.Chests:FindFirstChild(Player.UserId) then
		Closest = workspace.Chests:FindFirstChild(Player.UserId)
		Closest.Highlight.Enabled = true
	else
		--script.Disabled = true
		return
	end
	if Closest ~= nil and Closest.Bottom:FindFirstChild("Info") then

		if ChosenItem ~= nil and ChosenItem.Parent ~= nil and ChosenItem.Parent ~= workspace.ChestGraveyard then
			-- Tween Out
			ChosenItem.Bottom.Info.Root.Main:TweenPosition(UDim2.new(0.5,0,1.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)

			if OnScreen[ChosenItem] then
				OnScreen[ChosenItem] = nil
				ChosenItem = nil
			end
		end
		ChosenItem = Closest
		ChosenItem.Bottom.Info.Root.Main:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)

		OnScreen[Closest] = Closest
	end

	-- Tweening OnScreen Stuff if too far away
	for _,item in pairs(OnScreen) do
		if not item:FindFirstChild("Bottom") then
			return
		end

		local a = Character.HumanoidRootPart.Position
		local b = item.Bottom.Position
		if OnScreen[item].Parent == nil then
			if ChosenItem == item then
				ChosenItem = nil
			end
			OnScreen[item] = nil
		end

		if (a-b).Magnitude > DesiredDistance then
			OnScreen[item] = nil
			ChosenItem = nil
			if item.Bottom:FindFirstChild("Info") then
				item.Bottom.Info.Root.Main:TweenPosition(UDim2.new(0.5,0,1.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			end
		end
	end
end)

UserInputService.InputBegan:Connect(function(Input, Processed)
	if Processed then
		return
	end
	if Input.KeyCode == Enum.KeyCode.E then
		if ChosenItem ~= nil then
			Remotes.OpenChest:FireServer(ChosenItem.Name)
			ChosenItem.Bottom.Info:Destroy()
			--script.Disabled = true
		end
	end
end)
