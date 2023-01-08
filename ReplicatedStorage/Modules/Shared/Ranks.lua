--[[
	Level 5 - F-Class Wizard
	Level 10 - E-Class Wizard
	Level 15 - D-Class Wizard
	Level 20 - C-Class Wizard
	Level 30 - B-Class Wizard
	Level 40  - A-Class Wizard
	Level 50 - S-Class Wizard
]]

local Ranks = {
	{
		Name = "F",
		Level = 1,
		Color = Color3.fromRGB(255,255,255),
	},
	{
		Name = "E",
		Level = 10,
		Color = Color3.fromRGB(208, 203, 52),
	},
	{
		Name = "D",
		Level = 20,
		Color = Color3.fromRGB(223, 130, 49),
	},
	{
		Name = "C",
		Level = 30,
		Color = Color3.fromRGB(61, 222, 58),
	},
	{
		Name = "B",
		Level = 40,
		Color = Color3.fromRGB(70, 132, 230),
	},
	{
		Name = "A",
		Level = 50,
		Color = Color3.fromRGB(119, 47, 227),
	},
	{
		Name = "S",
		Level = 60,
		Color = Color3.fromRGB(255, 0, 0),
		
	},
	{
		Name = "SS",
		Level = 70,
		Color = Color3.fromRGB(162, 46, 46),

	},
	{
		Name = "Saint",
		Level = 80,
		Color = Color3.fromRGB(145, 47, 145),

	},
	{
		Name = "Transcendent",
		Level = 90,
		Color = Color3.fromRGB(121, 127, 68),

	},
	{
		Name = "World",
		Level = 90,
		Color = Color3.fromRGB(157, 117, 172),

	},
	{
		Name = "Apex",
		Level = 100,
		Color = Color3.fromRGB(85, 255, 47),

	},
	
}


local module = {}
module.Ranks = Ranks

function module:GetRankFromLevel(Level)
	local Rank = ""
	for i = 1, #Ranks do
		local RankData = Ranks[i]
		local NextRank = (i < #Ranks and Ranks[i+1]) or "None"
		
		if Level == RankData.Level then
			Rank = RankData.Name
			break
		end
		if Level > RankData.Level then
			if NextRank ~= "None" then
				if Level < NextRank.Level then
					Rank = RankData.Name
					break
				end
			else
				Rank = RankData.Name
				break
			end
		end
	end
	return Rank
end
function module:GetData(Rank)
	for i = 1, #Ranks do
		local d = Ranks[i]
		if d.Name == Rank then
			return d
		end
	end
	return nil
end

return module