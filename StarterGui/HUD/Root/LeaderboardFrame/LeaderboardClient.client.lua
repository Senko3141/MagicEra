-- Leaderboard Client Rescript
-- Senko

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local GuildsInGame = ReplicatedStorage:WaitForChild("GuildsInGame")

local FormatNumber = require(Modules.Shared.FormatNumber)
local Ranking = require(Modules.Shared.Ranks)
local Groups = require(Modules.Shared.Groups)

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

local leaderboardIsOpen = true


local ScrollingFrame = script.Parent:WaitForChild("ScrollingFrame")
local Templates = script:WaitForChild("Templates")

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

local function CreatePlayerFrame(data2)
	if ScrollingFrame:FindFirstChild(data2.Player.Name) then
		return
	end	
	local playerData = data2.Player:FindFirstChild("Data")
	
	if playerData then
		local PlayerFrame = Templates.PlayerFrame:Clone()
		
		local rank = Ranking:GetRankFromLevel(playerData.Level.Value)
		local rankColor = Ranking:GetData(rank).Color
		local strColor = math.floor(rankColor.R*255)..","..math.floor(rankColor.G*255)..","..math.floor(rankColor.B*255)

		PlayerFrame.Name = data2.Player.Name

		local finalText = "[<font color='FONT_COLOR'>RANK-Class</font>] <FIRST_NAME> <LAST_NAME>"	
		finalText = string.gsub(finalText, "<FIRST_NAME>", playerData.FirstName.Value)
		finalText = string.gsub(finalText, "<LAST_NAME>", playerData.LastName.Value)
		finalText = string.gsub(finalText, "FONT_COLOR", "rgb("..strColor..")")
		finalText = string.gsub(finalText, "RANK", rank)

		local formatted_2 = "[<font color='FONT_COLOR'>RANK-Class</font>] <PlayerName>"
		formatted_2 = string.gsub(formatted_2, "<PlayerName>", data2.Player.Name)
		formatted_2 = string.gsub(formatted_2, "FONT_COLOR", "rgb("..strColor..")")
		formatted_2 = string.gsub(formatted_2, "RANK", rank)

		PlayerFrame.Player.Text = finalText
		PlayerFrame.Player.Shadow.Text = finalText

		PlayerFrame.Bounty.Text = FormatNumber.Shorten(playerData.Bounty.Value).."B$"
		PlayerFrame.Bounty.Shadow.Text = FormatNumber.Shorten(playerData.Bounty.Value).."B$"

		PlayerFrame.Player.MouseEnter:Connect(function()
			PlayerFrame.Player.Text = formatted_2
			PlayerFrame.Player.Shadow.Text = formatted_2
		end)
		PlayerFrame.Player.MouseLeave:Connect(function()
			PlayerFrame.Player.Text = finalText
			PlayerFrame.Player.Shadow.Text = finalText
		end)

		-- Checking for Special Tags
		local FoundSpecialTag = Groups.SpecialTags[data2.Player.UserId] or Groups.SpecialTags
		if FoundSpecialTag then
			local ToColor = Groups.SpecialColors[FoundSpecialTag]

			if ToColor then
				PlayerFrame.Player.TextColor3 = ToColor
			end
		end

		PlayerFrame.Parent = ScrollingFrame
	end
end

local function update()
	-- Clearing
	for _,v in pairs(ScrollingFrame:GetChildren()) do
		if v:IsA("Frame") or v:IsA("ImageButton") then
			v:Destroy()
		end
	end

	-- Updating
	local toDisplay = {}
	local orderedGuilds = {}
	local playersOrder = {}

	for _,player: Player in next, Players:GetPlayers() do
		local data = player:FindFirstChild("Data")

		if data then
			-- Checking for Guild
			if data:FindFirstChild("Guild") then
				local guildValue = data.Guild.Value
				if GuildsInGame:FindFirstChild(guildValue) then
					local alreadyInTable = table.find(orderedGuilds, guildValue)
					if not alreadyInTable then
						table.insert(orderedGuilds, guildValue)
					end

					for _,v in pairs(Players:GetPlayers()) do
						local data2 = v:FindFirstChild("Data")
						if data2 then
							local g = data2:FindFirstChild("Guild")
							if g then
								if g.Value == guildValue then
									table.insert(playersOrder, {["Player"] = v, ["Guild"] = guildValue})
								end
							end
						end
					end

				else
					table.insert(playersOrder, {["Player"] = player, ["Guild"] = "None"})
				end
			end
		end
	end

	--warn(table.unpack(orderedGuilds))

	if #orderedGuilds > 0 then
		table.sort(orderedGuilds ,function(a,b)		
			return a < b
		end)
	end

	for i = 1,#orderedGuilds do
		local guildName = orderedGuilds[i]
		table.insert(toDisplay, {["GuildName"] = guildName})
	end

	local adventurersList = {}

	if #toDisplay > 0 then
		for i = 1, #toDisplay do
			local displayData = toDisplay[i]
			local guildName = displayData.GuildName

			local FactionFrame = Templates.FactionFrame:Clone()
			FactionFrame.Name = guildName.."Faction"
			FactionFrame.Parent = ScrollingFrame

			local guildData = GuildsInGame:FindFirstChild(guildName)
			FactionFrame.BackgroundColor3 = getRGB(guildData.GuildColor.Value)

			FactionFrame.Faction.Text = guildName
			FactionFrame.Faction.Shadow.Text = guildName

			for i2 = 1, #playersOrder do
				local data2 = playersOrder[i2]

				if data2.Guild == guildName then
					CreatePlayerFrame(data2)
				elseif data2.Guild == "None" then
					table.insert(adventurersList, data2)
				end
			end

		end
	else
		for i = 1, #playersOrder do

			local data = playersOrder[i]
			table.insert(adventurersList, data)
		end
	end

	if #adventurersList > 0 then
		-- Just doing adventurers now
		local AdventurersFrame = Templates.FactionFrame:Clone()
		AdventurersFrame.Name = "AdventurersFaction"

		AdventurersFrame.Parent = ScrollingFrame

		AdventurersFrame.Faction.Text = "Adventurers"
		AdventurersFrame.Faction.Shadow.Text = "Adventurers"
		AdventurersFrame.BackgroundColor3 = Color3.fromRGB(197, 197, 197)

		for i = 1, #adventurersList do
			local data = adventurersList[i]
			CreatePlayerFrame(data)
		end
	end

	--print(adventurersList, orderedGuilds)
end

task.spawn(function()
	while task.wait(1) do
		update()
	end
end)

update()

UserInputService.InputBegan:connect(function(inp)
	if inp.KeyCode == Enum.KeyCode.Tab then
		leaderboardIsOpen = not leaderboardIsOpen

		if leaderboardIsOpen then
			script.Parent:TweenPosition(UDim2.new(1,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
		else
			script.Parent:TweenPosition(UDim2.new(1.5,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 1, true)
		end		
	end
end)