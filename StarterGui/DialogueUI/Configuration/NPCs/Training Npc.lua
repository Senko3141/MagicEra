--- Configuration "Template"
--[[
	The function "canStart" is to be ran before each dialogue to assure that the player can interact
	or continue the dialogue.
	
	The redirect "Terminate" ends the entire dialogue.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local rem = ReplicatedStorage.Remotes.Purchase


local Modules = ReplicatedStorage:WaitForChild("Modules")
local Ranks = require(Modules.Shared.Ranks)

return {
	[1] = {
		canStart = function(...)
			local Arguments = {...}
			local Character = Arguments[1]

			return true
		end,

		Text = "Would you like to buy some trainings?",
		LastDialogue = false,

		Responses = { -- Will be displayed in the respsective order
			[1] = "Yes.",
			[2] = "No"
		},
		Redirects = {
			-- can start options
			[false] = "CAN'T INTERACT",

			-- proceed options
			[1] = 2,
			[2] = "Terminate"
		}
	},
	[2] = {		
		canStart = function(...)
			local Arguments = {...}
			local Player = Arguments[1]


			local PlayerData = Player:FindFirstChild("Data")
			local Money = PlayerData.Gold

			if Money.Value < 50 then
				return false
			end
			return true
		end,
		
		Text = "Which? They all cost $50 each.",
		LastDialogue = false,

		Responses = {
			[1] = "Pushup training.",
			[2] = "Situp training.",
			[3] = "Squat training.",
			[4] = "Mana training.",
			[5] = "Magic training.",
			[6] = "Nevermind."
		},
		Redirects = {
			-- can start options
			[false] = "CAN'T INTERACT",

			-- proceed options
			[1] = 3 ,
			[2] = 3 ,
			[3] = 3 ,
			[4] = 3 ,
			[5] = 3 ,
			[6] = "Terminate",

		}
	},
	[3] = {
		canStart = function(...)
			local Arguments = {...}
			local Character = Arguments[1]

			return true
		end,

		Text = "How many?",
		LastDialogue = true,
		DoSuccessFunction = function(...)
			-- success version, fired whenever the "1" option is clicked
			local Arguments = {...}
			local Player = Arguments[1]	
			local itemdict ={
				[1] = "Pushup Training",
				[2] = "Situp Training",
				[3] = "Squat Training",
				[4] = "Mana Training",
				[5] = "Magic Training",
			}
			local amounts = {
				[1] = 1,
				[2] = 5,
				[3] = 10,
				[4] = 15,
			}
			local item = itemdict[Arguments[3]]
			rem:FireServer(item,amounts[tonumber(Arguments[2])])	
		end,

		Responses = { -- Will be displayed in the respsective order
			[1] = "1",
			[2] = "5",
			[3] = "10",
			[4] = "15",
			[5] = "Nevermind."
		},
		Redirects = {
			-- can start options
			[false] = "CAN'T INTERACT",

			-- proceed options
			[1] = "Terminate/Success",
			[2] = "Terminate/Success",
			[3] = "Terminate/Success",
			[4] = "Terminate/Success",
			[5] = "Terminate",
		}
	},
	-- Separate Dialogues
	["CAN'T INTERACT"] = {
		canStart = function(...)
			return true
		end,

		Text = "Come back when you got money, trainings are $50 each.",
		LastDialogue = false,

		Responses = {
			[1] = "Okay.",
		},
		Redirects = {
			[1] = "Terminate",
		}
	}
}