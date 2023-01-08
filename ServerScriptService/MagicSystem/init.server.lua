-- Magic System

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CachedModules = {}
local Cooldowns = {}

local Modules = ReplicatedStorage.Modules
local Remotes = ReplicatedStorage.Remotes

local ElementsModule = require(Modules.Shared.Elements)
local MagicService = require(Modules.Shared.MagicService)

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

local function ValidateCreation(Player: Player, SpellName: string)
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
		if ElementFolder and ElementFolder:FindFirstChild(SpellName) or raceFolder and raceFolder:FindFirstChild(SpellName) or clanFolder and clanFolder:FindFirstChild(SpellName) then
			local SpellData = GetSpellDataFromName(SpellName)
			local raceSpellData = GetRaceSpellFromName(SpellName)
			local clanSpellData = GetClanSpellFromName(SpellName)
			if SpellData then
				-- Checking if you have unlocked yet --
				if Element_Level.Value >= SpellData.Level then
					local fetched = MagicService.fetch(SpellName)
					return true, fetched
				end			
			elseif raceSpellData then
				if raceSpellData then
					-- Checking if you have unlocked yet --
					if playerLevel.Value >= raceSpellData.Level then
						local fetched = MagicService.fetch(SpellName)
						return true, fetched
					end				
				end
			elseif clanSpellData then
				if clanSpellData then
					-- Checking if you have unlocked yet --
					if playerLevel.Value >= clanSpellData.Level then
						local fetched = MagicService.fetch(SpellName)
						return true, fetched
					end				
				end
			end
		else
			--
			-- Checking if [Customs]
			local CustomsFolder = script:FindFirstChild("Customs")
			if CustomsFolder:FindFirstChild(SpellName) then
				local fetched = MagicService.fetch(SpellName)
				return true, fetched
			end
		end
	end
	return false
end

-- PlayerAdded/Removed --
Players.PlayerAdded:Connect(function(Player)
	Cooldowns[Player.UserId] = {}
end)
Players.PlayerRemoving:Connect(function(Player)
	if Cooldowns[Player.UserId] then
		Cooldowns[Player.UserId] = nil
	end
end)

-- MagicEvent --
local function MagicEvent(Action, ...)
	local Arguments = {...}

	if Action == "ResetCooldowns" then
		local Index = Arguments[1]
		local Found = Cooldowns[Index]

		if Found then
			table.clear(Found)
		end
	end
	if Action == "RemoveCooldown" then
		local Index = Arguments[1]
		local Key = Arguments[2]

		local Found = Cooldowns[Index]
		if Found and Found[Key] then
			Found[Key] = nil
		end
	end
	if Action == "AddCooldown" then
		local Player = Arguments[1]
		local Index = Arguments[2]
		local Key = Arguments[3]
		local Duration = Arguments[4]
		local DisplayCooldown = Arguments[5]

		local Found = Cooldowns[Index]
		if Found then
			Found[Key] = os.clock()

			if DisplayCooldown == nil or DisplayCooldown ~= nil and DisplayCooldown == true then
				Remotes.Cooldown:FireClient(Player, Key, Duration)
			end
		end
	end

	-- Switch Tool --
	if Action == "SwitchTool" then
		--[[
		local Player = Arguments[1]
		local Character = Player.Character
		local CharacterData = Character:FindFirstChild("Data")
		local PlayerData = Player:FindFirstChild("Data")
		
		if CharacterData and PlayerData then
			local CurrentWeapon = PlayerData.Weapon
			if Player.Backpack:FindFirstChild(CurrentWeapon.Value) then
				Character.Humanoid:EquipTool(Player.Backpack[CurrentWeapon.Value])
			end
		end
		]]
	end

	-- Magic Circle
	if Action == "MagicCircle" then
		local RootCFrame = Arguments[2]
		local WeldObject = Arguments[1]
		local TweenTime = Arguments[3]
		local RotateSpeed = Arguments[4] or 0.01
		local HoldTime = Arguments[5] or 1
		local MagicType = Arguments[6] or "Default"
		local StartSize = Arguments[7] or Vector3.new(1,1,1)
		local MaxSize = Arguments[8] or Vector3.new(16,16,1)

		local MockPart = script.MagicCircleMock:Clone()
		MockPart.Name = "MagicCircleServer"

		MockPart.CFrame = RootCFrame

		if WeldObject == nil then
			MockPart.Anchored = true
		else
			MockPart.RootWeld.Part1 = WeldObject
		end


		local BaseCircle = game.ReplicatedStorage.Assets.MagicCircles[MagicType]
		for _,v in pairs(BaseCircle:GetChildren()) do
			if v:IsA("Decal") then
				local clone = v:Clone()
				clone.Parent = MockPart.Circle
			end
		end

		MockPart.Circle.Mesh.Scale = StartSize
		MockPart.Parent = workspace.Visuals

		game.TweenService:Create(MockPart.Circle.Mesh, TweenInfo.new(TweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Scale = MaxSize
		}):Play()


		task.delay(TweenTime + HoldTime, function()
			game.TweenService:Create(MockPart.Circle.Mesh, TweenInfo.new(.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Scale = Vector3.new(0,0,0)
			}):Play()
			task.wait(.5)
			MockPart:Destroy()
		end)

		task.spawn(function()
			while MockPart.Parent do
				MockPart.Weld.C1 = MockPart.Weld.C1 * CFrame.Angles(0,0,math.rad(4))
				task.wait(RotateSpeed)
			end
		end)

	end
