return {
	["Render"] = function(Data)
		for _,v in pairs(workspace.QuestData.ParkourDaily:GetChildren()) do
			v.Transparency = .8
		end
	end,
	["Destroy"] = function(Data)
		for _,v in pairs(workspace.QuestData.ParkourDaily:GetChildren()) do
			v.Transparency = 1
		end
	end,
}