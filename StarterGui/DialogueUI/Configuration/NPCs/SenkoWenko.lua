-- Configuration "Template"
--[[
	The function "canStart" is to be ran before each dialogue to assure that the player can interact
	or continue the dialogue.
	
	The redirect "Terminate" ends the entire dialogue.
]]
local QuestName = "F-Class Quest"
return {
	[1] = {
		canStart = function(...)
			local Arguments = {...}
			local Character = Arguments[1]
			
			return true
		end,
		
		Text = "Hello, I'm Senko. Do you need anything?",
		LastDialogue = false,
		
		Responses = { -- Will be displayed in the respsective order
			[1] = "Yeah, I'm looking to take quest.",
			[2] = "Nah, I'm just looking around."
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
		
		Text = "Alright here.",
		LastDialogue = true,
		DoSuccessFunction = function(...)
			-- success version, fired whenever the "1" option is clicked
			local Arguments = {...}

			warn("[SUCCESS] FINISHED WITH DIALOGUE")
			game.ReplicatedStorage.Remotes.Quest:FireServer("Start", {
				["Name"] = QuestName
			})
		end,

		Responses = {
			[1] = "Thanks.",
		},
		Redirects = {
			[1] = "Terminate/Success",
		}
	},
	-- Separate Dialogues
	["CAN'T INTERACT"] = {
		canStart = function(...)
			return true
		end,
		
		Text = "You cannot interact with me right now. Please come back later.",
		LastDialogue = false,

		Responses = {
			[1] = "Okay.",
			[2] = "Screw you. >:("
		},
		Redirects = {
			[1] = "Terminate",
			[2] = "Terminate",
		}
	}
}