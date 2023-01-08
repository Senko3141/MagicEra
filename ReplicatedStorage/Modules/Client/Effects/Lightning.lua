local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local LightningModule = require(Modules.Shared.ShinsLightning)

local DefaultTI = TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

return function(Data)
	LightningModule.new(table.unpack(Data))
end