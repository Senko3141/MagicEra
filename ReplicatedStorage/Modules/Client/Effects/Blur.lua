local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local DefaultTI = TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

return function(Data)
	local FinalSize = Data.FinalSize or 2
	local Duration = Data.Duration or .03
	local Info = Data.TweenInfo or DefaultTI

	local blur = Instance.new("BlurEffect")
	blur.Name = "Blur"
	blur.Size = 0
	blur.Parent = Lighting

	local TweenIn = TweenService:Create(blur, Info, {
		Size = FinalSize
	})
	TweenIn:Play()
	TweenIn.Completed:Connect(function()
		wait(Duration)
		local tweenOut = TweenService:Create(blur, Info, {
			Size = 0
		}):Play()
	end)

	Debris:AddItem(blur, Duration*2.5)
end