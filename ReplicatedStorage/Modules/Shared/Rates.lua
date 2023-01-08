-- Rates
--[[
	Fire - Common
	Dark - Uncommon
	Earth - Common
	Water - Common
	Speed - Rare
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MarketPlaceService = game:GetService("MarketplaceService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local TableUtil = require(Modules.Shared.Table)
local Gamepasses = require(Modules.Shared.Gamepasses)

local Rates = {}
Rates.Percentages = {
	["Common"] = 55,
	["Uncommon"] = 35,
	["Rare"] = 8,
	["Legendary"] = 1,
	["Mythical"] = 0.5,
	["Abnormal"] = 0.1,
	["Unobtainable"] = 0,
}
Rates.PityPercentages = {
	["Legendary"] = 55,
	["Mythical"] = 10,
	["Abnormal"] = 1,
	["Unobtainable"] = 0,
}
Rates.Elements = {
	["Earth"] = "Uncommon",
	["Water"] = "Common",
	["Healing"] = "Common",
		
	["Speed"] = "Common",
	
	["Fire"] = "Uncommon",
	["Gravity"] = "Rare",
	["Wind"] = "Rare",
	["Sleep"] = "Rare",
	["Poison"] = "Rare",
	["Bullet"] = "Common",
	
	["King's Flame"] = "Legendary",
	
	["Foresight"] = "Mythical",
	["Iron Dragon Slayer"] = "Abnormal",
	["Thunder Dragon Slayer"] = "Abnormal",
	["Heavenly Body"] = "Abnormal",
	["Shadow Dragon Slayer"] = "Abnormal",
	--
	["Juncture"] = "Unobtainable",
}
Rates.CategoryToColor = {
	["Common"] = Color3.fromRGB(255,255,255),
	["Uncommon"] = Color3.fromRGB(70, 227, 58),
	["Rare"] = Color3.fromRGB(209, 137, 36),
	["Legendary"] = Color3.fromRGB(217, 0, 0),
	["Mythical"] = Color3.fromRGB(113, 55, 180),
	["Abnormal"] = Color3.fromRGB(255,223,0),
	["Unobtainable"] = Color3.fromRGB(0,0,0)
}
function Rates:GetRarityFromName(Name)
	for n,rarity in pairs(Rates.Elements) do
		if n == Name then
			return rarity
		end
	end
	return nil
end
function Rates:GetElementsInOrder()
	local tbl = {}
	for name,category in pairs(Rates.Elements) do
		table.insert(tbl, {
			["Name"] = name, 
			["Category"] = category, 
			["Rate"] = Rates.Percentages[category]
		})
	end
	table.sort(tbl, function(a,b)
		return a.Rate > b.Rate
	end)
	return tbl
end
function Rates:GetPityElementsInOrder()
	local tbl = {}
	for name,category in pairs(Rates.Elements) do
		if Rates.Percentages[category] > Rates.Percentages.Legendary then
		else
			table.insert(tbl, {
				["Name"] = name, 
				["Category"] = category, 
				["Rate"] = Rates.Percentages[category]
			})
		end
	end
	table.sort(tbl, function(a,b)
		return a.Rate > b.Rate
	end)
	return tbl
end
function Rates:GetPercentagesInOrder()
	local tbl = {}
	for name,percentage in pairs(Rates.Percentages) do
		table.insert(tbl, {
			["Name"] = name, 
			["Rate"] = percentage
		})
	end
	table.sort(tbl, function(a,b)
		return a.Rate > b.Rate
	end)
	return tbl
end
function Rates:Roll(Player, PityCount)
	local RNG = Random.new()
	local Counter = 0
	local Multiplier = 1
	
	if MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, Gamepasses.GetGamepassIdFromName("2x Magic Chance")) then
		Multiplier = 5
	end
	
	local tblToUse = nil
	if PityCount < 300 then
		tblToUse = Rates.Percentages
	else
		tblToUse = Rates.PityPercentages
	end
	
	if tblToUse then
		for name,category in pairs(Rates.Elements) do 
			if tblToUse[category] then
				Counter = Counter + tblToUse[category]*Multiplier
			end
		end
		local Chosen = RNG:NextNumber(0, Counter)
		for name,category in pairs(Rates.Elements) do 
			if tblToUse[category] then
				Counter -= tblToUse[category]*Multiplier
				if Chosen > Counter then
					return name
				end
			end
		end	
	end
end

return Rates
