local TweenService = game:GetService("TweenService")
local Player = game.Players.LocalPlayer


return function(Data)
	local Character = Player.Character
	if Character == nil then return end
	local RootPart = Character.PrimaryPart
	if RootPart == nil then return end
	
	local Dist = (RootPart.Position - Data.Origin).Magnitude
	if Dist <= Data.Range then
		local Bloom = Instance.new("BloomEffect", game.Lighting)
		Bloom.Intensity = 0
		Bloom.Size = 0
		Bloom.Threshold = 2
		
		TweenService:Create(
			Bloom,
			TweenInfo.new(Data.InTime),
			{Intensity = Data.Intensity; Size = Data.Size, Threshold = Data.Threshold}
		):Play()
		
		wait(Data.HoldTime)
		TweenService:Create(
			Bloom,
			TweenInfo.new(Data.OutTime),
			{Intensity = 0; Size = 0, Threshold = 2}
		):Play()
		game:GetService("Debris"):AddItem(Bloom, Data.OutTime)
		
	end
end