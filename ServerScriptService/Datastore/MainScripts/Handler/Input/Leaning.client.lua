-- Leaning

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
repeat task.wait() until Player.Character
local Character = Player.Character
local Humanoid = Character:WaitForChild("Humanoid")

local client_hrp = Character:WaitForChild("HumanoidRootPart")
local client_joint = client_hrp:WaitForChild("RootJoint")

local dir
local vel
local angle = 0
local angle2 = 0
local original = client_joint.C0
local tweenInfo = TweenInfo.new(0.35)

RunService.Stepped:Connect(function()
	vel = client_hrp.Velocity * Vector3.new(1, 0.75, 1)

	if vel.Magnitude > 2 then
		dir = vel.Unit
		angle = client_hrp.CFrame.RightVector:Dot(dir) / 10
		angle2 = client_hrp.CFrame.LookVector:Dot(dir) / 10
	else
		angle = 0
		angle2 = 0
	end

	local tween = TweenService:Create(client_joint, tweenInfo, {C0 = original*CFrame.Angles(angle2, -angle, 0)})
	tween:Play()
end)