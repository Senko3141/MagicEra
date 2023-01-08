-- Quests Module
--[[
	The client already checks if the player has the quest or not, and if the player is on cooldown. As well as server.
	No need to add these checks in for :CanTake(...)
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Squads = ReplicatedStorage.Squads
local Ranks = require(Modules.Shared.Ranks)

local QuestsModule = {
	Quests = {
		-- DAILY QUESTS --
		["parkour_daily"] = {
			Name = "Complete the parkour course.",
			Description = "--",
			Cooldown = 43200,

			ExtraData = {
				RankRequirement = "F",			},
			Rewards = { --// Just for visuals
				["Experience"] = 500,
				["Element_Experience"] = 500,
			},

			RemoveOnDeath = true,
			RemoveOnLeave = true,
			StoreQuestOnFinish = false,
			IsDailyQuest = true,

			MIN_RROGRESS = 0,
			MAX_PROGRESS = 1,

			CanTake = function(self, Data)
				if typeof(Data) ~= "table" then
					return false
				end

				local Player: Player = Data.Player
				if Player then
					local PlayerData = Player:FindFirstChild("Data")
					local ExtraData = self.ExtraData

					if PlayerData then
						local RankData = Ranks:GetData(ExtraData.RankRequirement)

						if PlayerData.Level.Value >= RankData.Level then
							return true
						end
					end

					return false, "You need to be at least ".. self.ExtraData.RankRequirement.."-Class to do this quest."
				end
			end,
		},
		
		
		-- F-CLASS QUESTS --
		["log_quest"] = {
			Name = "Collect Logs",
			Description = "Help the Lumber Jack collect, and transport logs.",
			Cooldown = 30,

			ExtraData = {
				RankRequirement = "F",				},
			Rewards = { --// Just for visuals
				["Experience"] = 300,
				["Element_Experience"] = 500,
			},

			RemoveOnDeath = true,
			RemoveOnLeave = true,
			StoreQuestOnFinish = false,

			MIN_RROGRESS = 0,
			MAX_PROGRESS = 4,
			--IGNORE_PROGRESS = true,

			CanTake = function(self, Data)
				if typeof(Data) ~= "table" then
					return false
				end

				local Player: Player = Data.Player
				if Player then
					local PlayerData = Player:FindFirstChild("Data")
					local ExtraData = self.ExtraData

					if PlayerData then
						local RankData = Ranks:GetData(ExtraData.RankRequirement)

						if PlayerData.Level.Value >= RankData.Level then
							return true
						end
					end

					return false, "You need to be at least ".. self.ExtraData.RankRequirement.."-Class to do this quest."
				end
			end,
		},
		["collect_flowers"] = {
			Name = "Collect Flowers",
			Description = "The flourist would like a boundle of our crowny flowers.",
			Cooldown = 1,

			ExtraData = {
				RankRequirement = "F",				},
			Rewards = { --// Just for visuals
				["Gold"] = 25,
				["Experience"] = 90,
			},

			RemoveOnDeath = false,
			RemoveOnLeave = true,
			StoreQuestOnFinish = false,

			MIN_RROGRESS = 0,
			MAX_PROGRESS = 10,

			CanTake = function(self, Data)
				if typeof(Data) ~= "table" then
					return false
				end

				local Player: Player = Data.Player
				if Player then
					local PlayerData = Player:FindFirstChild("Data")
					local ExtraData = self.ExtraData

					if PlayerData then
						local RankData = Ranks:GetData(ExtraData.RankRequirement)

						if PlayerData.Level.Value >= RankData.Level then
							return true
						end
					end

					return false, "You need to be at least ".. self.ExtraData.RankRequirement.."-Class to do this quest."
				end
			end,
		},
		["find_missing_cat"] = {
			Name = "Find the Missing Cat",
			Description = "George has lost his cat somewhere in the city. Please help him find it.",
			Cooldown = 60,

			ExtraData = {
				RankRequirement = "F",			},
			Rewards = { --// Just for visuals
				["Gold"] = 30,
				["Experience"] = 110,
			},

			RemoveOnDeath = false,
			RemoveOnLeave = true,
			StoreQuestOnFinish = false,

			MIN_RROGRESS = 0,
			MAX_PROGRESS = 1,

			CanTake = function(self, Data)
				if typeof(Data) ~= "table" then
					return false
				end

				local Player: Player = Data.Player
				if Player then
					local PlayerData = Player:FindFirstChild("Data")
					local ExtraData = self.ExtraData

					if PlayerData then
						local RankData = Ranks:GetData(ExtraData.RankRequirement)

						if PlayerData.Level.Value >= RankData.Level then
							return true
						end
					end

					return false, "You need to be at least ".. self.ExtraData.RankRequirement.."-Class to do this quest."
				end
			end,
		},


		-- E-CLASS QUESTS --
		["letter_hospital"] = {
			Name = "Deliver the Letter to the Hospital",
			Description = "Deliver the letter to the hopsital lady.",
			Cooldown = 75,

			ExtraData = {
				RankRequirement = "F",			},
			Rewards = { --// Just for visuals
				["Gold"] = 40,
				["Experience"] = 110,
			},

			RemoveOnDeath = false,
			RemoveOnLeave = true,
			StoreQuestOnFinish = false,

			MIN_RROGRESS = 0,
			MAX_PROGRESS = 1,

			CanTake = function(self, Data)
				if typeof(Data) ~= "table" then
					return false
				end

				local Player: Player = Data.Player
				if Player then
					local PlayerData = Player:FindFirstChild("Data")
					local ExtraData = self.ExtraData

					if PlayerData then
						local RankData = Ranks:GetData(ExtraData.RankRequirement)

						if PlayerData.Level.Value >= RankData.Level then
							return true
						end
					end

					return false, "You need to be at least ".. self.ExtraData.RankRequirement.."-Class to do this quest."
				end
			end,
		},
		["collect_squirrel"] = {
			Name = "Catch Tenrou Squirrels",
			Description = "Catch the squirrels running around Magnolia!",
			Cooldown = 180,

			ExtraData = {
				RankRequirement = "F",
			},
			Rewards = { --// Just for visuals
				["Gold"] = 70,
				["Experience"] = 132,
			},

			RemoveOnDeath = true,
			RemoveOnLeave = true,
			StoreQuestOnFinish = false,

			MIN_RROGRESS = 0,
			MAX_PROGRESS = 2,

			CanTake = function(self, Data)
				if typeof(Data) ~= "table" then
					return false
				end

				local Player: Player = Data.Player
				if Player then
					local PlayerData = Player:FindFirstChild("Data")
					local ExtraData = self.ExtraData

					if PlayerData then
						local RankData = Ranks:GetData(ExtraData.RankRequirement)

						if PlayerData.Level.Value >= RankData.Level then
							return true
						end
					end

					return false, "You need to be at least ".. self.ExtraData.RankRequirement.."-Class to do this quest."
				end
			end,
		},

		["deliver_squirrel"] = {
			Name = "Take the squirrels to the client",
			Description = "Deliver the squirrels to the boy in town.",
			Cooldown = 180,

			ExtraData = {
				RankRequirement = "F",
			},
			Rewards = { --// Just for visuals
				["Gold"] = 70,
				["Experience"] = 132,
			},

			RemoveOnDeath = true,
			RemoveOnLeave = true,
			StoreQuestOnFinish = false,

			MIN_RROGRESS = 0,
			MAX_PROGRESS = 1,

			CanTake = function(self, Data)
				if typeof(Data) ~= "table" then
					return false
				end

				local Player: Player = Data.Player
				if Player then
					local PlayerData = Player:FindFirstChild("Data")
					local ExtraData = self.ExtraData

					if PlayerData then
						local RankData = Ranks:GetData(ExtraData.RankRequirement)

						if PlayerData.Level.Value >= RankData.Level then
							return true
						end
					end

					return false, "You need to be at least ".. self.ExtraData.RankRequirement.."-Class to do this quest."
				end
			end,
		},

		["kill_hodras"] = {
			Name = "Dispatch Hodras",
			Description = "Go into the Forest, and take care of the pack of Hodras.",
			Cooldown = 30,

			ExtraData = {
				RankRequirement = "E",
			},
			Rewards = { --// Just for visuals
				["Gold"] = 125,
				["Experience"] = 850,
			},

			RemoveOnDeath = false,
			RemoveOnLeave = true,
			StoreQuestOnFinish = false,

			MIN_RROGRESS = 0,
			MAX_PROGRESS = 4,

			CanTake = function(self, Data)
				if typeof(Data) ~= "table" then
					return false
				end

				local Player: Player = Data.Player
				if Player then
					local PlayerData = Player:FindFirstChild("Data")
					local ExtraData = self.ExtraData

					if PlayerData then
						local RankData = Ranks:GetData(ExtraData.RankRequirement)

						if PlayerData.Level.Value >= RankData.Level then
							return true
						end
					end

					return false, "You need to be at least ".. self.ExtraData.RankRequirement.."-Class to do this quest."
				end
			end,
		},
		["kill_thugs"] = {
			Name = "Deal With The Thugs",
			Description = "Go into town, and take care of the delinquents causing trouble.",
			Cooldown = 30,

			ExtraData = {
				RankRequirement = "E",
			},
			Rewards = { --// Just for visuals
				["Gold"] = 100,
				["Experience"] = 450,
				["Element_Experience"] = 100,

			},

			RemoveOnDeath = true,
			RemoveOnLeave = true,
			StoreQuestOnFinish = false,

			MIN_RROGRESS = 0,
			MAX_PROGRESS = 4,

			CanTake = function(self, Data)
				if typeof(Data) ~= "table" then
					return false
				end

				local Player: Player = Data.Player
				if Player then
					local PlayerData = Player:FindFirstChild("Data")
					local ExtraData = self.ExtraData

					if PlayerData then
						local RankData = Ranks:GetData(ExtraData.RankRequirement)

						if PlayerData.Level.Value >= RankData.Level then
							return true
						end
					end

					return false, "You need to be at least ".. self.ExtraData.RankRequirement.."-Class to do this quest."
				end
			end,
		},
		["deliver_barrel"] = {
			Name = "Deliver the Barrel",
			Description = "Take the goods to the client within the forest.",
			Cooldown = 43200,

			ExtraData = {
				RankRequirement = "E",
			},
			Rewards = { --// Just for visuals
				Gold = 170,
				Experience = 3000,
				Element_Experience = 400,

			},

			RemoveOnDeath = true,
			RemoveOnLeave = true,
			StoreQuestOnFinish = false,
			IsDailyQuest = true,

			MIN_RROGRESS = 0,
			MAX_PROGRESS = 1,

			CanTake = function(self, Data)
				if typeof(Data) ~= "table" then
					return false
				end

				local Player: Player = Data.Player
				if Player then
					local PlayerData = Player:FindFirstChild("Data")
					local ExtraData = self.ExtraData

					if PlayerData then
						local RankData = Ranks:GetData(ExtraData.RankRequirement)

						if PlayerData.Level.Value >= RankData.Level then
							return true
						end
					end

					return false, "You need to be at least ".. self.ExtraData.RankRequirement.."-Class to do this quest."
				end
			end,
		},
		["assassination"] = {
			Name = "Assassination",
			Description = "Assassinate the target.",
			Cooldown = 600,

			ExtraData = {
				RankRequirement = "F",
			},
			Rewards = { --// Just for visuals
				Gold = 130,
				Experience = 850,
				Element_Experience = 150,

			},

			RemoveOnDeath = true,
			RemoveOnLeave = true,
			StoreQuestOnFinish = false,
			IsDailyQuest = false,

			MIN_RROGRESS = 0,
			MAX_PROGRESS = 1,

			CanTake = function(self, Data)
				if typeof(Data) ~= "table" then
					return false
				end

				local Player: Player = Data.Player
				if Player then
					local PlayerData = Player:FindFirstChild("Data")
					local ExtraData = self.ExtraData

					if PlayerData then
						local RankData = Ranks:GetData(ExtraData.RankRequirement)

						if PlayerData.Level.Value >= RankData.Level then
							return true
						end
					end

					return false, "You need to be at least ".. self.ExtraData.RankRequirement.."-Class to do this quest."
				end
			end,
		},
		["defeat_highwaymen"] = {
			Name = "Defeat the Highwaymen",
			Description = "Now you've dealt with those thugs, deliver the barrel to the client.",
			Cooldown = 43200,

			ExtraData = {
				RankRequirement = "E",
			},
			Rewards = { --// Just for visuals
				Gold = 170,
				Experience = 3000,
				Element_Experience = 400,

			},

			RemoveOnDeath = true,
			RemoveOnLeave = true,
			StoreQuestOnFinish = false,

			MIN_RROGRESS = 0,
			MAX_PROGRESS = 2,

			CanTake = function(self, Data)
				if typeof(Data) ~= "table" then
					return false
				end

				local Player: Player = Data.Player
				if Player then
					local PlayerData = Player:FindFirstChild("Data")
					local ExtraData = self.ExtraData

					if PlayerData then
						local RankData = Ranks:GetData(ExtraData.RankRequirement)

						if PlayerData.Level.Value >= RankData.Level then
							return true
						end
					end

					return false, "You need to be at least ".. self.ExtraData.RankRequirement.."-Class to do this quest."
				end
			end,
		},
		["continue_barrel"] = {
			Name = "Finish Delivering the Barrel",
			Description = "Take care of these thieves and get the cargo delivered to the client.",
			Cooldown = 43200,

			ExtraData = {
				RankRequirement = "E",
			},
			Rewards = { --// Just for visuals
				Gold = 170,
				Experience = 3000,
				Element_Experience = 400,

			},

			RemoveOnDeath = true,
			RemoveOnLeave = true,
			StoreQuestOnFinish = false,

			MIN_RROGRESS = 0,
			MAX_PROGRESS = 1,

			CanTake = function(self, Data)
				if typeof(Data) ~= "table" then
					return false
				end

				local Player: Player = Data.Player
				if Player then
					local PlayerData = Player:FindFirstChild("Data")
					local ExtraData = self.ExtraData

					if PlayerData then
						local RankData = Ranks:GetData(ExtraData.RankRequirement)

						if PlayerData.Level.Value >= RankData.Level then
							return true
						end
					end

					return false, "You need to be at least ".. self.ExtraData.RankRequirement.."-Class to do this quest."
				end
			end,
		},
		["save_hostage"] = {
			Name = "Save the Hostage",
			Description = "Defeat the bandits and save the hostage from the bandit camp.",
			Cooldown = 50,

			ExtraData = {
				RankRequirement = "D",
			},
			Rewards = { --// Just for visuals
				Gold = 500,
				Experience = 1500,
				Element_Experience = 400,

			},

			RemoveOnDeath = true,
			RemoveOnLeave = true,
			StoreQuestOnFinish = false,

			MIN_RROGRESS = 0,
			MAX_PROGRESS = 5,

			CanTake = function(self, Data)
				if typeof(Data) ~= "table" then
					return false
				end

				local Player: Player = Data.Player
				if Player then
					local PlayerData = Player:FindFirstChild("Data")
					local ExtraData = self.ExtraData

					if PlayerData then
						local RankData = Ranks:GetData(ExtraData.RankRequirement)

						if PlayerData.Level.Value >= RankData.Level then
							return true
						end
					end

					return false, "You need to be at least ".. self.ExtraData.RankRequirement.."-Class to do this quest."
				end
			end,
		},
	}
	
}

function QuestsModule.GetQuestFromId(id)
	return QuestsModule.Quests[id]
end

function QuestsModule.RefreshQuests(QuestRank)
	local toreturn
	local F = {
		[1] = "collect_flowers",
		[2] = "find_missing_cat",
		[3] = "letter_hospital",
		[4] = "collect_squirrel",

	}

	local E = {
		[1] = "kill_thugs",
		[2] = "kill_hodras",
	}

	local D = {
		[1] = "save_hostage",
	}

	if QuestRank == "F" then
		toreturn = F[math.random(1,#F)]
	elseif QuestRank == "E" then
		toreturn = E[math.random(1,#E)]
	elseif QuestRank == "D" then
		toreturn = D[math.random(1,#D)]
	end

	return toreturn
end


function QuestsModule.CheckSquad(Target)
		local DataToReturn = {
		Owner = false
	}
	
		-- Checking if is the owner of a squad
		if Squads:FindFirstChild(Target.UserId.."'s Squad") then
		DataToReturn.Owner = Target.UserId
		return true, DataToReturn
		end
		-- Checking if is a member of a squad
		if #Squads:GetChildren() > 0 then
			for _,squad in pairs(Squads:GetChildren()) do
				local Members = squad:FindFirstChild("Members")
				if Members:FindFirstChild(Target.UserId) then
					local OwnerID = squad.Owner.Value
					DataToReturn.Owner = OwnerID
					return true, DataToReturn
				end
			end
		end
		--
		return false, DataToReturn
end

return QuestsModule