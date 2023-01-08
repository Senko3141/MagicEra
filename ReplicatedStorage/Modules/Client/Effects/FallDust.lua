local TweenService = game:GetService("TweenService")
local Player = game.Players.LocalPlayer

local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Whitelist
params.FilterDescendantsInstances = {workspace:WaitForChild("Place")}

return function(Data)
	local Character = Data.Character or nil
	local FallingTime = Data.FallingTime or 1
	
	if Character and FallingTime then
		local Dust = script.Dust:Clone()
		Dust.Parent = game.Workspace.Visuals
		Dust.CFrame = Character.HumanoidRootPart.CFrame+Vector3.new(0,-3,0)
		
		local ToEmit = 30
		if FallingTime > 4 then
			ToEmit = 60
		elseif FallingTime > 3 then
			ToEmit = 40
		elseif FallingTime >= 2 then
			ToEmit = 30
		end
		
		-- Raycast
		local result = workspace:Raycast(Dust.Position , Vector3.new(0,-100,0), params)
		if result then
			Dust.Attachment.ParticleEmitter.Color = ColorSequence.new(result.Instance.Color)
		end
		
		Dust.Attachment.ParticleEmitter:Emit(ToEmit)
		
		game.Debris:AddItem(Dust, 2)
		local DustWeld = Instance.new("Weld")
		DustWeld.Parent = Dust
		DustWeld.Part1 = Dust
		DustWeld.Part0 = Character.HumanoidRootPart
		DustWeld.C0 = CFrame.new(0,-3,0)
	end
end