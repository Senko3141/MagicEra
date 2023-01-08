-- Request Handler

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local MarketPlaceService = game:GetService("MarketplaceService")
local HTTPService = game:GetService("HttpService")
local debris = game:GetService("Debris")
local collectionservice = game:GetService("CollectionService")

local MagicTools = ServerStorage:WaitForChild("MagicTools")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local ServerEvents = script.Parent.Events

local Players = game:GetService("Players")
local Assets = ReplicatedStorage.Assets
local Rates = require(Modules.Shared.Rates)
local ElementData = require(Modules.Shared.Elements)
local ToolFunctions = require(script.Parent.Modules.ToolFunctions)
local Formulas = require(Modules.Shared.Formulas)
local Gamepasses = require(Modules.Shared.Gamepasses)
local ShopItems = require(Modules.Shared.Items)


local function GetSkillNumberFromName(Data, Name)
	for i = 1, #Data do
		local d = Data[i]
		if d.Name == Name then
			return i
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

-- SPIN --
local SpinsCooldowns = {}
local SpinCooldown = 2.8
Remotes.Spin.OnServerInvoke = function(Player, Skip_Spins)
	if Skip_Spins == true then 
		if not MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, Gamepasses.GetGamepassIdFromName("Instant Spin Skip")) then 
			return false end
	end

	local PlayerData = Player:FindFirstChild("Data")
	local GlobalData = Player:FindFirstChild("GlobalData")
	
	local Spins = GlobalData.Spins
	local Element = PlayerData.Element

	local Element_Level = PlayerData.Element_Level
	local Element_Experience = PlayerData.Element_Experience
	local EquippedSkills = PlayerData.EquippedSkills

	if Spins.Value <= 0 then
		return false
	end
	if os.clock() - (SpinsCooldowns[Player.UserId] or 0) < SpinCooldown and not Skip_Spins then
		return false -- on cooldown
	end

	local Chosen = Rates:Roll(Player, PlayerData.SpinPity.Value)
	if Chosen then
		SpinsCooldowns[Player.UserId] = os.clock()

		Spins.Value -= 1
		Element.Value = Chosen
		
		-- Updating Pity
		local Rarity = Rates:GetRarityFromName(Chosen)
		warn(Rarity)
		
		local RarityValue = Rates.Percentages[Rarity]
		if RarityValue <= Rates.Percentages.Abnormal then
			-- Reset Pity
			Remotes.Notify:FireClient(Player, "Pity Count Reset!", 4)
			PlayerData.SpinPity.Value = 0
		else
			Remotes.Notify:FireClient(Player, "+1 Pity", 4)
			PlayerData.SpinPity.Value += 1
		end
		--

		-- checking if owns magic storage gamepass
		if MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, Gamepasses.GetGamepassIdFromName("Magic Storage")) then
			-- bought
			local PreviousRolls = PlayerData:FindFirstChild("PreviousRolls")
			if PreviousRolls then
				local duplicate_element = PreviousRolls:FindFirstChild(Chosen)
				if not duplicate_element then
					-- add to list
					local f = Instance.new("BoolValue")
					f.Name = Chosen
					f.Value = true
					f.Parent = PreviousRolls
				end
			end
		end
		--

		-- Resetting All --
		--Element_Level.Value = 1
		--Element_Experience.Value = 0

		for _,equipped in pairs(EquippedSkills:GetChildren()) do
			equipped.Value = false
		end

		-- destroying magic tools
		ToolFunctions.Destroy_Nonmatching_Tools(Player)
		--

		return true, Chosen
	end
	return false, Chosen
end
-- EQUIP FUNCTIONS --
Remotes.EquipMagic.OnServerInvoke = function(Player, Action, Data)
	local PlayerData = Player:FindFirstChild("Data")
	local MagicName = Data.Name
	if not MagicName or not PlayerData then
		return
	end


	local Element_Info = ElementData.Element[PlayerData.Element.Value]
	if not Element_Info then return end
	local SkillNumber = GetSkillNumberFromName(Element_Info, MagicName)
	if not SkillNumber then
		return
	end

	if not ToolFunctions.CanEquipTool(Player, MagicName, "Element") then
		return "Error"
	end
	print(Action)
	if Action == "Equip" then

		print("Equip: ".. MagicName.. "\nSkill Number: ".. SkillNumber)
		PlayerData.EquippedSkills[tostring(SkillNumber)].Value = true

		-- cloning tool
		ToolFunctions.EquipTool(Player, MagicName, "Element")
		--

		return "Success"
	end
	if Action == "Unequip" then
		print("Unequip: ".. MagicName.. "\nSkill Number: ".. SkillNumber)
		PlayerData.EquippedSkills[tostring(SkillNumber)].Value = false

		-- destroyoing tools
		ToolFunctions.DestroyToolWithName(Player, MagicName)
		--

		return "Success"
	end
end
-- INVESTMENT POITNS --
local function AddStat(Player, Action, ...)
	local args = {...}
	local PlayerData = Player:FindFirstChild("Data")

	if not PlayerData then
		return
	end
	local Stats = PlayerData:FindFirstChild("Stats")
	if not Stats then
		return
	end

	if Action == "AddPoint" then
		local StatName = args[1]
		local InvestmentPoints = Formulas.GetInvestmentPoints(Player)

		if not Stats:FindFirstChild(StatName) then
			return
		end
		if InvestmentPoints <= 0 then
			return -- not enough points
		end
		if Stats[StatName].Value >= Formulas.MaxStatPoints then
			return
		end
		local AmountToAdd = (args[2] and args[2]) or 1

		Remotes.Notify:FireClient(Player, "<font color='rgb(255, 192, 32)'>[Investment Points]</font> Added ["..AmountToAdd.."] point(s) into " .. StatName..".", 3)

		Stats[StatName].Value += AmountToAdd
	end
end
Remotes.Stats.OnServerEvent:Connect(function(Player, Action, ...)
	local args = {...}
	local PlayerData = Player:FindFirstChild("Data")

	if not PlayerData then
		return
	end
	local Stats = PlayerData:FindFirstChild("Stats")
	if not Stats then
		return
	end

	if Action == "AddPoint" then
		local StatName = args[1]
		local InvestmentPoints = PlayerData.TrueInvestmentPoints

		if not Stats:FindFirstChild(StatName) then
			return
		end
		if InvestmentPoints.Value <= 0 then
			return -- not enough points
		end
		if Stats[StatName].Value >= Formulas.MaxStatPoints then
			return
		end

		InvestmentPoints.Value -= 1

		local AmountToAdd = (args[2] and args[2]) or 1
		Stats[StatName].Value += AmountToAdd
	end
end)
ServerEvents.AddStat.Event:Connect(AddStat)

