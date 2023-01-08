local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

local RunService = game:GetService("RunService")

return function(Data)
	_G.ShakeCamera(Data)
end