local Rotater = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

function Rotater.new(ObjectName, Data)
	if RunService:IsClient() then
		local Character = Player.Character
		local Root = Character.HumanoidRootPart
		
		local BodyGyro = Instance.new("BodyGyro", Root)
		BodyGyro.Name = ObjectName
		BodyGyro.P = Data.P or 30000
		BodyGyro.MaxTorque = Data.MaxTorque or Vector3.new(math.huge, math.huge, math.huge)
		BodyGyro.CFrame = CFrame.new(Root.Position, Mouse.UnitRay.Direction*10000)
		
		local Stay;
		local s,e = pcall(function()
			local t = Data.Anchor
		end)
		if s then
			Stay = Instance.new("BodyPosition", Character.HumanoidRootPart)
			Stay.P = 10000
			Stay.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			Stay.Position = Character.HumanoidRootPart.Position
		end
		
		local Connection;
		Connection = RunService.RenderStepped:Connect(function()
			if not BodyGyro.Parent then
				if Stay ~= nil then
					Stay:Destroy()
					Stay = nil
				end
				
				Connection:Disconnect()
				Connection = nil
				return
			end
			BodyGyro.CFrame = CFrame.new(Root.Position, Mouse.UnitRay.Direction*10000)			
		end)
	end
end
function Rotater:Destroy(Name)
	if RunService:IsClient() then
		local found = Player.Character.HumanoidRootPart:FindFirstChild(Name)
		if found then
			found:Destroy()
		end
	end
end


return Rotater