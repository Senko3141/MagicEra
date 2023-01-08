return {
	Level = 1,
	Element_Level = 1,

	Experience = 0,
	Element_Experience = 0,
	Bounty = 0,
	
	--
	SavedHealth = 100,
	SavedMana = 100,
	MaxHealth = 100,
	MaxMana = 100,
	--
	
	Gold = 0,
	-- Starter Jewels
	StarterJewels = false,
	--
	Element = "None",

	Hunger = 100,
	
	-- Investor Stuff --
	FirstJoin = true,
	--
	
	Clothing = "Starter",

	FirstName = "None",
	LastName = "None",

	Guild = "",

	-- Character Stuff --
	Gender = "None",
	Race = "None",
	
	-- Exeed Colors --
	ExceedColor = "None",
	-- Devil Slayer --
	DevilSlayerMarking = "None",

	Eyebrows = "None",
	Eyes = "None",
	Mouth = "None",
	Nose = "None",

	HairColor = "None",
	EyeColor = "None",

	ImbuedMagic = false,
	ImbuedType = "",
	----------------

	--Spins = 10,
	TrueInvestmentPoints = 0,

	Codes = {},
	PreviousRolls = {}, -- for magic storage gamepass

	Items = {
		Potions = {
			["Health Potion"] = 0,
			["Mana Potion"] = 0,
		},
		Foods = {
			["Meat"] = 5,	
		},
		Trainings = {
			["Pushup Training"] = 0,
			["Situp Training"] = 0,
			["Squat Training"] = 0,
			["Magic Training"] = 0,
			["Mana Training"] = 0,
		},
		Trinkets = {},
		Weapons = {}, -- Weapon Models to be able to be dropped
		Collectibles = {}, -- Lacrimas, WeaponModels, Accessories, Etc
		Equipments = {}, -- Armours, Clothings, Cloaks etc
	},
	-- Backpack System
	BackpackSlots = {
		[1] = "Combat",
		[2] = "Meat",
		[3] = "",
		[4] = "",
		[5] = "",
		[6] = "",
		[7] = "",
		[8] = "",
		[9] = "",
		[10] = "",
	},
	Weapon = "Combat",
	Equipment = "",

	--------

	SavedPosition = "",	

	-- Equipped Stuff --
	EquippedSkills = {
		[1] = false,
		[2] = false,
		[3] = false,
		[4] = false,
		[5] = false,
		[6] = false,
		[7] = false,
		[8] = false,
		[9] = false,
		[0] = false
	},
	-- Stats --
	["Stats"] = {
		Strength = 0,
		Defense = 0,
		Agility = 0,
		["Magic Power"] = 0,
		Mana = 0,
	},
	-- Settings --
	Settings = {
		LowGraphics = false,
		Music = false,
		DisableSS = false,
		DamageInd = false,
		EnableClientTags = false,
		InstantCast = false,
		CustomClothesEnabled = false,
	},
	-- Quests --
	Quests = {},
	QuestCooldowns = {},
	StoredQuests = {}, -- Quests that are saved, in order to do ProgressionQuests
	
	-- Traits --
	Traits = {},
	PendingGraces = {
		Active = false,
		FirstChoice = "",
		RerolledChoice = "",
		CurrentChoice = "",
	},
	
	-- Profile --
	DateJoined = os.time(),
	PreviousReset = 0,
	
	-- Fast Travel
	UnlockedFastTravels = {},
	-- Resetting Levels for Testing
	ReturningTester = true,
	DoubleExperienceTimer = 0,
	
	-- Pity
	SpinPity = 0,
}