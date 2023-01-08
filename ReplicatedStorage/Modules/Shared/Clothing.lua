local clothing = {
	[1] = {
		["Name"] = "Black Toga",
		Buffs = {
			Defense = 20
		},
		["StatToString"] = "Defense = 20",
		["Price"] = 1000
	},
	[2] = {
		["Name"] = "Cleric",
		Buffs = {
			Defense = 20,
			Mana = 10
		},
		["StatToString"] = "Defense = 20\nMana = 10",
		["Price"] = 2000
	},
	[3] = {
		["Name"] = "Clergyman",
		Buffs = {
			Defense = 20,
			Mana = 10
		},
		["StatToString"] = "N/A",
		["Price"] = 3000
	},
	[4] = {
		["Name"] = "Starter",
		Buffs = {
		},
		["StatToString"] = "N/A",
		["Price"] = 0
	}
}

local module = {}

module.Clothing = clothing

return module
