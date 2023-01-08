-- Global Functions

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Assets = ReplicatedStorage:WaitForChild("Assets")

local CameraShaker = require(Modules.Client.CameraShaker)

local Shaker = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
	workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * shakeCFrame
end)
_G.DisabledScreenShake = Instance.new("BoolValue")


local function updateShakerStatus()
	if _G.DisabledScreenShake.Value then
		-- disabled
		Shaker:Stop()
	else
		Shaker:Start()
	end
end

_G.DisabledScreenShake.Changed:Connect(function()
	updateShakerStatus()
end)
updateShakerStatus()

function _G.CheckDistance(Player, Distance)
	local Character = Player.Character or Player.CharacterAdded:Wait()

	local Range = Distance;
	if Range < (Character:FindFirstChild("HumanoidRootPart").CFrame.Position - workspace.CurrentCamera.CFrame.Position).Magnitude then
		return false
	end
	return true
end
function _G.PlaySound(Name, Parent, Duration)
	local Sound = Assets.Sounds:FindFirstChild(Name)
	if Sound then
		local Clone = Sound:Clone()
		Clone:Play()
		Clone.Parent = Parent
		Debris:AddItem(Clone, Duration or Clone.TimeLength)
	end
end
function _G.ShakeCamera(Data)
	-- change settings later mayb based on data?
	if _G.DisabledScreenShake.Value then return end	
	
	local Type = Data.Type
	
	if Type == "Preset" then
		local Preset = Data.Preset
		Shaker:Shake(CameraShaker.Presets[Preset])
	end
	if Type == "Settings" then
		local Info = Data.Info
		Shaker:ShakeOnce(table.unpack(Info))
	end
	if Type == "Sustained" then
		local Preset = Data.Preset
		Shaker:ShakeSustain(CameraShaker.Presets[Preset])
	end
	if Type == "StopSustained" then
		Shaker:StopSustained(Data.Duration or .2)
	end
end
function _G.TweenFunction(ObjectData, InfoData)
	local Goal = {}

	for Index, Value in next, InfoData do
		Goal[Index] = InfoData[Index]
		Goal[Value] = InfoData[Value]
	end

	local Tween = TweenService:Create(ObjectData["Instance"],TweenInfo.new(ObjectData["Duration"],ObjectData["EasingStyle"],ObjectData["EasingDirection"],0,false,0),InfoData)
	Tween:Play()
	Tween:Destroy()
end
function _G.CastRay(Orgin,Direction,List)
	table.insert(List,workspace.Visuals)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = List

	return workspace:Raycast(Orgin,Direction,raycastParams)
end