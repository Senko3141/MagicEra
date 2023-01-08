local Functions = {}
local Players = game:GetService("Players")
local Ranksmodule = require(script.Parent.Ranks)


local MaxStatPoints = 100
local function GetMaxExperience(Level)
	local rank = Ranksmodule:GetRankFromLevel(Level)
	local ranks = {
		["F"] = 1;
		["E"] = 1.1;
		["D"] = 2.5;
		["C"] = 6;
		["B"] = 9;
		["A"] = 10;
		["S"] = 5;
		["SS"] = 6.5;
		["Transcendent"] = 7;
		["World"] = 8;
		["Apex"] = 9;
		["Saint"] = 100,
	}
	local rankscaler = ranks[rank]
	return (Level*185*rankscaler)
	
end
local function GetMaxElementExperience(Level)
	return (Level*150)
end
local function GetLevelsToGainFromExperience(CurrentExperience, Level, MagicEXP)
	local MaxExperience = (MagicEXP and Functions.GetMaxElementExperience(Level)) or Functions.GetMaxExperience(Level)
	local LevelsToGain = 0
		
	if CurrentExperience < MaxExperience then
		return nil, nil
	end

	local CanLevelUp = true
	while CanLevelUp do
		CurrentExperience -= MaxExperience
		if CurrentExperience < 0 then
			CanLevelUp = false
			break
		end
		LevelsToGain += 1
		MaxExperience = (MagicEXP and Functions.GetMaxElementExperience(Level)) or Functions.GetMaxExperience(Level)
	end
	if CurrentExperience < 0 then
		CurrentExperience = 0
	end	
	return LevelsToGain, CurrentExperience
end
local function GetInvestmentPoints(Player)
	local PlayerData = Player:FindFirstChild("Data")
	if PlayerData then
		local Level = PlayerData.Level
		local Stats = PlayerData.Stats
		
		local CurrentInvestmentPoints = Level.Value*5
		for _,stat in pairs(Stats:GetChildren()) do
			if stat:IsA("IntValue") then
				CurrentInvestmentPoints -= stat.Value
			end
		end
		return CurrentInvestmentPoints
	end
