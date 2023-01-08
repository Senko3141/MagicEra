-- Guild System

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MessagingService = game:GetService("MessagingService")
local Chat = game:GetService("Chat")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Remotes = ReplicatedStorage.Remotes
local GuildsInGame = ReplicatedStorage.GuildsInGame
local Modules = ReplicatedStorage.Modules

local TableUtil = require(Modules.Shared.Table)
local Ranks = require(Modules.Shared.Ranks)

local GuildProfileStore = DataStoreService:GetDataStore("GuildDataStore_015")

local function Notify(Player, Text, Duration, ExtraData)
	Remotes.Notify:FireClient(Player, "<font color='rgb(58, 223, 255)'>[Guild System]</font> "..Text, (Duration == nil and 5) or Duration, ExtraData)
end


local ValidActions = {
	["Create"] = true, -- Done
	["Disband"] = true, -- Done
	["Leave"] = true, -- Done
	["Invite"] = true, -- Done
	["Accept"] = true, -- Done
	["Decline"] = true, -- Done
	["Kick"] = true,
}
local GuildInvites = {}
local AwaitingResponses = script.PlayerDebounces
local InviteDuration = 10
local Requests = {}
local InviteDistanceMax = 30

local function AddDebounce(Key, Duration)
	local New = Instance.new("BoolValue")
	New.Name = Key
	New.Value = true
	if Duration then
		Debris:AddItem(New, Duration)
	end

	New.Parent = AwaitingResponses

	return New
end
local function UpdateGuildsInGame()
	for _,Player in next, Players:GetPlayers() do
		local PlayerData = Player:FindFirstChild("Data")

		if PlayerData and PlayerData.Guild.Value ~= "" then
			-- Checking if the [GuildFolder] has already been made for this guild
			if not GuildsInGame:FindFirstChild(PlayerData.Guild.Value) then				
				local GuildData = GuildProfileStore:GetAsync(PlayerData.Guild.Value)

				if GuildData then
					local Clone = script.GuildTemplate:Clone()
					Clone.Name = GuildData.GuildName
					Clone.GuildName.Value = GuildData.GuildName
					Clone.Founded.Value = GuildData.Founded
					Clone.Founder.Value = GuildData.Founder
					Clone.GuildColor.Value = GuildData.GuildColor

					local Members = GuildData.Members
					for id,_ in pairs(Members) do
						local MemberClone = script.MemberTemplate:Clone()
						MemberClone.Name = tostring(id)
						MemberClone.Parent = Clone.Members
					end

					Clone.Parent = GuildsInGame
				end
			end
		end
	end
end

