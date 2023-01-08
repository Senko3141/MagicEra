-- Fast Travel UI Client

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local StatusFolder = Character:WaitForChild("Status", 99)
local PlayerData = Player:WaitForChild("Data")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local UnlockedPoints = PlayerData:WaitForChild("UnlockedFastTravels")
local Traits = PlayerData:WaitForChild("Traits")

local FastTravelPoints = workspace:WaitForChild("FastTravels")
local MainGui = script.Parent

local Notify = MainGui.Parent:WaitForChild("Notifications"):WaitForChild("Notify")
local Root = MainGui:WaitForChild("Root")
local Event = MainGui:WaitForChild("ToggleGui")

local MainFrame = Root.Main
local Options = MainFrame.Options
local Info = MainFrame.Info

local List = Options.List
local Template = script:WaitForChild("Template")

-- Current Camera
local Camera = Instance.new("Camera")
Camera.CameraType = Enum.CameraType.Scriptable
Camera.Parent = Info.CameraView
Info.CameraView.CurrentCamera = Camera

local Configuration = {
	CanClick = true,
	SelectedLocation = "",
	SelectedColor = Color3.fromRGB(244, 255, 39),
	DefaultColor = Color3.fromRGB(255,255,255)
}

local function UpdateGui()
	-- Restting
	for _,v in pairs(List:GetChildren()) do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end
	--
	for _,point in pairs(FastTravelPoints:GetChildren()) do
		if point:GetAttribute("CameraView") ~= nil then
			local Clone = Template:Clone()
			Clone.Name = point.Name
			Clone.UIStroke.Color = Configuration.DefaultColor
			
			local Locked = true
			if UnlockedPoints:FindFirstChild(point.Name) then
				Locked = false
			end

			if not Locked then
				Clone.Button.Text = point.Name.." [Unlocked]"
			else
				Clone.Button.Text = "<s>"..point.Name.." [Locked]</s>"
			end			
			Clone.Parent = List
			--
			Clone.Button.MouseButton1Click:Connect(function()
				if not Configuration.CanClick then
					return
				end
				if Locked then
					-- Locked
					Notify:Fire("This waypoint is locked... you cannot view it.", 4, {
						SoundName = "NotifyWrong"
					})
					return
				end
				
				-- Deselecting Previous
				if Configuration.SelectedLocation ~= "" then
					local found = List:FindFirstChild(Configuration.SelectedLocation)
					if found then
						local uiStroke = found:FindFirstChild("UIStroke")
						if uiStroke then uiStroke.Color = Configuration.DefaultColor end
					end
				end
				--
				Configuration.SelectedLocation = point.Name
				Clone.UIStroke.Color = Configuration.SelectedColor
				-- Setting CFrame
				Camera.CFrame = point:GetAttribute("CameraView")
			end)
		end
	end

end

local function ToggleGui(Bool)
	if Bool then
		if StatusFolder:FindFirstChild("Travelling") then return end
		Configuration.CanClick = false
		task.delay(1, function()
			Configuration.CanClick = true
		end)
		
		MainFrame.Visible = true
		
		TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			GroupTransparency = 0
		}):Play()

		-- Resetting
		Configuration.SelectedLocation = ""
		Camera.CFrame = CFrame.new(928.105469, 92.7723618, -194.889008, -0.0971848071, 0.030692393, -0.994792998, 2.32830671e-10, 0.999524534, 0.0308383685, 0.995266438, 0.00299702073, -0.0971385762)
		
		-- Interacting with Waypoint
		local Folder = Instance.new("Folder")
		Folder.Name = "InteractingWaypoint"
		Folder.Parent = StatusFolder
		task.spawn(function()
			local Connection = nil
			if Player:FindFirstChild("InCombat") then
				-- Stop Interacting
				Folder:Destroy()
				ToggleGui(false)
				--
			end
			
			Connection = Player.ChildAdded:Connect(function(c)
				if c.Name == "InCombat" then
					Folder:Destroy()
					ToggleGui(false)
					Connection:Disconnect()
					Connection = nil
				end
			end)
			Folder.Destroying:Connect(function()
				if Connection then Connection:Disconnect() Connection =nil end
			end)
		end)
		
		UpdateGui()
	else
		if StatusFolder:FindFirstChild("InteractingWaypoint") then
			StatusFolder:FindFirstChild("InteractingWaypoint"):Destroy()
		end
				
		TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			GroupTransparency = 1
		}):Play()
		task.delay(.5, function()
			MainFrame.Visible = false
		end)
		
		task.delay(1, function()
			Configuration.CanClick = true
		end)
	end
end

Info.Close.MouseButton1Click:Connect(function()
	if not Configuration.CanClick then return end
	ToggleGui(false)
	Configuration.CanClick = false
end)

-- Travel
Info.Travel.MouseButton1Click:Connect(function()
	if Player:FindFirstChild("InCombat") then
		return -- In Combat
	end
	if StatusFolder:FindFirstChild("Travelling") then return end
	--
	if not UnlockedPoints:FindFirstChild(Configuration.SelectedLocation) then -- Hasn't Unlocked
		return
	end
	if not Traits:FindFirstChild("Shards Heart") then -- Doesn't have Trait
		return
	end
	print("Travel to: ".. Configuration.SelectedLocation)
	Remotes.FastTravel:FireServer("Travel", {
		Location = Configuration.SelectedLocation
	})
end)

-- Checking for Travelling
StatusFolder.ChildAdded:Connect(function(c)
	if c.Name == "Travelling" then
		ToggleGui(false)
		Configuration.CanClick = false
	end
end)

Event.Event:Connect(ToggleGui)