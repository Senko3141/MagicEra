--[[
	Two types of configurations.

	configuration = {
		Type = "Instant",
		CastTime = 1,
	},
	
	configuration = {
		HoldRelease = true,
		ChargeTime = 2,
		MaxHoldTime = 8,
	},
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

return {
	configuration = {
		Type = "Instant",
		CastTime = 1,
		ManaUsage = 50
	},
	functions = {
		start = function(...)
			_G.ShakeCamera({
				Type = "Sustained",
				Preset = "RoughDriving",
			})
			
			
		end,
		["end"] = function(...)
			_G.ShakeCamera({
				Type = "StopSustained",
			})
			_G.ShakeCamera({
				Type = "Preset",
				Preset = "Explosion",
			})
		end,
		["_hit"] = function(...)
			local Parameters = {...}
			
			local Hit = script.Hit2:Clone()
			Hit.Position = Parameters[1]
			Hit.Parent = workspace.Effects
						
			-- camera shake stuff --
			local b = Parameters[1]
			
			game.TweenService:Create(Hit, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = Vector3.new(50,50,50),
				Transparency = 1
			}):Play()
		end,		
	}
}