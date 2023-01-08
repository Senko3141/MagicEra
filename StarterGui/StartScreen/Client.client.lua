-- Start Screen

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid: Humanoid = Character:WaitForChild("Humanoid")
local PlayerData = Player:WaitForChild("Data")

local HUD = script.Parent
local MainHUD = script.Parent.Parent:WaitForChild("HUD")
local AreasHUD = script.Parent.Parent:WaitForChild("Areas")
local SquadHUD = script.Parent.Parent:WaitForChild("SquadSystem")
local Root = HUD:WaitForChild("Root")
local Frames = Root.Frames
local UISettings = script.Parent.Parent:WaitForChild("UISettings")

local RerollElement_HUD = script.Parent.Parent:WaitForChild("RerollElement")
local NameInput_HUD = script.Parent.Parent:WaitForChild("NameInput")

local BackpackGui = script.Parent.Parent:WaitForChild("BackpackGui")
local NotifyGui = script.Parent.Parent:WaitForChild("Notifications")
local NotifyEvent = NotifyGui.Notify

local SpawnLocations = workspace:WaitForChild("Spawns")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Rates = require(Modules.Shared.Rates)
local Sound = require(Modules.Client.Effects.Sound)

-- Resetting all
local UIToToggle = {
	[MainHUD] = false,
	[HUD] = true,
	[BackpackGui] = false,
	[SquadHUD] = false,
	[AreasHUD] = false,
	--[script.Parent.Parent:WaitForChild("KeyDisplayer")] = false,
	[script.Parent.Parent:WaitForChild("Questboard")] = false,
}
for screenGui,value in pairs(UIToToggle) do
	screenGui.Enabled = value
end

