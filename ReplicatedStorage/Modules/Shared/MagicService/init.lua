-- Magic Service

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local Maid = require(Modules.Shared.Maid)
local ElementsModule = require(Modules.Shared.Elements)

local MagicService = {Data = {}}


local function GetSpellDataFromName(Name)
	for name,data in pairs(ElementsModule.Element) do
		for i = 1, #data do
			local _data = data[i]
			if _data.Name == Name then
				return _data
			end
		end
	end

	return nil
end

local function GetRaceSpellFromName(Name)
	for name,data in pairs(ElementsModule.Race) do
		for i = 1, #data do
			local _data = data[i]
			if _data.Name == Name then
				return _data
			end
		end
	end

	return nil
end

local function GetClanSpellFromName(Name)
	for name,data in pairs(ElementsModule.Clan) do
		for i = 1, #data do
			local _data = data[i]
			if _data.Name == Name then
				return _data
			end
		end
	end

	return nil
end
local function ValidateCreation(Player: Player, Tool: Tool)
	-- change later ig
	local PlayerData = Player:FindFirstChild("Data")
	if PlayerData then
		local CurrentElement = PlayerData.Element
		local EquippedSkills = PlayerData.EquippedSkills
		local Element_Level = PlayerData.Element_Level
		local playerLevel = PlayerData.Level
		local race = Player:FindFirstChild("Data")["Race"]
		local clan = Player:FindFirstChild("Data")["LastName"]
		local ElementFolder = script:FindFirstChild(CurrentElement.Value)
		local raceFolder = script:FindFirstChild(race.Value)
		local clanFolder = script:FindFirstChild(clan.Value)
		
		if ElementFolder and ElementFolder:FindFirstChild(Tool.Name) or raceFolder and raceFolder:FindFirstChild(Tool.Name) or clanFolder and clanFolder:FindFirstChild(Tool.Name) then
			local SpellData = GetSpellDataFromName(Tool.Name)
			local raceSpellData = GetRaceSpellFromName(Tool.Name)
			local clanSpellData = GetClanSpellFromName(Tool.Name)
			if SpellData then
				-- Checking if you have unlocked yet --
				if Element_Level.Value >= SpellData.Level then
					return true, {
						["SpellInfo"] = require(ElementFolder[Tool.Name]),
						-- add any data later
					}
				end				
			elseif raceSpellData then
				print(raceSpellData)
				if playerLevel.Value >= raceSpellData.Level then
					return true, {
						["SpellInfo"] = require(raceFolder[Tool.Name]),
						-- add any data later
					}
				end
			elseif clanSpellData then
				print(clanSpellData)
				if playerLevel.Value >= clanSpellData.Level then
					return true, {
						["SpellInfo"] = require(clanFolder[Tool.Name]),
						-- add any data later
					}
				end
			end
			
		else
			-- Checking if [Customs]
			local CustomsFolder = script:FindFirstChild("Customs")
			if CustomsFolder:FindFirstChild(Tool.Name) then
				return true, {
					["SpellInfo"] = require(CustomsFolder[Tool.Name]),
					-- add any data later
				}
			end
		end
	else
		
		return false
	end
	return false
end

function MagicService.fetch(Name: string)
	return MagicService.Data[Name]
end

function MagicService.new(Player: Player, Tool: Tool)
	local Character = Player.Character
	local StatusFolder = Character["Status"]
	if StatusFolder:FindFirstChild("NoMagic") then return end
	local CanCreate, TableData = ValidateCreation(Player, Tool)
	if CanCreate and TableData then
		local Connections = Maid.new()
		local Equipped = false
		local Mouse = Player:GetMouse()

		local SpellData = TableData.SpellInfo

		Connections["Equipped"] = Tool.Equipped:Connect(function()
			print("equip")
			Equipped = true
			
			if not Equipped then return end -- not equipped
			
			local PlayerData = Player:FindFirstChild("Data")
			if PlayerData then
				local PSettings = PlayerData.Settings
				if PSettings.InstantCast.Value then
					Remotes.Magic:InvokeServer("Start", {SpellName = Tool.Name, MouseHit = Mouse.Hit,})
					--[[
					task.spawn(function()
						while Equipped do
							Character.Humanoid:UnequipTools()
							-- Equipping CurrentWeapon
							local CharacterData = Character:FindFirstChild("Data")
							if CharacterData then
								local CurrentWeapon = CharacterData.CurrentWeapon
								local Backpack = Player:FindFirstChild("Backpack")
								if Backpack and Backpack:FindFirstChild(CurrentWeapon.Value) then
									Character.Humanoid:EquipTool(Backpack[CurrentWeapon.Value])
								end
							end
							task.wait()
						end
					end)
					]]
				end
			end
		end)
		Connections["Unequipped"] = Tool.Unequipped:Connect(function()
			print("unequip")
			Equipped = false
		end)

		local AlternateKeys = SpellData.configuration.AlternateKeys
		if AlternateKeys then
			Connections["UserInput"] = UserInputService.InputBegan:Connect(function(Input, Processed)
				
				if not Equipped then return end -- not equipped
				if Processed then return end
				local PlayerData = Player:FindFirstChild("Data")
				if PlayerData then
					local PSettings = PlayerData.Settings
					if PSettings.InstantCast.Value then
						return -- Instant Cast On
					end
				end

				if table.find(AlternateKeys, Input.KeyCode) then
					Remotes.Magic:InvokeServer("Start", {SpellName = Tool.Name, MouseHit = Mouse.Hit,
						["KeyPassed"] = Input.KeyCode
					})
				end
			end)	
		end

		Connections["Activated"] = Tool.Activated:Connect(function()
			--	print("holding")

			local Response = Remotes.Magic:InvokeServer("Start", {SpellName = Tool.Name, MouseHit = Mouse.Hit})
			--print(Response)
			if Response == "Success" then
				-- Checking Spell [Type] --
				if SpellData.configuration.Type == "HoldRelease" then
					while true do
						if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
							break
						end
						-- check if unequipped or destroyed
						task.wait()
					end
					--print("stopped holding")
				end
				if SpellData.configuration.Type == "Instant" then
					--print("nah we good dont need to hold")
				end
				--------------------------------
			end
		end)

		Connections["Destroyed"] = Tool.AncestryChanged:Connect(function(_, parent)
			if parent == nil then
				Connections:Destroy()
			end
		end)
	end
end


for _,spell in pairs(script:GetDescendants()) do
	if spell:IsA("ModuleScript") then
		MagicService.Data[spell.Name] = require(spell)
	end
end
return MagicService