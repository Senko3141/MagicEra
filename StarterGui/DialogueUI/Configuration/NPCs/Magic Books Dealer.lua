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

		Text = "Interested in anything you see?",
		LastDialogue = false,

		Responses = { -- Will be displayed in the respsective order
			[1] = "Magic Books...",
			[2] = "Nothing in particular..."
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
			return true
		end,
		
		Text = "Well, take your pick!",
		LastDialogue = true,
		DoSuccessFunction = function(...)
			-- success version, fired whenever the "1" option is clicked
			local Arguments = {...}
			local Player = Arguments[1]	
			local itemdict = {
				[1] = "Magic Book I",
				[2] = "Magic Book II",
				[3] = "Magic Book III",
				[4] = "Magic Book IV",
			}
			local item = itemdict[Arguments[2]]
			rem:FireServer(item,1)	
		end,

		Responses = {
			[1] = "Magic Book I ($500)",
			[2] = "Magic Book II ($2,000)",
			[3] = "Magic Book III ($5,000)",
			[4] = "Magic Book IV ($10,000)",
			[5] = "Nevermind."
		},
		Redirects = {
			-- can start options
			[false] = "CAN'T INTERACT",

			-- proceed options
			[1] = "Terminate/Success" ,
			[2] = "Terminate/Success" ,
			[3] = "Terminate/Success" ,
			[4] = "Terminate/Success" ,
			[5] = "Terminate" ,

		}
	},
	-- Separate Dialogues
	["CAN'T INTERACT"] = {
		canStart = function(...)
			return true
		end,

		Text = "...",
		LastDialogue = false,

		Responses = {
			[1] = "...",
		},
		Redirects = {
			[1] = "Terminate",
		}
	}
}