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
		
		Text = "Hello, I'm the Guildmaster, Avax. Are you looking to create a guild? [Requirements: D-Rank]",
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
			
			
			local PlayerData = Player:FindFirstChild("Data")
			local Level = PlayerData.Level.Value
						
			if Level < Ranks.Ranks[2].Level then
				return false
			end
			if PlayerData.Gold.Value <= 500 then
				return false
			end
			
			return true
		end,
		
		Text = "Well... it seems like you meet the requirements. Please choose your name wisely.",
		LastDialogue = true,
		DoSuccessFunction = function(...)
			-- success version, fired whenever the "1" option is clicked
			local Arguments = {...}
			local Player = Arguments[1]			
			
			warn("[SUCCESS] FINISHED WITH DIALOGUE", "CURRENT GUILD")
			Player.PlayerGui.GuildGui.Creation:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
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
	-- Separate Dialogues
	["CAN'T INTERACT"] = {
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
	}
}