end
local function GetDamage(Player, DefaultDamage, Table)
	local IsNPC = false
	local s,e = pcall(function()
		local t = Player.Character
	end)
	if s then
		IsNPC = false
	else
		IsNPC = true
	end
	
	DefaultDamage = 5
	
	local InvestedPoints = {
		Strength = 0,
		Defense = 0,
		Agility = 0,
		Mana = 0,
		["Magic Power"] = 0,
	}

	if IsNPC then
		-- Changed based on NPC name or smsth --, default is 10 for rn
		InvestedPoints.Strength = 10
	else
		local PlayerData = Player:FindFirstChild("Data")
		if PlayerData then
			local Stats = PlayerData:FindFirstChild("Stats")
			if Stats then
				InvestedPoints.Strength = Stats.Strength.Value
				InvestedPoints.Defense = Stats.Defense.Value
				InvestedPoints.Agility = Stats.Agility.Value
				InvestedPoints.Mana = Stats.Mana.Value
				InvestedPoints["Magic Power"] = Stats["Magic Power"].Value
			end
		end
	end
	
	-- CLAMPING _-
	for _,value in pairs(InvestedPoints) do
		value = math.clamp(value, 0, MaxStatPoints)
	end
	
	local function DoBonusDamage(Type)
		local BonusDamage = 0
		if not IsNPC then
			-- ADDING IN BONUS DMG --
			local CharacterData = Player.Character:FindFirstChild("Data")
			local Bonuses = CharacterData and CharacterData:FindFirstChild("Bonuses")
			
			if Type == "Magic" then
				return Bonuses["Magic Power"].Value
			end
			
			if Bonuses then
				BonusDamage = Bonuses.Strength.Value
			end
			
			if CharacterData.CurrentWeapon.Value == "Greatsword" then
				BonusDamage += 15
			end
			if CharacterData.CurrentWeapon.Value == "Katana" then
				BonusDamage += 2
			end
			if CharacterData.CurrentWeapon.Value == "Caestus" then
				BonusDamage += 1.5
			end
			if CharacterData.CurrentWeapon.Value == "Silver Gauntlet" then
				BonusDamage += 2.5
			end
			if CharacterData.CurrentWeapon.Value == "Dagger" then
				BonusDamage += 1
			end
			if CharacterData.CurrentWeapon.Value == "Battleaxe" then
				BonusDamage += 5
			end
			
			local PlayerData = Player:FindFirstChild("Data")
			if PlayerData then
				local TraitsFolder = PlayerData:FindFirstChild("Traits")
				if TraitsFolder and TraitsFolder:FindFirstChild("Brawler") then
					BonusDamage += 1
				end
			end
		else
			local CharacterData = Player:FindFirstChild("Data")
			local Bonuses = CharacterData:FindFirstChild("Bonuses")

			if Type == "Magic" then
				return Bonuses["Magic Power"].Value
			end

			if Bonuses then
				BonusDamage = Bonuses.Strength.Value
			end

			if CharacterData.CurrentWeapon.Value == "Greatsword" then
				BonusDamage += 5
			end
			if CharacterData.CurrentWeapon.Value == "Katana" then
				BonusDamage += 2
			end
			if CharacterData.CurrentWeapon.Value == "Caestus" then
				BonusDamage += 1.5
			end
			if CharacterData.CurrentWeapon.Value == "Silver Gauntlet" then
				BonusDamage += 2
			end
			if CharacterData.CurrentWeapon.Value == "Dagger" then
				BonusDamage += 1
			end
			if CharacterData.CurrentWeapon.Value == "Battleaxe" then
				BonusDamage += 5
			end
		end
		return BonusDamage
	end
	
	local new = DefaultDamage + (InvestedPoints.Strength*0.06)
	new += DoBonusDamage("Normal")
	
	if typeof(Table) == "table" then
		local Type = Table.Type
		local SkillType = Table.SkillType
		
		--print(Type, SkillType, new)
		
		-- Magics --
		if SkillType ~= nil then
			local MagicBase = 5
			local MagicDamage = MagicBase + (InvestedPoints["Magic Power"]*0.2)
			new = MagicDamage

			-- Changing Based on Skill Type if needed --
			if SkillType == "Thunder Spear" then
				new = new * 2
			end
			if SkillType == "Dark Bomb" then
				new *= 1.5
			end
			if SkillType == "Water Dragon" then
				new *= 1.5
			end
			if SkillType == "Earth Dragon" then
				new *= 2
			end
			if SkillType == "Shadow Dragon Roar" then
				new *= .7
			end
			if SkillType == "Iron Dragon's Roar" then
				new *= .7
			end
			if SkillType == "Thunder Dragon Roar" then
				new *= .7
			end
			if SkillType == "Thunder Roar" then
				new *= .8
			end
			if SkillType == "Thunder Claws" then
				new *= 1.2
			end
			if SkillType == "Iron Dragon's Lance" then
				new *= 2.5
			end
			if SkillType == "King's Spear" then
				new *= 1.8
			end
			if SkillType == "Gravity Force" then
				new *= .4
			end
			if SkillType == "Water Sharks" then
				new *= .5
			end
			if SkillType == "Fire Volley" then
				new *= .5
			end
			if SkillType == "Grimoire Ray" then
				new = new * 1.5
			end		
			if SkillType == "Water Trap" then
				new *= .5
			end
			if SkillType == "King's Shot" then
				new *= 1.5
			end
			if SkillType == "Dark Spear" then
				new *= 1.3
			end
			if SkillType == "Earth Smash" then
				new *= .5
			end
			if SkillType == "Blinding Shot" then
				new *= .6
			end
			if SkillType == "Gravity Pressure" then
				new *= .5
			end
			if SkillType == "King's Pillar" then
				new *= .4
			end
			if SkillType == "Waxing Wing" then
				new *= 2.5
			end
			if SkillType == "Meta Grab" then
				new *= 4
			end
			if SkillType == "Jiu Leixing" then
				new *= .3
			end
			if SkillType == "Altairis" then
				new *= 3
			end
			if SkillType == "Hit" then
				new = new * 1.6
			end			
			new += DoBonusDamage("Magic")
		end
		-- Normal Ones --
		if Type == "Block" then
			new = new*.1
		end
		if Type == "PerfectBlock" then
			new = 0
		end
		if Type == "BlockBreak" then
			new = 5
		end
		if Type == "Heavy" then

		end
		if Type == "Slam" then
			new = new + 5
		end
		if SkillType == nil then
			-- DO WEAPON STUFF --
			if not IsNPC then
				local CharacterData = Player.Character:FindFirstChild("Data")
				if CharacterData then
					local current_weapon = CharacterData.CurrentWeapon

					if current_weapon.Value == "Greatsword" then
						new *= 1.4
					end
					if current_weapon.Value == "SkullSpear" then
						new *= 1.7
					end
					if current_weapon.Value == "Sacred Katana" then
						new *= 1.3
					end
					if current_weapon.Value == "Excalibur" then
						new *= 1.7
					end
					if current_weapon.Value == "Caestus" then
						new *= 1.2
					end
					if current_weapon.Value == "Silver Gauntlet" then
						new *= 1.2
					end
					if current_weapon.Value == "Katana" then
						new *= 1.2
					end
					if current_weapon.Value == "Battleaxe" then
						new *= 1.5
					end
				end
			end
		end
		
		new = tonumber(string.format("%0.1f", new))
		return new
	end
	return nil
