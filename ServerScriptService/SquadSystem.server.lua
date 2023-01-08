 -- Squad System

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Squads = ReplicatedStorage.Squads
local Remotes = ReplicatedStorage.Remotes
local Modules = ReplicatedStorage.Modules

local QuestModule = require(Modules.Shared.QuestsModule)

local ValidActions = {
	["Create"] = true,
	["Disband"] = true,
	["Leave"] = true,
	["Invite"] = true,
	["Kick"] = true,
	["Accept"] = true,
	["Decline"] = true,
}
local ServerCooldowns = {}
local CooldownTimes = {
	Create = 5,
	Disband = 5,
	Leave = 5,
	Invite = 5,
	Kick = 5,
}
local InviteDuration = 10
local MaxSquadMembers = 5

local function IsInSquad(Target)
	local DataToReturn = {
		IsOwner = false
	}
	-- Checking if is the owner of a squad
	if Squads:FindFirstChild(Target.UserId.."'s Squad") then
		DataToReturn.IsOwner = true
		return true, DataToReturn
	end
	-- Checking if is a member of a squad
	if #Squads:GetChildren() > 0 then
		for _,squad in pairs(Squads:GetChildren()) do
			local Members = squad:FindFirstChild("Members")
			if Members:FindFirstChild(Target.UserId) then
				DataToReturn.IsOwner = false

				local OwnerID = squad.Owner.Value
				DataToReturn.SquadOwner = Players:GetPlayerByUserId(OwnerID).Name
				return true, DataToReturn
			end
		end
	end
	--
	return false, DataToReturn
end
local function Notify(Player, Text, Duration)
	Remotes.Notify:FireClient(Player, "<font color='rgb(255, 186, 10)'>[Squad System]</font> ".. Text, (Duration == nil and 5) or Duration)
end
local function IsOnCooldown(Player, Action)
	if os.clock() - (ServerCooldowns[Player.UserId.."/"..Action] or 0) < CooldownTimes[Action] then
		local TimeLeft = CooldownTimes[Action] - (os.clock() - (ServerCooldowns[Player.UserId.."/"..Action] or 0))
		TimeLeft = string.format("%0.1f", TimeLeft)		
		return true, {
			["TimeLeft"] = TimeLeft
		}
	end
	return false, {}
end
local function RemoveSquadQuests(SquadOwner, Target)
	task.spawn(function()
		local QuestsFolder = Target.Data.Quests
		for _,quest in pairs(QuestsFolder:GetChildren()) do
			local QuestData = QuestModule.GetQuestFromId(quest.Name)
			
			if QuestData then
				local Found = quest:FindFirstChild("SquadQuest")
				
				if Found and Found.Value == SquadOwner.UserId then
					-- Cancel
					quest:SetAttribute("Status", "Cancel")
					Remotes.Notify:FireClient(Target, "[Quest System] The squad quest [".. QuestData.Name.."] has been canceled because you are not in the squad anymore.", 4)
				end
			end
		end
	end)
end

