-- Client

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local PlayerData = Player:WaitForChild("Data", 999)
local RootPart = Character:WaitForChild("HumanoidRootPart", 999)
local GraceDisplayCharacter = script.Parent.Parent:WaitForChild("ClientGraceDisplay", 999)

local PendingGraces = PlayerData:WaitForChild("PendingGraces", 999)
local IsActive = PendingGraces.Active

local HUD = script.Parent
local Root = HUD:WaitForChild("Root")
local Main = Root.Main

local function UpdateCharacterDisplay()
	if IsActive.Value then
		GraceDisplayCharacter.Enabled = true
	else
		GraceDisplayCharacter.Enabled = false
	end
end
local function UpdateGui()
	
	Main.GraceName.Text = "- ".. PendingGraces.CurrentChoice.Value
	Main.Finish.Text = "Finish Selection"
	
	-- Updating Reroll Button
	if PendingGraces.RerolledChoice.Value ~= "" then
		Main.Reroll.Visible = false
	else
		Main.Reroll.Visible = true
	end
	-- Updating Revert Button
	if PendingGraces.RerolledChoice.Value ~= "" and PendingGraces.CurrentChoice.Value == PendingGraces.RerolledChoice.Value then
		Main.Revert.Text = "Revert to "..PendingGraces.FirstChoice.Value
		Main.Revert.Visible = true
	else
		Main.Revert.Visible = false
	end
end

UpdateCharacterDisplay()
IsActive.Changed:Connect(function()
	UpdateCharacterDisplay()
end)
--

GraceDisplayCharacter.Toggle.MouseEnter:Connect(function()
	TweenService:Create(GraceDisplayCharacter.Hover, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		ImageTransparency = 0
	}):Play()
end)
GraceDisplayCharacter.Toggle.MouseLeave:Connect(function()
	TweenService:Create(GraceDisplayCharacter.Hover, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		ImageTransparency = 1
	}):Play()
end)
GraceDisplayCharacter.Toggle.MouseButton1Click:Connect(function()
	warn("clicked")
	Main.Visible = not Main.Visible
end)
Main.Exit.MouseButton1Click:Connect(function()
	Main.Visible = false
end)

-- Main Buttons
Main.Reroll.MouseButton1Click:Connect(function()
	if PendingGraces.RerolledChoice.Value ~= "" then -- Already Rerolled
		return
	end
	Remotes.RerollGrace:FireServer()
end)
Main.Revert.MouseButton1Click:Connect(function()
	Remotes.RevertGrace:FireServer()
end)
Main.Finish.MouseButton1Click:Connect(function()
	Remotes.SelectGrace:FireServer()
	Main.Visible = false
end)
-- Updating
PendingGraces.RerolledChoice.Changed:Connect(function()
	UpdateGui()
end)
PendingGraces.FirstChoice.Changed:Connect(function()
	UpdateGui()
end)
PendingGraces.CurrentChoice.Changed:Connect(function()
	UpdateGui()
end)
UpdateGui()
