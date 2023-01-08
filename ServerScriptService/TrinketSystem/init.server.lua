-- Trinket System

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HTTPService = game:GetService("HttpService")

local TrinketSpawns = workspace.TrinketSpawns
local TrinketsModule = require(script.TrinketRates)

local SpawnRate =  10--60*3-- 60 seconds * 2 = 2 minutes
local Range = 200
local PickupRange = 30
local SpawnsCache = {}

local CooldownsCache = {}
local CooldownTime = .85

local Remotes = ReplicatedStorage.Remotes
local Trinkets = ReplicatedStorage.Assets.Trinkets

local function GetObjectFromID(id)
	for object,data in pairs(SpawnsCache) do
		if data.AlreadySpawned and not data.Clicked then
			if data.ID == id then
				return object
			end
		end
	end
	return nil
end

Players.PlayerAdded:Connect(function(Player)
	-- trinkets cooldown
	Player.AncestryChanged:Connect(function()
		if not Player:IsDescendantOf(game) then
			if CooldownsCache[Player.UserId] then
				CooldownsCache[Player.UserId] = nil
				warn("removed trinketcooldown from: ".. Player.Name..".")
			end
		end
	end)
end)

Remotes.TrinketPickup.OnServerEvent:Connect(function(Player, ID)
	local Character = Player.Character
	local Object = GetObjectFromID(ID)
	
	if Object ~= nil then
		
		local A = Object.CFrame.Position
		local B = Character.HumanoidRootPart.Position
		
		local Distance = (A-B).Magnitude
		if Distance > PickupRange then
			Player:Kick("Trinket exploiting")
			return
		end
		
		local ItemData = SpawnsCache[Object]
		
		if ItemData.Clicked then
			return
		end
		if not ItemData.AlreadySpawned then
			return
		end
		
		-- Cooldowns
		if os.clock() - (CooldownsCache[Player.UserId] or 0) < CooldownTime then
			return
		end
		
		print("Server: Pickup "..ItemData.Item)
		
		local PlayerData = Player:FindFirstChild("Data")
		if PlayerData then
			
			--
			CooldownsCache[Player.UserId] = os.clock()
			
			ItemData.Clicked = true
			ItemData.LastSpawn = os.clock()
			
			local PlayerTrinkets = PlayerData.Items.Trinkets
			
			local foundItem = PlayerTrinkets:FindFirstChild(ItemData.Item)
			if foundItem then
				foundItem.Value += 1
			else
				local NewValue = Instance.new("IntValue")
				NewValue.Name = ItemData.Item
				NewValue.Value = 1
				NewValue.Parent = PlayerTrinkets
			end
			
			Remotes.Notify:FireClient(Player, "Picked up x1 ".. ItemData.Item.."!", 5, {
				Sound = "TrinketPickup",
			})
			
			ItemData.Item = "Nothing"
			ItemData.AlreadySpawned = false
			
			Remotes.RenderTrinket:FireAllClients({
				Action = "Destroy",
				ID = ItemData.ID
			})
			task.delay(.5, function()
				ItemData.Clicked = false
			end)
			--
		end
	end
end)

for _,v in pairs(TrinketSpawns:GetChildren()) do
	if v.Name == "Spawn" and v:IsA("BasePart") then
		v.Transparency = 1

		SpawnsCache[v] = {
			["Clicked"] = false,
			AlreadySpawned = false,

			Item = "Nothing",
			Location = v.CFrame,

			["LastSpawn"] = os.clock(),
			["ID"] = HTTPService:GenerateGUID(false)
		}
		
		-- Destroying
		v:Destroy()
	end
end

local function SpawnTrinkets()
	for Object,Data in pairs(SpawnsCache) do
		-- Checking if already clicked
		if not Data.AlreadySpawned and Data.Clicked == false then
			
			if os.clock() - (Data.LastSpawn or 0) > SpawnRate then
				local Chosen = TrinketsModule:GetRandom()

				if Chosen ~= "Nothing" then
					-- setting new values
					
					Data.ID = HTTPService:GenerateGUID(false)
					Data.AlreadySpawned = true
					Data.Clicked = false
					Data.Item = Chosen
					
				--	warn("[Trinket System] Spawn in Trinket: ".. Chosen.. " | ID: ".. Data.ID)
				end
			end
		end
	end
end

task.spawn(function()
	while task.wait(2) do
		if not script.Parent then
			return
		end
		for _,Player in next, Players:GetPlayers() do
			if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player:GetAttribute("DataLoaded") == true then -- to prevent exhaust
				pcall(function()
					for Object, Data in pairs(SpawnsCache) do
						if Data.Item ~= "Nothing" then
							if (Player.Character.HumanoidRootPart.Position - Object.Position).Magnitude <= Range then
								Remotes.RenderTrinket:FireClient(Player,
									{
										Action = "Render",
										["Info"] = Data,
									}
								)
							else
								Remotes.RenderTrinket:FireClient(Player, {
									Action = "Destroy",
									ID = Data.ID
								})
							end
						end
					end
				end)
			end
		end
	end
end)

while task.wait(SpawnRate) do
	SpawnTrinkets()
end