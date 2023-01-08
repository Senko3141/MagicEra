-- Configuration "Template"
--[[
	The function "canStart" is to be ran before each dialogue to assure that the player can interact
	or continue the dialogue.
	
	The redirect "Terminate" ends the entire dialogue.
]]
return {
	[1] = {
		canStart = function(...)
			local Arguments = {...}
			local Character = Arguments[1]
			
			return true
		end,
		
		Text = "Hello, I'm Natsu. What do you need?",
		LastDialogue = false,
		
		Responses = { -- Will be displayed in the respsective order
			[1] = "I'm looking to turn in my Dragon Lacrima.",
			[2] = "Nothing."
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
			
			if not Player.Data.Items.Trinkets:FindFirstChild("Dragon Lacrima") then
				return false
			end
			return true
		end,
		
		Text = "Alright.",
		LastDialogue = true,
		DoSuccessFunction = function(...)
			game.ReplicatedStorage.Remotes.DragonLacrima:FireServer()
		end,

		Responses = {
			[1] = "Thanks.",
		},
		Redirects = {
			[1] = "Terminate/Success",
			[false] = "CAN'T INTERACT",
		}
	},
	-- Separate Dialogues
	["CAN'T INTERACT"] = {
		canStart = function(...)
			return true
		end,
		
		Text = "It seems like you do not have a Dragon Lacrima.",
		LastDialogue = false,

		Responses = {
			[1] = "Okay.",
			[2] = "Wow."
		},
		Redirects = {
			[1] = "Terminate",
			[2] = "Terminate",
		}
	}
}