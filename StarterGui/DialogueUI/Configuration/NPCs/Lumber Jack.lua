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
			local Player = Arguments[1]


			local PlayerData = Player:FindFirstChild("Data")
			local Level = PlayerData.Level.Value

			if PlayerData.QuestCooldowns:FindFirstChild("log_quest") then
				if os.time() - PlayerData.QuestCooldowns["log_quest"].Value < 30 then
					return false
				end
			end

			return true
		end,
		
		Text = "Hey, can you help me real quick? I need someone to help pick up some logs...",
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
			
			if PlayerData.QuestCooldowns:FindFirstChild("log_quest") then
				if os.time() - PlayerData.QuestCooldowns["log_quest"].Value < 30 then
					return false
				end
			end
			
			return true
		end,
		
		Text = "Thank you so much!",
		LastDialogue = true,
		DoSuccessFunction = function(...)
			-- success version, fired whenever the "1" option is clicked
			local Arguments = {...}
			local Player = Arguments[1]			
			
			game.ReplicatedStorage.Remotes.Quest:FireServer("Start", {
				Name = "log_quest",
			})
		end,

		Responses = {
			[1] = "No worries.",
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
		
		Text = "...",
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