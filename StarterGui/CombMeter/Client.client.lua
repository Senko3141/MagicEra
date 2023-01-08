-- Combo Meter

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Hits = Character:WaitForChild("Hits")
local Template = script:WaitForChild("Template")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local PreviousChange = nil
local TimeBeforeReset = 1
local random = Random.new()

local function getRandomAreaOnScreen()
	return UDim2.new(random:NextNumber(.1,.237),0,random:NextNumber(0.304,0.39),0)
end

Remotes.ComboCounter.OnClientEvent:Connect(function()
	-- Add hits
	Hits.Value += 1
end)
Hits.Changed:Connect(function()
	--warn("changed")
	if Hits.Value == 0 then return end
	
	if os.clock() - (PreviousChange or 0) >= TimeBeforeReset or Character:FindFirstChild("PerfectBlocked") then
		-- Reset
		Hits.Value = 1
		PreviousChange = os.clock()
	end
	
	-- Do stuff with combo meter
	PreviousChange = os.clock()
	
	-- Clearing children
	task.spawn(function()
		for _,v in pairs(script.Parent.Main:GetChildren()) do
			if v:IsA("Frame") then
				v:Destroy()
			end
		end
	end)
	
	local Clone = Template:Clone()
	Clone.Main.Text = tostring(Hits.Value)
	
	if Hits.Value > 1 then
		Clone.ComboText.Text = "HITS"
	else
		Clone.ComboText.Text = "HIT"
	end
	
	Clone.Parent = script.Parent.Main
	
	Clone.Position = UDim2.new(0.5,0,0.5,0)
	
	Clone.Main:TweenPosition(UDim2.new(.226,0,.376,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.25, true)
	
	TweenService:Create(Clone.Main, TweenInfo.new(.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true), {
		TextColor3 = Color3.fromRGB(255, 48, 51)
	}):Play()
	
	local tween = TweenService:Create(Clone.Cooldown, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		Transparency = 0,
		Size = UDim2.new(0,0,0.03,0),
		BackgroundColor3 = Color3.fromRGB(255,255,255)
	})
	tween:Play()
	tween.Completed:Connect(function()
		task.wait(.2)
		for _,v in pairs(Clone:GetChildren()) do
			task.spawn(function()
				local goal = {}
				if v:IsA("Frame") then goal.BackgroundTransparency = 1 end
				if v:IsA("TextLabel") then goal.TextTransparency = 1 goal.TextStrokeTransparency = 1 end

				TweenService:Create(v, TweenInfo.new(.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), goal):Play()
			end)
		end
	end)
	
	
	task.delay(1.75, function()
		Clone:Destroy()
	end)
end)