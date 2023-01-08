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

		Text = "Are you looking for work? [Assassination Quest]",
		LastDialogue = false,

		Responses = { -- Will be displayed in the respsective order
			[1] = "Yes, I am.",
			[2] = "No, thanks."
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
			if Player.Data.Quests:FindFirstChild("assassination") then
				return false
			end
			return true
		end,
		
		Text = "Let me see what I can do.",
		LastDialogue = true,
		DoSuccessFunction = function(...)
			-- success version, fired whenever the "1" option is clicked
			local Arguments = {...}
			local Player = Arguments[1]			
			game.ReplicatedStorage.Remotes.Quest:FireServer("Start", {
				Name = "assassination",
			})
		end,

		Responses = {
			[1] = "Thanks.",
		},
		Redirects = {
			-- can start options
			[false] = "CAN'T INTERACT",

			-- proceed options
			[1] = "Terminate/Success",
		}
	},
	["CAN'T INTERACT"] = {
		canStart = function(...)
			return true
		end,

		Text = "I don't have any targets for you right now, come back later.",
		LastDialogue = false,

		Responses = {
			[1] = "Okay.",
		},
		Redirects = {
			[1] = "Terminate",
		}
	}
	-- Separate Dialogues
--[[["CAN'T INTERACT"] = {
		canStart = function(...)
			return true
		end,
		
		Text = "Guild creation failed. Please come back when you meet the requirements. | Requirements: D-Class, $10000",
		LastDialogue = false,

		Responses = {
			[1] = "Okay.",
			[2] = "Bruh."
		},
		Redirects = {
			[1] = "Terminate",
			[2] = "Terminate",
		}
	}]]
}