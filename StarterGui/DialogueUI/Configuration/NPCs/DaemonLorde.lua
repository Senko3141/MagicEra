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
		
		Text = "Hey, what's up. Are you looking to sell some items?",
		LastDialogue = true,
		DoSuccessFunction = function(...)
			-- success version, fired whenever the "1" option is clicked
			local Arguments = {...}
			local Player = Arguments[1]			

			warn("[SUCCESS] FINISHED WITH DIALOGUE", "CURRENT GUILD")
			Player.PlayerGui.SellingSystem.Root.Main:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			Player.PlayerGui.SellingSystem.Events.Update:Fire()	
		end,
		
		Responses = { -- Will be displayed in the respsective order
			[1] = "Yeah.",
			[2] = "Nah."
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
			local Character = Arguments[1]

			return true
		end,

		Text = "Please pick an option.",
		LastDialogue = true,
		DoSuccessFunction = function(...)
			-- success version, fired whenever the "1" option is clicked
			local Arguments = {...}
			local Player = Arguments[1]			
			local response = Arguments[2]
			
			if response == 1 then			
				Player.PlayerGui.SellingSystem.Root.Main:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
				Player.PlayerGui.SellingSystem.Events.Update:Fire()	
			end
			if response == 2 then
				Player.PlayerGui.SellingSystem.Root.ConfirmationWeapon:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			end
		end,

		Responses = { -- Will be displayed in the respsective order
			[1] = "Sell Collectibles",
			[2] = "Sell Primary Weapon."
		},
		Redirects = {
			-- can start options
			[false] = "CAN'T INTERACT",

			-- proceed options
			[1] = "Terminate/Success",
			[2] = "Terminate/Success"
		}
	},
}