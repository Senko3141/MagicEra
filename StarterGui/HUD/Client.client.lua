-- Client

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local MarketPlaceService = game:GetService("MarketplaceService")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Formulas = require(Modules.Shared.Formulas)
local SettingsInfo = require(Modules.Client.Settings)
local Rates = require(Modules.Shared.Rates)
local ElementInfo = require(Modules.Shared.Elements)
local NotifyGui = script.Parent.Parent:WaitForChild("Notifications")
local NotifyEvent = NotifyGui:WaitForChild("Notify")
local Sound = require(Modules.Client.Effects.Sound)
local Ranking = require(Modules.Shared.Ranks)
local Formulas = require(Modules.Shared.Formulas)
local Gamepasses = require(Modules.Shared.Gamepasses)
local QuestsModule = require(Modules.Shared.QuestsModule)

local Player = Players.LocalPlayer
repeat task.wait() until Player:GetAttribute("DataLoaded") == true

local Mouse = Player:GetMouse()
local PlayerData = Player:WaitForChild("Data")
local GlobalData = Player:WaitForChild("GlobalData")
local Leaderstats = Player:WaitForChild("leaderstats")
local QuestsFolder = PlayerData:WaitForChild("Quests")
local Traits = PlayerData:WaitForChild("Traits")

local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

local CharacterData = Character:WaitForChild("Data")
local PlayerSettings = PlayerData.Settings
local Mana = CharacterData:WaitForChild("Mana")
local Bonuses = CharacterData:WaitForChild("Bonuses")
local GuildsInGame = ReplicatedStorage:WaitForChild("GuildsInGame")
local TraitsModule = require(Modules.Shared.CharacterTraits)
local TimeModule = require(Modules.Shared.Time)
local EXP_Character_Bar = Character:WaitForChild("HumanoidRootPart"):WaitForChild("EXPBar")

local HUD = script.Parent
local MenuBlur = nil

local Root = HUD:WaitForChild("Root")

local PlayerName = Root.PlayerName
local Level = Root.Level
local Gold = Root.Gold

local Bars = Root.Bars
local HealthFrame = Bars.Health
local ManaFrame = Bars.Mana
--local EXPFrame = Bars.EXP
local HungerFrame = Bars.Hunger

local MenuFrame = Root.Menu
local Frames = Root.Frames

local ElementsFrame = Frames.Elements
local HelpFrame = Frames.Help
local SettingsFrame = Frames.Settings
local GamepassFrame = Frames.Gamepasses
local CodesFrame = Frames.Codes
local StatsFrame = Frames.Stats
local GuildFrame = Frames.Guild
local QuestsFrame = Frames.Quests
local ProfileFrame = Frames.Profile
local Tooltip = Root:WaitForChild("Tooltip")

local MenuOpen = false
local FrameOpen = nil
local ButtonToFrame = {
	[MenuFrame.Root.Element] = ElementsFrame,
	[MenuFrame.Root.Help] = HelpFrame,
	[MenuFrame.Root.Settings] = SettingsFrame,
	[MenuFrame.Root.Gamepasses] = GamepassFrame,
	[MenuFrame.Root.Stats] = StatsFrame,
	[MenuFrame.Root.Quests] = QuestsFrame,
	[MenuFrame.Root.Guild] = GuildFrame,
	[MenuFrame.Root.Codes] = CodesFrame,
	[MenuFrame.Root.Profile] = ProfileFrame
}

local function Format(Int)
	return string.format("%02i", Int)
end

local function convertToHMS(Seconds)
	local Minutes = (Seconds - Seconds%60)/60
	Seconds = Seconds - Minutes*60
	local Hours = (Minutes - Minutes%60)/60
	Minutes = Minutes - Hours*60
	return Format(Hours)..":"..Format(Minutes)..":"..Format(Seconds)
end

if Lighting:FindFirstChild("MenuBlur") then
	Lighting:FindFirstChild("MenuBlur"):Destroy()
end

-- Functions --
local function updateProfileFrame()
	for _,v in pairs(ProfileFrame.InfoTraits:GetChildren()) do
		if v:IsA("TextLabel") then
			v:Destroy()
		end
	end

	for _,t in pairs(Traits:GetChildren()) do
		if TraitsModule[t.Name] then
			local Clone = script.TraitTemplate:Clone()
			Clone.Name = t.Name
			Clone.Text = t.Name
			Clone.Parent = ProfileFrame.InfoTraits
		end
	end

	-- Date Joined
	ProfileFrame.Info.Element.Text = "Element: ".. PlayerData.Element.Value
	ProfileFrame.Info.Guild.Text = "Guild: ".. PlayerData.Guild.Value
	ProfileFrame.Info.Investment.Text = "Investment Points: ".. Formulas.GetInvestmentPoints(Player)
	ProfileFrame.Info.TrueInvestment.Text = "True Investment Points: ".. PlayerData.TrueInvestmentPoints.Value
	ProfileFrame.Info.Jewels.Text = "Jewels: ".. PlayerData.Gold.Value
	ProfileFrame.Info.Level.Text = "Level: ".. PlayerData.Level.Value
	ProfileFrame.Info.Gender.Text = "Gender: ".. PlayerData.Gender.Value
	ProfileFrame.Info.Race.Text = "Race: ".. PlayerData.Race.Value
	ProfileFrame.Info.Spins.Text = "Spins: ".. GlobalData.Spins.Value
	ProfileFrame.Info.Equipment.Text = "Equipment: ".. PlayerData.Equipment.Value
	ProfileFrame.Info.DoubleExperience.Text = "Double Experience Timer: ".. convertToHMS(PlayerData.DoubleExperienceTimer.Value)

	local dateJoined = os.date("*t", PlayerData.DateJoined.Value)
	-- formating
	dateJoined = "Date Joined: "..dateJoined.day.."/"..dateJoined.month.."/"..dateJoined.year
	ProfileFrame.Info.TimePlayed.Text = dateJoined
	--
