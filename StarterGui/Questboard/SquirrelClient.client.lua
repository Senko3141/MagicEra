-- Squirrel Client
wait(3)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SquirrelSpawns = workspace:WaitForChild("QuestData"):WaitForChild("Squirrel")

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
	if #SquirrelSpawns:GetChildren() > 0 then
		for _,item in pairs(SquirrelSpawns:GetChildren()) do
			if not Character:FindFirstChild("HumanoidRootPart") then
				break
			end			
			local Distance = (Character.HumanoidRootPart.Position - item.Middle.Position).Magnitude

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
	local Closest = GetClosest()
	if Closest ~= nil then
		if not PlayerQuests:FindFirstChild("collect_squirrel") then
			return -- dont have quest
		end

		if ChosenItem ~= nil and ChosenItem.Parent ~= nil then
			-- Tween Out
			ChosenItem.Middle.Info.Root.Main:TweenPosition(UDim2.new(0.5,0,1.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)

			if OnScreen[ChosenItem] then
				OnScreen[ChosenItem] = nil
				ChosenItem = nil
			end
		end
		ChosenItem = Closest
		ChosenItem.Middle.Info.Root.Main:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)

		OnScreen[Closest] = Closest
	end

	-- Tweening OnScreen Stuff if too far away
	for _,item in pairs(OnScreen) do
		if not item:FindFirstChild("Middle") then
			return
		end

		local a = Character.HumanoidRootPart.Position
		local b = item.Middle.Position
		if OnScreen[item].Parent == nil then
			if ChosenItem == item then
				ChosenItem = nil
			end
			OnScreen[item] = nil
		end

		if (a-b).Magnitude > DesiredDistance then
			OnScreen[item] = nil
			ChosenItem = nil
			item.Middle.Info.Root.Main:TweenPosition(UDim2.new(0.5,0,1.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
		end
	end
end)

UserInputService.InputBegan:Connect(function(Input, Processed)
	if Processed then
		return
	end
	if Input.KeyCode == Enum.KeyCode.E then
		if ChosenItem ~= nil then
			warn("Clean up: ".. ChosenItem.Name..".")
			Remotes.PickupSquirrel:FireServer(tonumber(ChosenItem.Name))
		end
	end
end)
local remote = Remotes.Indicator

remote.OnClientEvent:Connect(function(quest,action, info)
	local indicator = ReplicatedStorage.Assets:FindFirstChild("Indicator"):Clone()
	local board = indicator.FailureWaypointBillboard
	local highlight = Instance.new("Highlight"):Clone()


	if quest == "collect_squirrel" then
		if action == "Create" then
			indicator.Parent = workspace.Visuals
			indicator.Position = Vector3.new(149.568, 128.998, -185.85)
		elseif action == "Destroy" then
			workspace.Visuals.Indicator:Destroy()
		end
	end
	if quest == "collect_flowers" then
		if action == "Create" then
			indicator.Parent = workspace.Visuals
			indicator.Position = Vector3.new(884.049, 90.812, -189.476)
		elseif action == "Destroy" then
			workspace.Visuals.Indicator:Destroy()
		end
	end

	if quest == "deliver_squirrel" then
		if action == "Create" then
			highlight.Parent = workspace.NPCs["squirrel boy"]
		elseif action == "Destroy" then
			workspace.NPCs["squirrel boy"].Highlight:Destroy()
		end
	end
	if quest == "letter_hospital" then
		if action == "Create" then
			highlight.Parent = workspace.NPCs["tracy"]
		elseif action == "Destroy" then
			workspace.NPCs["tracy"].Highlight:Destroy()
		end
	end
	if quest == "kill_hodras" then
		if action == "Create" then
			indicator.Parent = workspace.Visuals
			indicator.Position = Vector3.new(74.449, 226.497, -989.265)
		elseif action == "Destroy" then
			workspace.Visuals.Indicator:Destroy()
		end
	end
	if quest == "kill_thugs" then
		if info then
			if action == "Create" then
				indicator.Parent = workspace.Visuals
				indicator.Position = info
			end
		end
		if action == "Destroy" then
			workspace.Visuals.Indicator:Destroy()
		end
	end
	if quest == "assassination" then
		if info then
			if action == "Create1" then
				board.Parent = info
				board.Adornee = info
				indicator:Destroy()
			end
		end
		if action == "Destroy" then
			if info:FindFirstChild(board) ~= nil then
				board:Destroy()
			end
		end
	end
	if quest == "deliver_barrel" then
		if action == "Create" then
			indicator.Parent = workspace.Visuals
			indicator.Position = Vector3.new(-1420.492, 165.733, -157.404)
		elseif action == "Destroy" then
			workspace.Visuals.Indicator:Destroy()
		end
	end
	if quest == "defeat_highwaymen" then
		if action == "Create" then
			indicator.Parent = workspace.Visuals
			indicator.Position = Vector3.new(-1420.492, 165.733, -157.404)
		elseif action == "Destroy" then
			workspace.Visuals.Indicator:Destroy()
		end
	end
	if quest == "continue_barrel" then
		if action == "Create" then
			highlight.Parent = workspace.NPCs["crate"]
		elseif action == "Destroy" then
			workspace.NPCs["crate"].Highlight:Destroy()
		end
	end
	if quest == "log_quest" then
		if action == "Create" then
			indicator.Parent = workspace.Visuals
			indicator.Position = Vector3.new(727.519, 103.206, 198.602)
		end
		if action == "Destroy" then
			workspace.Visuals.Indicator:Destroy()
		end
	end
	if quest == "save_hostage" then
		if info then
			if action == "Create" then
				indicator.Parent = workspace.Visuals
				indicator.Position = info
			end
		end
		if action == "Destroy" then
			workspace.Visuals.Indicator:Destroy()
		end
	end
end)




Remotes.Cam.OnClientEvent:Connect(function(targ)
	if targ then
		local CurrentCamera = workspace.CurrentCamera
		--CurrentCamera.CameraType = Enum.CameraType.Custom
		CurrentCamera.CameraSubject = workspace.Live[targ.Name]:FindFirstChildOfClass("Humanoid")
	else
		local CurrentCamera = workspace.CurrentCamera
		--CurrentCamera.CameraType = Enum.CameraType.Custom
		CurrentCamera.CameraSubject = workspace.Live[Player.Name]:FindFirstChildOfClass("Humanoid")

	end
end)