end
script.MagicEvent.Event:Connect(MagicEvent)

-- Magic Func --
local function MagicFunc(Action, ...)
	local Arguments = {...}

	if Action == "CheckCooldown" then
		local Index = Arguments[1]
		local Key = Arguments[2]
		local Duration = Arguments[3]

		local Found = Cooldowns[Index]
		if Found and Found[Key] then
			if os.clock() - (Found[Key] or 0) < Duration then
				return true
			end
		end
		return false -- not on cooldown
	end
end
script.MagicFunc.OnInvoke = MagicFunc

---------------------
local GroundParams = RaycastParams.new()
GroundParams.FilterType = Enum.RaycastFilterType.Whitelist
GroundParams.FilterDescendantsInstances = {workspace.Place}

Remotes.Magic.OnServerInvoke = function(Player, Action, Data)
	print(Action)
	local PlayerData = Player:FindFirstChild("Data")
	local CharacterData = Player.Character:FindFirstChild("Data")
	local StatusFolder = Player.Character:FindFirstChild("Status")

	if Player:GetAttribute("DataLoaded") ~= true then
		return -- Not loaded
	end
	if not PlayerData then
		return
	end
	if not CharacterData then
		return
	end
	if not StatusFolder then
		return
	end
	local Mana = CharacterData:FindFirstChild("Mana")
	if not Mana then
		return
	end

	if Action == "Start" then
		
		local SpellName = Data.SpellName
		
		local CanCreate, SpellData = ValidateCreation(Player, SpellName)
		print(CanCreate, SpellData)
		--warn(CanCreate)

		if not CanCreate then
			return "Error"
		end

		local module = CachedModules[SpellName]
		--print(CachedModules)
		if module then
			print("got to magicservice1")
			--[[
			if MagicFunc("CheckCooldown", Player.UserId, SpellName, module.CooldownTime) then
				-- on cooldown
				return "Error"
			end
			]]--
			--print(SpellData)
			if Mana.Value < SpellData.configuration.ManaUsage then
				Remotes.MagicAlert:FireClient(Player, SpellData.configuration.ManaUsage)
				return "Error" -- not enough mana
			end
			if StatusFolder:FindFirstChild("Dead") then
				return "Error" -- died
			end
			
			if SpellData.configuration.BypassFreefall ~= nil and SpellData.configuration.BypassFreefall == true then -- Bypassed
				print("true?")
			else
				local RaycastResult = workspace:Raycast(Player.Character.HumanoidRootPart.Position, Vector3.new(0,-30,0), GroundParams)
				if not RaycastResult then
					return "Error" -- nothing
				end
			end
			
			local AlternateKeys = SpellData.configuration.AlternateKeys
			if AlternateKeys and Data.KeyPassed then
				if not table.find(AlternateKeys, Data.KeyPassed) then
					return "Error" -- invalid key alias
				end
			end
			if SpellData.configuration.IGNORE_STUN_CHECK ~= nil and SpellData.configuration.IGNORE_STUN_CHECK then
			else
				local ServerInfo = require(Player.Character.Handler.Input.Info)
				if ServerInfo:StunCheck(Player.Character, "Magic") then
					return "Error"
				end
			end

			task.spawn(function()
				print("activated")
				module.Activate(Player, Data)
			end)
		end		
		return "Success"
	end
	if Action == "Cast" then

	end
end

-- Caching Modules --
for _,module in pairs(script:GetDescendants()) do
	if module:IsA("ModuleScript") then
		CachedModules[module.Name] = require(module)
	end
end