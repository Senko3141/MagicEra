return function (data)
	local player = data.Player
	local character = player.Character
	
	local clone = script.SoulPunchOrb:Clone()
	clone.Weld.Part1 = (data.WeldTo and character:FindFirstChild(data.WeldTo)) or character:WaitForChild("Right Arm")
	clone.Parent = workspace.Visuals
	
	for _,v in pairs(clone:GetDescendants()) do
		if v:IsA("ParticleEmitter") then
			v.Enabled = true
			v:Emit(v:GetAttribute("EmitCount") or 20)
		elseif v:IsA("PointLight") then
			game.TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Range = 5
			}):Play()
		end
	end
	
	task.delay(data.Duration or 1, function()
		for _,v in pairs(clone:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = false
			elseif v:IsA("PointLight") then
				game.TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Range = 0
				}):Play()
			end
		end
		
		game.Debris:AddItem(clone, 2)
	end)
end

