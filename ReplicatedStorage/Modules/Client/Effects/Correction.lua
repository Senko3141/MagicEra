local TweenService = game:GetService("TweenService")
local Player = game.Players.LocalPlayer


return function(Data)
	local Character = Player.Character
	if Character == nil then return end
	local RootPart = Character.PrimaryPart
	if RootPart == nil then return end
	
	local Dist = (RootPart.Position - Data.Origin).Magnitude
	if Dist <= Data.Range then
		local Correction = Instance.new("ColorCorrectionEffect", game.Lighting)
		Correction.Brightness = 0
		Correction.Contrast = 0
		Correction.Saturation = 0
		Correction.TintColor = Color3.fromRGB(255,255,255)
		
		TweenService:Create(
			Correction,
			TweenInfo.new(Data.InTime),
			{Brightness = Data.Brightness; Contrast = Data.Contrast; Saturation = Data.Saturation; TintColor = Data.TintColor}
		):Play()
		
		wait(Data.HoldTime)
		TweenService:Create(
			Correction,
			TweenInfo.new(Data.OutTime),
			{Brightness = 0; Contrast = 0; Saturation = 0; TintColor = Color3.fromRGB(255,255,255)}
		):Play()
		game:GetService("Debris"):AddItem(Correction, Data.OutTime)
		
	end
end