-- FILTER STRING --
local function FilterString(Player, String)
	if String == "" then
		return ""
	end
	if String == "None" then
		return ""
	end

	if string.match(String, "%a+") ~= String then
		-- has non letters
		return ""
	end
	local filteredTextResult = ""
	local success, errorMessage = pcall(function()
		filteredTextResult = TextService:FilterStringAsync(String, Player.UserId)
	end)
	if not success then
		return ""
	end
	return filteredTextResult:GetNonChatStringForBroadcastAsync()
end

Remotes.FilterString.OnServerInvoke = FilterString
-- UPDATE NAME --
local ValidGenders = {["Male"] = true, ["Female"] = true,}
Remotes.UpdateName.OnServerInvoke = function(Player, Name, Gender)	
	local PlayerData = Player:FindFirstChild("Data")
	if not PlayerData then
		return "Error"
	end
	if PlayerData.FirstName.Value ~= "None" then
		--[[
		Player:Kick("Attempted exploiting. Tried to change FirstName value, though already set.")
		]]--
		return "Error"
	end
	if FilterString(Player, Name) ~= Name then
		return "Error" -- invalid
	end
	if not ValidGenders[Gender] then
		return "Error"
	end
	if PlayerData.Gender.Value ~= "None" then
		Remotes.Notify:FireClient(Player, "[INPUT ERROR] There was an error when trying to set your gender. | Reason: Gender value is already set to ".. PlayerData.Gender.Value..".", 6)
		return "Error"
	end
	PlayerData.FirstName.Value = Name
	PlayerData.Gender.Value = Gender

	-- Randomizing Face
	ServerEvents.RandomizeFace:Fire(Player, true)
	return "Success"
end

