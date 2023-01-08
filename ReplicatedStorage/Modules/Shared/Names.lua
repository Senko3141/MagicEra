-- Names
local Names = {}
Names["Names"] = {
	["Common"] = {
		"Naozane", 
		"Mobumasu", 
		"Hirotsugu",
		"Keiki",
		"Chojiro", 
		"Toin",
		"Genichi",
		"Seiki",
		"Natsuo", 
		"Con", 
		"Bali", 
		"Vemzo", 
		"Zen",
	},
	["Rare"] = {
		"Heartfillia",
		"Dreyar",
		"Eucliffe",
		"Cheney",
	},
	["Legendary"] = {
		"Fullbuster",
		"Scarlet",
		"Dragneel",
	},
}
Names["Rates"] = {
	Common = 94,
	Rare = 5,
	Legendary = 1,
}
Names.Descriptions = {
	["Naozane"] = "", 
	["Mobumasu"] = "", 
	["Hirotsugu"] = "",
	["Keiki"] = "",
	["Chojiro"] = "", 
	["Toin"] = "",
	["Genichi"] = "",
	["Seiki"] = "",
	["Natsuo"] = "", 
	["Con"] = "", 
	["Bali"] = "", 
	["Vemzo"] = "", 
	["Zen"] = "",
	["Heartfillia"] = "Your family has a history of producing powerful spirit users. You are born with [+50] more natural Mana.",
	["Dreyar"] = "",
	["Fullbuster"] = "The Fullbuster family is known for their skill in many types of Ice Magic. You are born with [+50] more natural Health, and [+3] default Magic Damage.",
	["Scarlet"] = "The Scarlet family has a history for powerful sword users. With any type of melee weapon, you deal more damage.",
	["Dragneel"] = "Your family wields the uncany ability to boost the effects of any type of Fire Magic. You also do extra M1 damage, and are born with Dragon Scales.",
	["Eucliffe"] = "",
	["Cheney"] = "",
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