-- Names
local Names = {}
Names["Names"] = {
	["Common"] = {
		"Human",
	},
	["Uncommon"] = {
		"Exceed",
	},
	["Rare"] = {
		"Celestial",
	},
	["Legendary"] = {
		"Devil Slayer",
	},
	["Mythic"] = {
		"Dragon Slayer",
	},
}
Names["Rates"] = {
	Common = 81,
	Uncommon = 10,
	Rare = 6,
	Legendary = 2,
	Mythic = 1,
}

function Names:Roll()
	local RNG = Random.new()
	local Counter = 0
	
	for category,names in pairs(Names.Names) do
		for i = 1, #names do
			Counter += Names.Rates[category]
		end
	end
	local Chosen = RNG:NextNumber(0, Counter)
	
	for category,names in pairs(Names.Names) do
		for i,n in pairs(names) do
			Counter -= Names.Rates[category]
			if Chosen > Counter then
				return n
			end
		end
	end
end


return Names