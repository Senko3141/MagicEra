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
		ManaUsage = 40
	},
	functions = {
		shot_hit = function(...)
			local Parameters = {...}

			local Hit = script.Hit:Clone()
			Hit.Position = Parameters[1]
			Hit.Parent = workspace.Effects
			
			-- camera shake stuff --
			local a = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
			local b = Parameters[1]
			
			if (a-b).Magnitude <= 60 then
				_G.ShakeCamera({
					Type = "Preset",
					Preset = "Fireball_Hit"
				})
			end
			
			Hit.Attachment.Spark:Emit(1)
			Hit.Attachment.Gradient:Emit(1)
			Hit.Attachment.Shards:Emit(20)
			Hit.Attachment.Smoke:Emit(25)
			Hit.Attachment.Specs:Emit(35)

			game.Debris:AddItem(Hit, 1.2)

			task.wait(0.35)
			game.TweenService:Create(Hit.Attachment.PointLight, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Brightness = 0}):Play()
		end,		
	}
}