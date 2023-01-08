-- Leaning

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
repeat task.wait() until Player.Character
local Character = Player.Character
local Humanoid: Humanoid = Character:WaitForChild("Humanoid")
local StatusFolder = Character:WaitForChild("Status")
local Events = script.Parent.Parent:WaitForChild("Events")
local InfoModule = require(script.Parent.Parent:WaitForChild("Input").Info)

Humanoid.StateChanged:Connect(function(old, new)
	if new == Enum.HumanoidStateType.Freefall then
		local Falling = Instance.new("NumberValue")
		Falling.Name = "FallingTime"
		Falling.Value = 0
		Falling.Parent = StatusFolder
		
		local PreviousPosition = Character.HumanoidRootPart.Position
		
		while Humanoid:GetState() == Enum.HumanoidStateType.Freefall do
			local foundReset = Falling:FindFirstChild("Reset")
			if foundReset then
				Falling.Value = 0
				foundReset:Destroy()
			end
			if StatusFolder:FindFirstChild("UsingMagic") then
				Falling.Value = 0
			end
			if InfoModule.Swimming == true then
				Falling.Value = 0
			end
			
			local change = Character.HumanoidRootPart.Position - PreviousPosition
			PreviousPosition = Character.HumanoidRootPart.Position
			if change.Magnitude <= .03 then
				-- standing still in the air
				Falling.Value = 0
			end
			
			Falling.Value += task.wait()
		end
		--print(Character.Name.." was falling down for: ".. Falling.Value.."s")
		if Falling.Value >= InfoModule.MinimumFallInterval then 
			-- Do Damage
			Events.FallDamage:FireServer(Falling.Value)
		end

		Falling:Destroy()
	end
end)