local MainFunctions = {
	["Create"] = function(Player, Action, Data)
		local InSquad, Returned = IsInSquad(Player)
		if InSquad then
			local IsOwner = Returned.IsOwner
			if IsOwner then
				Notify(Player, "You are already the owner of a squad!", 5)
			else
				Notify(Player, "You are already in a squad! [".. Returned.SquadOwner.."]", 5)
			end
			return
		end
		------
		-- Checking on Cooldown
		local OnCooldown, CooldownData = IsOnCooldown(Player, "Create")
		if OnCooldown then
			Notify(Player, "Please wait ".. CooldownData.TimeLeft.."s before creating another squad.")
			return
		end

		-- Create Squad
		local NewSquad = script.SquadTemplate:Clone()
		NewSquad.Name = Player.UserId.."'s Squad"
		NewSquad.Owner.Value = Player.UserId

		-- Adding yourself as a member
		local NewMember = script.MemberTemplate:Clone()
		NewMember.Name = Player.UserId
		NewMember.Parent = NewSquad.Members

		NewSquad.Parent = Squads
		--
		Notify(Player, "Successfully created a squad.", 5)
		-- Setting Disband Cooldown
		ServerCooldowns[Player.UserId.."/Disband"] = os.clock()
	end,
	["Disband"] = function(Player, Action, Data)
		local InSquad, Returned = IsInSquad(Player)
		if InSquad and Returned.IsOwner then
			-- Checking Cooldown
			local OnCooldown, CooldownData = IsOnCooldown(Player, "Disband")
			if OnCooldown then
				Notify(Player, "Please wait ".. CooldownData.TimeLeft.."s before attempting to disband your squad.")
				return
			end
			-- Disband here
			local SquadFolder = Squads[Player.UserId.."'s Squad"]
			-- Notifying
			local Members = SquadFolder.Members
			for _,member in pairs(Members:GetChildren()) do
				if tonumber(member.Name) ~= Player.UserId then -- Making sure the Member isn't the owner 
					local member_player = Players:GetPlayerByUserId(tonumber(member.Name))
					if member_player then
						RemoveSquadQuests(Player, member_player)
						Notify(member_player, "The squad has been disbanded. [Reason: By Request of the Owner]", 5)
					end
				end
			end

			Notify(Player, "You have successfully disbanded your squad.", 5)
			SquadFolder:Destroy()
			-- Setting [Create] cooldown
			ServerCooldowns[Player.UserId.."/Create"] = os.clock()
			
			-- Removing SquadQuest from Player/Owner because disbanded
			task.spawn(function()
				local PlayerQuests = Player.Data.Quests
				for _,q in pairs(PlayerQuests:GetChildren()) do
					if q:FindFirstChild("SquadQuest") and q.SquadQuest.Value == Player.UserId then
						-- cancel
						q.SquadQuest:Destroy()
						
						local qData = QuestModule.GetQuestFromId(q.Name)
						if qData then
							Remotes.Notify:FireClient(Player, "The quest ["..qData.Name.."] is no longer a squad quest.", 4)
						end
					end
				end
			end)
			
		end
	end,
	["Leave"] = function(Player, Action, Data)
		local InSquad, Returned = IsInSquad(Player)
		if InSquad and not Returned.IsOwner then
			-- Not the Owner

			-- Checking on Cooldown
			local OnCooldown, CooldownData = IsOnCooldown(Player, "Create")
			if OnCooldown then
				Notify(Player, "Please wait ".. CooldownData.TimeLeft.."s before leaving this squad.")
				return
			end
			--

			local SquadOwner = Returned.SquadOwner
			SquadOwner = Players:FindFirstChild(SquadOwner)

			if SquadOwner then
				local SquadFolder = Squads:FindFirstChild(SquadOwner.UserId.."'s Squad")

				if SquadFolder then
					local Members = SquadFolder.Members
					local FoundMember = Members:FindFirstChild(Player.UserId)

					if FoundMember then
						FoundMember:Destroy()

						Notify(Player, "You have left ".. SquadOwner.Name.."'s squad.", 5)
						Notify(SquadOwner, Player.Name.." has left your squad.", 5)
						
						RemoveSquadQuests(SquadOwner, Player)
					end
				end
			end

		end
	end,
	["Invite"] = function(Player, Action, Data)
		local InSquad, Returned = IsInSquad(Player)
		if InSquad and Returned.IsOwner then
			-- Is the Owner

			local SquadFolder = Squads[Player.UserId.."'s Squad"]
			if SquadFolder then
				if #SquadFolder.Members:GetChildren()-1 >= MaxSquadMembers then
					Notify(Player, "You can only have up to ["..MaxSquadMembers.."] Squad Members at a time.", 5)
					return
				end

				local Invites = SquadFolder.Invites

				local Target = Data.Target
				local TargetPlayer = Players:FindFirstChild(Target)

				if TargetPlayer then
					-- Checking if you invited yourself
					if TargetPlayer == Player then
						Notify(Player, "You cannot invite yourself.", 5)
						return
					end

					-- Checking if Target is already in a Squad
					local TargetInSquad, DataReturned = IsInSquad(TargetPlayer)
					if TargetInSquad then
						local TargetSquadOwner = DataReturned.SquadOwner
						TargetSquadOwner = Players:FindFirstChild(TargetSquadOwner)

						if TargetSquadOwner.UserId == Player.UserId then
							Notify(Player, TargetPlayer.Name.." is already in your squad.", 5)
						else
							Notify(Player, TargetPlayer.Name.." is already in a squad.", 5)
						end
						return
					end
					-- Checking if already invited
					if Invites:FindFirstChild(TargetPlayer.UserId) then
						local InviteObject = Invites[TargetPlayer.UserId]
						local TimeLeft = InviteDuration - (os.clock() - (InviteObject.Value or 0))
						TimeLeft = string.format("%0.1f", TimeLeft)

						Notify(Player, "You have already invited ".. TargetPlayer.Name..". Please wait ".. TimeLeft.."s before inviting this person again.", 5)
						return
					end
					-- Hasn't invited
					local InviteObject = script.InviteTemplate:Clone()
					InviteObject.Name = TargetPlayer.UserId
					InviteObject.Value = os.clock()
					InviteObject.Parent = Invites

					task.delay(InviteDuration, function()
						if InviteObject.Parent then
							InviteObject:Destroy()
						end
					end)
					-- Fire Client
					Notify(Player, "Successfully sent a squad invite to ".. TargetPlayer.Name..". They have ".. InviteDuration.."s to accept/decline.", 5)
					Remotes.Squad:FireClient(TargetPlayer, "Invite", {
						["Sender"] = Player.UserId,
						Duration = InviteDuration
					})
				end


			end
		end
	end,
	["Kick"] = function(Player, Action, Data)
		local Target = Data.Target
		if not Target then
			return
		end
		local InSquad, Returned = IsInSquad(Player)
		if InSquad and Returned.IsOwner then
			-- Is the Owner
			local OnCooldown, Returned = IsOnCooldown(Player, "Kick")
			if OnCooldown then
				Notify(Player, "Please wait ".. Returned.TimeLeft.."s before attempting to [Kick] another player.", 5)
				return
			end

			local SquadFolder = Squads[Player.UserId.."'s Squad"]

			if SquadFolder then
				local TargetPlayer = Players:FindFirstChild(Target)
				if TargetPlayer then
					if TargetPlayer == Player then
						Notify(Player, "You cannot kick yourself.", 5)
						return
					end

					local Members = SquadFolder.Members

					local FoundMember = Members:FindFirstChild(TargetPlayer.UserId)
					if FoundMember then
						FoundMember:Destroy()

						Notify(TargetPlayer, "You have been kicked from ".. Player.Name.."'s squad.", 5)
						Notify(Player, "Successfully kicked ".. TargetPlayer.Name.." from the squad.", 5)
						
						-- Removing Squad Quests
						RemoveSquadQuests(Player, TargetPlayer)
						
						-- Set Cooldown
						ServerCooldowns[Player.UserId.."/Kick"] = os.clock()
					end

				end
			end
		end
	end,
	["Accept"] = function(Player, Action, Data)
		local Sender = Data.Sender
		if not Sender then
			return
		end
		local InSquad, Returned = IsInSquad(Player)
		if InSquad then
			Notify(Player, "You are already in a squad.", 5)
			return
		end

		local SenderPlayer = Players:GetPlayerByUserId(Sender)
		if SenderPlayer then
			local SquadFolder = Squads:FindFirstChild(SenderPlayer.UserId.."'s Squad")
			if SquadFolder then
				if #SquadFolder:GetChildren()-1 >= MaxSquadMembers then
					Notify(SenderPlayer, "This squad already has ["..MaxSquadMembers.."+] members in it.", 5)
					return
				end

				local Members = SquadFolder.Members
				local Invites = SquadFolder.Invites

				local FoundInvite = Invites:FindFirstChild(Player.UserId)
				if FoundInvite then
					FoundInvite:Destroy()

					Notify(Player, "You have accepted ".. SenderPlayer.Name.."'s squad invite.", 5)
					Notify(SenderPlayer, Player.Name.." has accepted your squad invite.", 5)

					-- Creating [Member]
					local NewMember = script.MemberTemplate:Clone()
					NewMember.Name = Player.UserId
					NewMember.Parent = Members

					-- Set Cooldown for Target
					ServerCooldowns[Player.UserId.."/Leave"] = os.clock()
				end
			end
		end
	end,
	["Decline"] = function(Player, Action, Data)
		local Sender = Data.Sender
		if not Sender then
			return
		end
		local InSquad, Returned = IsInSquad(Player)
		if InSquad then
			Notify(Player, "You are already in a squad.", 5)
			return
		end
		local SenderPlayer = Players:GetPlayerByUserId(Sender)
		if SenderPlayer then
			local SquadFolder = Squads:FindFirstChild(SenderPlayer.UserId.."'s Squad")
			if SquadFolder then
				local Members = SquadFolder.Members
				local Invites = SquadFolder.Invites

				local FoundInvite = Invites:FindFirstChild(Player.UserId)
				if FoundInvite then
					FoundInvite:Destroy()
					Notify(Player, "You have declined ".. SenderPlayer.Name.."'s squad invite.", 5)
					Notify(SenderPlayer, Player.Name.." has declined your squad invite.", 5)

					FoundInvite:Destroy()
				end
			end
		end
	end,
}

