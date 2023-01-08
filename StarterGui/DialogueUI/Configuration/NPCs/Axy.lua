-- Configuration "Template"
--[[
	The function "canStart" is to be ran before each dialogue to assure that the player can interact
	or continue the dialogue.
	
	The redirect "Terminate" ends the entire dialogue.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local triggerinfo = require(Modules.Shared.TriggerInfo)
local Ranks = require(Modules.Shared.Ranks)

return {
	[1] = {
		canStart = function(...)
			local Arguments = {...}
			local Character = Arguments[1]
			
			return true
		end,
		
		Text = "Hey, are you interested in delivering something for me?",
		LastDialogue = false,
		
		Responses = { -- Will be displayed in the respsective order
			[1] = "Sure.",
			[2] = "No thanks..."
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
						
			if Level < Ranks.Ranks[3].Level then
				return false
			end
			
			if PlayerData.QuestCooldowns:FindFirstChild("deliver_barrel") then
				if os.time() - PlayerData.QuestCooldowns["deliver_barrel"].Value < 43200 then
					return false
				end
				if triggerinfo.Highwayman ~= true then
					return false
				end
			end
			
			return true
		end,
		
		Text = "Well, you seem reliable, good luck and thank you!",
		LastDialogue = true,
		DoSuccessFunction = function(...)
			-- success version, fired whenever the "1" option is clicked
			local Arguments = {...}
			local Player = Arguments[1]			
			
			game.ReplicatedStorage.Remotes.Quest:FireServer("Start", {
				Name = "deliver_barrel",
			})
		end,

		Responses = {
			[1] = "Thanks.",
			[2] = "Nevermind. I won't take this.",
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
		
		Text = "Hmmmh, on second thought, come back at a later date, it seems I don't need anything taking right now.",
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