end
local function displayQuestInfo(Data, ID)
	if Data == nil then
		-- reset
		QuestsFrame.Info.Info.Title.Text = "--"
		QuestsFrame.Info.Info.Rewards.Text = "--"
		QuestsFrame.Info.Info.ExtraInfo.Text = "--"
		QuestsFrame.Info.Info.Description.Text = "--"
	else
		QuestsFrame.Info.Info.Title.Text = "<u>"..Data.Name.."</u>"
		QuestsFrame.Info.Info.Description.Text = Data.Description

		-- Displaying Extra Info
		local ExtraInfo = Data.ExtraData
		local FinalExtraInfo = ""

		for name,value in pairs(ExtraInfo) do
			if FinalExtraInfo == "" then
				FinalExtraInfo = name..": "..value
			else
				FinalExtraInfo = FinalExtraInfo..", "..name..": "..value
			end
		end

		QuestsFrame.Info.Info.ExtraInfo.Text = FinalExtraInfo

		-- Displaying Rewards
		local Rewards = Data.Rewards
		local FinalRewards = ""

		for name,value in pairs(Rewards) do
			if FinalRewards == "" then
				FinalRewards = name..": "..value
			else
				FinalRewards = FinalRewards..", "..name..": "..value
			end
		end

		QuestsFrame.Info.Info.Rewards.Text = FinalRewards
		-- Updating Progress

		local FoundQuest = QuestsFolder:FindFirstChild(ID)
		if FoundQuest then
			QuestsFrame.Info.Info.Progress.Text = FoundQuest.Progress.Value.."/"..Data.MAX_PROGRESS
		end
	end
end

local PreviouslyDisplayed = nil
local function updateSelectedBorder()
	for _,v in pairs(QuestsFrame.Info.Quests.List:GetChildren()) do
		if v:IsA("Frame") and v:FindFirstChild("UIStroke") then
			v.UIStroke.Transparency = 1

			if v.Name == PreviouslyDisplayed then
				v.UIStroke.Transparency = 0
			end
		end
	end
end

local AlreadyPinned = nil

local function updateQuestsFrame()
	for _,f in pairs(QuestsFrame.Info.Quests.List:GetChildren()) do
		if f:IsA("Frame") then
			f:Destroy()
		end
	end
	for _,f in pairs(Root.PinnedQuest.Rewards.List:GetChildren()) do
		if f:IsA("TextLabel") then
			f:Destroy()
		end
	end
	displayQuestInfo(nil)
	Root.PinnedQuest.Visible = false

	local FoundPreviousDisplayed = false

	for _,quest in pairs(QuestsFolder:GetChildren()) do
		local QuestData = QuestsModule.GetQuestFromId(quest.Name)
		if QuestData then
			local Clone = script.QuestTemplate:Clone()
			Clone.Name = quest.Name
			Clone.Title.Text = QuestData.Name
			Clone.Parent = QuestsFrame.Info.Quests.List

			PreviouslyDisplayed = quest.Name
			displayQuestInfo(QuestData, quest.Name)
			updateSelectedBorder()

			Root.PinnedQuest.Visible = true
			Root.PinnedQuest.Title.Text = QuestData.Name

			-- Displaying Rewards
			local Rewards = QuestData.Rewards
			local FinalRewards = ""

			for name,value in pairs(Rewards) do
				if FinalRewards == "" then
					FinalRewards = name..": "..value
				else
					FinalRewards = FinalRewards..", "..name..": "..value
				end

				local clone = script.QuestProgress:Clone()
				clone.Text = "- ".. value.." ".. name
				clone.Parent = Root.PinnedQuest.Rewards.List
			end

			QuestsFrame.Info.Info.Rewards.Text = FinalRewards

			local FoundQuest = QuestsFolder:FindFirstChild(quest.Name)
			if FoundQuest then
				Root.PinnedQuest.Title.Text = QuestData.Name.." ["..FoundQuest.Progress.Value.."/"..QuestData.MAX_PROGRESS.."]"
			end

			-- Updating Previously Displayed Before Was Updated
			if PreviouslyDisplayed ~= nil and PreviouslyDisplayed == quest.Name then
				warn("??")
				displayQuestInfo(QuestData, quest.Name)
				FoundPreviousDisplayed = true

				-- update pinned quest
				Root.PinnedQuest.Visible = true
				Root.PinnedQuest.Title.Text = QuestData.Name

				local FoundQuest = QuestsFolder:FindFirstChild(quest.Name)
				if FoundQuest then
					Root.PinnedQuest.Title.Text = QuestData.Name.." ["..FoundQuest.Progress.Value.."/"..QuestData.MAX_PROGRESS.."]"
				end

			end
			--
		end

		if not FoundPreviousDisplayed then
			PreviouslyDisplayed = nil
			Root.PinnedQuest.Visible = false
		end
	end
	updateSelectedBorder()
end





-- Cancel Button Quests
QuestsFrame.Info.Info.Cancel.Main.MouseButton1Click:Connect(function()
	if PreviouslyDisplayed ~= nil and FrameOpen == QuestsFrame and QuestsFolder:FindFirstChild(PreviouslyDisplayed) then
		print("Cancel Quest ".. PreviouslyDisplayed)
		Remotes.Quest:FireServer("Cancel", {
			["Name"] = PreviouslyDisplayed
		})
	end
end)


local CurrentStatePage = 1
local function updateStatsInfoFrame()
	-- Updating Info Frame --

	-- Damage
	local Damage = Formulas.GetDamage(Player, 0, {})
	local BonusDamage = Bonuses.Strength.Value
	Damage -= BonusDamage
	StatsFrame.Info.List["1"].Title.Text = "Damage: ".. tostring(Damage).. " (+"..BonusDamage..")"

	-- Health
	local MaxHealth = Formulas.GetMaxHealth(Player)
	local BonusHealth = Bonuses.Defense.Value
	StatsFrame.Info.List["2"].Title.Text = "MaxHealth: ".. tostring(MaxHealth).. " (+"..BonusHealth..")"

	-- Speed
	local Walkspeed = Formulas.GetDefaultWalkspeed(Player)
	local BonusSpeed = Bonuses.Agility.Value
	StatsFrame.Info.List["3"].Title.Text = "Speed: ".. tostring(Walkspeed).. " (+"..BonusSpeed..")"

	-- Mana
	local Max_Mana = Formulas.GetMaxMana(Player)
	local BonusMana = Bonuses.Mana.Value
	StatsFrame.Info.List["4"].Title.Text = "MaxMana: ".. tostring(Max_Mana).. " (+"..BonusMana..")"

	-- Magic Damage
	local MagicDamage = Formulas.GetDamage(Player, 0, {
		SkillType = "None", -- simulate actual damage thing
	})
	local BonusMD = Bonuses["Magic Power"].Value
	StatsFrame.Info.List["5"].Title.Text = "Magic Damage: ".. tostring(MagicDamage).. " (+"..BonusMD..")"
