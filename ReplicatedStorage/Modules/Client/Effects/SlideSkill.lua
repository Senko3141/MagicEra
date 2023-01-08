local TweenService = game:GetService("TweenService")

return function(Data)
	local Parent = Data.Parent
	local Duration = Data.Duration
	if Parent then
		local Highlight = Instance.new("Highlight")
		Highlight.FillColor = Color3.fromRGB(255, 238, 0)
		Highlight.OutlineTransparency = .8
		Highlight.Parent = Parent
		task.delay(Duration or .5, function()
			TweenService:Create(Highlight, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				FillColor = Color3.fromRGB(255,255,255),
				OutlineTransparency = 1,
				FillTransparency = 1
			}):Play()
		end)
		game.Debris:AddItem(Highlight, (Duration or .5)+.2)
	end
	
end