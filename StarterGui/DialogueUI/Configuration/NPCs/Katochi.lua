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

		Text = "Hey, I'm the helper, Katochi. Do you need any tips?",
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
			return true
		end,

		Text = "Start by doing quest in magnolia until you're E-Class, I'll give you some jewels to start you off.",
		LastDialogue = true,
		DoSuccessFunction = function(...)
			-- success version, fired whenever the "1" option is clicked
			local Arguments = {...}
			local Player = Arguments[1]			
			
			local PlayerData = Player:FindFirstChild("Data")
			if PlayerData then
				if PlayerData.StarterJewels.Value then
					return
				else
					ReplicatedStorage.Remotes.StarterJewels:FireServer()
				end
			end
		end,

		Responses = {
			[1] = "No worries.",
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

		Text = "Start by going to the Fairy Tail Guild Hall. That's where everything begins. I'll give you some jewels to start you off.",
		LastDialogue = false,

		Responses = {
			[1] = "Okay, thanks.",
		},
		Redirects = {
			[1] = "Terminate",
		}
	}
}