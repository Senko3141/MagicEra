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
		fireball_hit = function(...)
			local Parameters = {...}

			local Hit = script.Hit:Clone()
			Hit.Position = Parameters[1]
			Hit.Parent = workspace.Effects
						
			Hit.Attachment.Spark:Emit(1)
			Hit.Attachment.Gradient:Emit(1)
			Hit.Attachment.Shards:Emit(20)
			Hit.Attachment.Smoke:Emit(25)
			Hit.Attachment.Specs:Emit(35)

			game.Debris:AddItem(Hit, 1.2)
			
			local Hit2 = script.WaterImpact:Clone()
			Hit2.Position = Parameters[1]
			Hit2.Parent = workspace.Effects
			
			game.Debris:AddItem(Hit2, 1.5)
			
			game.TweenService:Create(Hit2, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = Hit2.Size*2,
				Transparency = 1
			}):Play()
			
			for _,v in pairs(Hit2:GetDescendants()) do
				if v:IsA("Texture") then
					game.TweenService:Create(v, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Transparency = 1
					}):Play()
				end
			end
			
			for _,v in pairs(Hit2:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v:Emit(25)
				end
			end

			task.wait(0.35)
			game.TweenService:Create(Hit.Attachment.PointLight, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Brightness = 0}):Play()
		end,		
	}
}