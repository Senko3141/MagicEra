return function (data)
	local player = data[1]
	local character = player.Character

	local attach = script.Part.Attachment:clone()
	local part = Instance.new("Part")
	part.Transparency = 1
	part.Anchored = false
	part.CanCollide = false
	part.CFrame = (character["HumanoidRootPart"].CFrame * CFrame.new(0,0,-3)) + part.CFrame.LookVector
	part.Parent = workspace

	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Parent = part
	weldConstraint.Part0 = character["HumanoidRootPart"]
	weldConstraint.Part1 = part

	attach.Parent = part
	--attach.Position = character:FindFirstChild("Right Arm").Position + Vector3.new(0,-2,0)
	attach.Rings.Enabled = true
	attach.Wind.Enabled = true
	wait(.5)
	attach.Rings.Enabled = false
	attach.Wind.Enabled = false
	wait(1)
	part:Destroy()
	attach:Destroy()
end

