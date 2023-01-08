local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

return function(Data)
	local Character = Data.Character
	local Victim = Data.Victim
	local Duration = Data.Duration or .35
	
	if RunService:IsServer() then
		local VHum,VRoot = Victim:FindFirstChild("Humanoid"), Victim:FindFirstChild("HumanoidRootPart")
		local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

		local BodyGyro = Instance.new("BodyGyro")
		BodyGyro.Name = "FaceTowards"
		BodyGyro.MaxTorque = Vector3.new(12, 15555, 12)
		BodyGyro.P = 10000
		BodyGyro.CFrame = CFrame.lookAt(VRoot.CFrame.Position, HumanoidRootPart.Position + Vector3.new(0,2,0))
		BodyGyro.Parent = VRoot

		Debris:AddItem(BodyGyro, Duration) 

	end
end