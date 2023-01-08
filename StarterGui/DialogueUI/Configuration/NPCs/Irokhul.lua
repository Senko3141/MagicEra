-- Configuration "Template"
--[[
	The function "canStart" is to be ran before each dialogue to assure that the player can interact
	or continue the dialogue.
	
	The redirect "Terminate" ends the entire dialogue.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Rates = require(Modules.Shared.Rates)

return {
	[1] = {
		canStart = function(...)
			local Arguments = {...}
			local Character = Arguments[1]
			
			return true
		end,
		
		Text = "Greetings, the one you are speaking to is Irokhul.",
		LastDialogue = false,
		
		Responses = { -- Will be displayed in the respsective order
			[1] = "Hello, i'm looking to imbue my magic into my weapons.",
			[2] = "Bye."
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
			local Level = PlayerData.Level.Value
						
			if Level < 25 then
				return false
			end
			--[[
			local rarity = Rates.Elements[PlayerData.Element.Value]
			if rarity == "Common" or rarity == "Uncommon" or rarity == "Rare" then
				return false
			end
			]]--
			
			if PlayerData.Gold.Value < 3000 then
				return false
			end
			
			return true
		end,
		
		Text = "Well... it seems like you meet the requirements. Your magic has been imbued within your weapon(s).",
		LastDialogue = false,
		DoSuccessFunction = function(...)
			-- success version, fired whenever the "1" option is clicked
			local Arguments = {...}
			local Player = Arguments[1]
			
			ReplicatedStorage.Remotes.ImbueMagic:FireServer()
		end,

		Responses = {
			[1] = "Alright.",
		},
		Redirects = {
			-- can start options
			[false] = "CAN'T INTERACT",

			-- proceed options
			[1] = 3,
		}
	},
	[3] = {
		canStart = function(...)
			return true
		end,

		Text = "Would you like to imbue your weapons with magic?",
		LastDialogue = true,
		DoSuccessFunction = function(...)
			-- success version, fired whenever the "1" option is clicked
			local Arguments = {...}
			local Player = Arguments[1]

			ReplicatedStorage.Remotes.ImbueMagic:FireServer()
		end,

		Responses = {
			[1] = "Yes.",
			[2] = "No thanks."
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
		
		Text = "It seems like you do not meet the requirements. You must be level [25+],The requirement for this process is $3,000.",
		LastDialogue = false,

		Responses = {
			[1] = "Okay.",
		},
		Redirects = {
			[1] = "Terminate",
		}
	}
}