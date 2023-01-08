local module = {}





module.chest = function(plr, char)
	if workspace.Chests:FindFirstChild("HodraChest") then return end
	local chest = game.ReplicatedStorage.Assets.Chest:Clone()
	chest.Parent = workspace.Chests
	chest.Name = "HodraChest"
	game.Debris:AddItem(chest,25)
	chest:SetPrimaryPartCFrame(CFrame.new(-1122.383, 19.85, -18.946))
	chest.Low_low.Claim.Value = plr.Name
	
	plr.PlayerGui.Questboard.ChestClient.Disabled = false
	
	
	


end







return module