end
local function GetMaxMana(Player, Current)
	local PlayerData = Player:FindFirstChild("Data")
	if PlayerData then
		local Stats = PlayerData:FindFirstChild("Stats")
		if Stats then
			local ManaPoints = Current or Stats.Mana.Value
			local Initial = 100
			
			if PlayerData.LastName.Value == "Heartfillia" then
				Initial += 50 
			end
			
			if Player.Character then
				local Bonuses = Player.Character:FindFirstChild("Data"):WaitForChild("Bonuses")
				Initial += Bonuses.Mana.Value
			end
			
			return Initial+ManaPoints*2
		end
	end
	return nil
end
local function GetMaxHealth(Player, Current)
	local PlayerData = Player:FindFirstChild("Data")
	if PlayerData then
		local Stats = PlayerData:FindFirstChild("Stats")
		if Stats then
			local HealthPoints = Current or Stats.Defense.Value
			local BonusHealth = 0
			
			if Player.Character then
				local CharacterData = Player.Character:FindFirstChild("Data")
				if CharacterData then
					local Bonuses = CharacterData:WaitForChild("Bonuses",99)
					if Bonuses then
						BonusHealth += Bonuses.Defense.Value
					end
				end
			end
			
			return 100+(HealthPoints/2.75*Functions.HealthMultiplier)+BonusHealth
		end
	end
	return nil
end
local function GetDefaultWalkspeed(Player, Current)
	local PlayerData = Player:FindFirstChild("Data")
	if PlayerData then
		local Stats = PlayerData:FindFirstChild("Stats")
		if Stats then
			local WS = Current or Stats.Agility.Value
			return 16+WS/2.75*0.09
		end
	end
	return nil
end

local StatsOrder = {
	"Strength",
	"Defense",
	"Agility",
	"Mana",
	"Magic Power",
}

Functions.GetMaxExperience = GetMaxExperience
Functions.GetLevelsToGainFromExperience = GetLevelsToGainFromExperience
Functions.GetDamage = GetDamage
Functions.GetInvestmentPoints = GetInvestmentPoints
Functions.StatsOrder = StatsOrder
Functions.GetMaxMana = GetMaxMana
Functions.MaxStatPoints = MaxStatPoints
Functions.HealthToKnock = 1
Functions.HealthRemovePercentageOnCombatLog = .4
Functions.HealthMultiplier = 6.5
Functions.GetMaxHealth = GetMaxHealth
Functions.GetDefaultWalkspeed = GetDefaultWalkspeed
Functions.GetMaxElementExperience = GetMaxElementExperience

return Functions