-- Datastore

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local MarketPlaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local HTTPService = game:GetService("HttpService")
local collectionservice = game:GetService("CollectionService")


local MagicTools = ServerStorage.MagicTools
local Remotes = ReplicatedStorage.Remotes
local Modules = ReplicatedStorage.Modules

local DatastoreTemplate = require(script.Template)
local ProfileService = require(script.Parent.Modules.ProfileService)
local TableUtil = require(Modules.Shared.Table)
local Rates = require(Modules.Shared.Rates)
local Formulas = require(Modules.Shared.Formulas)
local ElementsData = require(Modules.Shared.Elements)
local ToolFunctions = require(script.Parent.Modules.ToolFunctions)
local Ranking = require(Modules.Shared.Ranks)
local Names = require(Modules.Shared.Names)
local Races = require(Modules.Shared.Races)
local ServerEvents = script.Parent.Events
local Gamepasses = require(Modules.Shared.Gamepasses)
local ShopItems = require(Modules.Shared.Items)
local QuestsModule = require(Modules.Shared.QuestsModule)
local distributeModule = require(game.ServerScriptService.MagicSystem.DistributeSpell)

local levelcd = false


local ExceedColors = {
	Color3.fromRGB(32, 191, 223),
	Color3.fromRGB(0,0,0),
	Color3.fromRGB(255,255,255)
}

local ProfileStore = ProfileService.GetProfileStore(
	"Elementals_DEV_031",
	DatastoreTemplate
)
local GuildStore = DataStoreService:GetDataStore("GuildDataStore_015")
local BanStore = DataStoreService:GetDataStore("BanDataStore_001")
local SlotsData = DataStoreService:GetDataStore("SlotsData_001")
local SpinsData = DataStoreService:GetDataStore("SpinsData_001")

local Profiles = {}
local HealthMultiplier = 6

-- AUTO_SAVE CONFIGURATION
local AutoSave = false
local AutoSaveTime = 60
-- PASSIVE EXP
local PassiveEXPInterval = 600
local PassiveEXPGain = 25

local function GetSkillNumberFromName(Data, Name)
	for i = 1, #Data do
		local d = Data[i]
		if d.Name == Name then
			return i
		end
	end
	return nil
end
local function GetNameFromSkillNumber(Data, Number)
	for i = 1, #Data do
		if i == Number then
			return Data[i].Name
		end
	end
	return nil
end
local function is_a_magic_skill(name)
	for _,v in pairs(MagicTools:GetDescendants()) do
		if v:IsA("Tool") then
			if v.Name == name then
				return true
			end
		end
	end
	return false
end

local function UpdateHealth(Player)
	local DataFolder = Player.Data
	local Character = Player.Character

	Character.Humanoid.MaxHealth = Formulas.GetMaxHealth(Player)
	--Character.Humanoid.Health = Character.Humanoid.MaxHealth
end

local function UpdateFace(Player)
	local DataFolder = Player:WaitForChild("Data")
	local Character = Player.Character

	local FakeHead = Character:WaitForChild("FakeHead")

	for _,v in pairs(FakeHead:GetDescendants()) do
		if v:IsA("Decal") then
			v:Destroy()
		end
	end

	-----
	local Gender = DataFolder.Gender.Value
	if Gender == "None" then
		return -- wait until loaded in
	end
	-----
	local Info = {
		["Eyebrows"] = DataFolder.Eyebrows.Value,
		["Eyes"] = DataFolder.Eyes.Value,
		["Mouth"] = DataFolder.Mouth.Value,
		["Nose"] = DataFolder.Nose.Value,
	}

	local Splitted = DataFolder.EyeColor.Value:split(",")
	local FinalColor = Color3.fromRGB(255,255,255)

	for i = 1,3 do
		FinalColor = Color3.fromRGB(Splitted[1], Splitted[2], Splitted[3])
	end

	for name,value in pairs(Info) do
		if value == "None" then
			break -- make sure all of them have a value first
		end

		if ReplicatedStorage.Assets.Faces:FindFirstChild(name) then
			local folder = ReplicatedStorage.Assets.Faces[name]
			local FolderToClone = nil
			if name == "Eyes" then
				FolderToClone = folder[Gender][value]
			else
				FolderToClone = folder[value]
			end

			if FolderToClone then
				for _,v in pairs(FolderToClone:GetChildren()) do
					if v:IsA("Decal") then
						local clone = v:Clone()
						clone.Parent = FakeHead

						if name == "Eyes" then
							if clone.Name == "Pupil" then
								clone.Color3 = FinalColor
							end
						end
					end
				end
			end
		end
	end
end
local function UpdateHairColor(Player)
	-- Hair Color --
	local DataFolder = Player:WaitForChild("Data")
	local Character = Player.Character

	local HairColor = DataFolder:WaitForChild("HairColor")

	if HairColor.Value == "None" then
		local randomized = Color3.fromRGB(math.random(1,255), math.random(1,255), math.random(1,255))
		HairColor.Value = math.floor(randomized.R*255)..","..math.floor(randomized.G*255)..","..math.floor(randomized.B*255)
	end

	local Splitted = HairColor.Value:split(",")
	local FinalColor = Color3.fromRGB(255,255,255)

	for i = 1,3 do
		FinalColor = Color3.fromRGB(Splitted[1], Splitted[2], Splitted[3])
	end

	-- clearing
	for _,v in pairs(Character:GetChildren()) do
		if v:IsA("Accessory") and v.Handle:FindFirstChild("HairAttachment") and Player.UserId ~= 9567133 then
			local handle = v.Handle
			--			warn(v)

			local specialMesh = handle:FindFirstChildWhichIsA("SpecialMesh")
			if specialMesh then
				specialMesh.TextureId = ""
			end
			handle.Color = FinalColor
		end
	end