end
local function updateStatsFrame()
	local InvestmentPoints = Formulas.GetInvestmentPoints(Player)
	local StatsFolder = PlayerData:FindFirstChild("Stats")

	if not StatsFolder then return end


	if CurrentStatePage == 1 then
		StatsFrame.TurnPage.Main.Text = "TURN PAGE >"
		StatsFrame.List.Visible = true
		StatsFrame.Info.Visible = false
	end
	if CurrentStatePage == 2 then
		StatsFrame.TurnPage.Main.Text = "BACK PAGE <"
		StatsFrame.List.Visible = false
		StatsFrame.Info.Visible = true
	end

	updateStatsInfoFrame()

	-- Notifying --
	if InvestmentPoints > 0 then
		MenuFrame.Root.Stats.Notif.Visible = true
	else
		MenuFrame.Root.Stats.Notif.Visible = false
	end
	-----------

	if PlayerData.TrueInvestmentPoints.Value > 0 then
		StatsFrame.Points.Text = "Investment Points: ".. InvestmentPoints.. " <font color='rgb(255, 192, 32)'>(".. PlayerData.TrueInvestmentPoints.Value..")</font>"
	else
		StatsFrame.Points.Text = "Investment Points: ".. InvestmentPoints
	end
	-----------
	if PlayerData.TrueInvestmentPoints.Value > 0 then
		-- make add visible
		for _,v in pairs(StatsFrame.List.List:GetChildren()) do
			local statName = Formulas.StatsOrder[tonumber(v.Name)]
			if statName then
				local AddButton = v:FindFirstChild("Add")
				if AddButton then
					AddButton.Visible = true
				end
			end
		end
	else
		for _,v in pairs(StatsFrame.List.List:GetChildren()) do
			local AddButton = v:FindFirstChild("Add")
			if AddButton then
				AddButton.Visible = false
			end
		end
	end

	for i = 1, #Formulas.StatsOrder do
		local stat_name = Formulas.StatsOrder[i]
		StatsFrame.List.List[tostring(i)].Title.Text = stat_name.." (".. StatsFolder[stat_name].Value.."/".. Formulas.MaxStatPoints..")"
	end

end
local function updateElementFrame()
	local current_element = PlayerData.Element
	local element_data = ElementInfo.Element[current_element.Value]

	if element_data then
		for i = 1,4 do
			local skill_data = element_data[i]
			local coress_frame = ElementsFrame.Moves.List[tostring(i)]
			coress_frame.Title:SetAttribute("MagicName", "None")

			local function unlock_gui()
				coress_frame.Locked.Visible = false
				coress_frame.Equip.Visible = true
				coress_frame.Unequip.Visible = false
			end
			local function lock_gui()
				coress_frame.Locked.Visible = true
				-- locked
				coress_frame.Equip.Visible = false
				coress_frame.Unequip.Visible = false
			end

			if not skill_data then
				coress_frame.Title.Text = "- NONE -"
				coress_frame.Title:SetAttribute("MagicName", "None")
				-- lock gui, no data
				lock_gui()
				--
				continue
			end
			coress_frame.Title.Text = skill_data.Name.. " (LVL. ".. tostring(skill_data.Level)..")"
			coress_frame.Title:SetAttribute("MagicName", skill_data.Name)

			-- checking if unlocked
			local unlocked = (PlayerData.Element_Level.Value >= skill_data.Level and true) or false

			if unlocked then
				unlock_gui()

				local equipped_skills = PlayerData:FindFirstChild("EquippedSkills")
				if equipped_skills then

					local is_equipped = equipped_skills[tostring(i)]
					if is_equipped.Value then
						-- equipped
						coress_frame.Equip.Visible = false
						coress_frame.Unequip.Visible = true
					else
						-- not equipped
						coress_frame.Equip.Visible = true
						coress_frame.Unequip.Visible = false
					end

				else
					lock_gui()
				end
			else
				lock_gui()
			end	
		end
	end
end

-- guild gui --


-- UPDATE FUNCTIONS --
local UpdateFunctions = {}
UpdateFunctions.PlayerName = function()
	local rank = Ranking:GetRankFromLevel(PlayerData.Level.Value)

	local rankColor = Ranking:GetData(rank).Color
	local strColor = math.floor(rankColor.R*255)..","..math.floor(rankColor.G*255)..","..math.floor(rankColor.B*255)

	local formatted = "<FirstName> <LastName> (<font color='FONT_COLOR'>RANK-Class</font>)"
	formatted = string.gsub(formatted, "<FirstName>", PlayerData.FirstName.Value)
	formatted = string.gsub(formatted, "<LastName>", PlayerData.LastName.Value)

	formatted = string.gsub(formatted, "FONT_COLOR", "rgb("..strColor..")")
	formatted = string.gsub(formatted, "RANK", rank)

	PlayerName.Text = formatted
