local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local Codes = {
	

	

	["Template"] = {
		Name = "Template",
		ClaimFunc = function(Player, PlayerData)
			if not RunService:IsServer() then
				return
			end
			if PlayerData.Codes:FindFirstChild("Template") then
				return
			end
			--PlayerData.Spins.Value += 15
			--PlayerData.Gold.Value += 1
			
			game.ReplicatedStorage.Remotes.Notify:FireClient(Player, "Sub2Shael", 8)
			return true
		end,
	},
	["YOUTHOUGHTTTTTTT"] = {
		Name = "YOUTHOUGHTTTTTTT",
		ClaimFunc = function(Player, PlayerData)
			if not RunService:IsServer() then
				return
			end
			if PlayerData.Codes:FindFirstChild("YOUTHOUGHTTTTTTT") then
				return
			end
			local GlobalData = Player:FindFirstChild("GlobalData")
			if GlobalData then
				GlobalData.Spins.Value += 60
			end
			return true
		end,
	},

	["TEST1"] = {
		Name = "TEST1",
		ClaimFunc = function(Player, PlayerData)
			if not RunService:IsServer() then
				return
			end
			if PlayerData.Codes:FindFirstChild("TEST1") then
				return
			end
			game.ReplicatedStorage.Remotes.Notify:FireClient(Player, "Hello u have tested", 8)
			return true
		end,
	},
	
	
	
	

	
}



return Codes