end
local function UpdateRaceAccessories(Player)
	-- Race  --
	local DataFolder = Player:WaitForChild("Data")
	local Character = Player.Character

	local Race = DataFolder:WaitForChild("Race")

	if Race.Value == "Exceed" then
		local ExceedColor = DataFolder:WaitForChild("ExceedColor")

		if ExceedColor.Value == "None" then
			local randomized = ExceedColors[math.random(#ExceedColors)]
			ExceedColor.Value = math.floor(randomized.R*255)..","..math.floor(randomized.G*255)..","..math.floor(randomized.B*255)
		end

		local Splitted = ExceedColor.Value:split(",")
		local FinalColor = Color3.fromRGB(255,255,255)

		for i = 1,3 do
			FinalColor = Color3.fromRGB(Splitted[1], Splitted[2], Splitted[3])
		end

		local Whiskers = ReplicatedStorage.Assets.RaceAssets.Whiskers:Clone()
		Whiskers.Parent = Character
		Whiskers.Weld.Part1 = Character:WaitForChild("Head")

		local Ears = ReplicatedStorage.Assets.RaceAssets.CatEars:Clone()
		Ears.Parent = Character
		Ears.Weld.Part1 = Character:WaitForChild("Head")

		Whiskers.Color = FinalColor
		Ears.Color = FinalColor
	end
	if Race.Value == "Devil Slayer" then
		task.spawn(function()
			local SlayerMarking = DataFolder:WaitForChild("DevilSlayerMarking")

			if SlayerMarking.Value == "None" then
				local randomized = math.random(#ReplicatedStorage.Assets.DevilSlayerMarkings:GetChildren())
				DataFolder.DevilSlayerMarking.Value = tostring(randomized)
			end

			local Clone = ReplicatedStorage.Assets.DevilSlayerMarkings[SlayerMarking.Value]:Clone()
			Clone.Parent = Character:WaitForChild("Head")			
		end)
	end
end
local function ClearAccessories(Character)
	local Player = Players:GetPlayerFromCharacter(Character)
	if Player.UserId == 9567133 then
		return
	end
	for _, Child in pairs(Character:GetChildren()) do
		if Child:IsA("Accessory") and not Child:FindFirstChild("Handle",true):FindFirstChild  ("HairAttachment") then
			Child:Destroy()
		elseif Child:IsA("Accessory") and Child.Handle:FindFirstChild("HairAttachment") then
			UpdateHairColor(game.Players:GetPlayerFromCharacter(Character))
		elseif Child:IsA("CharacterMesh") then
			Child:Destroy()
		elseif (Child:IsA("Pants") or Child:IsA("Shirt")) and Child.Name ~= "GameClothes" then			
			-- Checking if has "Wear Own Clothing" Gamepass --			
			if not MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, Gamepasses.GetGamepassIdFromName("Wear Your Own Clothing")) then
				Child:Destroy()
			end			
		end
	end
end
local function UpdateClothing(Player)
	-- Clothing --	
	local PlayerData = Player:WaitForChild("Data")
	local Settings = PlayerData:WaitForChild("Settings")

	local WearNormalClothes = true
	if MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, Gamepasses.GetGamepassIdFromName("Wear Your Own Clothing")) or Player.UserId == 9567133 then
		-- Has Gamepass
		if Settings.CustomClothesEnabled.Value == false then
			WearNormalClothes = true
		else
			-- Wear Custom Clothes
			WearNormalClothes = false
		end
	end
	local Character = Player.Character
	if WearNormalClothes then
		local DataFolder = Player:WaitForChild("Data")
		local Character = Player.Character

		local CurrentClothing = DataFolder:WaitForChild("Clothing")

		-- clearing
		for _,v in pairs(Character:GetDescendants()) do
			if v:IsA("Shirt") or v:IsA("Pants") then
				v:Destroy()
			end
		end

		if ReplicatedStorage.Assets.Clothes:FindFirstChild(CurrentClothing.Value) then
			for _,v in pairs(ReplicatedStorage.Assets.Clothes[CurrentClothing.Value]:GetChildren()) do
				local clone = v:Clone()
				clone.Name = "GameClothes"
				clone.Parent = Character
			end
		end
	else
		for _,v in pairs(Character:GetChildren()) do
			if v.Name == "GameClothes" then
				v:Destroy()
			end
		end

		local Humanoid: Humanoid = Character:WaitForChild("Humanoid")
		local HumDescription = Players:GetHumanoidDescriptionFromUserId(Player.UserId)

		local ShirtId = HumDescription.Shirt
		local PantsId = HumDescription.Pants

		if ShirtId then
			task.spawn(function()
				local ShirtsInsert = game.InsertService:LoadAsset(ShirtId)
				local Shirt = Instance.new("Shirt")
				Shirt.Name = "GameClothes"
				Shirt.ShirtTemplate = ShirtsInsert.Shirt.ShirtTemplate
				Shirt.Parent = Character

				ShirtsInsert:Destroy()
			end)
		end
		if PantsId then
			task.spawn(function()
				local PantsInsert = game.InsertService:LoadAsset(PantsId)
				local Pants = Instance.new("Pants")
				Pants.Name = "GameClothes"
				Pants.PantsTemplate = PantsInsert.Pants.PantsTemplate
				Pants.Parent = Character

				PantsInsert:Destroy()
			end)
		end
	end
end
local function DoBonusDamage(CharacterData, DataFolder)
	if DataFolder.LastName.Value == "Eucliffe" then
		CharacterData.Bonuses.Strength.Value += 1
		CharacterData.Bonuses.Agility.Value += 5
	end
	if DataFolder.LastName.Value == "Dragneel" then
		CharacterData.Bonuses.Strength.Value += 2
		CharacterData.Bonuses.Agility.Value += 2
	end
	if DataFolder.LastName.Value == "Cheney"  then
		CharacterData.Bonuses.Strength.Value += 1
		CharacterData.Bonuses.Agility.Value += 4
	end
	if DataFolder.LastName.Value == "Dreyar" then
		CharacterData.Bonuses.Strength.Value += 1
	end
	if DataFolder.LastName.Value == "Fullbuster" then
		CharacterData.Bonuses.Defense.Value += 25
		CharacterData.Bonuses["Magic Power"].Value += 5
	end
	if DataFolder.LastName.Value == "Scarlet" then
		CharacterData.Bonuses.Defense.Value += 35
	end
	if DataFolder.LastName.Value == "Heartfilia" then
		CharacterData.Bonuses.Mana.Value += 40
	end
end

local function UpdateEquippedSkills(Player, DataFolder)
	-- Cloning Tools
	local equipped_skills = DataFolder:FindFirstChild("EquippedSkills")
	local element = DataFolder:FindFirstChild("Element")
	local race = DataFolder:FindFirstChild("Race")
	local element_data = ElementsData.Element[element.Value]
	local race_data = ElementsData.Race[race.Value]

	if not element_data then
		print("no element data found ".. Player.Name)
		return
	end
	if not race_data then
		print("no race data found ".. Player.Name)
		return
	end

	if equipped_skills and element and element_data or equipped_skills and race and race_data then		
		-- Checking if found Other Magics in Inventory/Character
		local function loopThroughElement(n)
			local found = false
			for i = 1,#element_data do
				local d = element_data[i]
				if d.Name == n then
					found = true
				end

			end
			if race_data ~= nil then
				for i = 1,#race_data do
					print(race_data)
					local d = race_data[i]
					if d.Name == n then
						found = true
					end
				end
			end
			return found
		end

		for _,v in pairs(Player.Backpack:GetChildren()) do
			if is_a_magic_skill(v.Name) then
				local found1 = loopThroughElement(v.Name)
				if found1 == false then
					print(found1)
					warn("Destroyed: ".. v.Name)
					ToolFunctions.DestroyToolWithName(Player, v.Name)
				end
			end
		end
		--

		for _,equipped in pairs(equipped_skills:GetChildren()) do
			local magic_name = GetNameFromSkillNumber(
				element_data,
				tonumber(equipped.Name)
			)
			local magic_name2 = GetNameFromSkillNumber(
				race_data,
				tonumber(equipped.Name)
			)


			if magic_name ~= nil then
				-- CHECKING IF WITHIN LEVEL _-
				if not ToolFunctions.CanEquipTool(Player, magic_name, "Element") then
					equipped.Value = false
				else
					equipped.Value = true
				end
				-----------------
				if equipped.Value then
					-- is equipped, clone
					ToolFunctions.EquipTool(Player, magic_name, "Element")
					--
				else
					-- find in player and destroy
					ToolFunctions.DestroyToolWithName(Player, magic_name)
					--
				end
			end
			if magic_name2 ~= nil and race_data ~= nil then
				-- CHECKING IF WITHIN LEVEL _-
				if not ToolFunctions.CanEquipTool(Player, magic_name2, "Race") then
					equipped.Value = false
				else
					equipped.Value = true
				end
				-----------------
				if equipped.Value then
					print(equipped.Value)
					-- is equipped, clone
					ToolFunctions.EquipTool(Player, magic_name2, "Race")
					--
				else
					-- find in player and destroy
					ToolFunctions.DestroyToolWithName(Player, magic_name2)
					--
				end
			end
		end
	end
end
local function UpdateRankTags(DataFolder, Character)
	local Player = Players:GetPlayerFromCharacter(Character)
	local rank_gui = Character:WaitForChild("HumanoidRootPart"):WaitForChild("RankGui")

	local rank = Ranking:GetRankFromLevel(DataFolder.Level.Value)

	rank_gui.Rank.Text = rank.."-Class Wizard"
	rank_gui.Rank.TextColor3 = Ranking:GetData(rank).Color
	rank_gui.PlayerName.Text =  "<i><b>".. DataFolder.FirstName.Value.." ".. DataFolder.LastName.Value.."</b></i>"

	-------------
	local Guild = DataFolder:WaitForChild("Guild")
	if Guild.Value ~= "" then
		local found_guild = GuildStore:GetAsync(Guild.Value)
		warn(found_guild)

		if found_guild then
			rank_gui.Guild.Visible = true
			rank_gui.Guild.Text = "<i>(".. Guild.Value..")</i>"

			local split = found_guild.GuildColor:split(",")

			rank_gui.Guild.TextColor3 = Color3.fromRGB(tonumber(split[1]),tonumber(split[2]),tonumber(split[3]))

			if found_guild.Founder == Player.UserId then
				rank_gui.GuildOwner.Visible = true
			else
				rank_gui.GuildOwner.Visible = false
			end
		end
	else
		rank_gui.Guild.Visible = false
	end
end
local function FillInEmptySlot(Player, TabledSlots, slotNumber)
	for _,v in pairs(Player.Backpack:GetChildren()) do
		-- Checking if already in a slot
		if not table.find(TabledSlots, v.Name) then
			TabledSlots[slotNumber] = v.Name
			break
		end
	end

	return TabledSlots
end
local function updateCharacterTraits(Character)
	local Player = Players:GetPlayerFromCharacter(Character)
	if Player then
		local CharacterData = Character:WaitForChild("Data")
		local Bonuses = CharacterData.Bonuses
		local TraitsFolder = Player.Data.Traits
		local Applied = CharacterData:WaitForChild("AppliedTraits")

		for _,v in pairs(Applied:GetChildren()) do
			if not TraitsFolder:FindFirstChild(v.Name) then
				v:Destroy()				
			end
		end

		for _,trait in pairs(TraitsFolder:GetChildren()) do
			if not Applied:FindFirstChild(trait.Name) then
				local newVal = Instance.new("BoolValue")
				newVal.Name = trait.Name
				newVal.Value = true
				newVal.Parent = Applied
			end
		end

	end
end

local function CharacterAdded(Character)
	local Player = Players:GetPlayerFromCharacter(Character)

	local DataFolder = Player:WaitForChild("Data")
	local Backpack = Player:WaitForChild("Backpack")

	--warn(Character.Name)

	-- Parent to Live
	RunService.Heartbeat:Wait()
	Character.Parent = workspace.Live

	-- Remove Accessories
	ClearAccessories(Character)
	Character.ChildAdded:Connect(function(Child)
		task.wait()
		if Child then
			ClearAccessories(Character)
		end
	end)

	-- Collission
	for Index, Part in ipairs(Character:GetDescendants()) do
		if Part:IsA'BasePart' then
			game.PhysicsService:SetPartCollisionGroup(Part, "Players")
		end
	end

	-- Trails
	task.spawn(function()
		for _,v in pairs(Character:GetChildren()) do
			if v.Name == "Left Arm" or v.Name == "Right Arm" or v.Name == "Left Leg" or v.Name == "Right Leg" then
				for _,v2 in pairs(script.Effects["dash effects"]:GetChildren()) do
					local c = v2:Clone()
					c.Parent = v
				end

				v["DashAtt1"].DashTrail.Attachment0 = v["DashAtt0"]
				v["DashAtt1"].DashTrail.Attachment1 = v["DashAtt1"]
			end
		end
	end)
	task.spawn(function()
		for _,v in pairs(Character:GetChildren()) do
			if v.Name == "Left Arm" or v.Name == "Right Arm" or v.Name == "Left Leg" or v.Name == "Right Leg" then
				for _,v2 in pairs(script.Effects["run effects"]:GetChildren()) do
					local c = v2:Clone()
					c.Parent = v
				end

				v["RunAtt1"].RunTrail.Attachment0 = v["RunAtt0"]
				v["RunAtt1"].RunTrail.Attachment1 = v["RunAtt1"]
			end
		end
	end)
	task.spawn(function()
		for _,v in pairs(Character:GetChildren()) do
			if v.Name == "Left Arm" or v.Name == "Right Arm" then
				for _,v2 in pairs(script.Effects["punch trail"]:GetChildren()) do
					local c = v2:Clone()
					c.Parent = v
				end

				v["PunchAtt1"].PunchTrail.Attachment0 = v["PunchAtt0"]
				v["PunchAtt1"].PunchTrail.Attachment1 = v["PunchAtt1"]
			end
		end
	end)

	-- face test rq
	task.spawn(function()
		repeat task.wait() until Player:HasAppearanceLoaded() == true
		for _,v in pairs(Character:WaitForChild("Head"):GetChildren()) do
			if v:IsA("Decal") then
				v:Destroy()
			end
		end

		local FakeHead = script.FakeHead:Clone()
		FakeHead.Parent = Character
		FakeHead.Head.Part1 = Character.Head

		--[[
		local cc = script.Face:Clone()
		cc.Parent = FakeHead
		]]--
		UpdateFace(Player)
		--Character.Head.Reflectance = .0001
	end)

	-- Setting Health
	UpdateHealth(Player)
	-- Other Stuff

	UpdateClothing(Player)
	UpdateHairColor(Player)

	-- CoreScripts, data all loaded
	task.spawn(function()
		if Player:GetAttribute("DataLoaded") == true then

		else
			repeat task.wait() until Player:GetAttribute("DataLoaded") == true
		end
		for _,coreScript in pairs(script.MainScripts:GetChildren()) do
			local clone = coreScript:Clone()
			--			print(Character.Name)
			clone.Parent = Character
			clone.Disabled = false
		end		
	end)

	-- Traits
	task.spawn(function()
		local TraitsFolder = Player:WaitForChild("Data"):FindFirstChild("Traits")
		local BonusesFolder: Folder = Character:WaitForChild("Data").Bonuses

		if TraitsFolder then
			updateCharacterTraits(Player.Character)
		end

		TraitsFolder.ChildAdded:Connect(function(c)
			updateCharacterTraits(Player.Character)
		end)
		TraitsFolder.ChildRemoved:Connect(function(c)
			updateCharacterTraits(Player.Character)
		end)

		BonusesFolder.AttributeChanged:Connect(function(attributeName)
			updateCharacterTraits(Player.Character)
		end)		
	end)

	-- Hits
	local Hits = Instance.new("IntValue")
	Hits.Name = "Hits"
	Hits.Value = 0
	Hits.Parent = Character

	-- Rank Gui
	local rank_gui = script.RankGui:Clone()
	local rank = Ranking:GetRankFromLevel(DataFolder.Level.Value)

	rank_gui.Parent = Character:WaitForChild("HumanoidRootPart")
	UpdateRankTags(DataFolder, Character)

	-- Fixing GraceDisplay
	task.spawn(function()
		local FoundGraceDisplay = Player.PlayerGui:WaitForChild("ClientGraceDisplay", 999)
		if FoundGraceDisplay then
			FoundGraceDisplay.Adornee = Character:WaitForChild("HumanoidRootPart")
		end
	end)

	-- Core Effects
	local FX_Clone = script.Effects.Core:Clone()
	FX_Clone.Parent = Character:WaitForChild("HumanoidRootPart")

	local FX_Clone2 = script.Effects.Core:Clone()
	FX_Clone2.Parent = Character:WaitForChild("Torso")

	-- Died
	local Humanoid: Humanoid = Character:WaitForChild("Humanoid")
	Humanoid.BreakJointsOnDeath = false
	Humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

	task.spawn(function()
		repeat task.wait() until Player:HasAppearanceLoaded() and Humanoid:FindFirstChild("HumanoidDescription")
		-- Removing Packages
		local HumDescription = Humanoid:GetAppliedDescription()
		HumDescription.Head = 0
		HumDescription.Torso = 0
		HumDescription.LeftArm = 0
		HumDescription.RightArm = 0
		HumDescription.LeftLeg = 0
		HumDescription.RightLeg = 0

		Character.Head.Mesh.MeshType = Enum.MeshType.Head

		Humanoid:ApplyDescription(HumDescription)
	end)

	-- Saved Position
	local SavedPosition = DataFolder:WaitForChild("SavedPosition")
	if SavedPosition.Value == "" then
		-- set
		local children = workspace.Spawns:GetChildren()
		local ran_spawn = children[math.random(#children)]
		local pos = ran_spawn.Position

		SavedPosition.Value = math.floor(pos.X+.5)..","..math.floor(pos.Y+.5)..","..math.floor(pos.Z+.5)		
	end
	---

	-- Race Accessories
	UpdateRaceAccessories(Player)

	-- Tool
	local CurrentWeapon = DataFolder:WaitForChild("Weapon")
	local C = ServerStorage.Weapons:FindFirstChild(CurrentWeapon.Value)

	if C then
		local CLONE = C:Clone()
		CLONE.Parent = Player.Backpack
	end


	--

	local Items = DataFolder:WaitForChild("Items")

	local Weapons = Items:WaitForChild("Weapons")
	local Potions = Items:WaitForChild("Potions")
	local Foods = Items:WaitForChild("Foods")
	local Trainings = Items:WaitForChild("Trainings")
	local Trinkets = Items:WaitForChild("Trinkets")
	local Collectibles = Items:WaitForChild("Collectibles")
	local Equipment = Items:WaitForChild("Equipments")
	--local EquippedWeapon = Items:WaitForChild("EquippedWeapon")



	-- Cloning Food and Potions and Trainings and Collectibles
	-- Weapons first, Trainings, Potions, Foods
	--[[for _,weapon in pairs(Weapons:GetChildren()) do -- for weaopn models
		if weapon.Value > 0 then
			local trainingData = ShopItems[weapon.Name]

			weapon.Value = math.clamp(weapon.Value, 0, trainingData.MAX_STACK)
			-- Checking if is an actual weapon
			local weapon_clone = ServerStorage.Tools[weapon.Name]:Clone()
			weapon_clone.Parent = Player.Backpack
		end
	end]]


	UpdateEquippedSkills(Player, DataFolder)

	for _,training in pairs(Trainings:GetChildren()) do
		if training.Value > 0 then
			local trainingData = ShopItems[training.Name]
			training.Value = math.clamp(training.Value, 0, trainingData.MAX_STACK)


			local training_clone = ServerStorage.Tools[training.Name]:Clone()
			training_clone.Parent = Player.Backpack
		end
	end

	for _,potion in pairs(Potions:GetChildren()) do
		if potion.Value > 0 then
			local PotionData = ShopItems[potion.Name]
			potion.Value = math.clamp(potion.Value, 0, PotionData.MAX_STACK)


			local potion_clone = ServerStorage.Tools[potion.Name]:Clone()
			potion_clone.Parent = Player.Backpack
		end
	end
	for _,food in pairs(Foods:GetChildren()) do
		local FoodData = ShopItems[food.Name]
		if food.Value > FoodData.MAX_STACK then
			food:Destroy()
		end
		if food.Value > 0 then

			food.Value = math.clamp(food.Value, 0, FoodData.MAX_STACK)


			local food_clone = ServerStorage.Tools[food.Name]:Clone()
			food_clone.Parent = Player.Backpack
		end
	end
	for _,equipment in pairs(Equipment:GetChildren()) do
		if equipment.Value > 0 then
			local equipmentdata = ShopItems[equipment.Name]
			equipment.Value = math.clamp(equipment.Value, 0, equipmentdata.MAX_STACK)


			local equipment_clone = ServerStorage.Tools[equipment.Name]:Clone()
			equipment_clone.Parent = Player.Backpack
		end
	end

	--
	for _,trinket in pairs(Trinkets:GetChildren()) do
		if trinket.Value > 0 then
			local FoodData = ShopItems[trinket.Name]
			if trinket.Value > FoodData.MAX_STACK then
				-- set to max amount
				trinket.Value = FoodData.MAX_STACK
			end

			local food_clone = ServerStorage.Tools[trinket.Name]:Clone()
			food_clone.Parent = Player.Backpack
		end
	end
	--
	for _,collectible in pairs(Collectibles:GetChildren()) do
		if collectible.Value > 0 then
			local FoodData = ShopItems[collectible.Name]
			if collectible.Value > FoodData.MAX_STACK then
				-- set to max amount
				collectible.Value = FoodData.MAX_STACK
			end

			local food_clone = ServerStorage.Tools[collectible.Name]:Clone()
			food_clone.Parent = Player.Backpack
		end
	end

	for _,weapons in pairs(Weapons:GetChildren()) do
		if weapons.Value > 0 then
			local FoodData = ShopItems[weapons.Name]
			if weapons.Value > FoodData.MAX_STACK then
				-- set to max amount
				weapons.Value = FoodData.MAX_STACK
			end
			if weapons.Name ~= DataFolder:WaitForChild("Weapon").Value then
				local food_clone = ServerStorage.Tools[weapons.Name]:Clone()
				food_clone.Parent = Player.Backpack
			end
		end
	end

	-- Magic Aura --
	if script.Auras:FindFirstChild(DataFolder.ImbuedType.Value) then
		for _,v in pairs(Character:GetChildren()) do
			if v.Name == "Left Arm" or v.Name == "Right Arm" then

				for _,c in pairs(script.Auras[DataFolder.ImbuedType.Value]:GetChildren()) do
					if c.Name == "ManaAura_Arm" then
						local clone = c:Clone()
						clone.Enabled = false
						clone.Parent = v
						clone:SetAttribute("IgnoreAura", false)
					end
				end

			end
		end
	end
	-------------

	local CharacterData = Character:WaitForChild("Data")
	local currentClothing = Player:WaitForChild("Data").Clothing
	local clothingMod = require(ReplicatedStorage.Modules.Shared.Clothing)
	local variableTab = clothingMod:GetStatFromName(currentClothing.Value)


	for i,v in pairs(variableTab) do
		for a,b in pairs(CharacterData.Bonuses:GetChildren()) do
			if i.Name == b.Name then
				b.Value += v
			end
		end
	end
	-- Bonus Damage
	DoBonusDamage(CharacterData, DataFolder)

	local StatusFolder = Character:WaitForChild("Status")
	local LastDamage = CharacterData:WaitForChild("LastHit")

	-- Customs
	if Player.Name == "SennkoDevs" or Player.Name == "avaxwrld" or Player.Name == "EternalProwessKun" then
		distributeModule.Distribute(Player, "Race", MagicTools["Customs"]["Conquer"])
		distributeModule.Distribute(Player, "Race", MagicTools["Customs"].Soumetsu)
		distributeModule.Distribute(Player, "Race", MagicTools["Customs"].Globus)
		distributeModule.Distribute(Player, "Race", MagicTools["Customs"].Kagesekai)
	end




	Humanoid.Died:Connect(function()
		warn("DIED")

		if StatusFolder:FindFirstChild("Dead") then
			return -- already died
		end
		local dead = Instance.new("Folder")
		dead.Name = "Dead"
		dead.Parent = StatusFolder



		-- destroying left over stuff --
		task.spawn(function()
			for _,object in pairs(workspace.Visuals:GetChildren()) do
				if object:GetAttribute("DestroyOnDeath") == true and Player and object:GetAttribute("Owner") == Player.UserId then
					object:Destroy()
				end
			end		
		end)

		if Player and Player.UserId then
			game.ServerScriptService.MagicSystem.MagicEvent:Fire("ResetCooldowns", Player.UserId)
		end
		--
		-- Lost Stuff --
		if Player and Player.UserId then

			local _inCombat = Player:FindFirstChild("InCombat")
			if _inCombat then
				_inCombat:Destroy()
			end
		end

		DataFolder.SavedPosition.Value = ""

		-- Removing Quests
		local PlayerQuests = DataFolder.Quests
		for _,Folder in pairs(PlayerQuests:GetChildren()) do
			local QuestData = QuestsModule.GetQuestFromId(Folder.Name)
			if QuestData then
				if QuestData.RemoveOnDeath then

					-- Checking if in Squad
					local IsSquadQuest = Folder:FindFirstChild("SquadQuest")
					if IsSquadQuest and IsSquadQuest.Value == Player.UserId then -- is the Squad Ownenr
						for _,other in pairs(Players:GetPlayers()) do
							if other ~= Player then
								local otherData = other:FindFirstChild("Data")
								if otherData then
									local otherQuests = otherData:FindFirstChild("Quests")
									if otherQuests then

										local foundOtherQuest = otherQuests:FindFirstChild(Folder.Name)
										if foundOtherQuest and foundOtherQuest:FindFirstChild("SquadQuest") then
											local sq = foundOtherQuest.SquadQuest
											if sq.Value == Player.UserId then
												-- cancel
												foundOtherQuest:SetAttribute("Status", "Cancel")
												Remotes.Notify:FireClient(other, "[Squad System] The quest [".. QuestData.Name.."] has been cancelled because the squad owner died.", 4)
											end
										end
									end
								end
							end
						end
					end

					--
					Folder:SetAttribute("Status", "Cancel")
				end
			end
		end
	end)


end
local function DataChanged(Player, Object, OldValue, OldName)
	local Profile = Profiles[Player]
	if not Profile then return end

	local DataFolder = Player:FindFirstChild("Data")
	local Leaderstats = Player:FindFirstChild("leaderstats")
	local Backpack = Player:WaitForChild("Backpack")

	if DataFolder and Leaderstats then
		-- Update Profile
		local newData = TableUtil:ToTable(DataFolder)
		Profile.Data = newData
		------

		if (Object.Name == "Level" or Object.Name == "Element_Level") then
			-- Level Cap
			Object.Value = math.clamp(Object.Value, 1, 100)

			Remotes.ClientFX:FireAllClients("Sound", {
				SoundName = "LevelUp",
				Parent = Player.Character.HumanoidRootPart
			})

			Remotes.ClientFX:FireAllClients("LevelUpFX", {
				["Type"] = (Object.Name == "Element_Level" and "Magic") or "Normal",
				Parent = Player.Character.HumanoidRootPart
			})

			if Object.Name == "Element_Level" then
				Remotes.NotifyLarge:FireClient(Player, {
					["Text"] = "You have leveled up your <font color='rgb(122, 56, 255)'>[Element Level]</font> to level ".. Object.Value.."!",
					["Description"] = "-----",
					Duration = 3.5,
				})
			else
				Remotes.NotifyLarge:FireClient(Player, {
					["Text"] = "You have <font color='rgb(255, 197, 51)'>leveled</font> up to level ".. Object.Value.."!",
					["Description"] = "+5 Investment Points, +100 Jewels",
					Duration = 3.5,
				})

				DataFolder.Gold.Value += 100
			end			
		end
		if (Object.Name == "Experience" or Object.Name == "Element_Experience") then
			-- Clamping			
			if Object.Value < 0 then
				Object.Value = 0
			end
			---
		end
		-- Updating Face
		if (Object.Name == "Eyebrows" or Object.Name == "Eyes" or Object.Name == "Mouth" or Object.Name == "Nose" or Object.Name == "EyeColor") then
			UpdateFace(Player)
		end
		---
		if Object.Parent.Name == "Stats" and Object.Parent:IsA("Folder") then
			Object.Value = math.clamp(Object.Value, 0, Formulas.MaxStatPoints)

			if Object.Name == "Defense" then
				local Character = Player.Character
				if Character then
					UpdateHealth(Player)
				end
			end
			if Object.Name == "Mana" then
				-- Mana --
				--[[
				local Mana = Player.Character:WaitForChild("Data"):WaitForChild("Mana")
				Mana.Value = Formulas.GetMaxMana(Player)
				]]--
			end
		end
		if Object.Name == "HairColor" then
			UpdateHairColor(Player)
		end
		if Object.Name == "Clothing" then
			UpdateClothing(Player)
		end
		if Object.Name == "CustomClothesEnabled" and Object.Parent.Name == "Settings" then
			UpdateClothing(Player)
		end
		if Object.Name == "Gold" then

			if Object.Value < 0 then
				Object.Value = 0
			end


			Remotes.Notify:FireClient(Player, 
				'<font color="rgb(0, 204, 0)">[LEVEL]</font> Your [Jewels] has been updated to: $'.. Object.Value..".",
				3
			)
		end
		if Object.Name == "Level" then
			local magicTools = game.ServerStorage.MagicTools
			-- Increase Health

			Remotes.Notify:FireClient(Player, 
				'<font color="rgb(0, 204, 0)">[LEVEL]</font> You have leveled up! [LVL.'..tostring(Object.Value-1).."-"..Object.Value.."]",
				2.5
			)

			--move giver
			if DataFolder.Race.Value == "Celestial" then
				if DataFolder.Level.Value >= 10 then
					distributeModule.Distribute(Player, "Race", MagicTools["Celestial"]["Celestial Teleport"])
				end
			elseif DataFolder.Race.Value == "Exceed" then
				if DataFolder.Level.Value >= 25 then
					distributeModule.Distribute(Player, "Race", MagicTools["Exceed"]["Glide"])
				end	
			elseif DataFolder.Race.Value == "Dragon Slayer" then
				if DataFolder.Level.Value >= 40 then
					distributeModule.Distribute(Player, "Race", MagicTools["Dragon Slayer"]["Dragon Transformation"])
				end
			elseif DataFolder.Race.Value == "Devil Slayer" then
				if DataFolder.Level.Value >= 40 then
					distributeModule.Distribute(Player, "Race", MagicTools["Devil Slayer"]["Devil Transformation"])
				end
			end

			--[[if DataFolder.LastName.Value == "Dragneel" then
				distributeModule.Distribute(Player, "Clan", MagicTools[""])
			end]]

			local Character = Player.Character
			-- update rank
			Leaderstats.Rank.Value = Ranking:GetRankFromLevel(Object.Value).."-Class"			

			UpdateRankTags(DataFolder, Character)

			---------------
			local MaxExperience = Formulas.GetMaxExperience(DataFolder.Level.Value)
			local CurrentExperience = DataFolder.Experience.Value

			if CurrentExperience >= MaxExperience then
				-- UPDATING EXPERIENCE BY JUST ADDING ONE --
				DataFolder.Experience.Value += 1
			end

			-- Traits
			ServerEvents.GiveTrait:Fire(Player)
		end
		if Object.Name == "FirstName" then
			UpdateRankTags(DataFolder, Player.Character)
		end
		if Object.Name == "LastName" then
			UpdateRankTags(DataFolder, Player.Character)
		end
		if Object.Name == "Element_Level" then
			Remotes.Notify:FireClient(Player, 
				'<font color="rgb(0, 204, 204)">[ELEMENT LEVEL]</font> You have leveled up! [LVL.'..tostring(Object.Value-1).."-"..Object.Value.."]",
				2.5
			)

			local MaxExperience = Formulas.GetMaxElementExperience(DataFolder.Element_Experience.Value)
			local CurrentExperience = DataFolder.Element_Experience.Value

			if CurrentExperience >= MaxExperience then
				-- UPDATING EXPERIENCE BY JUST ADDING ONE --
				DataFolder.Element_Experience.Value += 1
			end

			-- destroying tools that don't meet level --
			UpdateEquippedSkills(Player, DataFolder)
			------
		end
		if Object.Name == "Bounty" then
			Leaderstats.Bounty.Value = Object.Value

			if Object.Value < 0 then
				Object.Value = 0
			end			
		end

		if Object.Name == "Experience" then			
			-- checking stuff
			local amountGained = Object.Value-OldValue

			if DataFolder.Level.Value >= 50 then -- greater than 50
				-- can't gain anymore experience
				Object.Value = OldValue
				return
			end


			if DataFolder.Level.Value > 50 then
				DataFolder.Level.Value = 50
				if amountGained > 0 and OldValue > 0 then
					Remotes.Notify:FireClient(Player, 
						'<font color="rgb(255, 255, 0)">[EXP]</font> Gained: '.. tostring(amountGained).." Experience!",
						2.5
					)
				end
				return
			end
			if DataFolder.Level.Value == 50 then
				if amountGained > 0 and OldValue > 0 then
					Remotes.Notify:FireClient(Player, 
						'<font color="rgb(255, 255, 0)">[EXP]</font> Gained: '.. tostring(amountGained).." Experience!",
						2.5
					)
				end
				return
			end


			local MaxExperience = Formulas.GetMaxExperience(DataFolder.Level.Value)
			local CurrentExperience = DataFolder.Experience.Value
			if CurrentExperience >= MaxExperience then 
				if levelcd == false then
					task.spawn(function()
						levelcd = true
						local LevelsToGain, NewExperience = Formulas.GetLevelsToGainFromExperience(CurrentExperience, DataFolder.Level.Value)
						DataFolder.Level.Value += LevelsToGain
						DataFolder.Experience.Value = NewExperience
						task.wait(10)
						levelcd = false
					end)
				end
			else
				-- just gained experience
				-- Notify
				if amountGained > 0 and OldValue > 0 then
					Remotes.Notify:FireClient(Player, 
						'<font color="rgb(255, 255, 0)">[EXP]</font> Gained: '.. tostring(amountGained).." Experience!",
						2.5
					)
				else
					if amountGained < 0 then
						Remotes.Notify:FireClient(Player, 
							'<font color="rgb(255, 0, 0)">[EXP]</font> LOST: '.. tostring(amountGained).." Experience!",
							2.5
						)
					end
				end
			end
		end
		if Object.Name == "Element_Experience" then		
			local amountGained = Object.Value-OldValue

			if DataFolder.Element_Level.Value >= 50 then -- greater than 50
				-- can't gain anymore experience
				Object.Value = OldValue
				return
			end

			if DataFolder.Element_Level.Value > 50 then
				DataFolder.Element_Level.Value = 50
				if amountGained > 0 and OldValue > 0 then -- making sure the amountGained was positive and the OldValue wasn't less than 0

				end
				return
			end		
			if DataFolder.Element_Level.Value == 50 then
				if amountGained > 0 and OldValue > 0 then -- making sure the amountGained was positive and the OldValue wasn't less than 0

				end
				return
			end


			local MaxExperience = Formulas.GetMaxElementExperience(DataFolder.Element_Level.Value)
			local CurrentExperience = DataFolder.Element_Experience.Value

			if CurrentExperience > MaxExperience then 
				if CurrentExperience > MaxExperience then
					while CurrentExperience > MaxExperience do
						DataFolder.Element_Level.Value += 1
						CurrentExperience = math.clamp(CurrentExperience - MaxExperience,0,math.huge)

						MaxExperience = Formulas.GetMaxElementExperience(DataFolder.Element_Level.Value)
						task.wait()
					end
					DataFolder.Element_Experience.Value = CurrentExperience
				end
			else
				-- just gained experience
				-- Notify
				if amountGained > 0 and OldValue > 0 then -- making sure the amountGained was positive and the OldValue wasn't less than 0

				else
					if amountGained < 0 then
						--[[
						Remotes.Notify:FireClient(Player, 
							'<font color="rgb(255, 0, 0)">[EXP]</font> LOST: '.. tostring(amountGained).." Experience!",
							2.5,
							{
								["Sound"] = "NONE"
							}
						)
						]]
					end
				end
			end
		end
		if Object.Name == "Guild" then
			UpdateRankTags(DataFolder, Player.Character)
		end

		-- Foods/Potions/Trainings
		if Object.Parent.Name == "Foods" then
			if OldValue == 0 then
				-- clone
				local Clone = ServerStorage.Tools[Object.Name]:Clone()
				Clone.Parent = Player.Backpack
			end
			if Object.Value <= 0 then

				-- destroy
				local inBackpack = Backpack:FindFirstChild(Object.Name)
				if inBackpack then
					inBackpack:Destroy()
				else
					local inCharacter = Player.Character:FindFirstChild(Object.Name)
					if inCharacter and inCharacter:IsA("Tool") then
						inCharacter:Destroy()
					end
				end 

			end
		end
		if Object.Parent.Name == "Equipments" then
			if OldValue == 0 then
				-- clone
				local Clone = ServerStorage.Tools[Object.Name]:Clone()
				Clone.Parent = Player.Backpack
			end
			if Object.Value <= 0 then
				-- destroy
				local inBackpack = Backpack:FindFirstChild(Object.Name)
				if inBackpack then
					inBackpack:Destroy()
				else
					local inCharacter = Player.Character:FindFirstChild(Object.Name)
					if inCharacter and inCharacter:IsA("Tool") then
						inCharacter:Destroy()
					end
				end

				Object:Destroy()
			end
			return
		end
		--[[if Object.Parent.Name == "EquippedWeapon" then
			-- clone

			print(OldValue)
			if OldValue == 0 or OldValue == 1  then
				print("sssawwaw")
				Player.Character.Humanoid:UnequipTools() -- unequipping to stop any animations


				local Clone = ServerStorage.Weapons[Object.Name]:Clone()
				Clone.Parent = Player.Backpack

			end			




			if Object.Value <= 0 then
				print(Object.Name)
				Player.Character.Humanoid:UnequipTools() -- unequipping to stop any animations
				-- destroy
				local inBackpack = Backpack:FindFirstChild(Object.Name)
				if inBackpack then
					inBackpack:Destroy()
				end 

				-- Finding stuff in character
				for _,v in pairs(Player.Character:GetChildren()) do -- destroying models
					if v.Name == Object.Name.."_Main" or v.Name == Object.Name.."_Back" then
						v:Destroy()
					end
				end


				Object:Destroy()
			end
			return
		end]]
		if Object.Parent.Name == "Weapons" then
			--[[if OldValue == 0 then
				-- clone
				local Clone = ServerStorage.Tools[Object.Name]:Clone()
				Clone.Parent = Player.Backpack
			end]]
			if Object.Value <= 0 then
				-- destroy
				local inBackpack = Backpack:FindFirstChild(Object.Name)
				if inBackpack then
					inBackpack:Destroy()
				else
					local inCharacter = Player.Character:FindFirstChild(Object.Name)
					if inCharacter and inCharacter:IsA("Tool") then
						inCharacter:Destroy()
					end
				end

				Object:Destroy()
			end
			return
		end
		if Object.Parent.Name == "Potions" then
			if OldValue == 0 then
				-- clone
				local Clone = ServerStorage.Tools[Object.Name]:Clone()
				Clone.Parent = Player.Backpack
			end
			if Object.Value <= 0 then
				-- destroy
				local inBackpack = Backpack:FindFirstChild(Object.Name)
				if inBackpack then
					inBackpack:Destroy()
				else
					local inCharacter = Player.Character:FindFirstChild(Object.Name)
					if inCharacter and inCharacter:IsA("Tool") then
						inCharacter:Destroy()
					end
				end 
			end
		end
		if Object.Parent.Name == "Trainings" then
			if OldValue == 0 then
				-- clone
				local Clone = ServerStorage.Tools[Object.Name]:Clone()
				Clone.Parent = Player.Backpack
			end
			if Object.Value <= 0 then
				-- destroy
				local inBackpack = Backpack:FindFirstChild(Object.Name)
				if inBackpack then
					inBackpack:Destroy()
				else
					local inCharacter = Player.Character:FindFirstChild(Object.Name)
					if inCharacter and inCharacter:IsA("Tool") then
						inCharacter:Destroy()
					end
				end 
			end
		end
		if Object.Parent.Name == "Trinkets" then
			if OldValue == 0 then
				-- clone
				local Clone = ServerStorage.Tools[Object.Name]:Clone()
				Clone.Parent = Player.Backpack
			end
			if Object.Value <= 0 then
				-- destroy
				warn("Destroy trinket test")
				local inBackpack = Backpack:FindFirstChild(Object.Name)
				if inBackpack then
					inBackpack:Destroy()
				else
					local inCharacter = Player.Character:FindFirstChild(Object.Name)
					if inCharacter and inCharacter:IsA("Tool") then
						inCharacter:Destroy()
					end
				end

				Object:Destroy()
			end
		end
		if Object.Parent and Object.Parent.Name == "Collectibles" then
			if OldValue == 0 then
				-- clone
				local Clone = ServerStorage.Tools[Object.Name]:Clone()
				Clone.Parent = Player.Backpack
			end
			if Object.Value <= 0 then
				-- destroy
				local inBackpack = Backpack:FindFirstChild(Object.Name)
				if inBackpack then
					inBackpack:Destroy()
				else
					local inCharacter = Player.Character:FindFirstChild(Object.Name)
					if inCharacter and inCharacter:IsA("Tool") then
						inCharacter:Destroy()
					end
				end

				Object:Destroy()
			end
		end
		----------
		if Object.Name == "ImbuedType" then
			if script.Auras:FindFirstChild(Object.Value) then
				for _,v in pairs(Player.Character:GetDescendants()) do
					if v.Name == "ManaAura_Arm" then
						v:Destroy()
					end
				end

				for _,v in pairs(Player.Character:GetChildren()) do
					if v.Name == "Left Arm" or v.Name == "Right Arm" then
						for _,c in pairs(script.Auras[DataFolder.ImbuedType.Value]:GetChildren()) do
							if c.Name == "ManaAura_Arm" then
								local clone = c:Clone()
								clone.Enabled = false
								clone.Parent = v
								clone:SetAttribute("IgnoreAura", false)
							end
						end
					end
				end
			end
		end
	end
end

local function DataLoaded(Player)	
	local Profile = Profiles[Player]

	if Profile then
		-- Getting other Slots


		local SlotsAmount = SlotsData:GetAsync(tostring(Player.UserId))
		if SlotsAmount then
			for i = 1, SlotsAmount do
				local ViewedProfile = nil
				if i == 1 then 
					ViewedProfile = ProfileStore:ViewProfileAsync(tostring(Player.UserId))
				else
					ViewedProfile = ProfileStore:ViewProfileAsync(tostring(Player.UserId).."Slot_"..i)
				end
				if ViewedProfile then
					local ViewedData = ViewedProfile.Data
					--[[for i,v in pairs(ViewedData.Codes) do
						if i ~= nil and Profile.Data.Codes[i] == nil then
							Profile.Data.Codes[i] = {}
							local NewInstance = Instance.new("Folder")
							NewInstance.Name = i
							NewInstance.Parent = Player.Data.Codes
						end

					end]]
					if Profile.Data.Guild == "" then
						if ViewedData and ViewedData.Guild ~= "" then
							-- Checking if the current Profile is up to date with the other guild values
							if Profile.Data.Guild ~= ViewedData.Guild then
								Profile.Data.Guild = ViewedData.Guild
								warn("Updated guild for ".. Player.Name.." to their other slots's guild. [Guild Name: ".. ViewedData.Guild.."]")
							end
						end
					end
					
				end
			end
		end

		local globalData = Instance.new("Folder")
		globalData.Name = "GlobalData"
		globalData.Parent = Player

		-- Spins Data
		local FoundSpinsData = SpinsData:GetAsync(tostring(Player.UserId)) or 10
		if FoundSpinsData then
			local Spins = Instance.new("IntValue")
			Spins.Name = "Spins"
			Spins.Value = FoundSpinsData
			Spins.Parent = globalData
		end

		local Folder = Instance.new("Folder")
		Folder.Name = "Data"

		TableUtil:ToInstance(Profile.Data, Folder)
		Folder.Parent = Player

		-- Removing Spins from [Data]
		if Folder:FindFirstChild("Spins") then
			Folder.Spins:Destroy()
		end

		-- Resetting
		local isReturning = Folder:FindFirstChild("ReturningTester")
		if isReturning and isReturning.Value then
			isReturning.Value = false

			Folder.Experience.Value = 0
			Folder.Element_Experience.Value = 0

			Folder.Level.Value = 1
			Folder.Element_Level.Value = 1

			for _,v in pairs(Folder.Traits:GetChildren()) do
				v:Destroy()
			end

			Folder.Guild.Value = ""
			Folder.Weapon.Value = "Combat"

			for _,v in pairs(Folder.Stats:GetChildren()) do
				v.Value = 0
			end

			Remotes.NotifyLarge:FireClient(Player, {
				["Text"] = "<font color='rgb(255, 174, 33)'>[ RETURNING TESTER DATA RESET ]</font>",
				["Description"] = "Certain aspects of your data have been reset.",
				Duration = 10,
			})	
		end

		-- leaderstats
		local leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"

		local rank = Instance.new("StringValue")
		rank.Name = "Rank"
		rank.Value = Ranking:GetRankFromLevel(Folder.Level.Value).."-Class"
		rank.Parent = leaderstats

		local bounty = Instance.new("IntValue")
		bounty.Name = "Bounty"
		bounty.Value = Folder:FindFirstChild("Bounty").Value
		bounty.Parent = leaderstats

		leaderstats.Parent = Player
		--

		-- Fixing Ice
		if Folder:WaitForChild("Element").Value == "Ice" then
			Folder.Element.Value = "Fire"
		end
		-- Magic Storage
		if MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, Gamepasses.GetGamepassIdFromName("Magic Storage")) then
			-- Adding current Element
			local PreviousRolls = Folder:WaitForChild("PreviousRolls")

			local duplicate_element = PreviousRolls:FindFirstChild(Folder.Element.Value)
			if not duplicate_element then
				-- add to list
				local f = Instance.new("BoolValue")
				f.Name = Folder.Element.Value
				f.Value = true
				f.Parent = PreviousRolls
			end
		end
		--


		-- Removing FirstJoin
		local FirstJoin = Folder:WaitForChild("FirstJoin")
		if FirstJoin.Value then
			FirstJoin.Value = false
			ServerEvents.InvestorPerks:Fire(Player)
		end

		-- Quests 
		local QuestsFolder = Instance.new("Folder")
		QuestsFolder.Name = "Quests"
		QuestsFolder.Parent = Player
		
		-- Removing FastHandsl
		local GracesFolder = Folder:FindFirstChild("Traits")
		if GracesFolder then
			if GracesFolder:FindFirstChild("Fast Hands") then
				GracesFolder["Fast Hands"]:Destroy()
			end
		end

		--[[
		-- Guild
		local GuildFolder = Instance.new("Folder")
		GuildFolder.Name = "GUILD_INFO"
		GuildFolder.Parent = Player

		if Folder.Guild.Value ~= "" then
			local guild_data = GuildStore:GetAsync(Folder.Guild.Value)
			if guild_data then
				TableUtil:ToInstance(guild_data, GuildFolder)
			end
		end
		]]--

		Player:SetAttribute("DataLoaded", true)
		warn("Successfully loaded data for ".. Player.Name..".")

		-- LastName Updating --
		if Folder.LastName.Value == "None" or Folder.LastName.Value == "" then
			-- set last name, randomize
			Folder.LastName.Value = Names:Roll()
		end
		-- Race Updating --
		if Folder.Race.Value == "None" or Folder.Race.Value == "" then
			-- set last name, randomize
			local res = Races:Roll()

			if res == "Exceed" then
				if Folder.ExceedColor.Value == "None" then
					local randomized = ExceedColors[math.random(#ExceedColors)]
					Folder.ExceedColor.Value = math.floor(randomized.R*255)..","..math.floor(randomized.G*255)..","..math.floor(randomized.B*255)
				end
			end
			if res == "Devil Slayer" then
				if Folder.DevilSlayerMarking.Value == "None" then
					local randomized = math.random(#ReplicatedStorage.Assets.DevilSlayerMarkings:GetChildren())
					Folder.DevilSlayerMarking.Value = tostring(randomized)
				end
			end

			Folder.Race.Value = res
		end

		-- Detecting Data Changes
		for _,Object in pairs(Folder:GetDescendants()) do
			if not Object:IsA("Folder") then
				local OldValue = Object.Value

				-- UPDATING EXP COMPONENTS --
				if Object.Name == "Element_Experience" then
					DataChanged(Player, Object, OldValue)
				end
				if Object.Name == "Experience" then
					DataChanged(Player, Object, OldValue)
				end

				Object.Changed:Connect(function()
					DataChanged(Player, Object, OldValue)
					OldValue = Object.Value
				end)
			end
		end
		-- Detecting Additions to the Equipments Folder --
		local EquipmentsFolder = Folder:WaitForChild("Items"):WaitForChild("Equipments")
		if EquipmentsFolder then
			EquipmentsFolder.ChildAdded:Connect(function(Child)		
				local collectible_clone = ServerStorage.Tools[Child.Name]:Clone()
				collectible_clone.Parent = Player.Backpack

				if Child:IsA("IntValue") then
					Child.Changed:Connect(function()
						if Child.Value <= 0 then
							Child:Destroy()

							local inCharacter = Player.Character:FindFirstChild(Child.Name)
							if inCharacter and inCharacter:IsA("Tool") then
								Player.Character.Humanoid:UnequipTools() -- unequipping to stop any animations
							end
							local inBackpack = Player.Backpack:FindFirstChild(Child.Name)
							if inBackpack then
								inBackpack:Destroy()
							end

						end
					end)
				end
			end)
		end



		-- Detecting Additions to the Weapons Folder --
		local WeaponsFolder = Folder:WaitForChild("Items"):WaitForChild("Weapons")
		if WeaponsFolder then
			WeaponsFolder.ChildAdded:Connect(function(Child)		
				local collectible_clone = ServerStorage.Tools[Child.Name]:Clone()
				collectible_clone.Parent = Player.Character

				if Child:IsA("IntValue") then
					Child.Changed:Connect(function()
						if Child.Value <= 0 then
							Child:Destroy()

							local inCharacter = Player.Character:FindFirstChild(Child.Name)
							if inCharacter and inCharacter:IsA("Tool") then
								Player.Character.Humanoid:UnequipTools() -- unequipping to stop any animations
							end
							local inBackpack = Player.Backpack:FindFirstChild(Child.Name)
							if inBackpack then
								inBackpack:Destroy()
							end

						end
					end)
				end
			end)
		end

		--[[local EquippedWepFolder = Folder:WaitForChild("Items"):WaitForChild("EquippedWeapon")
		if EquippedWepFolder then
			EquippedWepFolder.ChildAdded:Connect(function(Child)		
				--local collectible_clone = ServerStorage.Tools[Child.Name]:Clone()
				--collectible_clone.Parent = Player.Backpack

				if Child:IsA("IntValue") then
					Child.Changed:Connect(function()
						if Child.Value <= 0 then
							Child:Destroy()

							local inCharacter = Player.Character:FindFirstChild(Child.Name)
							if inCharacter and inCharacter:IsA("Tool") then
								Player.Character.Humanoid:UnequipTools() -- unequipping to stop any animations
							end
							local inBackpack = Player.Backpack:FindFirstChild(Child.Name)
							if inBackpack then
								inBackpack:Destroy()
							end

						end
					end)
				end
			end)
		end]]

		-- Collectibles --
		local CollectiblesFolder = Folder:WaitForChild("Items"):WaitForChild("Collectibles")
		if CollectiblesFolder then
			CollectiblesFolder.ChildAdded:Connect(function(Child)				
				local collectible_clone = ServerStorage.Tools[Child.Name]:Clone()
				collectible_clone.Parent = Player.Backpack

				if Child:IsA("IntValue") then
					Child.Changed:Connect(function()
						if Child.Value <= 0 then
							Child:Destroy()

							local inCharacter = Player.Character:FindFirstChild(Child.Name)
							if inCharacter and inCharacter:IsA("Tool") then
								Player.Character.Humanoid:UnequipTools() -- unequipping to stop any animations
							end
							local inBackpack = Player.Backpack:FindFirstChild(Child.Name)
							if inBackpack then
								inBackpack:Destroy()
							end

						end
					end)
				end
			end)
		end

		-----------
		-- Detecting Trinkets Added --
		local TrinketsFolder = Folder:WaitForChild("Items"):WaitForChild("Trinkets")
		if TrinketsFolder then
			TrinketsFolder.ChildAdded:Connect(function(Child)				
				local trinket_clone = ServerStorage.Tools[Child.Name]:Clone()
				trinket_clone.Parent = Player.Backpack

				if Child:IsA("IntValue") then
					Child.Changed:Connect(function()
						if Child.Value <= 0 then
							warn("Destroy trinket test")
							Child:Destroy()

							local inCharacter = Player.Character:FindFirstChild(Child.Name)
							if inCharacter and inCharacter:IsA("Tool") then
								Player.Character.Humanoid:UnequipTools() -- unequipping to stop any animations
							end
							local inBackpack = Player.Backpack:FindFirstChild(Child.Name)
							if inBackpack then
								inBackpack:Destroy()
							end 

						end
					end)
				end
			end)
		end

		-- Auto Saving
		task.spawn(function()
			if not AutoSave then return end
			while Profiles[Player] do
				Profiles[Player]:Save()
				task.wait(AutoSaveTime)
			end
		end)
		-- Adding Experience every [5] minutes, Passive
		task.spawn(function()
			while Profiles[Player] do
				task.wait(PassiveEXPInterval)
				Folder.Experience.Value += PassiveEXPGain
			end
		end)
		-- Spins
		task.spawn(function()
			while Profiles[Player] do
				task.wait(3600)
				globalData.Spins.Value += 5
				Remotes.Notify:FireClient(Player, "+5 Magic Spin", 4)
			end
		end)
		task.spawn(function()
			while Profiles[Player] do
				if Folder.DoubleExperienceTimer.Value > 0 then
					Folder.DoubleExperienceTimer.Value -= 1
				end
				task.wait(1)
			end
		end)
	end
end
local function PlayerAdded(Player: Player)
	local JoinData = Player:GetJoinData()	
	local SlotNumber = nil
	if JoinData and JoinData.TeleportData and JoinData.TeleportData.SlotToLoad then
		SlotNumber = JoinData.TeleportData.SlotToLoad

	end
	--

	Player:SetAttribute("DataLoaded", false)

	local ID = tostring(Player.UserId)
	if not RunService:IsStudio() then
		if SlotNumber ~= nil then
			if SlotNumber == 1 then

			else
				ID = ID.."Slot_"..SlotNumber
			end		
		end
	end

	local Profile = ProfileStore:LoadProfileAsync(ID, "ForceLoad")

	local BanData
	pcall(function()
		BanData = BanStore:GetAsync(Player.UserId)
	end)
	local IsBanned
	if BanData ~= nil then
		IsBanned = BanData
	else
		IsBanned = false
	end
	if IsBanned == true then
		Player:Kick("You have been banned from the game")
	end

	if Profile ~= nil then
		Profile:AddUserId(Player.UserId)
		Profile:Reconcile()
		Profile:ListenToRelease(function()
			-- Checking if Wiped
			if Player:FindFirstChild("Wiped") then
				Player:Kick("You have been wiped!")
			else
				Player:Kick()
			end			
			Profiles[Player] = nil
		end)
		if Player:IsDescendantOf(Players) == true then
			Profiles[Player] = Profile
			-- Data Loaded
			DataLoaded(Player)
		else
			Profile:Release()
		end
	else
		Player:Kick() 
	end

	if Player.Character then
		CharacterAdded(Player.Character)
		local slotVal = Instance.new("IntValue")
		slotVal.Name = "Slot"
		slotVal.Value = SlotNumber
		slotVal.Parent = Player
	end
	Player.CharacterAdded:Connect(function(Character)

		CharacterAdded(Character)
	end)

	--[[local provideFunc = function()
		local DataFolder = Player:WaitForChild("Data")
		if DataFolder.Race.Value == "Celestial" then
			if DataFolder.Level.Value >= 10 then
				distributeModule.Distribute(Player, "Race", MagicTools["Celestial"]["Celestial Teleport"])
			end
		elseif DataFolder.Race.Value == "Exceed" then
			if DataFolder.Level.Value >= 25 then
				distributeModule.Distribute(Player, "Race", MagicTools["Exceed"]["Glide"])
			end	
		elseif DataFolder.Race.Value == "Dragon Slayer" then
			if DataFolder.Level.Value >= 40 then
				distributeModule.Distribute(Player, "Race", MagicTools["Dragon Slayer"]["Dragon Transformation"])
			end
		elseif DataFolder.Race.Value == "Devil Slayer" then
			if DataFolder.Level.Value >= 40 then
				distributeModule.Distribute(Player, "Race", MagicTools["Devil Slayer"]["Devil Transformation"])
			end
		end
	end

	provideFunc()]]
end
local function PlayerRemoved(Player, IsShutdown)
	local Profile = Profiles[Player]
	if Profile ~= nil then
		local ProfileData = Profile.Data

		-- Checking for dropped items
		for _,droppedItem in pairs(workspace.DropItems:GetChildren()) do
			local owner = droppedItem:GetAttribute("Owner")
			if owner ~= nil and owner == Player.UserId then
				-- destroying dropped item
				local itemInfo = ShopItems[droppedItem.Name]
				local amount = droppedItem:GetAttribute("Amount")

				droppedItem:Destroy()
				-- adding back to inventory || avax said it dont go back into inv
				--[[
				if itemInfo then
					if itemInfo.Type == "Food" then
						ProfileData.Foods[itemInfo.Name] += amount
					end
					if itemInfo.Type == "Potion" then
						ProfileData.Potions[itemInfo.Name] += amount
					end
				end
				]]--
			end
		end

		--
		-- GuildsInGame
		local Keep = false

		for _,p in pairs(Players:GetPlayers()) do
			if p ~= Player then
				local target_data = p:FindFirstChild("Data")
				if target_data and target_data.Guild.Value == ProfileData.Guild then
					Keep = true
					break
				end
			end
		end
		if not Keep then
			-- Remove from [GuildsInGame]
			local FoundGuild = ReplicatedStorage.GuildsInGame:FindFirstChild(ProfileData.Guild)			
			if FoundGuild then
				FoundGuild:Destroy()
				warn("Removed")
			end
		end
		-- Removing PlayerDebounces
		for _,debounce in pairs(script.Parent.GuildSystem.PlayerDebounces:GetChildren()) do
			if string.find(debounce.Name, tostring(Player.UserId)) then
				debounce:Destroy()
			end
		end
		--------------
		-- Checking Quests
		local PlayerQuests = ProfileData.Quests
		for QuestName,Info in pairs(PlayerQuests) do
			local QuestData = QuestsModule.GetQuestFromId(QuestName)
			if QuestData then

				-- Checking was a Squad Quest
				local Found = PlayerQuests[QuestName]
				if Found then
					if Found.SquadQuest then
						if Found.SquadQuest == Player.UserId then
							-- is the Owner, remove from other members
							for _,other in pairs(Players:GetPlayers()) do
								if other ~= Player then
									local otherData = other:FindFirstChild("Data")
									if otherData then
										local otherQuests = otherData:FindFirstChild("Quests")
										if otherQuests then

											local foundOtherQuest = otherQuests:FindFirstChild(QuestName)
											if foundOtherQuest and foundOtherQuest:FindFirstChild("SquadQuest") and foundOtherQuest.SquadQuest.Value == Player.UserId then -- is the Owner
												-- cancel
												foundOtherQuest:SetAttribute("Status", "Cancel")
												Remotes.Notify:FireClient(other, "[Squad System] The quest [".. QuestData.Name.."] has been cancelled because the squad owner left.", 4)
											end
										end
									end
								end
							end
						end
					end
				end


				-- REMOVING ON LEAVE
				if QuestData.RemoveOnLeave then
					PlayerQuests[QuestName] = nil
					local questnpcs = collectionservice:GetTagged(Player.UserId)
					if questnpcs then
						for i,v in pairs(questnpcs) do
							v:Destroy()
						end
					end

					local sortnpcspawns = game.ServerScriptService.QuestSystem.SortNpcSpawns
					sortnpcspawns:Fire(QuestName,Player)

					print("Removed Quest: ".. QuestName.." on ".. Player.Name.." left.")					
				else
					-- Saves
					local Found = PlayerQuests[QuestName]
					if Found.SquadQuest then
						if Found.SquadQuest ~= Player.UserId then
							-- Player is not the Owner
							-- Removing Quest because not the SquadOwner even though its a squad quest
							PlayerQuests[QuestName] = nil
							print("Removed [SQUAD] Quest: ".. QuestName.." on ".. Player.Name.." left.")
						else
							-- Was the Owner of the Squad
							-- Remove the SquadQuest value because left
							Found.SquadQuest = nil
						end
					end
				end

			end
		end

		if Players:FindFirstChild("Shutdown") then
			if Player:FindFirstChild("InCombat") then
				Player.InCombat:Destroy()
			end
		end

		if Player:FindFirstChild("Wiped") then
			Profile.Data = DatastoreTemplate
			Profile:Release()
			return
		else
			local InCombat = Player:FindFirstChild("InCombat")
			if InCombat then
				if ProfileData.Experience - 50 < 0 then
					ProfileData.Experience = 0
				else
					ProfileData.Experience -= 50
				end
				if ProfileData.Element_Experience - 50 < 0 then
					ProfileData.Element_Experience = 0
				else
					ProfileData.Element_Experience -= 50
				end
				if ProfileData.Gold - (ProfileData.Gold/2) < 0 then
					ProfileData.Gold = 0
				else
					ProfileData.Gold -= ProfileData.Gold/2
				end

				---- shael it's legit one line
				ProfileData.SavedPosition = ""
				----

				local PersonWhoTagged = InCombat:GetAttribute("TaggedBy")
				local TaggedPlayer = Players:FindFirstChild(PersonWhoTagged)

				if TaggedPlayer then
					local foundData = TaggedPlayer:FindFirstChild("Data")

					ServerEvents.GiveData:Fire(
						TaggedPlayer,
						{
							["Experience"] = 50,
							["Element_Experience"] = 50,
							["Gold"] = ProfileData.Gold/2,
							["Bounty"] = ProfileData.Bounty/2
						},
						{IgnoreGamepasses = true}
					)
				--[[
				foundData.Experience.Value += 50
				foundData.Element_Experience.Value += 50
				foundData.Gold.Value += 50
				foundData.Bounty.Value += ProfileData.Bounty/2
				]]--
				end


				ProfileData.Bounty /= 2
			end
		end

		-- Saving Spins
		local GlobalData = Player:FindFirstChild("GlobalData")
		if GlobalData then
			local spins = GlobalData:WaitForChild("Spins")
			SpinsData:SetAsync(tostring(Player.UserId), spins.Value)
			warn("Successfully saved global data for: ".. Player.Name..".")
		end

		warn("Successfully saved data for: ".. Player.Name..".")	
		Profile:Release()
	end
end

Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(PlayerRemoved)


-- Wipe
ServerEvents.Wipe.Event:Connect(function(Player, Target)
	local Profile = Profiles[Target]

	local newVal = Instance.new("BoolValue")
	newVal.Name = "Wiped"
	newVal.Parent = Target

	Target:Kick("You have been wiped!")
end)
-- Dragon Lacrima --
Remotes.DragonLacrima.OnServerEvent:Connect(function(Player: Player)
	local PlayerData = Player:FindFirstChild("Data")

	if PlayerData then
		local Collectibles = PlayerData.Items.Trinkets
		local FoundLacrima = Collectibles:FindFirstChild("Dragon Lacrima")

		if FoundLacrima then
			FoundLacrima.Value = math.clamp(FoundLacrima.Value-1,0,math.huge)

			local SlayerMagics = {}
			for name,_ in pairs(Rates.Elements) do
				if string.find(name, "Dragon Slayer") then
					table.insert(SlayerMagics, name)
				end
			end

			if #SlayerMagics > 0 then
				local newMagic = SlayerMagics[math.random(#SlayerMagics)]
				PlayerData.Element.Value = newMagic

				UpdateEquippedSkills(Player, PlayerData)

				Remotes.ClientFX:FireAllClients("LacrimaConsume2", {
					["Character"] = Player.Character
				})
				Remotes.ClientFX:FireAllClients("Sound", {
					SoundName = "DeathSound",
					Parent = Player.Character.HumanoidRootPart
				})
				Remotes.NotifyLarge:FireClient(Player, {
					["Text"] = "New Dragon Slayer Magic",
					["Description"] = newMagic,
					["Duration"] = 3.5,
				})
			end

		end
	end
end)

for _,player in ipairs(Players:GetPlayers()) do
	task.spawn(PlayerAdded, player)
end

-- Lighting --

task.spawn(function()
	local brightnessValue = game.Lighting.TimeBrightness;
	local dayLength = 20

	local cycleTime = dayLength*60
	local minutesInADay = 24*60

	local lighting = game:GetService("Lighting")

	local startTime = tick() - (lighting:getMinutesAfterMidnight() / minutesInADay)*cycleTime
	local endTime = startTime + cycleTime

	local timeRatio = minutesInADay / cycleTime

	if dayLength == 0 then
		dayLength = 1
	end

	while task.wait(1/15) do
		local currentTime = tick()
		if currentTime > endTime then
			startTime = endTime
			endTime = startTime + cycleTime
		end

		lighting:setMinutesAfterMidnight((currentTime - startTime)*timeRatio)

		local Minutes = lighting:getMinutesAfterMidnight()
		local X = (Minutes/720) * math.pi
		brightnessValue.Value = 0.5 * math.sin(X - (math.pi/2)) + 0.5
	end
end)

--//Bans
ServerEvents.Ban.Event:Connect(function(Type,Player)
	print(Type,Player)
	if Type == "Ban" then
		local success,err = pcall(function()
			BanStore:UpdateAsync(Player.UserId,function(Old)
				return true
			end)
		end)
		if err then
			print(err)
		end
		Player:Kick("You have been banned from the game")
	elseif Type == "Unban" then
		local PlayerId = Players:GetUserIdFromNameAsync(Player)
		local success,err = pcall(function()
			BanStore:UpdateAsync(PlayerId,function(Old)
				return false
			end)
		end)
		if err then
			print(err)
		end
	elseif Type == "RemoteBan" then
		local PlayerId = Players:GetUserIdFromNameAsync(Player)
		local success,err = pcall(function()
			BanStore:UpdateAsync(PlayerId,function(Old)
				return true
			end)
		end)
		if err then
			print(err)
		end
	end
end)
