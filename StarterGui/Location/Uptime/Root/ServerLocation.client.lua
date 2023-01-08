-- Server Location/Uptime

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local ServerRegion = ReplicatedStorage:WaitForChild("ServerRegion")
local ServerStartTime = ReplicatedStorage:WaitForChild("ServerStartTime")

local Info = script.Parent:WaitForChild("Data")

local Icon = require(Modules.Client.Icon)

local function updateText()
	local serverTime = os.time()-ServerStartTime.Value
	local totalMins = math.floor(serverTime/60)
	local hours = math.floor(totalMins/60)
	local mins = totalMins%60
	local secs = serverTime%60
	local txt = string.format("%01i:%02i:%02i",hours,mins,secs)
	Info.Text = string.format("Server Region: %s\nServer Uptime: %s",ServerRegion.Value,txt)
end

updateText()

task.spawn(function()
	while wait(1) do
		updateText()
	end
end)