-- RANDOMIZE FACE --
ServerEvents.RandomizeFace.Event:Connect(function(Player: Player, RerollEyeColor)
	local PlayerData = Player:FindFirstChild("Data")
	if PlayerData then
		local Gender = PlayerData.Gender.Value
		local Eyebrows = math.random(1, #Assets.Faces.Eyebrows:GetChildren())
		local Eyes = math.random(1, #Assets.Faces.Eyes[Gender]:GetChildren())
		local Mouth = math.random(1, #Assets.Faces.Mouth:GetChildren())
		local Nose = math.random(1, #Assets.Faces.Nose:GetChildren())

		if Eyebrows and Eyes and Mouth and Nose then
			PlayerData.Eyebrows.Value = tostring(Eyebrows)
			PlayerData.Eyes.Value = tostring(Eyes)
			PlayerData.Mouth.Value = tostring(Mouth)
			PlayerData.Nose.Value = tostring(Nose)

			if RerollEyeColor then
				local randomized = Color3.fromRGB(math.random(1,255), math.random(1,255), math.random(1,255))
				PlayerData.EyeColor.Value = math.floor(randomized.R*255)..","..math.floor(randomized.G*255)..","..math.floor(randomized.B*255)
			end
		end
	end
end)
-- GIVE DATA --
ServerEvents.GiveData.Event:Connect(function(Target, Data, Config, Squadamount)
	if Target and Target:FindFirstChild("Data") then
		local PlayerData = Target.Data
		for name,amount in pairs(Data) do
			if PlayerData:FindFirstChild(name) then

				local final_amount = amount
				
				print(Squadamount)
				if Squadamount then
					print("these")
					final_amount = final_amount/Squadamount
				else
					print("nuts")
				end
				if type(Config) == "table" and Config.IgnoreGamepasses then
				else
					-- Check for Gamepasses
					if name == "Element_Experience" then
						if MarketPlaceService:UserOwnsGamePassAsync(Target.UserId, Gamepasses.GetGamepassIdFromName("2x Magic Exp")) then
							final_amount *= 2
						end
					end
					if name == "Experience" then
						if MarketPlaceService:UserOwnsGamePassAsync(Target.UserId, Gamepasses.GetGamepassIdFromName("2x Level Exp")) or PlayerData.DoubleExperienceTimer.Value > 0 then
							final_amount *= 2
						end
					end
					--[[
					if name == "Gold" then
						if MarketPlaceService:UserOwnsGamePassAsync(Target.UserId, Gamepasses.GetGamepassIdFromName("2x Gold")) then
							final_amount *= 2
						end
					end
					]]
					

					local TraitsFolder = PlayerData:FindFirstChild("Traits")
					if TraitsFolder then
						if TraitsFolder:FindFirstChild("Trainee") then
							if name == "Element_Experience" or name == "Experience" then
								final_amount = final_amount + (final_amount*.01)
							end
						end
					end					
				end

				PlayerData[name].Value = PlayerData[name].Value + final_amount
			end
		end
	end
end)
-- HEALTH PACKS --
local HEALTH_PACK_COOLDOWN = 30

ServerEvents.HealthPacks.Event:Connect(function(Target)
	if not Target then
		return -- no target
	end

	local CharacterData = Target:FindFirstChild("Data")
	if CharacterData and CharacterData:FindFirstChild("LastHealthPack") then
		if os.clock() - (CharacterData.LastHealthPack.Value or 0) < HEALTH_PACK_COOLDOWN then
			return -- On Cooldown
		end

		CharacterData.LastHealthPack.Value = os.clock()

		local PercentToHeal = .2

		local TargetPlayer = game.Players:GetPlayerFromCharacter(Target)
		if TargetPlayer then
			local TargetData = TargetPlayer:FindFirstChild("Data")
			if TargetData then
				local TargetTraits = TargetData:FindFirstChild("Traits")
				if TargetTraits and TargetTraits:FindFirstChild("Greedy") then
					PercentToHeal += .1
				end
			end
		end

		Target.Humanoid.Health = Target.Humanoid.Health + (PercentToHeal*Target.Humanoid.MaxHealth)

		Remotes.ClientFX:FireAllClients("LevelUpFX", {
			["Type"] = "HealthPack",
			Parent = Target.HumanoidRootPart
		})

		if TargetPlayer then
			Remotes.Notify:FireClient(TargetPlayer, "<font color='rgb(0,128,0)'>[HP BOOST]</font> +"..math.floor(PercentToHeal*100).."%", 5)
		end
	end
end)
-- SWITCH MAGIC --
Remotes.SwitchMagic.OnServerInvoke = function(Player, MagicName)
	local PlayerData = Player:FindFirstChild("Data")
	if PlayerData then
		local PreviousRolls = PlayerData:FindFirstChild("PreviousRolls")
		local EquippedSkills = PlayerData:FindFirstChild("EquippedSkills")

		if PreviousRolls and EquippedSkills then
			-- Checking if has Magic

			if PreviousRolls:FindFirstChild(MagicName) then
				if PlayerData.Element.Value == MagicName then
					return false -- currently equipped
				end
				PlayerData.Element.Value = MagicName

				for _,equipped in pairs(EquippedSkills:GetChildren()) do
					equipped.Value = false
				end

				-- destroying magic tools
				ToolFunctions.Destroy_Nonmatching_Tools(Player)
				--
				return true
			end

		end
	end
	return false
end
-- PURCHASE --
Remotes.Purchase.OnServerEvent:Connect(function(Player, ItemName, Amount)
	print(Player,ItemName,Amount)
	if not ShopItems[ItemName] then
		return
	end
	if not tonumber(Amount) then
		return
	end
	if Amount < 1 then
		return -- negative number
	end

	Amount = math.floor(Amount+.5)

	if Amount ~= Amount then
		return
	end

	local ItemInfo = ShopItems[ItemName]

	local PlayerData = Player:FindFirstChild("Data")
	if PlayerData then
		if Amount > ItemInfo.MAX_BULK_AMOUNT then
			return -- Past limit
		end
		--[[
		if PlayerData.Level.Value < 5 then
			return -- requirement
		end
		]]--

		local FoundCategory = PlayerData.Items:FindFirstChild(ItemInfo.Category)
		if not FoundCategory and not ItemInfo.IGNORE_CATEGORY_CHECK then
			return
		end

		if not ItemInfo.IGNORE_CATEGORY_CHECK and FoundCategory[ItemInfo.Name].Value+Amount > ItemInfo.MAX_STACK then
			return -- already has max
		end

		---------

		local Gold = PlayerData.Gold
		local FinalPrice = ItemInfo.Price * Amount

		if Gold.Value < FinalPrice then
			Remotes.Notify:FireClient(Player, "You do not have enough Jewels to purchase this! ["..ItemInfo.Name.."]")
			return -- can't purchase
		end

		Gold.Value -= FinalPrice

		-- giving stuff --

		local Category = ItemInfo.Category
		if Category == "Potions" or Category == "Foods" or Category == "Trainings" or Category == "Equipments" or Category == "Weapons" then
			PlayerData.Items[Category][ItemInfo.Name].Value += Amount
		end
		if Category == "Trinkets" then
			local foundObject = FoundCategory:FindFirstChild(ItemInfo.Name)
			if not foundObject then
				local c = Instance.new("IntValue")
				c.Name = ItemInfo.Name
				c.Value = 0
				c.Value += Amount
				c.Parent = FoundCategory
			else
				foundObject.Value += Amount
			end
		end


		Remotes.Notify:FireClient(Player, "[SHOP SYSTEM] Successfully purchased [".. ItemName.."] (x".. Amount..") for: $".. FinalPrice.."!", 5)
		Remotes.ClientFX:FireClient(Player, "Sound", {
			SoundName = "Cash",
			Parent = Player.Character.HumanoidRootPart
		})
		-------
	end
end)
-- GIVE MONEY --
local SendCooldowns = {}
local SendCooldown = 5
local SendCap = 5000
local StudsCap = 20

Remotes.SendMoney.OnServerEvent:Connect(function(Player, Target, Amount)
	local PlayerData = Player:FindFirstChild("Data")
	if not PlayerData then return end

	local Amount = tonumber(Amount)
	if Amount < 1 then
		return
	end
	if PlayerData.Level.Value < 5 then
		return
	end
	Amount = math.floor(Amount+.5)
	if Amount > SendCap then
		return
	end
	if os.clock() - (SendCooldowns[Player.UserId] or 0) < SendCooldown then
		return -- on cooldown
	end
	if Amount ~= Amount then
		return
	end

	if PlayerData.Gold.Value < Amount then
		return
	end


	SendCooldowns[Player.UserId] = os.clock()--[[
	
	SendCooldowns[Player.UserId] = os.clock()

	local PlayerData = Player:FindFirstChild("Data")
	if PlayerData then
		local TargetPlayer = game.Players:FindFirstChild(Target)
		if TargetPlayer then
			local TargetData = TargetPlayer:FindFirstChild("Data")
			if TargetData then

				local A = Player.Character.HumanoidRootPart.Position
				local B = TargetPlayer.Character.HumanoidRootPart.Position

				if (A-B).Magnitude > StudsCap then
					return
				end

				PlayerData.Gold.Value -= Amount
				TargetData.Gold.Value += Amount

				Remotes.Notify:FireClient(Player, "[GIVE MONEY] Successfully sent $"..Amount.. " to ".. Target.."!", 5)
				Remotes.Notify:FireClient(TargetPlayer, "[GIVE MONEY] You have received money from: ".. Player.Name..". [AMOUNT: $".. Amount.."]", 5)
			end
		end
	end
	]]--

	-- Subtracting Gold	
	PlayerData.Gold.Value -= Amount

	local Template = script.ItemTemplate:Clone()
	Template.Name = "MoneyBag"

	Template:SetAttribute("Owner", Player.UserId)
	Template:SetAttribute("Amount", Amount)

	Template.BillboardGui.ItemName.Text = "Jewels ($"..tostring(Amount)..")"

	Template.CFrame = Player.Character.HumanoidRootPart.CFrame * CFrame.new(1.5, -2, -4.5)
	Template.CollisionGroup = "NonCollidable"

	Template.Parent = workspace.DropItems

	-- Notify
	Remotes.Notify:FireClient(Player, "[Drop System] Successfully dropped $".. tostring(Amount).."!", 5)

	-- Anchoring when done falling --
	Template:SetNetworkOwner(nil)

	task.spawn(function()
		local Elapsed = 0
		while Template:IsDescendantOf(workspace) do
			Elapsed += task.wait()
			if (Elapsed > 1 and Template.AssemblyLinearVelocity.Magnitude < 1) or Elapsed > 10 then
				Template.Anchored = true
				break
			end
		end
	end)
	------------
	local AlreadyClaimed = false
	local Connection

	Connection = Template.ClickDetector.MouseClick:Connect(function(PlayerWhoClicked)
		if AlreadyClaimed then
			return
		end
		local TargetData = PlayerWhoClicked:FindFirstChild("Data")
		if TargetData then
			local PointA = PlayerWhoClicked.Character.HumanoidRootPart.Position
			local PointB = Template.Position
			local Distance = (PointA-PointB).Magnitude

			if Distance <= 20 then
				-- can pick up
				AlreadyClaimed = true
				Connection:Disconnect() Connection = nil

				TargetData.Gold.Value += Amount
				Template:Destroy()
			end
		end
	end)
end)
-- IMBUE MAGIC --
local ImbuedTypes = {
	"King's Flame",
	"Foresight",
	"Thunder Dragon Slayer",
	"Devil's Shadow"
}
Remotes.ImbueMagic.OnServerEvent:Connect(function(Player)
	local PlayerData = Player:FindFirstChild("Data")
	if PlayerData then	
		if PlayerData.Level.Value < 25 then
			return
		end
		--[[
		local Rarity = Rates.Elements[PlayerData.Element.Value]
		if Rarity == "Common" or Rarity == "Uncommon" or Rarity == "Rare" then
			return
		end
		]]--
		if PlayerData.Gold.Value < 1000 then
			return
		end
		if PlayerData.ImbuedMagic.Value then
			-- already imbued
			Remotes.Notify:FireClient(Player, "You have already imbued yourself with magic.", 4)
			return
		end

		PlayerData.Gold.Value -= 1000

		local Range = math.random(1, 100)

		if Range <= 3 then
			Remotes.Notify:FireClient(Player, "<i>Imbued Successful!</i>", 5)

			PlayerData.ImbuedMagic.Value = true
			PlayerData.ImbuedType.Value = ImbuedTypes[math.random(#ImbuedTypes)]

			Remotes.Notify:FireClient(Player, "<i><font color='rgb(52,52,52)'>You feel your magic fusing within your body...</font></i>", 8)
			Remotes.Notify:FireClient(Player, "[Notice] Press T to toggle your mana aura.", 5)

			Remotes.ClientFX:FireAllClients("LevelUpFX", {
				["Type"] = "ImbueMagic",
				Parent = Player.Character.HumanoidRootPart
			})	
			Remotes.ClientFX:FireAllClients("Sound", {
				SoundName = "LevelUp",
				Parent = Player.Character.HumanoidRootPart
			})
		else
			Remotes.Notify:FireClient(Player, "<i>Imbued Failed!</i>", 5)
		end
	end
end)
-- AURA --
local PreviousAuras = {}
Remotes.ManaAura.OnServerEvent:Connect(function(Player)
	local Character = Player.Character
	local PlayerData = Player:FindFirstChild("Data")

	if not PlayerData then return end
	if not PlayerData.ImbuedMagic.Value then
		return
	end

	local CharacterData = Character:FindFirstChild("Data")
	if not CharacterData then
		return
	end
	if CharacterData.CurrentWeapon.Value == "" then
		return -- need to have a weapon equipped
	end

	if not CharacterData.AuraEnabled.Value then
		-- check if cooldown to toggle to true
		if os.clock() - (PreviousAuras[Player.UserId] or 0) < 3 then
			return
		end
		CharacterData.AuraEnabled.Value = not CharacterData.AuraEnabled.Value
		PreviousAuras[Player.UserId] = os.clock()

		-- Do Animation
		local Anim = Assets.Animations:FindFirstChild("AuraStart_"..CharacterData.CurrentWeapon.Value)
		if Anim then
			local Animation = Character.Humanoid:LoadAnimation(Anim)
			Animation:Play()
		end
		-- Sound
		if Assets.Sounds:FindFirstChild("AuraStart/"..PlayerData.ImbuedType.Value) then
			Remotes.ClientFX:FireAllClients("Sound", {
				SoundName = "AuraStart/"..PlayerData.ImbuedType.Value,
				Parent = Character.HumanoidRootPart
			})
		end
	else
		if os.clock() - (PreviousAuras[Player.UserId] or 0) < 2 then
			return
		end
		PreviousAuras[Player.UserId] = os.clock()
		CharacterData.AuraEnabled.Value = not CharacterData.AuraEnabled.Value
	end
end)
-- UPDATE SETTING --
Remotes.UpdateSetting.OnServerInvoke = function(Player, SettingName, NewValue)
	if typeof(SettingName) ~= "string" then
		return "Failed"
	end
	if typeof(NewValue) ~= "boolean" then
		return "Failed"
	end

	local PlayerData = Player:FindFirstChild("Data")
	if PlayerData then
		local Settings = PlayerData.Settings

		if Settings:FindFirstChild(SettingName) then
			Settings[SettingName].Value = NewValue
			return "Success"
		end
	end
	return "Failed"
end
-- DROP ITEM --
local Drop_Cooldowns = {}
local DropCooldown = 2

Remotes.Drop.OnServerEvent:Connect(function(Player, Data)
	if typeof(Data) ~= "table" then
		return
	end
	local PlayerData = Player:FindFirstChild("Data")
	if not PlayerData then return end

	local Item = Data.Item
	local Amount = Data.Amount

	local ServerInfo = require(Player.Character:WaitForChild("Handler").Input.Info)

	if not Item or not Amount then
		return
	end
	local ItemInfo = ShopItems[Item.Name]
	if ItemInfo then
		if not ItemInfo.CAN_DROP then
			return
		end
		if ItemInfo.MAX_DROP_COUNT == nil then
			return
		end
		Amount = tonumber(Amount)
		if not Amount then
			return
		end
		if Amount < 1 then
			return
		end
		if Amount%1 > 0 then
			-- Decimal
			return
		end
		if Amount ~= Amount then
			return
		end
		if Amount > ItemInfo.MAX_DROP_COUNT then
			return
		end
		if os.clock() - (Drop_Cooldowns[Player.UserId] or 0) < DropCooldown then
			return
		end
		-- Checking Type, and if player has in inventory --
		local FoundCategory = PlayerData.Items:FindFirstChild(ItemInfo.Category)
		if not FoundCategory then
			return
		end

		if FoundCategory[ItemInfo.Name].Value < Amount then
			return
		end
		-- Checking if Stunned --
		if ServerInfo:StunCheck(Player.Character) then
			return
		end

		Drop_Cooldowns[Player.UserId] = os.clock()

		-- Drop Item
		if ItemInfo.Category == "Foods" then
			if PlayerData.Items.Foods[ItemInfo.Name].Value - Amount <= 0 then
				local foundItem = Player.Backpack:FindFirstChild(ItemInfo.Name)
				if foundItem then
					foundItem:Destroy()
				end
			end
			----
			PlayerData.Items.Foods[ItemInfo.Name].Value -= Amount
		end
		if ItemInfo.Category == "Potions" then
			if PlayerData.Items.Potions[ItemInfo.Name].Value - Amount <= 0 then
				local foundItem = Player.Backpack:FindFirstChild(ItemInfo.Name)
				if foundItem then
					foundItem:Destroy()
				end
			end
			----
			PlayerData.Items.Potions[ItemInfo.Name].Value -= Amount
		end
		if ItemInfo.Category == "Trinkets" then
			if PlayerData.Items.Trinkets[ItemInfo.Name].Value - Amount <= 0 then
				local foundItem = Player.Backpack:FindFirstChild(ItemInfo.Name)
				if foundItem then
					foundItem:Destroy()
				end
			end
			----
			PlayerData.Items.Trinkets[ItemInfo.Name].Value -= Amount
		end
		if ItemInfo.Category == "Collectibles" then
			if PlayerData.Items.Collectibles[ItemInfo.Name].Value - Amount <= 0 then
				local foundItem = Player.Backpack:FindFirstChild(ItemInfo.Name)
				if foundItem then
					foundItem:Destroy()
				end
			end
			----
			PlayerData.Items.Collectibles[ItemInfo.Name].Value -= Amount
		end
		if ItemInfo.Category == "Equipments" then
			if PlayerData.Items.Equipments[ItemInfo.Name].Value - Amount <= 0 then
				local foundItem = Player.Backpack:FindFirstChild(ItemInfo.Name)
				if foundItem then
					foundItem:Destroy()
				end
			end
			----
			PlayerData.Items.Equipments[ItemInfo.Name].Value -= Amount
		end
		if ItemInfo.Category == "Weapons" then
			if PlayerData.Items.Weapons[ItemInfo.Name].Value - Amount <= 0 then
				local foundItem = Player.Backpack:FindFirstChild(ItemInfo.Name)
				if foundItem then
					foundItem:Destroy()
				end
			end
			----
			PlayerData.Items.Weapons[ItemInfo.Name].Value -= Amount
		end
		local Template = script.ItemTemplate:Clone()
		Template.Name = ItemInfo.Name

		Template:SetAttribute("Owner", Player.UserId)
		Template:SetAttribute("Amount", Amount)

		Template.BillboardGui.ItemName.Text = ItemInfo.Name.. " ("..Amount..")"

		Template.CFrame = Player.Character.HumanoidRootPart.CFrame * CFrame.new(1.5, -2, -4.5)
		Template.Parent = workspace.DropItems

		-- Notify
		Remotes.Notify:FireClient(Player, "[Drop System] Successfully dropped ".. ItemInfo.Name.." (x"..Amount..")!", 5)

		-- Anchoring when done falling --
		Template:SetNetworkOwner(nil)
		task.spawn(function()
			local Elapsed = 0
			while Template:IsDescendantOf(workspace) do
				Elapsed += task.wait()
				if (Elapsed > 1 and Template.AssemblyLinearVelocity.Magnitude < 1) or Elapsed > 10 then
					Template.Anchored = true
					break
				end
			end
		end)
		------------
		local AlreadyClaimed = false
		local Connection

		Connection = Template.ClickDetector.MouseClick:Connect(function(PlayerWhoClicked)
			if AlreadyClaimed then
				return
			end
			local TargetData = PlayerWhoClicked:FindFirstChild("Data")
			if TargetData then
				local PointA = PlayerWhoClicked.Character.HumanoidRootPart.Position
				local PointB = Template.Position
				local Distance = (PointA-PointB).Magnitude

				if Distance <= 20 then
					-- can pick up
					AlreadyClaimed = true
					Connection:Disconnect() Connection = nil

					if ItemInfo.Category == "Foods" then
						TargetData.Items.Foods[ItemInfo.Name].Value += Amount
					end
					if ItemInfo.Category == "Potions" then
						TargetData.Items.Potions[ItemInfo.Name].Value += Amount
					end
					if ItemInfo.Category == "Trinkets" then
						local foundItem = TargetData.Items.Trinkets:FindFirstChild(ItemInfo.Name)
						if foundItem then
							foundItem.Value += Amount
						else
							local NewValue = Instance.new("IntValue")
							NewValue.Name = ItemInfo.Name
							NewValue.Value = Amount
							NewValue.Parent = TargetData.Items.Trinkets
						end
					end
					if ItemInfo.Category == "Collectibles" then
						local foundItem = TargetData.Items.Collectibles:FindFirstChild(ItemInfo.Name)
						if foundItem then
							foundItem.Value += Amount
						else
							local NewValue = Instance.new("IntValue")
							NewValue.Name = ItemInfo.Name
							NewValue.Value = Amount
							NewValue.Parent = TargetData.Items.Collectibles
						end
					end
					if ItemInfo.Category == "Equipments" then
						local foundItem = TargetData.Items.Equipments:FindFirstChild(ItemInfo.Name)
						if foundItem then
							foundItem.Value += Amount
						else
							local NewValue = Instance.new("IntValue")
							NewValue.Name = ItemInfo.Name
							NewValue.Value = Amount
							NewValue.Parent = TargetData.Items.Equipments
						end
					end
					if ItemInfo.Category == "Weapons" then
						local potentialWeapon = PlayerWhoClicked.Backpack:FindFirstChild(ItemInfo.Name) or PlayerWhoClicked.Character:FindFirstChild(ItemInfo.Name)
						if potentialWeapon ~= nil then
							Remotes.Notify:FireClient(Player, "You already have a "..ItemInfo.Name, 4)
							return
						end
						local foundItem = TargetData.Items.Weapons:FindFirstChild(ItemInfo.Name)
						if foundItem then
							foundItem.Value += Amount
						else
							local NewValue = Instance.new("IntValue")
							NewValue.Name = ItemInfo.Name
							NewValue.Value = Amount
							NewValue.Parent = TargetData.Items.Weapons
						end
					end
					Template:Destroy()
				end
			end
		end)
	end
end)
-- SELLING --
local MarketItems = require(Modules.Shared.MarketItems)
local FormatNumber2 = require(Modules.Shared.FormatNumber2)

Remotes.Sell.OnServerEvent:Connect(function(Player, Data)
	local PlayerData = Player:FindFirstChild("Data")
	if PlayerData then
		local AmountInTable = 0
		for _,v in pairs(Data) do
			AmountInTable += 1
		end
		if AmountInTable < 1 then
			Player:Kick("Suspected exploiting.")
			return
		end		
		local Total = 0
		local TotalItems = 0

		for name,value in pairs(Data) do
			local ItemInfo = MarketItems[name]
			print(name)
			print(value)
			if math.floor(value) ~= value then
				return
			end




			if ItemInfo then
				local Price = ItemInfo.Price
				local Category = ItemInfo.Category

				local FoundCategory = PlayerData.Items:FindFirstChild(Category)
				if FoundCategory then
					local FoundItem = FoundCategory:FindFirstChild(name)
					if not FoundItem or FoundItem.Value < value then
						Remotes.Notify:FireClient(Player, "You do not have ["..value.."] or more of ["..name.."] to sell.", 4)
						return
					end

					-- Removing Item
					if Category == "Trinkets" or Category == "Weapons" or Category == "Collectibles" then
						-- destroy trinket
						FoundItem.Value = math.clamp(FoundItem.Value-value, 0, math.huge)
					else
						FoundItem.Value = math.clamp(FoundItem.Value-value, 0, math.huge)
					end

					-- Adding to Total
					Total += (value*Price)
					TotalItems += value
				end

			else
				Remotes.Notify:FireClient(Player, "You cannot sell ["..name.."].", 4)
				return
			end
		end

		if Total > 0 then

			if not tonumber(TotalItems) then
				return
			end

			if TotalItems < 1 then
				return
			end



			TotalItems = math.floor(TotalItems+.5)

			if TotalItems~=TotalItems then
				return
			end


			PlayerData.Gold.Value += Total
			Remotes.Notify:FireClient(Player, "Successfully sold (x"..TotalItems..") items for $"..FormatNumber2.FormatLong(Total).."!", 5)

			Remotes.ClientFX:FireClient(Player, "Sound", {
				SoundName = "Cash",
				Parent = Player.Character.HumanoidRootPart
			})
		end
	end
end)
-- SELL PRIMARY WEAPON --
local equipmentModule = require(Modules.Shared.Equipment)
Remotes.SellWeapon.OnServerEvent:Connect(function(Player)
	local PlayerData = Player:FindFirstChild("Data")

	if PlayerData then
		local PrimaryWeapon = PlayerData.Weapon
		if PrimaryWeapon.Value == "Combat" then
			return
		end

		local ItemInfo = MarketItems[PrimaryWeapon.Value]
		if ItemInfo then
			
			equipmentModule.RemoveWeapon(Player)
			--PrimaryWeapon.Value = "Combat"
			PlayerData.Gold.Value += ItemInfo.Price

			Remotes.ClientFX:FireClient(Player, "Sound", {
				SoundName = "Cash",
				Parent = Player.Character.HumanoidRootPart
			})
		end
	end
end)

local CharacterTraits = require(Modules.Shared.CharacterTraits)

local function getRandomTrait()
	local RNG = Random.new();
	local Counter = 0;
	for i, v in pairs(CharacterTraits) do
		Counter += v
	end
	local Chosen = RNG:NextNumber(0, Counter);
	for i, v in pairs(CharacterTraits) do
		Counter -= v
		if Chosen > Counter then
			return i
		end
	end
	return nil
end
local function returnTrait(Folder)
	local newTrait = getRandomTrait()
	if Folder:FindFirstChild(newTrait) then
		warn(newTrait)
		return returnTrait(Folder)
	else
		return newTrait
	end
end

local MaxTraits = 5 -- Leave space for [Shards Heart] --50/10 -- MaxLevel/10
local function down(x, n) 
	return x - x % (n or 1)
end
local function GetTraitsChildren(Traits, ExcludeShardsHeart)
	local TraitsChildren = Traits:GetChildren()
	-- Removing from Pool
	if ExcludeShardsHeart then
		for i = 1, #TraitsChildren do
			if TraitsChildren[i].Name == "Shards Heart" then
				table.remove(TraitsChildren, i)
				break
			end
		end
	end
	--
	return TraitsChildren
end

Remotes.RerollGrace.OnServerEvent:Connect(function(Player)
	local PlayerData = Player:FindFirstChild("Data")

	if PlayerData then
		local Traits = PlayerData.Traits
		local PendingGraces = PlayerData.PendingGraces
		if PendingGraces.Active.Value then
			-- Active
			local FirstChoice = PendingGraces.FirstChoice
			local RerolledChoice = PendingGraces.RerolledChoice

			if RerolledChoice.Value == "" then
				-- Reroll
				local newTrait = returnTrait(Traits)
				if newTrait then
					RerolledChoice.Value = newTrait
					PendingGraces.CurrentChoice.Value = newTrait
				end			
			end
		end
	end
end)
Remotes.RevertGrace.OnServerEvent:Connect(function(Player)
	local PlayerData = Player:FindFirstChild("Data")

	if PlayerData then
		local Traits = PlayerData.Traits
		local PendingGraces = PlayerData.PendingGraces
		if PendingGraces.Active.Value then
			-- Active
			local FirstChoice = PendingGraces.FirstChoice
			local RerolledChoice = PendingGraces.RerolledChoice

			if RerolledChoice.Value ~= "" then
				-- Revert
				PendingGraces.CurrentChoice.Value = FirstChoice.Value
			end
		end
	end
end)
Remotes.SelectGrace.OnServerEvent:Connect(function(Player)
	local PlayerData = Player:FindFirstChild("Data")

	if PlayerData then
		local Traits = PlayerData.Traits
		local PendingGraces = PlayerData.PendingGraces
		if PendingGraces.Active.Value then
			-- Active
			PendingGraces.Active.Value = false

			local trait = PendingGraces.CurrentChoice.Value

			warn("Give Trait: ".. trait.." to ".. Player.Name..".")

			Remotes.Notify:FireClient(Player, "New trait! (".. trait..")", 7, {
				Sound = "NewTrait",
			})
			local newValue = Instance.new("BoolValue")
			newValue.Name = trait
			newValue.Value = true
			newValue.Parent = Traits			
			-- Resetting
			PendingGraces.FirstChoice.Value = ""
			PendingGraces.CurrentChoice.Value = ""
			PendingGraces.RerolledChoice.Value = ""

			-- Checking if Eligible for Another Grace

			ServerEvents.GiveTrait:Fire(Player)
		end
	end
end)
ServerEvents.GiveTrait.Event:Connect(function(Player: Player)
	local PlayerData = Player:FindFirstChild("Data")

	if PlayerData then
		local Traits = PlayerData.Traits
		local PendingGraces = PlayerData.PendingGraces
		local TraitsChildren = GetTraitsChildren(Traits, true)

		if #TraitsChildren >= MaxTraits then -- Max Traits
			return
		end

		local function func()
			local trait = returnTrait(Traits)
			if trait then

				-- Setting up
				PendingGraces.Active.Value = true
				PendingGraces.FirstChoice.Value = trait
				PendingGraces.CurrentChoice.Value = trait

				Remotes.Notify:FireClient(Player, "New Pending Grace!", 7, {
					Sound = "NewTrait",
				})

				--[[
				warn("Give Trait: ".. trait.." to ".. Player.Name..".")

				local newValue = Instance.new("BoolValue")
				newValue.Name = trait
				newValue.Value = true
				newValue.Parent = Traits

				]]
			end	
		end

		local CurrentLevel = PlayerData.Level
		local ShouldHaveTraits = (down(CurrentLevel.Value, 5))/5

		if ShouldHaveTraits >= 1 then		
			if ShouldHaveTraits ~= #GetTraitsChildren(Traits, true) and ShouldHaveTraits > #GetTraitsChildren(Traits, true) then
				for i = 1,ShouldHaveTraits-#GetTraitsChildren(Traits, true) do
					if #GetTraitsChildren(Traits, true) >= MaxTraits then -- Max Traits
						break
					end
					if PendingGraces.Active.Value then
						-- Already Active
						break
					end
					--
					func()
				end
			end
		end
	end
end)

-- Investor Perks --
ServerEvents.InvestorPerks.Event:Connect(function(Target)
	local PlayerData = Target:WaitForChild("Data")
	local GlobalData = Target:WaitForChild("GlobalData")

	--[[
	-- Example, SennkoDevs
	if Target.UserId == 3735646183 then
		PlayerData.Spins.Value += 30
		PlayerData.Gold.Value += 2000
	end
	]]--

	if Target.UserId == 135610201 then
		GlobalData.Spins.Value += 30
		PlayerData.Gold.Value += 3000
	end


	if Target.UserId == 18875743 then
		GlobalData.Spins.Value += 30
		PlayerData.Gold.Value += 3000
	end


	if Target.UserId == 124744244 then
		GlobalData.Spins.Value += 30
		PlayerData.Gold.Value += 3000
	end


	if Target.UserId == 128655180 then
		GlobalData.Spins.Value += 30
		PlayerData.Gold.Value += 3000
	end


	if Target.UserId == 213026677 then
		GlobalData.Spins.Value += 30
		PlayerData.Gold.Value += 3000
	end

	if Target.UserId == 2873187669 then
		GlobalData.Spins.Value += 30
		PlayerData.Gold.Value += 3000
	end


	if Target.UserId == 79921966 then
		GlobalData.Spins.Value += 30
		PlayerData.Gold.Value += 3000
	end


	if Target.UserId == 2289096803 then
		GlobalData.Spins.Value += 30
		PlayerData.Gold.Value += 3000
	end


	if Target.UserId == 128166700 then
		GlobalData.Spins.Value += 30
		PlayerData.Gold.Value += 3000
	end


	if Target.UserId == 311677665 then
		GlobalData.Spins.Value += 30
		PlayerData.Gold.Value += 3000
	end


	if Target.UserId == 185014259 then
		GlobalData.Spins.Value += 30
		PlayerData.Gold.Value += 3000
	end


	if Target.UserId == 169854316 then
		GlobalData.Spins.Value += 30
		PlayerData.Gold.Value += 3000
	end


	if Target.UserId == 2003839869 then
		GlobalData.Spins.Value += 30
		PlayerData.Gold.Value += 3000
	end


	if Target.UserId == 35314665 then
		GlobalData.Spins.Value += 30
		PlayerData.Gold.Value += 3000
	end


	if Target.UserId == 1063107349 then
		GlobalData.Spins.Value += 30
		PlayerData.Gold.Value += 3000
	end


	if Target.UserId == 646299746 then
		GlobalData.Spins.Value += 30
		PlayerData.Gold.Value += 3000
	end


	if Target.UserId == 115045092 then
		GlobalData.Spins.Value += 30
		PlayerData.Gold.Value += 3000
	end

	if Target.UserId == 115565314 then
		GlobalData.Spins.Value += 30
		PlayerData.Gold.Value += 3000
	end


	if Target.UserId == 115045092 then
		GlobalData.Spins.Value += 30
		PlayerData.Gold.Value += 3000
	end


	if Target.UserId == 2647263361 then
		GlobalData.Spins.Value += 30
		PlayerData.Gold.Value += 3000
	end


	if Target.UserId == 647928510 then
		GlobalData.Spins.Value += 30
		PlayerData.Gold.Value += 3000
	end

	if Target.UserId == 232439223 then
		GlobalData.Spins.Value += 30
		PlayerData.Gold.Value += 3000
	end

	if Target.UserId == 668374161 then
		GlobalData.Spins.Value += 30
		PlayerData.Gold.Value += 3000
	end

	if Target.UserId == 1020907312 then
		GlobalData.Spins.Value += 30
		PlayerData.Gold.Value += 3000
	end

	-- HIGH INVESTERS

	if Target.UserId == 2544937761 then
		GlobalData.Spins.Value += 60
		PlayerData.Gold.Value += 8000
	end

	if Target.UserId == 56933238 then
		GlobalData.Spins.Value += 60
		PlayerData.Gold.Value += 8000	end

	if Target.UserId == 318909126 then
		GlobalData.Spins.Value += 60
		PlayerData.Gold.Value += 8000
	end

	if Target.UserId == 35314665 then
		GlobalData.Spins.Value += 60
		PlayerData.Gold.Value += 8000
	end

	if Target.UserId == 2595189896 then
		GlobalData.Spins.Value += 60
		PlayerData.Gold.Value += 8000
	end

	if Target.UserId == 1456786055 then
		GlobalData.Spins.Value += 60
		PlayerData.Gold.Value += 8000
	end

	if Target.UserId == 2035692286 then
		GlobalData.Spins.Value += 60
		PlayerData.Gold.Value += 8000
	end

	if Target.UserId == 8716814 then
		GlobalData.Spins.Value += 60
		PlayerData.Gold.Value += 8000
	end



end)

-- Consume Lacrima --
local GraceCooldown = 3
ServerEvents.ConsumeGraceLacrima.Event:Connect(function(Player: Player)
	local PlayerData = Player:FindFirstChild("Data")

	if PlayerData then
		local FoundDebounce = Player:FindFirstChild("GraceLacrimaDebounce")
		if FoundDebounce then
			if (os.time() - FoundDebounce.Value) >= 3 then
				FoundDebounce:Destroy()
			else
				return
			end
		end

		local Collectibles = PlayerData:WaitForChild("Items").Trinkets
		local TraitsFolder = PlayerData:WaitForChild("Traits")

		if Collectibles["Grace Lacrima"].Value > 0 then

			local Character = Player.Character
			if not Character then
				return
			end

			local InfoModule = require(Character:WaitForChild("Handler").Input.Info)
			if InfoModule:StunCheck(Character, "Default") then
				return
			end

			Collectibles["Grace Lacrima"].Value = math.clamp(Collectibles["Grace Lacrima"].Value-1,0,math.huge)

			Remotes.ClientFX:FireAllClients("LacrimaConsume", {
				["Character"] = Player.Character
			})	

			-- Cooldown
			local LacrimaCooldown = Instance.new("IntValue")
			LacrimaCooldown.Name = "GraceLacrimaDebounce"
			LacrimaCooldown.Value = os.time()
			LacrimaCooldown.Parent = Player
			
			local AmountOfTraits = #TraitsFolder:GetChildren()
			for _,t in pairs(TraitsFolder:GetChildren()) do
				if t.Name == "Shards Heart" then
					AmountOfTraits -= 1
				end
			end
			-- Clearing all Children except [Shards Heart]
			for _,v in pairs(TraitsFolder:GetChildren()) do
				if v.Name ~= "Shards Heart" then
					v:Destroy()
				end
			end

			Remotes.Notify:FireClient(Player, "[Grace Lacrima] Consumed!", 5, {
				Sound = "DeathSound"
			})

			for i = 1,AmountOfTraits do
				local newTrait = returnTrait(TraitsFolder)
				if newTrait then
					local newValue = Instance.new("BoolValue")
					newValue.Name = newTrait
					newValue.Value = true
					newValue.Parent = TraitsFolder

					Remotes.Notify:FireClient(Player, "New Grace: ".. newTrait.."!", 5, {
						Sound = "NONE",
					})
				end
			end
		end

	end
end)

-- Reset --
Remotes.Reset.OnServerEvent:Connect(function(Player)
	local PlayerData = Player:FindFirstChild("Data")
	local Character = Player.Character

	if PlayerData and Character then
		local Head = Character:FindFirstChild("Head")
		local PreviousReset = PlayerData:FindFirstChild("PreviousReset")

		if PreviousReset and Head then
			local StatusFolder = Character:FindFirstChild("Status")
			if not StatusFolder then
				return
			end
			if Player:FindFirstChild("InCombat") then
				return
			end

			-- Checking Cooldown
			if os.time() - (PreviousReset.Value) < 20 then
				return -- Cooldown
			end
			if StatusFolder:FindFirstChild("IsResetting") then
				return
			end

			-- Add Resetting Value
			local value = Instance.new("Folder")
			value.Name = "IsResetting"
			value.Parent = StatusFolder

			local Clone = script.ResetTemplate:Clone()
			Clone.Parent = Head

			local TimePassed = 0
			local Max = 20

			Clone.TextLabel.Text = tostring(Max-TimePassed)

			local Connection
			Connection = game["Run Service"].Heartbeat:Connect(function(dt)
				if TimePassed >= Max then
					-- Reset
					Connection:Disconnect()
					Connection = nil

					Character:BreakJoints()
					PreviousReset.Value = os.time()
				elseif not Character:IsDescendantOf(workspace.Live) then
					Connection:Disconnect()
					Connection = nil
				elseif StatusFolder:FindFirstChild("Stunned") then
					Clone:Destroy()
					value:Destroy()
					PreviousReset.Value = os.time()
					Connection:Disconnect()
					Connection = nil
				else
					TimePassed += dt
					Clone.TextLabel.Text = tostring(Max-math.floor(TimePassed))
				end
			end)

		end
	end
end)
local serverService = game:GetService("ServerScriptService")
local clothingMod = require(ReplicatedStorage.Modules.Shared.Clothing)
local numberOn = 1
Remotes.Clothing.OnServerEvent:connect(function(player, action, num)
	local character = player.Character
	if action == "Start" then
	elseif action == "Forward" then
	elseif action == "Back" then
	elseif action == "Purchase" then
		local name, statTable, price = clothingMod.ReturnInformation(player, num)
		local characterData = character:FindFirstChild("Data")
		if player.Data:FindFirstChild("Gold").Value >= price then
			local currentClothing = player.Data:FindFirstChild("Clothing")
			if currentClothing.Value ~= name then
				player.Data:FindFirstChild("Gold").Value -= price
				local oldVariableTab = clothingMod:GetStatFromName(currentClothing.Value)
				local variableTab = clothingMod:GetStatFromName(name)

				for i,v in pairs(oldVariableTab) do
					for a,b in pairs(characterData.Bonuses:GetChildren()) do
						if i.Name == b.Name then
							b.Value -= v
						end
					end
				end

				for i,v in pairs(variableTab) do
					for a,b in pairs(characterData.Bonuses:GetChildren()) do
						if i.Name == b.Name then
							b.Value += v
						end
					end
				end

				--[[
				local shirt = ReplicatedStorage.Assets.Clothes:FindFirstChild(name).Shirt:clone()
				local pants = ReplicatedStorage.Assets.Clothes:FindFirstChild(name).Pants:clone()

				for i,v in pairs(character:GetChildren()) do
					if v:IsA("Shirt") or v:IsA("Pants") then
						v:Destroy()
					end
				end
				

				shirt.Parent = character
				pants.Parent = character
				]]
				player.Data:FindFirstChild("Clothing").Value = name

				Remotes.Notify:FireClient(player, "You have purchased "..name.."!", 4, {
					Sound = "Open Chest!"
				})
				Remotes.ClientFX:FireClient(player, "Sound", {
					SoundName = "Cash",
					Parent = character["HumanoidRootPart"]
				})


			else
				Remotes.Notify:FireClient(player, "You're already wearing "..name.."!", 4, {
					Sound = "Fail"
				})
			end

		else
			Remotes.Notify:FireClient(player, "Insufficient funds to purchase "..name.."!", 4, {
				Sound = "Fail"
			})
		end

	end
end)

--
Remotes.StarterJewels.OnServerEvent:Connect(function(Player)
	local PlayerData = Player:FindFirstChild("Data")
	if PlayerData then
		if PlayerData.StarterJewels.Value then
			return
		else
			-- Give
			PlayerData.StarterJewels.Value = true
			PlayerData.Gold.Value += 100
		end
	end
end)
