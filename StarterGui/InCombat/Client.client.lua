-- Client InCombat

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

local MainText = script.Parent:WaitForChild("InCombat")
local DurationText = MainText.TextLabel
local Line = script.Parent:WaitForChild("Line")

repeat task.wait() until Player:GetAttribute("DataLoaded") == true

local function ChildAdded(Child)
	if Child.Name == "InCombat" then
		MainText.Visible = true
		DurationText.Visible = true
		Line:TweenSize(UDim2.new(0.15,0,0.003,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)

		while Child.Parent do
			DurationText.Text = "UNSAFE DONT LEAVE! ["..tostring(Child.Value).."]"
			task.wait(1)
		end
		-- No Parent Anymore --
		MainText.Visible = false
		DurationText.Visible = false
		Line:TweenSize(UDim2.new(0,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
	end
end

Player.ChildAdded:Connect(function(Child)
	ChildAdded(Child)
end)

MainText.Visible = false
DurationText.Visible = false
Line:TweenSize(UDim2.new(0,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)

if Player:FindFirstChild("InCombat") then
	ChildAdded(Player:FindFirstChild("InCombat"))
end