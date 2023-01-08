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
		
		Text = "Senko is the best brother I ever had!",
		LastDialogue = true,
		
		DoSuccessFunction = function(...)
			
		end,
		
		Responses = { -- Will be displayed in the respsective order
			[1] = "I agree!",
			[2] = "Nah."
		},
		Redirects = {
			-- can start options
			[false] = "CAN'T INTERACT",
			
			-- proceed options
			[1] = "Terminate/Success",
			[2] = "Terminate"
		}
	},
}