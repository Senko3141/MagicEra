-- Idle Animations

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponData = ReplicatedStorage.WeaponData
local Animations = ReplicatedStorage.Assets.Animations

local Character = script.Parent
local Humanoid = Character:WaitForChild("Humanoid")

local CharacterData = Character:WaitForChild("Data")
local CurrentWeapon = CharacterData:WaitForChild("CurrentWeapon")

local IdleAnim = nil
local CurrentValue = CurrentWeapon.Value

local function playNewIdle()
	local equipped = CurrentWeapon.Value
	if WeaponData:FindFirstChild(equipped) then
		local AnimFolder = Animations:FindFirstChild(equipped)
		if AnimFolder then
			IdleAnim = Humanoid:LoadAnimation(AnimFolder[equipped.."Idle"])
			IdleAnim:Play()
		end
	end
end

CurrentWeapon.Changed:Connect(function()
	if IdleAnim then IdleAnim:Stop(0.1) IdleAnim = nil end
	if CurrentWeapon.Value ~= "" then
		playNewIdle()
	end
end)

playNewIdle()