local MainFunctions = {
	["Create"] = function(Player, Action, Data)
		local GuildName = Data.Name
		local Color = Data.Color

		local PlayerData = Player:FindFirstChild("Data")
		if not PlayerData then
			return
		end
		if typeof(GuildName) ~= "string" then
			return
		end
		if typeof(Color) ~= "Color3" then
			return
		end
		
		-- More Checks
		if script.PlayerDebounces:FindFirstChild(Player.UserId.."/GuildCreation") then
			return
		end
		
		-- Checking if already in a Guild
		if PlayerData.Guild.Value ~= "" then
			Notify(Player, "You are already in a guild.", 5)
			return
		end
		-- Checking if meets requirements
		if PlayerData.Level.Value < Ranks.Ranks[3].Level then
			Notify(Player, "You need to be at least D-Rank to create a guild.", 5)
			return
		end
		if PlayerData.Gold.Value < 10000 then
			Notify(Player, "You need at least $10000 to create a guild.", 5)
			return
		end
		-- Filtering
		local FilteredName = Chat:FilterStringForBroadcast(GuildName, Player)
		if FilteredName ~= GuildName then
			Notify(Player, "This guild name is filtered, please type a different one.", 5)
			return
		end
		-- Removing Strings
		FilteredName = FilteredName:gsub('%d', '')
		FilteredName = FilteredName:gsub('%p', '')
		-------
		FilteredName = FilteredName:sub(1, 1):upper() .. FilteredName:sub(2):lower()

		local splitted = FilteredName:split(" ")
		if #splitted > 0 then
			for i = 1, #splitted do
				splitted[i] = splitted[i]:sub(1,1):upper()..splitted[i]:sub(2, #splitted[i])
			end
		end

		FilteredName = table.concat(splitted, " ")
		
		-- Checking if Guild has already been created
		if GuildProfileStore:GetAsync(FilteredName) then
			--warn(GuildProfileStore:GetAsync(GuildName))
			Notify(Player, "The guild name [".. FilteredName.."] is already taken.", 5)
			return
		end

		local StringedColor = math.floor(Color.R*255)..","..math.floor(Color.G*255)..","..math.floor(Color.B*255)
		
		-- Subtracting Gold
		PlayerData.Gold.Value -= 10000

		local Debounce = AddDebounce(Player.UserId.."/GuildCreation")

		Notify(Player, "Creating [Guild], please wait 1-10s for the creation to be complete.", 10)

		local GuildData = TableUtil:ToTable(script.GuildTemplate)
		GuildData.Founder = Player.UserId
		GuildData.GuildName = FilteredName

		-- Setting Guild Color
		GuildData.GuildColor = StringedColor

		-- Adding in Member
		GuildData.Members[tostring(Player.UserId)] = true
		--
		-- Founded Date
		GuildData.Founded = os.clock()
		--
		
		local NewGuild = GuildProfileStore:SetAsync(FilteredName, GuildData)
		if NewGuild then
			task.delay(3, function()
				if Debounce.Parent then
					Debounce:Destroy()
				end
			end)						
			Notify(Player, "Successfully created the ["..FilteredName.."]!", 5)
			
			PlayerData.Guild.Value = FilteredName
			UpdateGuildsInGame()
		end
	end,
	["Disband"] = function(Player, Action, Data)
		local PlayerData = Player:FindFirstChild("Data")

		if PlayerData and PlayerData.Guild.Value ~= "" then
			local GuildFolder = GuildsInGame:FindFirstChild(PlayerData.Guild.Value)
			if GuildFolder then
				local Founder = GuildFolder.Founder
				if Player.UserId ~= Founder.Value then
					Notify(Player, "You cannot disband this guild; you are not the Founder.", 5)
					return
				end

				local Debounce = AddDebounce(Player.UserId.."/DisbandGuild")

				Notify(Player, "Disbanding guild. Please wait...", 7)

				GuildProfileStore:RemoveAsync(PlayerData.Guild.Value)
				MessagingService:PublishAsync("UpdateGuildInfo", 
					{
						["Action"] = "GuildDisbanded",
						["GuildName"] = PlayerData.Guild.Value,
					}
				)
				task.delay(3, function()
					if Debounce.Parent then
						Debounce:Destroy()
					end
				end)

			end
		end
	end,
	["Invite"] = function(Player, Action, Data)
		local PlayerData = Player:FindFirstChild("Data")
		local Target = Data.Target

		if not Target then
			return
		end

		if PlayerData and PlayerData.Guild.Value ~= "" then
			local GuildFolder = GuildsInGame:FindFirstChild(PlayerData.Guild.Value)
			if GuildFolder then
				local Founder = GuildFolder.Founder
				if Player.UserId ~= Founder.Value then
					Notify(Player, "Invalid permissions. (Must be the Founder)", 5)
					return
				end

				-- Invite
				local TargetPlayer = Players:FindFirstChild(Target)
				if TargetPlayer then
					-- Checking if the Target is in a guild
					local TargetData = TargetPlayer:FindFirstChild("Data")
					if not TargetData then
						return
					end
					if TargetData.Guild.Value ~= "" then
						-- Checking if in [Your] Guild
						if TargetData.Guild.Value == PlayerData.Guild.Value then
							Notify(Player, Target.." is already your guild.", 5)
						else
							Notify(Player, Target.." is already in a guild.", 5)
						end						
						return
					end
					--
					-- Checking Distance
					local PointA = Player.Character.HumanoidRootPart.Position
					local PointB = TargetPlayer.Character.HumanoidRootPart.Position
					local Distance = (PointB-PointA).Magnitude
					
					if Distance > InviteDistanceMax then
						Notify(Player, "You need to be at least ["..InviteDistanceMax.."] studs away to invite this player.", 4)
						return
					end

					if os.clock() - (GuildInvites[PlayerData.Guild.Value] or 0) < InviteDuration then
						local TimeLeft = InviteDuration - os.clock() - (GuildInvites[PlayerData.Guild.Value] or 0)
						TimeLeft = string.format("%0.1f", TimeLeft)

						Notify(Player, "Please wait "..TimeLeft.."s before inviting another player.", 5)
						return
					end

					local StartTime = os.clock()
					GuildInvites[PlayerData.Guild.Value.."/"..TargetPlayer.UserId] = StartTime
					GuildInvites[PlayerData.Guild.Value] = StartTime

					Remotes.Guild:FireClient(TargetPlayer, "Invite", {
						["Sender"] = Player.UserId,
						["Duration"] = InviteDuration
					})
					
					Notify(Player, "You have sent a guild invite to ".. TargetPlayer.Name..". They have "..InviteDuration.."s to accept/decline.", 5)
				end
			end
		end
	end,
	["Accept"] = function(Player, Action, Data)
		local PlayerData = Player:FindFirstChild("Data")
		if not PlayerData then
			return
		end

		local Sender = Data.Sender
		local SenderPlayer = Players:GetPlayerByUserId(Sender)

		if SenderPlayer then
			local SenderData = SenderPlayer:FindFirstChild("Data")
			if not SenderData then
				return
			end
			local GuildFolder = GuildsInGame:FindFirstChild(SenderData.Guild.Value)
			if not GuildFolder then
				return
			end
			if GuildFolder.Founder.Value ~= SenderPlayer.UserId then
				return -- Sender isn't the owner, weird, exploiter LOL
			end

			local SentTime = GuildInvites[SenderData.Guild.Value.."/"..Player.UserId]
			if os.clock() - (SentTime) <= InviteDuration then
				local Debounce = AddDebounce(Player.UserId.."/AcceptedGuildInvite")
				local SenderDebounce = AddDebounce(SenderPlayer.UserId.."/TargetAcceptedGuildInvite")

				-- Accept into Guild
				local GuildData = GuildProfileStore:GetAsync(SenderData.Guild.Value)
				local Members = GuildData.Members

				Members[tostring(Player.UserId)] = true
				GuildProfileStore:SetAsync(SenderData.Guild.Value, GuildData)

				PlayerData.Guild.Value = SenderData.Guild.Value -- setting new guild value

				MessagingService:PublishAsync("UpdateGuildInfo", 
					{
						["Action"] = "NewGuildMember",
						["GuildName"] = SenderData.Guild.Value,
						["Member"] = Player.UserId
					}
				)				

				Notify(SenderPlayer, Player.Name.." has accepted your guild invite!", 6)
				Notify(Player, "You have joined the guild ["..SenderData.Guild.Value.."]!", 6, {
					["Confetti"] = true,
				})

				task.delay(1.5, function()
					if Debounce.Parent then
						Debounce:Destroy()
					end
					if SenderDebounce.Parent then
						SenderDebounce:Destroy()
					end
				end)
			end

		end
	end,
	["Decline"] = function(Player, Action, Data)
		local PlayerData = Player:FindFirstChild("Data")
		if not PlayerData then
			return
		end

		local Sender = Data.Sender
		local SenderPlayer = Players:GetPlayerByUserId(Sender)

		if SenderPlayer then
			local SenderData = SenderPlayer:FindFirstChild("Data")
			if not SenderData then
				return
			end
			local GuildFolder = GuildsInGame:FindFirstChild(SenderData.Guild.Value)
			if not GuildFolder then
				return
			end
			if GuildFolder.Founder.Value ~= SenderPlayer.UserId then
				return -- Sender isn't the owner, weird, exploiter LOL
			end

			local SentTime = GuildInvites[SenderData.Guild.Value.."/"..Player.UserId]
			if os.clock() - (SentTime) <= InviteDuration then
				-- Declined
				Notify(Player, "You have declined the guild invite to ["..SenderData.Guild.Value.."] from ".. SenderPlayer.Name..".", 5)
				Notify(SenderPlayer, Player.Name.." has declined your guild invite.", 5)
			end

		end
	end,
	["Leave"] = function(Player, Action, Data)
		local PlayerData = Player:FindFirstChild("Data")
		if not PlayerData then
			return
		end

		if PlayerData.Guild.Value ~= "" then
			local GuildFolder = GuildsInGame:FindFirstChild(PlayerData.Guild.Value)
			if not GuildFolder then
				return
			end
			if GuildFolder.Founder.Value == Player.UserId then
				return -- you can't leave your own guild, must disband
			end

			-- Leave Guild
			local GuildData = GuildProfileStore:GetAsync(PlayerData.Guild.Value)
			local Members = GuildData.Members

			if Members[tostring(Player.UserId)] then
				Members[tostring(Player.UserId)] = nil
			end

			GuildProfileStore:SetAsync(PlayerData.Guild.Value, GuildData)
			MessagingService:PublishAsync("UpdateGuildInfo", 
				{
					["Action"] = "GuildMemberLeft",
					["GuildName"] = PlayerData.Guild.Value,
					["Member"] = Player.UserId
				}
			)	

			PlayerData.Guild.Value = ""

			Notify(Player, "You have successfully left the guild ["..GuildFolder.Name.."]!", 5)
		end
	end,
	["Kick"] = function(Player, Action, Data)
		local Target = Data.Target
		if not Target then
			return
		end
		
		local PlayerData = Player:FindFirstChild("Data")
		if not PlayerData then
			return
		end

		if PlayerData.Guild.Value ~= "" then
			local GuildFolder = GuildsInGame:FindFirstChild(PlayerData.Guild.Value)
			if not GuildFolder then
				return
			end
			if Player.UserId ~= GuildFolder.Founder.Value then
				Notify(Player, "Invalid permissions. [You must be the Founder]", 5)
				return
			end
			if not GuildFolder.Members:FindFirstChild(Target) then
				-- not in the guild folder/guild?
				return
			end
			
			local TargetPlayer = Players:GetPlayerByUserId(Target)
			if not TargetPlayer then
				-- not in game
				return
			end
			local TargetData = TargetPlayer:FindFirstChild("Data")
			if not TargetData then
				return
			end

			-- Kick Member
			local Debounce = AddDebounce(Player.UserId.."/KickMemberAttempt")
			
			local GuildData = GuildProfileStore:GetAsync(PlayerData.Guild.Value)
			local Members = GuildData.Members
			
			if Members[tostring(TargetPlayer.UserId)] then
				Members[tostring(TargetPlayer.UserId)] = nil
			end
			
			TargetData.Guild.Value = ""
			GuildProfileStore:SetAsync(PlayerData.Guild.Value, GuildData)
			MessagingService:PublishAsync("UpdateGuildInfo", 
				{
					["Action"] = "GuildMemberKicked",
					["GuildName"] = PlayerData.Guild.Value,
					["Member"] = TargetPlayer.UserId
				}
			)	
			
			Notify(TargetPlayer, "You have been kicked from the guild. ["..PlayerData.Guild.Value.."].", 5)
			Notify(Player, "You have successfully kicked ["..TargetPlayer.Name.."] from the guild.", 5)
			
			task.delay(2, function()
				if Debounce.Parent then
					Debounce:Destroy()
				end
			end)
		end
	end,
}
Remotes.Guild.OnServerEvent:Connect(function(Player, Action, Data)
	if not ValidActions[Action] then
		return
	end
	if typeof(Data) ~= "table" then
		return
	end
	if MainFunctions[Action] then
		--
		local FoundCooldown, Reason = false, ""
		for _,Debounce in pairs(AwaitingResponses:GetChildren()) do
			if string.find(Debounce.Name, tostring(Player.UserId)) then
				FoundCooldown = true
				local Splitted = Debounce.Name:split("/")
				Reason = Splitted[2]
				break
			end
		end

		if FoundCooldown then
			Notify(Player, "You are still waiting for a pending action to finish. [Action: ".. Reason.."]", 5)
			return
		end
		if os.clock() - (Requests[Player.UserId] or 0) < 1 then
			-- dont spam the remote evennt
			Notify(Player, "Please wait 1s for everything to finish.", 2)
			return
		end
		
		Requests[Player.UserId] = os.clock()
		MainFunctions[Action](Player, Action, Data)
	end
end)

-- Messasging Service Stuff
if not RunService:IsStudio() then
	MessagingService:SubscribeAsync("UpdateGuildInfo", function(Received)
		if typeof(Received.Data) ~= "table" then return end
		local Data = Received.Data

		local Action = Data.Action
		if Action == "NewGuildMember" then
			local GuildName = Data.GuildName
			local NewMember = Data.Member
			
			local MemberName = Players:GetNameFromUserIdAsync(NewMember)

			local FoundGuild = GuildsInGame:FindFirstChild(GuildName)

			if FoundGuild then
				local Members = FoundGuild.Members

				for _,member in pairs(Members:GetChildren()) do
					local member_player = Players:GetPlayerByUserId(tonumber(member.Name))
					if member_player then
						local memberData = member_player:FindFirstChild("Data")
						if memberData then
							if memberData.Guild.Value == GuildName then
								-- Notifying
								if member_player.UserId ~= FoundGuild.Founder.Value then
									Notify(member_player, MemberName.." has joined the guild!", 8)
								end				
							end
						end
					end
				end

				-- Adding to Folder
				local Clone = script.MemberTemplate:Clone()
				Clone.Name = NewMember
				Clone.Value = true
				Clone.Parent = Members
			end
		end
		if Action == "GuildMemberLeft" then
			local GuildName = Data.GuildName
			local MemberLeft = Data.Member
			local MemberName = Players:GetNameFromUserIdAsync(MemberLeft)

			local FoundGuild = GuildsInGame:FindFirstChild(GuildName)

			if FoundGuild then
				local Members = FoundGuild.Members

				for _,member in pairs(Members:GetChildren()) do
					local member_player = Players:GetPlayerByUserId(tonumber(member.Name))
					if member_player then
						local memberData = member_player:FindFirstChild("Data")
						if memberData then
							if memberData.Guild.Value == GuildName then
								-- Notifying
								if member_player.UserId ~= MemberLeft then -- just checking
									Notify(member_player, MemberName.." has left the guild!", 8)
								end
							end
						end
					end
				end

				-- Removing from Folder
				if Members:FindFirstChild(tostring(MemberLeft)) then
					Members[tostring(MemberLeft)]:Destroy()
				end
			end
		end
		if Action == "GuildMemberKicked" then
			local GuildName = Data.GuildName
			local MemberLeft = Data.Member
			local MemberName = Players:GetNameFromUserIdAsync(MemberLeft)

			local FoundGuild = GuildsInGame:FindFirstChild(GuildName)

			if FoundGuild then
				local Members = FoundGuild.Members

				for _,member in pairs(Members:GetChildren()) do
					local member_player = Players:GetPlayerByUserId(tonumber(member.Name))
					if member_player then
						local memberData = member_player:FindFirstChild("Data")
						if memberData then
							if memberData.Guild.Value == GuildName then
								-- Notifying
								if member_player.UserId ~= MemberLeft then -- just checking
									Notify(member_player, MemberName.." has been kicked from the guild!", 8)
								end
							end
						end
					end
				end

				-- Removing from Folder
				if Members:FindFirstChild(tostring(MemberLeft)) then
					Members[tostring(MemberLeft)]:Destroy()
				end
			end
		end
		if Action == "GuildDisbanded" then
			local GuildName = Data.GuildName
			local FoundGuild = GuildsInGame:FindFirstChild(GuildName)

			if FoundGuild then
				-- Getting Members
				local Members = FoundGuild.Members

				for _,member in pairs(Members:GetChildren()) do
					local member_player = Players:GetPlayerByUserId(tonumber(member.Name))
					if member_player then
						local memberData = member_player:FindFirstChild("Data")
						if memberData then
							if memberData.Guild.Value == GuildName then
								-- Setting [Guild] value to ""
								memberData.Guild.Value = ""
								-- Notifying

								if member_player.UserId == FoundGuild.Founder.Value then
									Notify(member_player, "You have successfully disbanded the guild.", 8)
								else
									Notify(member_player, "The guild ["..GuildName.."] has been disbanded. You have left.", 8)
								end							
							end
						end
					end
				end
				FoundGuild:Destroy()
			end
		end

	end)
end
-- PlayerAdded
local function PlayerAdded(Player)
	repeat task.wait() until Player:FindFirstChild("Data") and Player:GetAttribute("DataLoaded") == true

	local PlayerData = Player:FindFirstChild("Data")
	if PlayerData and PlayerData.Guild.Value ~= "" then
		local GuildData = GuildProfileStore:GetAsync(PlayerData.Guild.Value)
		if not GuildData then
			-- Guild was Disbanded
			Notify(Player, "The guild ["..PlayerData.Guild.Value.."] was disbanded.", 10)
			PlayerData.Guild.Value = ""		
			return
		end
		if GuildData then
			-- checking if the player is actually a member
			local Members = GuildData.Members
			if not Members[tostring(Player.UserId)] then
				Notify(Player, "The guild ["..PlayerData.Guild.Value.."] was disbanded.", 10)
				PlayerData.Guild.Value = ""
				return
			end
		end
		-- Update Guilds
		UpdateGuildsInGame()
	end
end
local function PlayerRemoved(Player)
	if Requests[Player.UserId] then
		Requests[Player.UserId] = nil
	end
end

Players.PlayerAdded:Connect(function(Player)	
	PlayerAdded(Player)
end)
Players.PlayerRemoving:Connect(function(Player)
	PlayerRemoved(Player)
end)

game:BindToClose(function()
	for _,Player in next, Players:GetPlayers() do
		PlayerRemoved(Player)
	end
end)

for _,Player in next, Players:GetPlayers() do
	PlayerAdded(Player)
end