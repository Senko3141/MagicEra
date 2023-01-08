local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")
local DefaultTI = TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

return function(Data)
	local SoundName = Data.SoundName
	local Parent = Data.Parent
	if Assets.Sounds:FindFirstChild(SoundName) then
		local asset = Assets.Sounds[SoundName]:Clone()
		asset.Parent = Parent
		asset:Play()
		
	--	warn(asset.TimeLength)
	--	print(Data.SoundName)
		--Debris:AddItem(asset, asset.TimeLength)
		task.delay(asset.TimeLength, function()
			asset:Destroy()
		end)
	end
end