local rs = game:GetService("RunService")
local place = workspace:WaitForChild("Place")

local plr = game.Players.LocalPlayer
local character = plr.Character or plr.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

local minimap = script.Parent
local arrow = minimap.Arrow

local camera = Instance.new("Camera", workspace)
camera.CameraType = Enum.CameraType.Scriptable
minimap.CurrentCamera = camera
camera.FieldOfView = 1

for _,v in pairs(place:GetChildren()) do
	v:Clone().Parent = minimap
end

rs.RenderStepped:Connect(function()
	camera.CFrame = CFrame.new(root.Position + Vector3.new(0,3000,0), root.Position)
	arrow.Rotation = -root.Orientation.Y-90
end)