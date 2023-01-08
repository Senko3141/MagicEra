-- Emotes Handler

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Emotes = ReplicatedStorage:WaitForChild("Emotes")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Humanoid = Character:WaitForChild("Humanoid")
local StatusFolder = Character:WaitForChild("Status", 999)

local HUD = script.Parent
local Root = HUD:WaitForChild("Root")

-- Emotes
local EmotesFrame = Root.EmoteMenu
local SelectedEmote = nil

local function UpdateEmotes()
	for _,v in pairs(EmotesFrame.List:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end
	
	for _,v in pairs(Emotes:GetChildren()) do
		local Clone = script.EmoteTemplate:Clone()
		Clone.Name = v.Name
		Clone.Text = v.Name
		
		Clone.MouseEnter:Connect(function()
			SelectedEmote = v.Name
		end)
		Clone.MouseLeave:Connect(function()
			SelectedEmote = nil
		end)
		
		Clone.Parent = EmotesFrame.List
	end
end

UserInputService.InputBegan:Connect(function(Input, Processed)
	if Processed then
		return
	end

	if Input.KeyCode == Enum.KeyCode.H then
		EmotesFrame.Visible = true
	end
end)
UserInputService.InputEnded:Connect(function(Input, Processed)
	if Input.KeyCode == Enum.KeyCode.H then
		EmotesFrame.Visible = false
		
		if SelectedEmote ~= nil then
			
			local foundEmoting = StatusFolder:FindFirstChild("Emoting")
			if foundEmoting then
				foundEmoting:Destroy()
				return
			end
			
			-- Play Emote
			local IsEmoting = Instance.new("StringValue")
			IsEmoting.Name = "Emoting"
			IsEmoting.Value = SelectedEmote
			IsEmoting.Parent = StatusFolder
			--
			
			SelectedEmote = nil
		end
	end
end)

UpdateEmotes()