local Indicator = {};
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Ti22 = TweenInfo.new(.16,Enum.EasingStyle.Quint,Enum.EasingDirection.Out,0,false,0)

local Settings = require(ReplicatedStorage:WaitForChild("Modules").Client.Settings)

return function(Data)
	if not Data.DamageAmount then return end
	if not Data.Victim then return end
	if not Data.Color then Data.Color = Color3.fromRGB(208, 22, 26) end
	
	-- SETTINGS TOGGLE --
	local PlayerData = game.Players.LocalPlayer:WaitForChild("Data")
	if PlayerData and PlayerData.Settings.DamageInd.Value then
		return -- disabled
	end

	task.spawn(function()
		local x = math.random(-2,2)
		--[[
		if tonumber(Data.DamageAmount) then
			Data.DamageAmount = math.floor(Data.DamageAmount+.5)
		end
		]]--
		
		local DMM = "-"..tostring(Data.DamageAmount)

		local DamageIndicator = script.Damage:Clone()
		DamageIndicator.CFrame = Data.Victim:FindFirstChild("HumanoidRootPart").CFrame*CFrame.new(0,0,0)
		DamageIndicator.Indicator.Main.Text = DMM
		DamageIndicator.Anchored = false
		DamageIndicator.Indicator.Main:FindFirstChild("Text").Text = DMM
		DamageIndicator.Parent = workspace.Effects

		DamageIndicator.Indicator.Main:FindFirstChild("Text").TextColor3 = Data.Color or Color3.fromRGB(255,255,255)

		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.P = math.huge
		BodyVelocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
		BodyVelocity.Velocity = Vector3.new(math.random(-3,3),math.random(4, 8),math.random(-1,1))
		BodyVelocity.Parent = DamageIndicator
		Debris:AddItem(BodyVelocity,.35)

		task.wait(.25)
		local Tween = TweenService:Create(DamageIndicator.Indicator.Main:FindFirstChild("Text"),Ti22,{TextColor3 = Data.NormalColor})
		Tween:Play()

		Tween.Completed:Connect(function()
			task.wait(.15)
			local Tween2 = TweenService:Create(DamageIndicator.Indicator.Main:FindFirstChild("Text"),Ti22,{TextTransparency = 1, TextStrokeTransparency = 1})
			Tween2:Play()

			local Tween3 = TweenService:Create(DamageIndicator.Indicator.Main,Ti22,{TextTransparency = 1, TextStrokeTransparency = 1})
			Tween3:Play()
		end)

		Debris:AddItem(DamageIndicator,.5)
	end)	
end