Remotes.Squad.OnServerEvent:Connect(function(Player, Action, Data)
	if not ValidActions[Action] then
		return
	end
	if typeof(Data) ~= "table" then
		return
	end
	if MainFunctions[Action] then
		MainFunctions[Action](Player, Action, Data)
	end
end)

Players.PlayerRemoving:Connect(function(Player)
	local InSquad, Returned = IsInSquad(Player)
	if InSquad then
		local IsOwner = Returned.IsOwner
		if IsOwner then
			-- Disband Squad
			local SquadFolder = Squads[Player.UserId.."'s Squad"]
			local Members = SquadFolder.Members

			for _,member in pairs(Members:GetChildren()) do
				if tonumber(member.Name) ~= Player.UserId then -- Making sure not the player
					local member_player = Players:GetPlayerByUserId(tonumber(member.Name))
					if member_player then
						Notify(member_player, "The squad has been disbanded. [Reason: Owner has left the game]", 5)
					end
				end
			end
			SquadFolder:Destroy()			
		else
			-- Leave Squad
			local SquadOwner = Returned.SquadOwner
			SquadOwner = Players:FindFirstChild(SquadOwner)

			if SquadOwner then
				local SquadFolder = Squads:FindFirstChild(SquadOwner.UserId.."'s Squad")

				if SquadFolder then
					local Members = SquadFolder.Members
					local FoundMember = Members:FindFirstChild(Player.UserId)

					if FoundMember then
						FoundMember:Destroy()
						Notify(SquadOwner, Player.Name.." has left your squad. [Reason: Left the game]", 5)
					end
				end
			end
		end
	end
	-- Checking for Cooldowns regarding the Player
	for key, _ in pairs(ServerCooldowns) do
		if string.find(key, Player.UserId) then
			-- clear
			ServerCooldowns[key] = nil
		end
	end
end)