end
local previousEXPChange = os.clock()
UpdateFunctions.Experience = function()
	local MaxEXP = Formulas.GetMaxExperience(PlayerData.Level.Value)

	previousEXPChange = os.clock()

	EXP_Character_Bar.Main:TweenPosition(UDim2.new(0,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
	TweenService:Create(EXP_Character_Bar.Main.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Offset = Vector2.new(0, -(1-PlayerData.Experience.Value/MaxEXP))
	}):Play()

	local amountThing = math.floor((PlayerData.Experience.Value/MaxEXP)*100)
	--amountThing = string.format("%0.1f", amountThing)

	EXP_Character_Bar.Main.Amount.Text = amountThing.."%"

	task.delay(2, function()
		if os.clock() - (previousEXPChange) >= 1 then
			-- tween out
			EXP_Character_Bar.Main:TweenPosition(UDim2.new(2,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.5, true)
		end
	end)

	--EXPFrame.Main:TweenSize(UDim2.new(PlayerData.Experience.Value/MaxEXP,0,1,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
	--Root.LevelEXP.Text = PlayerData.Experience.Value.."/"..MaxEXP
end
UpdateFunctions.Level = function()
	Level.Text = "Level: ".. PlayerData.Level.Value
	UpdateFunctions.PlayerName()
	UpdateFunctions.Experience()
	updateStatsFrame()
end
UpdateFunctions.Health = function()
	--	HealthFrame.Info.Text = math.floor(Humanoid.Health).."/"..Humanoid.MaxHealth
	local perc = (Humanoid.Health/Humanoid.MaxHealth)

	HealthFrame.Main:TweenSize(UDim2.new(perc,0,1,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)	
end
UpdateFunctions.Element = function()
	if Rates.Elements[PlayerData.Element.Value] then
		ElementsFrame.Element.Text = PlayerData.Element.Value
		ElementsFrame.Element.TextColor3 = Rates.CategoryToColor[Rates.Elements[PlayerData.Element.Value]]

		updateElementFrame()
	end
end
UpdateFunctions.Hunger = function()
	--[[
	HungerFrame.Main:TweenSizeAndPosition(
		UDim2.new(math.clamp(PlayerData.Hunger.Value/100,0,.97),0,.15,0),
		UDim2.new(0.018,0,0.42,0),
		Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true
	)
	]] 

	HungerFrame.Main:TweenSize(UDim2.new(PlayerData.Hunger.Value/100,0,1,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
end
UpdateFunctions.ElementExperience = function()
	local MaxEXP = Formulas.GetMaxElementExperience(PlayerData.Element_Level.Value)
	ElementsFrame.EXP.Main:TweenSize(UDim2.new(PlayerData.Element_Experience.Value/MaxEXP,0,1,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
	ElementsFrame.EXP.Info.Text = PlayerData.Element_Experience.Value.."/"..MaxEXP

	updateElementFrame()
end
UpdateFunctions.ElementLevel = function(Passed)
	ElementsFrame.Level.Text = "Magic Level: "..PlayerData.Element_Level.Value
	UpdateFunctions.ElementExperience()

	-- check level, and unlocking tool notify
	local element_data = ElementInfo.Element[PlayerData.Element.Value]
	if element_data then
		task.spawn(function()
			local JustUpdating = false
			local s,e = pcall(function()
				local t = Passed.JustUpdating
			end)
			if s then
				JustUpdating = true
			end

			for i = 1,#element_data do
				local d = element_data[i]
				if PlayerData.Element_Level.Value == d.Level and not JustUpdating then
					-- notify, unlocked
					NotifyEvent:Fire('<font color="rgb(191, 64, 191)">[UNLOCKED MAGIC]</font> You have unlocked the magic skill: '.. d.Name..".", 6)
				end
			end		
		end)
	end

	task.spawn(function()
		updateElementFrame()
	end)
end
UpdateFunctions.Mana = function(Passed)
	--[[
	ManaFrame.Main:TweenSizeAndPosition(
		UDim2.new(Mana.Value/Formulas.GetMaxMana(Player),0,.32,0),
		UDim2.new(0,0,0.24,0),
		Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true
	)
	]]

	ManaFrame.Main:TweenSize(UDim2.new(Mana.Value/Formulas.GetMaxMana(Player),0,1,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
	--ManaFrame.Info.Text = math.floor(Mana.Value).."/"..Formulas.GetMaxMana(Player)
end
UpdateFunctions.Gold = function()
	Gold.Text = "Jewels : ".. tostring(PlayerData.Gold.Value)
end

UpdateFunctions.All = function()
	for name,func in pairs(UpdateFunctions) do
		if name ~= "All" then
			func({JustUpdating = true})
		end
	end
end

-- Buttons

for _,button in pairs(MenuFrame.Root:GetChildren()) do
	if button:IsA("TextButton") then
		button.MouseEnter:Connect(function()
			--	button:TweenPosition(UDim2.new(button.Position.X.Scale,0,0.4,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			button:TweenSize(UDim2.new(1,0,0.12,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			Sound({
				SoundName = "MouseHover",
				Parent = script.Parent.Parent.Effects
			})	
		end)
		button.MouseLeave:Connect(function()
			-- button:TweenPosition(UDim2.new(button.Position.X.Scale,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			button:TweenSize(UDim2.new(0.9,0,0.08,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)	
		end)
		button.MouseButton1Click:Connect(function()
			Sound({
				SoundName = "Click",
				Parent = script.Parent.Parent.Effects
			})

			if FrameOpen == ButtonToFrame[button] then
				-- toggle frame
				FrameOpen:TweenPosition(UDim2.new(0.5,0,-0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
				FrameOpen = nil

				-- tween back to center
				MenuFrame:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
				return
			end

			if ButtonToFrame[button] then

				if FrameOpen ~= nil then
					FrameOpen:TweenPosition(UDim2.new(0.5,0,-0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
					FrameOpen = nil
				end

				FrameOpen = ButtonToFrame[button]
				ButtonToFrame[button]:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)

				--
				if FrameOpen.Name == "Profile" then
					updateProfileFrame()
				end
				--

				if button.Name == "Quests" then
					MenuFrame:TweenPosition(UDim2.new(0.2,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
				elseif button.Name == "Gamepasses" then
					MenuFrame:TweenPosition(UDim2.new(0.15,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
				else
					MenuFrame:TweenPosition(UDim2.new(0.3,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
				end
			end
		end)
	end
end

local function InputBegan(Input, Processed)
	if Processed then return end

	if Input.KeyCode == Enum.KeyCode.M then
		MenuOpen = not MenuOpen
		Sound({
			SoundName = "MenuOpen",
			Parent = script.Parent.Parent.Effects
		})	
		if MenuOpen then
			MenuFrame.Root:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)

			MenuBlur = Instance.new("BlurEffect")
			MenuBlur.Size = 15
			MenuBlur.Parent = Lighting
			MenuBlur.Name = "MenuBlur"
			MenuBlur:SetAttribute("GameBlurEffect", true)
		else
			MenuFrame:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			MenuFrame.Root:TweenPosition(UDim2.new(0.5,0,-1,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			if MenuBlur then
				Debris:AddItem(MenuBlur, 0)
			end

			if FrameOpen ~= nil then
				FrameOpen:TweenPosition(UDim2.new(0.5,0,-0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
				FrameOpen = nil
			end

		end
	end
end

UserInputService.InputBegan:Connect(InputBegan)
PlayerData.Level.Changed:Connect(function()
	UpdateFunctions.Level()
end)
PlayerData.Experience.Changed:Connect(function()
	UpdateFunctions.Experience()
end)
Humanoid.HealthChanged:Connect(function(Health)
	UpdateFunctions.Health()
end)
PlayerData.Element.Changed:Connect(function()
	UpdateFunctions.Element()
end)
PlayerData.Element_Level.Changed:Connect(function()
	UpdateFunctions.ElementLevel()
	UpdateFunctions.Mana()
end)
PlayerData.Element_Experience.Changed:Connect(function()
	UpdateFunctions.ElementExperience()
	UpdateFunctions.Mana()
end)
Mana.Changed:Connect(function()
	UpdateFunctions.Mana()
end)
PlayerData.Gold.Changed:Connect(function()
	UpdateFunctions.Gold()
end)
PlayerData.Hunger.Changed:Connect(function()
	UpdateFunctions.Hunger()
end)
PlayerData.FirstName.Changed:Connect(function()
	UpdateFunctions.PlayerName()
end)
PlayerData.LastName.Changed:Connect(function()
	UpdateFunctions.PlayerName()
end)

UpdateFunctions.All()
-- Settings Toggle Buttons
local ClickCooldown = .5
for _,frame in pairs(SettingsFrame.Info.List:GetChildren()) do
	if frame:IsA("ImageLabel") then
		local toggleFrame = frame:FindFirstChild("Toggle")
		local settingName = frame.Name
		local correspondingFunc = SettingsInfo[settingName]

		local Info = SettingsInfo.ButtonInfo[settingName]

		if toggleFrame and Info and correspondingFunc then
			-- set to previous states

			Info.AwaitingResult = false -- reset

			local function updateToggled()
				local finalPos = UDim2.new()
				if PlayerSettings[settingName].Value then
					finalPos = UDim2.new(0.85,0,0.47,0)
					-- change color
					toggleFrame.ImageColor3 = Color3.fromRGB(82, 255, 74)
					--toggleFrame.Button.Text = "ON"
				else
					finalPos = UDim2.new(0.15,0,0.47,0)
					-- change color
					toggleFrame.ImageColor3 = Color3.fromRGB(255,71,74)
					--toggleFrame.Button.Text = "OFF"
				end
				toggleFrame.Button:TweenPosition(finalPos, Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
			end
			updateToggled()

			toggleFrame.Button.MouseButton1Click:Connect(function()
				if Info.AwaitingResult then return end

				if os.clock() - (Info.Time or 0) > ClickCooldown then
					Sound({
						SoundName = "Click",
						Parent = script.Parent.Parent.Effects
					})
					if not PlayerSettings:FindFirstChild(settingName) then
						return
					end
					Info.Time = os.clock()
					Info.AwaitingResult = true

					local ServerResult = Remotes.UpdateSetting:InvokeServer(settingName, not PlayerSettings[settingName].Value)
					if ServerResult == "Success" then
						-- tween
						updateToggled()

						local result = correspondingFunc(PlayerSettings[settingName].Value)
						if result == "Success" then
							Info.AwaitingResult = false
						end
					else
						Info.AwaitingResult = false
					end
				end
			end)
		end
	end
end
-- Elements Equip and Unequip --
local IsProcessing = false

local function IsASkill(skill_name)
	local current_element = PlayerData.Element.Value

	local element_data = ElementInfo.Element[current_element]
	if element_data then
		for i = 1, #element_data do
			local d = element_data[i]
			if d.Name == skill_name then
				return true, d
			end
		end
	end

	return false
end

for _,frame in pairs(ElementsFrame.Moves.List:GetChildren()) do
	if frame and frame:FindFirstChild("Equip") and frame:FindFirstChild("Unequip") then
		frame.Equip.Main.MouseButton1Click:Connect(function()					
			if IsProcessing then return end
			if frame.Title:GetAttribute("MagicName") == "None" then
				return
			end

			Sound({
				SoundName = "Click",
				Parent = script.Parent.Parent.Effects
			})
			local skill_name = frame.Title:GetAttribute("MagicName")

			local is_skill = IsASkill(skill_name)
			if is_skill and not PlayerData.EquippedSkills[tostring(frame.Name)].Value then -- is a skill and not equipped
				print("equip")
				IsProcessing = true
				local response = Remotes.EquipMagic:InvokeServer("Equip", {Name = skill_name})
				if response == "Success" then
					updateElementFrame()
				end
				task.wait(.1)
				IsProcessing = false
			end			
		end)
		frame.Unequip.Main.MouseButton1Click:Connect(function()
			if IsProcessing then return end
			if frame.Title:GetAttribute("MagicName") == "None" then
				return
			end

			Sound({
				SoundName = "Click",
				Parent = script.Parent.Parent.Effects
			})
			local skill_name = frame.Title:GetAttribute("MagicName")

			local is_skill = IsASkill(skill_name)
			if is_skill and PlayerData.EquippedSkills[tostring(frame.Name)].Value then -- is a skill and not equipped
				print("unequip")
				IsProcessing = true
				local response = Remotes.EquipMagic:InvokeServer("Unequip", {Name = skill_name})
				if response == "Success" then
					updateElementFrame()
				end
				task.wait(.1)
				IsProcessing = false
			end						
		end)
		frame.Title.MouseEnter:Connect(function()
			Tooltip.Visible = true

			local magic_name = frame.Title:GetAttribute("MagicName")
			local is_skill, skill_data = IsASkill(magic_name)

			if is_skill and skill_data ~= nil then
				Tooltip.Text = skill_data.Description
			else
				Tooltip.Text = "No Description"
			end
		end)
		frame.Title.MouseLeave:Connect(function()
			Tooltip.Visible = false
		end)
	end
end

Mouse.Move:Connect(function()
	if Tooltip.Visible then
		Tooltip.Position = UDim2.new(0, Mouse.X+10, 0, Mouse.Y+5)
	end
end)

-- Detecting Equip/Unequip Changes --
for _,equipped in pairs(PlayerData.EquippedSkills:GetChildren()) do
	equipped.Changed:Connect(function()
		updateElementFrame()
	end)
end
-- Investment Points --


StatsFrame.TurnPage.Main.MouseButton1Click:Connect(function()
	if CurrentStatePage == 2 then
		CurrentStatePage = 1
	elseif CurrentStatePage == 1 then
		CurrentStatePage = 2
	end

	updateStatsFrame()
end)

for _,stat in pairs(PlayerData:WaitForChild("Stats"):GetChildren()) do
	stat.Changed:Connect(function()
		updateStatsFrame()
	end)
end
for _,statObject in pairs(StatsFrame.List.List:GetChildren()) do
	if statObject:IsA("Frame") and statObject:FindFirstChild("Add") then
		local add_button = statObject.Add
		local holdingButton = false

		add_button.MouseButton1Down:Connect(function()
			local InvestmentPoints = PlayerData.TrueInvestmentPoints
			if InvestmentPoints.Value > 0 then
				holdingButton = true
				print("Attempt to add investment points to ".. statObject.Title.Text..".")

				while holdingButton do
					local points = InvestmentPoints.Value
					if points <= 0 then
						break
					end
					Remotes.Stats:FireServer("AddPoint", Formulas.StatsOrder[tonumber(statObject.Name)])
					task.wait(.1)
				end
			end
			--NotifyEvent:Fire("disabled for now", 1)
		end)
		add_button.MouseButton1Up:Connect(function()
			holdingButton = false
		end)
		add_button.MouseLeave:Connect(function()
			holdingButton = false
		end)
	end
end
PlayerData.TrueInvestmentPoints.Changed:Connect(function()
	updateStatsFrame()
end)

-- Gamepasses
local function UpdateGamepasses()
	-- Clearing
	for _,v in pairs(GamepassFrame.Info:GetChildren()) do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end
	----
	for id,data in pairs(Gamepasses.Gamepasses) do
		if data.IgnoreInMain then
			continue
		end

		local Clone = script.PassTemplate:Clone()
		Clone.Name = id
		Clone.Title.Text = data.Name

		local GamepassInfo = nil
		if data.Type == "DevProduct" then
			GamepassInfo = MarketPlaceService:GetProductInfo(id, Enum.InfoType.Product)
		end
		if data.Type == "Gamepass" then
			GamepassInfo = MarketPlaceService:GetProductInfo(id, Enum.InfoType.GamePass)
		end

		local Price = GamepassInfo.PriceInRobux
		local ProductDescription = GamepassInfo.Description or data.Description or "No Description"

		Clone.Purchase.Main.Text = "Purchase (R$".. Price.. ")"
		Clone.Parent = GamepassFrame.Info

		Clone.Purchase.Main.MouseButton1Click:Connect(function()
			if data.Type == "DevProduct" then
				MarketPlaceService:PromptProductPurchase(Player, id)
			end
			if data.Type == "Gamepass" then
				MarketPlaceService:PromptGamePassPurchase(Player, id)
			end
		end)
		-- Hovering
		Clone.Title.MouseEnter:Connect(function()
			Tooltip.Text = ProductDescription
			Tooltip.Visible = true

			if data.Name == "Reroll Last Name" then
				Root.LastNames.Visible = true
			end
		end)
		Clone.Title.MouseLeave:Connect(function()
			Tooltip.Text = "No Description"
			Tooltip.Visible = false

			if data.Name == "Reroll Last Name" then
				Root.LastNames.Visible = false
			end
		end)
	end
end
UpdateGamepasses()

-- Resetting Stat Points --
StatsFrame.Reset.Main.MouseButton1Click:Connect(function()
	-- can always reset for testing
	MarketPlaceService:PromptProductPurchase(Player, 1256825783)
end)

updateStatsFrame()

updateQuestsFrame()

Remotes.Quest.OnClientEvent:Connect(function(Action)
	if Action == "UpdateGui" then
		updateQuestsFrame()
	end
end)
Remotes.MagicAlert.OnClientEvent:Connect(function(Needed)
	local NotEnough = script.NotEnough:Clone()
	NotEnough.Parent = ManaFrame

	Debris:AddItem(NotEnough, 1)

	NotEnough.Size = UDim2.new(Needed/Formulas.GetMaxMana(Player),0,1,0)
	TweenService:Create(NotEnough, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0
	}):Play()
	task.wait(.5)
	TweenService:Create(NotEnough, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1
	}):Play()
end)

--[[
QuestsFolder.ChildAdded:Connect(function(Child)
	updateQuestsFrame()
end)
QuestsFolder.ChildRemoved:Connect(function(Child)
	updateQuestsFrame()
end)
]]--

-- GUILD STUFF --
local function getRGB(str)
	local splitted = str:split(",")

	local r = splitted[1]
	local g = splitted[2]
	local b = splitted[3]

	if tonumber(r) and tonumber(g) and tostring(b) then
		local toRGB = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
		if toRGB then
			return toRGB
		end
	end
	return nil
end
local function updateGuildFrame()
	local FoundGuild = GuildsInGame:FindFirstChild(PlayerData.Guild.Value)
	if FoundGuild then
		local FounderName = Players:GetNameFromUserIdAsync(FoundGuild.Founder.Value)

		GuildFrame.GuildName.Text = FoundGuild.Name
		GuildFrame.Owner.Text = "Owner: ".. FounderName
		-- Color
		GuildFrame.ColorVisual.BackgroundColor3 = getRGB(FoundGuild.GuildColor.Value)

		local Members = FoundGuild.Members

		-- Clearing Children
		for _,v in pairs(GuildFrame.List:GetChildren()) do
			if v:IsA("Frame") then
				local MemberID = Players:GetUserIdFromNameAsync(v.Name)
				if not Members:FindFirstChild(tostring(MemberID)) then
					v:Destroy()
				end
				if not MemberID then
					v:Destroy()
				end
			end
		end

		if not GuildFrame.List:FindFirstChild(FounderName) then
			-- Not in the List yet
			local OwnerClone = script.GuildMemberTemplate:Clone()
			OwnerClone.Name = FounderName

			OwnerClone.MemberName.TextColor3 = Color3.fromRGB(255, 202, 43)
			OwnerClone.MemberName.Text = FounderName..": Founder"

			OwnerClone.Parent = GuildFrame.List

			-- Checking if Founder IsInGame
			OwnerClone.Kick.Visible = false
			if Players:FindFirstChild(FounderName) then
				-- Yes
				OwnerClone.Kick.Visible = true
				OwnerClone.Kick.Text = "IN-GAME"
				OwnerClone.Kick.BackgroundColor3 = Color3.fromRGB(56, 226, 56)
			end
		end

		if GuildFrame.List:FindFirstChild(FounderName) then
			-- updating
			local OwnerClone = GuildFrame.List[FounderName]
			if Players:FindFirstChild(FounderName) then
				-- Yes
				OwnerClone.Kick.Visible = true
				OwnerClone.Kick.Text = "IN-GAME"
				OwnerClone.Kick.BackgroundColor3 = Color3.fromRGB(56, 226, 56)
			else
				-- not in game
				OwnerClone.Kick.Visible = true
				OwnerClone.Kick.BackgroundColor3 = Color3.fromRGB(139, 139, 139)
				OwnerClone.Kick.Text = "NOT IN SERVER"
			end
		end

		local IsFounder = (Player.UserId == FoundGuild.Founder.Value) and true or false
		if IsFounder then
			GuildFrame.Disband.Text = "DISBAND GUILD"
		else
			GuildFrame.Disband.Text = "LEAVE GUILD"
		end

		for _,member in pairs(Members:GetChildren()) do
			if tonumber(member.Name) ~= FoundGuild.Founder.Value then -- Ignoring Owner
				local memberName = Players:GetNameFromUserIdAsync(tonumber(member.Name))
				if memberName then
					if not GuildFrame.List:FindFirstChild(memberName) then
						warn("??")
						-- Not in the List
						local Clone = script.GuildMemberTemplate:Clone()

						Clone.Name = memberName
						if memberName == Player.Name then
							-- is the LocalPlayer
							Clone.MemberName.Text = memberName..": Member (YOU)"
						else
							Clone.MemberName.Text = memberName..": Member"
						end

						Clone.Parent = GuildFrame.List

						local IsInGame = false
						if Players:FindFirstChild(memberName) then
							IsInGame = true
						end

						-- Kick Visibility
						if IsFounder then
							if IsInGame then							
								if Clone.Name ~= FounderName then
									-- not the founder
									Clone.Kick.Text = "KICK"
								else
									Clone.Kick.Text = "IN-GAME"
									Clone.Kick.BackgroundColor3 = Color3.fromRGB(56, 226, 56)
								end
							else
								Clone.Kick.BackgroundColor3 = Color3.fromRGB(139, 139, 139)
								Clone.Kick.Text = "NOT IN SERVER"
							end
						else
							-- Not Founder
							if IsInGame then
								Clone.Kick.Text = "IN-GAME"
								Clone.Kick.BackgroundColor3 = Color3.fromRGB(56, 226, 56)
							else
								Clone.Kick.Text = "NOT IN SERVER"
								Clone.Kick.BackgroundColor3 = Color3.fromRGB(139, 139, 139)
							end
						end
						------------------
						-- Click Detection
						Clone.Kick.MouseButton1Click:Connect(function()
							if IsFounder then
								Sound({
									SoundName = "Click",
									Parent = script.Parent.Parent.Effects
								})
								print("Kick?")

								Remotes.Guild:FireServer("Kick", {
									["Target"] = tonumber(member.Name)
								})
							end
						end)

					end
				end
			end
		end

	else
		-- Clear		
		GuildFrame.GuildName.Text = "-"
		GuildFrame.Owner.Text = "-"
		GuildFrame.ColorVisual.BackgroundColor3 = Color3.fromRGB(255,255,255)

		for _,v in pairs(GuildFrame.List:GetChildren()) do
			if v:IsA("Frame") then
				v:Destroy()
			end
		end

	end
end
-- DISBAND
GuildFrame.Disband.MouseButton1Click:Connect(function() -- text is changed depending on founder/not
	local GuildFolder = GuildsInGame:FindFirstChild(PlayerData.Guild.Value)

	if GuildFolder then
		Root.LeaveConfirm:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)	
	end
end)
Root.LeaveConfirm.Yes.Main.MouseButton1Click:Connect(function()
	local GuildFolder = GuildsInGame:FindFirstChild(PlayerData.Guild.Value)
	if GuildFolder then
		if Player.UserId == GuildFolder.Founder.Value then
			-- is founder
			Remotes.Guild:FireServer("Disband", {})
		else
			-- leave, not founder
			Remotes.Guild:FireServer("Leave", {})
		end	
		Root.LeaveConfirm:TweenPosition(UDim2.new(0.5,0,-0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)			
	end
end)
Root.LeaveConfirm.No.Main.MouseButton1Click:Connect(function()
	Root.LeaveConfirm:TweenPosition(UDim2.new(0.5,0,-0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)	
end)

-- INVITE BUTTON
local function GetPlayerFromPartial(String)
	for i,v in pairs(game.Players:GetPlayers()) do
		local matched = v.Name:lower():match('^' .. String:lower())	
		if matched and v ~= Player then
			return v
		end
	end
end
GuildFrame.Box.Focused:Connect(function()
	Sound({
		SoundName = "Click",
		Parent = script.Parent.Parent.Effects
	})
end)
GuildFrame.Box.FocusLost:Connect(function()
	local p = GetPlayerFromPartial(GuildFrame.Box.Text)
	if p then
		GuildFrame.Box.Text = p.Name
	end
end)
GuildFrame.Invite.MouseButton1Click:Connect(function()
	Sound({
		SoundName = "Click",
		Parent = script.Parent.Parent.Effects
	})

	-- Not in a Guild
	if PlayerData.Guild.Value == "" then
		return
	end
	-- Checking Guild
	local GuildFolder = GuildsInGame:FindFirstChild(PlayerData.Guild.Value)
	local IsFounder = false
	local Members = nil

	if GuildFolder then
		Members = GuildFolder.Members

		local FounderID = GuildFolder.Founder.Value
		if Player.UserId == FounderID then
			IsFounder = true
		end
	end
	if not IsFounder then
		NotifyEvent:Fire("You do not have permission to invite people. [Only available to the Founder]", 5)
		return
	end

	local TargetName = GuildFrame.Box.Text
	local FoundPlayer = Players:FindFirstChild(TargetName)

	if FoundPlayer then
		if Members then
			-- alerady in guild
			if Members:FindFirstChild(tostring(FoundPlayer.UserId)) then
				NotifyEvent:Fire("This person is already in the guild.", 5)
				return
			end
			Remotes.Guild:FireServer("Invite", {
				["Target"] = TargetName
			})
		end
	end
end)


-- Codes System --
local CodesFolder = PlayerData:WaitForChild("Codes")
CodesFrame.Info.Finish.MouseButton1Click:Connect(function()
	Remotes.Codes:FireServer("Claim", {
		CodeName = CodesFrame.Info.Input.Text
	})
end)
-- Money Options --
local MoneyOptions = Root.MoneyOptions
local OptionsOpen = false

local GiveMoneyFrame = Root.GiveMoney
local SelectedTarget = true

local SendCooldown = 5
local LastSend = nil

local SendCap = 5000
local StudsCap = 20

local function updateGiveMoneyFrame()
	SelectedTarget = nil

	local FinishedUpdating = false
	for _,v in pairs(GiveMoneyFrame.List:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end
	--

	for _,p in next, Players:GetPlayers() do
		if p.Name == Player.Name then
			continue
		end
		local Clone = script.GiveMoneyTemplate:Clone()
		Clone.Name = p.Name
		Clone.Text = p.Name
		Clone.UIStroke.Transparency = 1

		Clone.Parent = GiveMoneyFrame.List

		Clone.MouseButton1Click:Connect(function()
			-- updating strokes
			if not FinishedUpdating then
				return
			end
			--
			for _,object in pairs(GiveMoneyFrame.List:GetChildren()) do
				if object:IsA("TextButton") and object:FindFirstChild("UIStroke") then
					object.UIStroke.Transparency = 1
				end
			end
			Clone.UIStroke.Transparency = 0
			SelectedTarget = p.Name
		end)
	end

	FinishedUpdating = true
end

Gold.MouseButton1Click:Connect(function()
	OptionsOpen = not OptionsOpen
	if OptionsOpen then
		MoneyOptions:TweenPosition(UDim2.new(0.006,0,0.839,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.2, true)
	else
		MoneyOptions:TweenPosition(UDim2.new(-0.1,0,0.839,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.2, true)
	end
end)
MoneyOptions.GiveMoney.MouseButton1Click:Connect(function()
	GiveMoneyFrame.Visible = not GiveMoneyFrame.Visible
	--updateGiveMoneyFrame()
end)
GiveMoneyFrame.Send.Main.MouseButton1Click:Connect(function()
	if SelectedTarget ~= nil then
		local Amount = tonumber(GiveMoneyFrame.Amount.Text)
		print(Amount)
		if not Amount  then
			return
		end
		if Amount < 1 then
			NotifyEvent:Fire("[DROP MONEY] You can only drop an amount more than 1.", 5)
			return
		end
		Amount = math.floor(Amount+.5)
		if Amount > SendCap then
			-- 10,000 is max you can send
			NotifyEvent:Fire("[DROP MONEY] You can only drop up to $10,000.", 5)
			return
		end
		if os.clock() - (LastSend or 0) < SendCooldown then
			NotifyEvent:Fire("[DROP MONEY] Please wait ".. math.floor(SendCooldown - (os.clock() - (LastSend or 0)) + .5).. " seconds before dropping money again.", 5)
			return -- on cooldown
		end
		if PlayerData.Level.Value < 5 then
			NotifyEvent:Fire("[DROP MONEY] You need to be at least level 5 to drop money.", 5)
			return
		end

		if PlayerData.Gold.Value < Amount then
			NotifyEvent:Fire("[DROP MONEY] You do not have enough to drop this amount.", 5)
			return
		end


		--[[
		local TargetPlayer = Players:FindFirstChild(SelectedTarget)
		if not TargetPlayer then
			return
		end

		local TargetCharacter = TargetPlayer.Character
		local A = Character.HumanoidRootPart.Position
		local B = TargetCharacter.HumanoidRootPart.Position

		]]--
		--[[
		if (A-B).Magnitude > StudsCap then
			NotifyEvent:Fire("[DROP MONEY] You must be at least ".. StudsCap.. " studs away from this player to send money.", 5)
			return
		end
		]]--

		Remotes.SendMoney:FireServer(nil, Amount)
		LastSend = os.clock()
	end
end)


-----------
--[[
while true do
	task.spawn(function()
		SettingsInfo.Music(PlayerSettings.Music.Value)
	end)
	task.spawn(function()
		updateGuildFrame()
	end)
	updateStatsInfoFrame()
	updateProfileFrame()
	task.wait()
end
]]

-- StatsInfo Updating
for _,b in pairs(Bonuses:GetChildren()) do
	b.Changed:Connect(function()
		updateStatsInfoFrame()
	end)
end
-- Music
SettingsInfo.Music(PlayerSettings.Music.Value)
PlayerSettings.Music.Changed:Connect(function()
	SettingsInfo.Music(PlayerSettings.Music.Value)
end)
-- Guild Updating
updateGuildFrame()
GuildsInGame.ChildAdded:Connect(function(c)
	if c.Name == PlayerData.Guild.Value then		
		repeat task.wait() until #c:GetChildren() > 1
		updateGuildFrame()

		for _,datapair in pairs(c:GetChildren()) do
			if datapair:IsA("Folder") then
				datapair.ChildAdded:Connect(function()
					updateGuildFrame()
				end)
			elseif string.find(datapair.ClassName, "Value") then
				-- Update
				updateGuildFrame()
			end
		end
	end
end)
GuildsInGame.ChildRemoved:Connect(function(c)
	updateGuildFrame()
end)
--