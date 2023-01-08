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
module.ReturnInformation = function(player, numberOn)
	local stat
	local amt
	local name
	local price
	local statToString
	local variableTab = {}

	for i,v in pairs(clothing[numberOn]) do
		if i == "Name" then
			name = v
		elseif i == "Price" then
			price = v
		elseif i == "StatToString" then
			statToString = v
		end
		if type(v) == "table" then
			for a,b in pairs(v) do
				stat = a
				amt = b
				variableTab[stat] = amt
			end
		end
	end
	return name, variableTab, price, statToString
end

module.ReturnMinMax = function()
	local max
	local min

	min = 1
	for i,v in pairs(clothing) do
		max = #clothing
	end
	return min,max
end

function module:GetStatFromName(name)
	local variableTab = {}
	local stat
	local amt
	for i,v in pairs(clothing) do
		if v["Name"] == name then
			for a,b in pairs(v["Buffs"]) do
				stat = a
				amt = b
				variableTab[stat] = amt
			end
		end
	end

	return variableTab

end

return module