-- Functions
local function tpToRandomSpawn()
	local SavedPosition = PlayerData:WaitForChild("SavedPosition")
	local Splitted = SavedPosition.Value:split(",")
	
	if SavedPosition.Value ~= "" then
		Character:SetPrimaryPartCFrame(CFrame.new(Splitted[1], Splitted[2], Splitted[3]))
	else
		local children = SpawnLocations:GetChildren()
		local ran_spawn = children[math.random(#children)]
		Character:SetPrimaryPartCFrame(ran_spawn.CFrame)
	end
end

-- Resetting UI Settings
UISettings.CanClick.Value = true

repeat task.wait() until Player:GetAttribute("DataLoaded") == true

if Player:GetAttribute("AlreadyFinishedStartScreen") == true then
	if Lighting:FindFirstChild("StartScreen_Blur") then
		Lighting:FindFirstChild("StartScreen_Blur"):Destroy()
	end
	
	UISettings.CanClick.Value = false
	tpToRandomSpawn() -- teleporting
	Root.Visible = false
	RunService:UnbindFromRenderStep("CameraMovement")
	
	-- camera offset --
	Humanoid.CameraOffset = Vector3.new(0,0,0)
	-----kjl

	for screenGui,value in pairs(UIToToggle) do
		screenGui.Enabled = not value
	end
	
	return
end

-- FORCEFIELD SPAWN
local Spawns = workspace.Safezones.Blackbox
local ChosenSpawn = nil
local Array = {}
for _,v in pairs(Spawns:GetChildren()) do
	if v:IsA("SpawnLocation") then
		table.insert(Array, v)
	end
end

ChosenSpawn = Array[math.random(#Array)]
Character:SetPrimaryPartCFrame(ChosenSpawn.CFrame)

local PlayerData = Player:WaitForChild("Data")
local Mouse = Player:GetMouse()

-- Start Screen Blur
if Lighting:FindFirstChild("StartScreen_Blur") then
	Lighting:FindFirstChild("StartScreen_Blur"):Destroy()
end

local Blur = script:WaitForChild("StartScreen_Blur"):Clone()
Blur.Parent = Lighting
-- Initating Camera
local StartCFrame = CFrame.new(789.128845, 95.7593994, -239.431473, -0.216450825, 0.0933106691, -0.971824169, 1.86264515e-09, 0.995422125, 0.0955764428, 0.976293564, 0.0206875987, -0.215459928)
local RerollCFrame = CFrame.new(-141.856827, 74.0479584, -186.676605, 0.050807789, -0.173679933, 0.983490705, -0, 0.984762609, 0.173904538, -0.998708487, -0.008835705, 0.0500336066)
local NameInputCFrame = CFrame.new(15.8293686, 760.982117, -234.404343, 0.909383953, 0.0466625951, -0.413332105, -3.7252903e-09, 0.993687749, 0.11218109, 0.415957719, -0.102015682, 0.903643727)

local CurrentLocation = UISettings:WaitForChild("Location")

RunService:UnbindFromRenderStep("CameraMovement")
workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
workspace.CurrentCamera.CFrame = StartCFrame

RunService:BindToRenderStep("CameraMovement", Enum.RenderPriority.Camera.Value, function()
	local xPos = workspace.CurrentCamera.ViewportSize.X/2
	local yPos = workspace.CurrentCamera.ViewportSize.Y/2
	local center = Vector2.new(xPos, yPos)    
	local moveAngle = Vector2.new((Mouse.X-center.X)/200, (Mouse.Y-center.Y)/200)
	
	local cf = CFrame.new() 
	if CurrentLocation.Value == "Start" then
		cf = StartCFrame
	end
	if CurrentLocation.Value == "NameInput" then
		cf = NameInputCFrame
	end
	if CurrentLocation.Value == "Reroll" then
		cf = RerollCFrame
	end	
	workspace.CurrentCamera.CFrame = cf * CFrame.Angles(math.rad(-moveAngle.Y), math.rad(-moveAngle.X), 0)
end)
-- Mouse Hover/UnHover
local function hovered(object, bool)
	if object:FindFirstChild("UIStroke") then
		if bool then
			TweenService:Create(object.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Transparency = 0
			}):Play()
			
			local foundBackground = object:FindFirstChild("Background")
			if foundBackground then
				foundBackground:TweenSizeAndPosition(UDim2.new(0.9,0,1.45,0), UDim2.new(.45,0,.6,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			end
		else
			TweenService:Create(object.UIStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			
			local foundBackground = object:FindFirstChild("Background")
			if foundBackground then
				foundBackground:TweenSizeAndPosition(UDim2.new(0,0,1.45,0), UDim2.new(0,0,.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			end
		end
	end
end

--[[
local function movingbackground()
	local cancelled = false

	Root.Overlay.Lines.Position = UDim2.new(0,0,-1,0)
	local Tween = TweenService:Create(Root.Overlay.Lines, TweenInfo.new(40, Enum.EasingStyle.Linear), {
		Position = UDim2.new(-1,0,0,0)
	})
	Tween:Play()

	Tween.Completed:Connect(function()
		if cancelled then return end
		movingbackground()
	end)

	-- checking if current loctaion changed
	while UISettings.Location.Value == "Start" do
		task.wait()
	end
	cancelled = true
	Tween:Cancel()
	Root.Overlay.Lines.Position = UDim2.new(0,0,-1,0)
	Tween:Destroy()
end

task.spawn(function()
	UISettings.Location.Changed:Connect(function()
		if UISettings.Location.Value == "Start" then
			movingbackground()
		end
	end)
	if UISettings.Location.Value == "Start" then
		movingbackground()
	end	
end)
]]--

for _,button in pairs(Root:GetChildren()) do
	if button:IsA("TextButton") then
		button.MouseEnter:Connect(function()
			if script.Parent.Parent.PreLoadSlots.Enabled then
				return
			end
			
			hovered(button, true)
			Sound({
				SoundName = "MouseHover",
				Parent = script.Parent.Parent.Effects
			})
			
			--[[
			if button:GetAttribute("HoveredText") then
				button.Text = button:GetAttribute("HoveredText")
			end
			]]--
		end)
		button.MouseLeave:Connect(function()
			hovered(button, false)
			--[[
			if button:GetAttribute("NonHoverText") then
				button.Text = button:GetAttribute("NonHoverText")
			end
			]]--
		end)
		button.MouseButton1Click:Connect(function()
			if not UISettings.CanClick.Value then return end
			if script.Parent.Parent.PreLoadSlots.Enabled then
				return
			end
			
			Sound({
				SoundName = "Click",
				Parent = script.Parent.Parent.Effects
			})
			--print("Clicked on button: ".. button.Name)
			if button.Name == "Credits" then
				Frames.Credits:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			end
			if button.Name == "Play" then
				if not Rates.Elements[PlayerData.Element.Value] then
					NotifyEvent:Fire(
						"Please spin for a magic first.",
						3
					)
					return
				end
				
				-- Checking if doesn't have a First/Last name.
				if PlayerData.FirstName.Value == "None" or PlayerData.FirstName.Value == "" then
					NotifyEvent:Fire(
						"It seems you have not inputted a name for yourself yet.",
						3
					)
					-- Go to NameInput Frame
					
					Root.Visible = false
					CurrentLocation.Value = "NameInput"
					UISettings.CanClick.Value = false
					NameInput_HUD.Root:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
					return
				end
				
				
				Player:SetAttribute("AlreadyFinishedStartScreen", true)
				
				UISettings.CanClick.Value = false
				tpToRandomSpawn() -- teleporting
				Root.Visible = false
				RunService:UnbindFromRenderStep("CameraMovement")
				workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
				workspace.CurrentCamera.CameraSubject = Player.Character.Humanoid
				TweenService:Create(Blur, TweenInfo.new(1), {
					Size = 0
				}):Play()
				
				-- camera offset --
				Humanoid.CameraOffset = Vector3.new(0,0,0)
				-----kjl
				
				for screenGui,value in pairs(UIToToggle) do
					screenGui.Enabled = not value
				end
			end
			if button.Name == "Reroll" then
				Root.Visible = false
				CurrentLocation.Value = "Reroll"
				UISettings.CanClick.Value = false
				RerollElement_HUD.Root:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			end
			if button.Name == "AFK" then
				game.ReplicatedStorage.Remotes.TeleportTo:FireServer()
			end
		end)
	end
end
-- Close Button
Frames.Credits.Close.MouseButton1Click:Connect(function()
	Frames.Credits:TweenPosition(UDim2.new(0.5,0,-0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
	Sound({
		SoundName = "Click",
		Parent = script.Parent.Parent.Effects
	})
end)