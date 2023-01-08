return {
	["Render"] = function(Data)
		local Location = Data.Location
		
		local CatClone = game.ReplicatedStorage.Assets.Cat:Clone()
		CatClone.Anchored = true
		CatClone.CFrame = Location * CFrame.new(0,.5,0)
		CatClone.Parent = workspace.QuestData["Cat Locations"]
		
		CatClone.ClickDetector.MouseClick:Connect(function(Player)
			print(Player.Name.." clicked")
			game.ReplicatedStorage.Remotes.CollectCat:FireServer(Location)
		end)
	end,
	["Destroy"] = function(Data)
		for _,v in pairs(workspace.QuestData["Cat Locations"]:GetChildren()) do
			v:Destroy()
		end
	end,
}