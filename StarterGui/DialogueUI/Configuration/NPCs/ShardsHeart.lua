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

		Text = "Travel Waypoints are a great way to travel across the kingdoms.",
		LastDialogue = false,

		Responses = { -- Will be displayed in the respsective order
			[1] = "Really..?",
			[2] = "Goodbye."
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
			return true
		end,
		
		Text = "I can sell you something that'll allow you use to them... I think. You in?",
		LastDialogue = true,
		DoSuccessFunction = function(...)
			ReplicatedStorage.Remotes.FastTravel:FireServer("PurchaseGrace", {})
		end,

		Responses = {
			[1] = "Yeah sure.",
			[2] = "Nah, I'm good.",
		},
		Redirects = {
			-- can start options
			[false] = "CAN'T INTERACT",

			-- proceed options
			[1] = "Terminate/Success",
			[2] = "Terminate",

		}
	},
	-- Separate Dialogues
	["CAN'T INTERACT"] = {
		canStart = function(...)
			return true
		end,

		Text = "N/A",
		LastDialogue = false,

		Responses = {
			[1] = "Okay.",
		},
		Redirects = {
			[1] = "Terminate",
		}
	}
}