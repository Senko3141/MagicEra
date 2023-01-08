-- Hide Gui

local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui", 999)

local Stored = {}
local Hidden = false

Player.Chatted:Connect(function(message)
	if message:lower() == "!hidegui" then
		Hidden = not Hidden
		
		if Hidden then
			-- Hide
			for _,v in pairs(PlayerGui:GetChildren()) do
				if v:IsA("ScreenGui") and v.Enabled and v.Name ~= "Chat" and v.Name ~= "BubbleChat" then
					v.Enabled = false
					Stored[v] = true
				end
			end
		else
			for ui,_ in pairs(Stored) do
				ui.Enabled = true
			end
			Stored = {}
		end
		
	end
end)