-- Training System

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local StatusFolder = Character:WaitForChild("Status")
local PlayerGui = Player:WaitForChild("PlayerGui")

local UIToToggle = {
	[PlayerGui.TrainingSystem] = true,
	[PlayerGui.HUD] = false,
	[PlayerGui.ShopSystem] = false,
}

local CurrentKeys = nil
local Root = script.Parent:WaitForChild("Root")

Remotes.Training.OnClientEvent:Connect(function(Action, Data)
	if Action == "StartTraining" then
		local Object = Data.Object
		local Keys = Data.Keys
		
		Root.Score.Text = "0/0"
		Root.Duration.Text = "Time Left: 20s"
		
		-- Disabling Blurs
		task.spawn(function()
			for _,b in pairs(game.Lighting:GetChildren()) do
				if b:GetAttribute("GameBlurEffect") == true then
					b.Enabled = false
				end
			end
		end)

		CurrentKeys = Keys

		for ui,value in pairs(UIToToggle) do
			ui.Enabled = value
		end
		
		Root.Separator.Size = UDim2.new(0,0,0.001,0)
		
		Root.Separator:TweenSize(UDim2.new(0.3,0,0.001,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)

		-- Updating Key
		local function update_key_ui()
			Root.Clipper.Main.Frame.Title.Text = Object.Key.Value
		end
		Object.Key.Changed:Connect(function()
			update_key_ui()
		end)
		update_key_ui()
		-- Updating Color
		local function update_color()
			if #Object.Score:GetChildren() > 0 then
				if Object.Score:FindFirstChild("Success") then
					Root.Clipper.Main.Frame.Title.TextColor3 = Color3.fromRGB(59, 240, 32)
				end
				if Object.Score:FindFirstChild("Fail") then
					Root.Clipper.Main.Frame.Title.TextColor3 = Color3.fromRGB(234, 55, 58)
				end
			else
				Root.Clipper.Main.Frame.Title.TextColor3 = Color3.fromRGB(255,255,255)
			end
		end

		update_color()
		Object.Score.ChildAdded:Connect(function()
			update_color()
		end)
		Object.Score.ChildRemoved:Connect(function()
			update_color()
		end)
		
		local function update_score()
			local TotalScore = Object.Score.Value+Object.Missed.Value
			Root.Score.Text = Object.Score.Value.."/"..TotalScore
		end
		
		Object.Missed.Changed:Connect(function()
			update_score()
		end)
		Object.Score.Changed:Connect(function()
			update_score()
		end)
		Object.TimeLeft.Changed:Connect(function()
			Root.Duration.Text = "Time Left: ".. Object.TimeLeft.Value.."s"
		end)
	end
	if Action == "FinishTraining" then
		for ui,value in pairs(UIToToggle) do
			ui.Enabled = not value
		end

		CurrentKeys = nil
		task.spawn(function()
			for _,b in pairs(game.Lighting:GetChildren()) do
				if b:GetAttribute("GameBlurEffect") == true then
					b.Enabled = true
				end
			end
		end)
	end
end)

UserInputService.InputBegan:Connect(function(Input, Proccessed)
	if Proccessed then return end

	if StatusFolder:FindFirstChild("DoingTraining") then
		local TrainingObject = StatusFolder.DoingTraining
		
		if CurrentKeys[Input.KeyCode.Name] then
			Remotes.Training:FireServer("InputKey", {
				["Key"] = {
					["Name"] = Input.KeyCode.Name,
					["Encoded"] = CurrentKeys[Input.KeyCode.Name]
				}
			})
		end
	end
end)