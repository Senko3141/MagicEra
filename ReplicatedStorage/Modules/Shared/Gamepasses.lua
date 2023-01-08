local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Names = require(Modules.Shared.Names)
local Races = require(Modules.Shared.Races)

local Products = {
	["Gamepasses"] = {
		[1256825783] = {
			Name = "Reset Stat Points",
			Description = "Resets all your stat points.",
			Type = "DevProduct",
			Func = function(Player)
				if not RunService:IsServer() then 
					return false
				end
				local PlayerData = Player:WaitForChild("Data")
				local Total = 0
				
				for _,stat in pairs(PlayerData.Stats:GetChildren()) do
					Total += stat.Value
					stat.Value = 0
				end
				
				PlayerData.TrueInvestmentPoints.Value += Total
				game.ReplicatedStorage.Remotes.Notify:FireClient(Player, "You have received ["..Total.."] True Investment Points because of your purchase!", 5)
				return true
			end,
		},
		[1257547941] = {
			Name = "Reroll Hair Color",
			Description = "Reroll your hair color.",
			Type = "DevProduct",
			Func = function(Player)
				if not RunService:IsServer() then 
					return false
				end
				local PlayerData = Player:WaitForChild("Data")
				local randomized = Color3.fromRGB(math.random(1,255), math.random(1,255), math.random(1,255))
				PlayerData.HairColor.Value = math.floor(randomized.R*255)..","..math.floor(randomized.G*255)..","..math.floor(randomized.B*255)
				return true
			end,
		},
		[39476260] = {
			Name = "Wear Your Own Clothing",
			Type = "Gamepass",
			Func = function(Player)
				if not RunService:IsServer() then 
					return false
				end
				return true
			end,
		},
		[38416129] = {
			Name = "Instant Spin Skip",
			Type = "Gamepass",
			Func = function(Player)
				if not RunService:IsServer() then 
					return false
				end
				return true
			end,
		},
		[39135169] = {
			Name = "2x Magic Exp",
			Type = "Gamepass",
			Func = function(Player)
				if not RunService:IsServer() then 
					return false
				end
				return true
			end,
		},
		
		[39135332] = {
			Name = "2x Level Exp",
			Type = "Gamepass",
			Func = function(Player)
				if not RunService:IsServer() then 
					return false
				end
				return true
			end,
		},
		
		[39136365] = {
			Name = "2x Magic Chance",
			Type = "Gamepass",
			Func = function(Player)
				if not RunService:IsServer() then 
					return false
				end
				return true
			end,
		},
		--[[
		[40138218] = {
			Name = "2x Gold",
			Type = "Gamepass",
			Func = function(Player)
				if not RunService:IsServer() then 
					return false
				end
				return true
			end,
		},
		]]
		[42235384] = { -- 42235384
			Name = "Magic Storage",
			Type = "Gamepass",
			Func = function(Player)
				if not RunService:IsServer() then 
					return false
				end
				return true
			end,
		},
		
		-- Spins
		[1256825784] = { -- 42235384
			Name = "1 Spin",
			Type = "DevProduct",
			Description = "+1 Spin",
			IgnoreInMain = true,
			Func = function(Player)
				if not RunService:IsServer() then 
					return false
				end
				local PlayerData = Player:WaitForChild("GlobalData")
				PlayerData.Spins.Value += 1
				return true
			end,
		},
		[1264406654] = { -- 42235384
			Name = "10 Spins",
			Type = "DevProduct",
			Description = "+10 Spins",
			IgnoreInMain = true,
			Func = function(Player)
				if not RunService:IsServer() then 
					return false
				end
				local PlayerData = Player:WaitForChild("GlobalData")
				PlayerData.Spins.Value += 10
				return true
			end,
		},
		[1264406655] = { -- 42235384
			Name = "30 Spins",
			Type = "DevProduct",
			Description = "+30 Spins",
			IgnoreInMain = true,
			Func = function(Player)
				if not RunService:IsServer() then 
					return false
				end
				local PlayerData = Player:WaitForChild("GlobalData")
				PlayerData.Spins.Value += 30
				return true
			end,
		},
		[1264406657] = { -- 42235384
			Name = "60 Spins",
			Type = "DevProduct",
			Description = "+60 Spins",
			IgnoreInMain = true,
			Func = function(Player)
				if not RunService:IsServer() then 
					return false
				end
				local PlayerData = Player:WaitForChild("GlobalData")
				PlayerData.Spins.Value += 60
				return true
			end,
		},
		
		--
		[1265519011] = { -- 42235384
			Name = "Reroll Eye Color",
			Type = "DevProduct",
			Description = "Rerolls your eye color.",
			Func = function(Player)
				if not RunService:IsServer() then 
					return false
				end
				local PlayerData = Player:WaitForChild("Data")
				local randomized = Color3.fromRGB(math.random(1,255), math.random(1,255), math.random(1,255))
				PlayerData.EyeColor.Value = math.floor(randomized.R*255)..","..math.floor(randomized.G*255)..","..math.floor(randomized.B*255)
				return true
			end,
		},
		[1269473196] = { -- 42235384
			Name = "Reroll Last Name",
			Type = "DevProduct",
			Description = "Rerolls your last name.",
			Func = function(Player)
				if not RunService:IsServer() then 
					return false
				end
				local PlayerData = Player:WaitForChild("Data")
				local new = Names:Roll()
				
				PlayerData.LastName.Value = new
				game.ReplicatedStorage.Remotes.Notify:FireClient(Player, "[Last Name] You last name has been updated to: ".. new.."!", 4)
				Player:LoadCharacter()
				return true
			end,
		},
		[1291964736] = {
			Name = "Reroll Race",
			Type = "DevProduct",
			Description = "Rerolls your Race.",
			Func = function(Player)
				if not RunService:IsServer() then 
					return false
				end
				local PlayerData = Player:WaitForChild("Data")
				local new = Races:Roll()

				PlayerData.Race.Value = new
				game.ReplicatedStorage.Remotes.Notify:FireClient(Player, "[Last Name] You last name has been updated to: ".. new.."!", 4)
				Player:LoadCharacter()
				return true
			end,
		},
		[1291964735] = {
			Name = "Reroll Face",
			Type = "DevProduct",
			Description = "Rerolls your facial features.",
			Func = function(Player)
				if not RunService:IsServer() then 
					return false
				end
				
				game.ServerScriptService.Events.RandomizeFace:Fire(Player, false)				
				return true
			end,
		},
		[1347487634] = {
			Name = "2x Experience (1 Hour)",
			Type = "DevProduct",
			Description = "Gives you double experience for an hour. (STACKABLE)",
			Func = function(Player)
				if not RunService:IsServer() then 
					return false
				end
				local PlayerData = Player:WaitForChild("Data")
				PlayerData.DoubleExperienceTimer.Value += 3600
				
				ReplicatedStorage.Remotes.NotifyLarge:FireClient(Player, {
					["Text"] = "2x Experience is now active!",
					["Description"] = "-----",
					Duration = 6,
				})	
				return true
			end,
		},
	},
}

function Products.GetGamepassIdFromName(Name)
	for id, data in pairs(Products.Gamepasses) do
		if Name == data.Name then
			return id
		end
	end
	return nil
end

return Products