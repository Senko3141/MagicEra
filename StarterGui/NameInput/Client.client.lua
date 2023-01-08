-- Reroll Client

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local MarketPlaceService = game:GetService("MarketplaceService")
local Chat = game:GetService("Chat")

local Player = Players.LocalPlayer
repeat task.wait() until Player:GetAttribute("DataLoaded") == true

local PlayerData = Player:WaitForChild("Data")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Sound = require(Modules.Client.Effects.Sound)
local Names = require(Modules.Shared.Names)

local HUD = script.Parent
local Root = HUD:WaitForChild("Root")

local NotifyEvent = script.Parent.Parent:WaitForChild("Notifications"):WaitForChild("Notify")
local UISettings = script.Parent.Parent:WaitForChild("UISettings")

local MainFrame = Root.Main
local ConfirmationFrame = Root.Confirmation
local FinalInfoFrame = Root.FinalInfo

local MaleButton = MainFrame.Male
local FemaleButton = MainFrame.Female

-- INPUT STUFF --
local CanClickFinish = true
local CanClick = true
local Selected_Gender = "None"


-- GENDER STUFF --
local function update_gender_display()
	MaleButton.UIStroke.Transparency = 1
	FemaleButton.UIStroke.Transparency = 1
	-- ^ resetting stuff
	
	if Selected_Gender == "Male" then
		MaleButton.UIStroke.Transparency = 0
	end
	if Selected_Gender == "Female" then
		FemaleButton.UIStroke.Transparency = 0
	end
end
MaleButton.MouseButton1Click:Connect(function()
	Selected_Gender = "Male"
	update_gender_display()
end)
FemaleButton.MouseButton1Click:Connect(function()
	Selected_Gender = "Female"
	update_gender_display()
end)

MainFrame.Finish.Main.MouseButton1Click:Connect(function()
	Sound({
		SoundName = "Click",
		Parent = script.Parent.Parent.Effects
	})
	if not CanClickFinish then return end
	if not CanClick then return end

	-- Validating --
	if Selected_Gender == "None" then
		NotifyEvent:Fire("[GENDER] Please select a gender.", 3)
		return
	end
	
	if MainFrame.Result.Text == "None" or MainFrame.Result.Text == "" then
		NotifyEvent:Fire("[NAME INPUT] Invalid name.", 3)
		return
	end
	if string.match(MainFrame.Result.Text, "%a+") ~= MainFrame.Result.Text then
		-- has non letters
		NotifyEvent:Fire("[NAME INPUT] Invalid name. Your name must only contain letters.", 3)
		return
	end

	local filtered = Remotes.FilterString:InvokeServer(MainFrame.Result.Text)
	if filtered == MainFrame.Result.Text then
		print("success, chosen name: ".. MainFrame.Result.Text)
		CanClickFinish = false

		-- confirmation --
		MainFrame.Visible = false
		ConfirmationFrame:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
	else
		NotifyEvent:Fire("[NAME INPUT] Invalid name.", 3)
		return
	end
end)

-- CONFIRMATION --
ConfirmationFrame.Yes.Main.MouseButton1Click:Connect(function()
	Sound({
		SoundName = "Click",
		Parent = script.Parent.Parent.Effects
	})
	
	if not CanClick then return end
	
	if CanClickFinish == false then
		if Selected_Gender == "None" then
			NotifyEvent:Fire("[NAME INPUT] Invalid name.", 3)
			return
		end
		
		-- Should be in this frame.
		local finalText = MainFrame.Result.Text
		local result = Remotes.UpdateName:InvokeServer(finalText, Selected_Gender)
		
		if result == "Error" then
			CanClick = false
			
			NotifyEvent:Fire("[NAME INPUT] There was an error when trying to set your name, please input a new one.", 3)
			-- going back --
			ConfirmationFrame:TweenPosition(UDim2.new(0.5,0,-0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			MainFrame.Visible = true
			task.wait(.5)
			CanClickFinish = true
			CanClick = true
			return
		end
		if result == "Success" then
			-- go to finalinfo frame --
			CanClick = false
			
			ConfirmationFrame:TweenPosition(UDim2.new(0.5,0,-0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			FinalInfoFrame:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			
			-- setting text --
			FinalInfoFrame.Title.Text = 
				"Your name is ".. PlayerData.FirstName.Value.." ".. PlayerData.LastName.Value..", born into the ".. PlayerData.LastName.Value.." family. ".. Names.Descriptions[PlayerData.LastName.Value].." You are a ".. PlayerData.Race.Value.."."
			task.wait(.5)
			
			local ClickConnection = nil
			ClickConnection = FinalInfoFrame.Finish.Main.MouseButton1Click:Connect(function()
				Sound({
					SoundName = "Click",
					Parent = script.Parent.Parent.Effects
				})
				
				ClickConnection:Disconnect()
				ClickConnection = nil
				
				Root:TweenPosition(UDim2.new(0.5,0,-0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
				
				-- BRINGING BACK --
				script.Parent.Parent.StartScreen.Root.Visible = true
				UISettings.Location.Value = "Start"
				task.delay(1, function()
					UISettings.CanClick.Value = true
				end)				
				task.wait(.5)
				-- RESETTING ALL --
				FinalInfoFrame.Position = UDim2.new(0.5,0,-0.5,0)
				ConfirmationFrame.Position = UDim2.new(0.5,0,-0.5,0)
				MainFrame.Visible = true
				CanClickFinish = true
				CanClick = true
			end)
			
		end
	end
end)
ConfirmationFrame.No.Main.MouseButton1Click:Connect(function()
	Sound({
		SoundName = "Click",
		Parent = script.Parent.Parent.Effects
	})
	if CanClickFinish == false then
		-- Should be in this frame.
		ConfirmationFrame:TweenPosition(UDim2.new(0.5,0,-0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
		MainFrame.Visible = true
		task.wait(.5)
		CanClickFinish = true
	end
end)



-- GO BACK --
MainFrame.GoBack.Main.MouseButton1Click:Connect(function()
	Sound({
		SoundName = "Click",
		Parent = script.Parent.Parent.Effects
	})
	Root:TweenPosition(UDim2.new(0.5,0,-0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
	script.Parent.Parent.StartScreen.Root.Visible = true
	UISettings.Location.Value = "Start"
	task.wait(1)
	UISettings.CanClick.Value = true
end)
