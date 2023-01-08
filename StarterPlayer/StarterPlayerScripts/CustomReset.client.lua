-- Custom Reset

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local Player = Players.LocalPlayer
local PlayerData = Player:WaitForChild("Data")

local ResetCooldown = PlayerData:WaitForChild("PreviousReset")

local resetBindable = Instance.new("BindableEvent")
resetBindable.Event:connect(function()
	if os.time() - (ResetCooldown.Value) < 20 then
		task.spawn(function()
			local time_left = 20 - (os.time() - ResetCooldown.Value)
			Player.PlayerGui:WaitForChild("Notifications").Notify:Fire("Please wait: ".. math.floor(time_left).."s before resetting cooldown.")
		end)
		return
	end
	
	if Player:FindFirstChild("InCombat") then
		return
	end
	
	local FoundReset = Player.Character.Status:FindFirstChild("IsResetting")
	if FoundReset then
		return
	end
	Remotes.Reset:FireServer()
end)

local coreCall do
	local MAX_RETRIES = 8

	local StarterGui = game:GetService('StarterGui')
	local RunService = game:GetService('RunService')

	function coreCall(method, ...)
		local result = {}
		for retries = 1, MAX_RETRIES do
			result = {pcall(StarterGui[method], StarterGui, ...)}
			if result[1] then
				break
			end
			RunService.Stepped:Wait()
		end
		return unpack(result)
	end
end

coreCall("SetCore", "ResetButtonCallback", resetBindable)