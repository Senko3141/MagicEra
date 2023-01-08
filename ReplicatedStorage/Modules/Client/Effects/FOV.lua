local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

return function(Data)	
	local FOV_Amount = Data.Amount
	local tweenInfo = Data.Info or TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	
	TweenService:Create(Workspace.CurrentCamera, tweenInfo, {
		FieldOfView = FOV_Amount
	}):Play()
end