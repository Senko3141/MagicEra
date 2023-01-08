-- Configuration "Template"
--[[
	The function "canStart" is to be ran before each dialogue to assure that the player can interact
	or continue the dialogue.
	
	The redirect "Terminate" ends the entire dialogue.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Ranks = require(Modules.Shared.Ranks)

return {
	[1] = {
		canStart = function(...)
			local Arguments = {...}
			local Character = Arguments[1]

			return true
		end,

		Text = "I heard outside of magnolia is scary.",
		LastDialogue = false,

		Responses = { -- Will be displayed in the respsective order
			[1] = "Really?.",
			[2] = "Okay"
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
			local Quests = PlayerData.Quests:FindFirstChild("letter_hospital")
			local Level = PlayerData.Level.Value

			if not Quests then
				print("nope")
				return false
			end

			return true
		end,

		Text = "Yeah i dont suggest going out there unless you're high ranking.",
		LastDialogue = true,
		DoSuccessFunction = function(...)
			-- success version, fired whenever the "1" option is clicked
			local Arguments = {...}
			local Player = Arguments[1]			

			
		end,

		Responses = {
			[1] = "Thank You.",
		},
		Redirects = {
			-- can start options
			[false] = "CAN'T INTERACT",

			-- proceed options
			[1] = "Terminate/Success",
		}
	},
	-- Separate Dialogues
	["CAN'T INTERACT"] = {
		canStart = function(...)
			return true
		end,

		Text = "Yeah i dont suggest going out there unless you're high ranking.",
		LastDialogue = false,

		Responses = {
			[1] = "Okay.",
		},
		Redirects = {
			[1] = "Terminate",
		}
	}
}