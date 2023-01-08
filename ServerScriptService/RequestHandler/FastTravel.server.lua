-- Fast Travel Handler

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FastTravelLocations = workspace:FindFirstChild("FastTravels")
local Remotes = ReplicatedStorage.Remotes

local ValidActions = {
	["Unlock"] = true,
	["Travel"] = true,
	["PurchaseGrace"] = true,
}
local TravelCooldown = 5
local TravelTime = 3
local ShardsHeartCost = 1000

local function HasTrait(TraitsFolder, Name)
	if not TraitsFolder:FindFirstChild(Name) then
		return false
	end
	return true
end
local function GetClosestWaypoint(Root)
	for _,v in pairs(FastTravelLocations:GetChildren()) do
		local CF,_ = v:GetBoundingBox()
		local Magnitude = (CF.Position - Root.Position).Magnitude
		if Magnitude <= 19 then
			return v
		end
	end
	return nil
end

Remotes.FastTravel.OnServerEvent:Connect(function(Player, Action, Data)
	if not ValidActions[Action] then
		Player:Kick("Exploiting")
		return
	end
	if typeof(Data) ~= "table" then
		return
	end

	local Character = Player.Character
	local Root = Character:FindFirstChild("HumanoidRootPart")
	local StatusFolder = Character:FindFirstChild("Status")
	if not Root then
		return
	end
	if not StatusFolder then
		return
	end

	local PlayerData = Player:FindFirstChild("Data")
	if PlayerData then
		local UnlockedTravels = PlayerData:FindFirstChild("UnlockedFastTravels")
		local Traits = PlayerData:FindFirstChild("Traits")

		if UnlockedTravels and Traits then
			--
			if Action == "PurchaseGrace" then
				if not Traits:FindFirstChild("Shards Heart") then
					if #Traits:GetChildren() < 6 then
						local newValue = Instance.new("BoolValue")
						newValue.Name = "Shards Heart"
						newValue.Value = true
						newValue.Parent = Traits

						Remotes.Notify:FireClient(Player, "New Grace: Shards Heart!", 5, {
							Sound = "NewTrait",
						})
					end
				else
					-- Already has
					Remotes.Notify:FireClient(Player, "You already have this grace...", 3)
				end
			end
			--
			if Action == "Unlock" then
				if not HasTrait(Traits, "Shards Heart") then
					Player:Kick("Exploiting")
					return
				end
				if not FastTravelLocations:FindFirstChild(Data.Location) then
					Player:Kick("Exploiting")
					return
				end

				-- Already Unlocked
				if UnlockedTravels:FindFirstChild(Data.Location) then
					return
				end
				--

				-- Passed, Magnitude Check
				local Location: Model = FastTravelLocations[Data.Location]
				local CF,_ = Location:GetBoundingBox()
				local Magnitude = (CF.Position - Root.Position).Magnitude

				warn(Magnitude)

				if Magnitude >= 19 then
					return -- Don't do anything, possible exploiting
				end

				local BoolValue = Instance.new("BoolValue")
				BoolValue.Name = Data.Location
				BoolValue.Value = true
				BoolValue.Parent = UnlockedTravels
				--
				Remotes.ClientFX:FireAllClients("Sound", {
					SoundName = "NewTravelPoint",
					Parent = Root
				})
				Remotes.ClientFX:FireAllClients("LevelUpFX", {
					Type = "TravelPointUnlocked",
					Parent = Root
				})
			end
			--
			if Action == "Travel" then
				if not HasTrait(Traits, "Shards Heart") then
					Player:Kick("Exploiting")
					return 
				end
				if not UnlockedTravels:FindFirstChild(Data.Location) then
					Player:Kick("Exploiting")
					return
				end
				if not FastTravelLocations:FindFirstChild(Data.Location) then
					Player:Kick("Exploiting")
					return
				end
				if Player:FindFirstChild("InCombat") then
					return -- In Combat
				end				
				-- Passed, Magnitude Check
				local Location: Model = FastTravelLocations[Data.Location]

				local Closest = GetClosestWaypoint(Root)
				if not Closest then
					return
				end
				if Closest.Name == Data.Location then
					Remotes.Notify:FireClient(Player, "You are already at this waypoint!", 4)
					return
				end

				-- Cooldown
				local foundDebounce = Player:FindFirstChild("FastTravelDebounce")
				if foundDebounce then
					local spwanTime = foundDebounce:GetAttribute("SpawnTime")
					local TimeLeft = (TravelCooldown - (os.clock() - (spwanTime)))
					TimeLeft = string.format("%0.1f", TimeLeft)

					Remotes.Notify:FireClient(Player, "Please wait ".. TimeLeft.."s before travelling again.", 3)
					return
				end
				-- Teleport
				local Immune = Instance.new("Folder")
				Immune.Name = "Intangibility"
				Immune.Parent = StatusFolder
				local Travelling = Instance.new("Folder")
				Travelling.Name = "Travelling"
				Travelling.Parent = StatusFolder

				local ForceField = Instance.new("ForceField")
				ForceField.Name = "Safezone_ForceField"
				ForceField.Visible = false
				ForceField.Parent = Character
				
				Remotes.ClientFX:FireAllClients("ForceField", {
					Parent = Character,
					["Duration"] = TravelTime+.5
				})
				
				Debris:AddItem(Immune, TravelTime)
				Debris:AddItem(Travelling, TravelTime)
				Debris:AddItem(ForceField, TravelTime)

				Remotes.Cutscene:FireClient(Player, nil, TravelTime-1, "TravelWaypoint")
				task.delay(1.5, function()
					-- Teleport
					local Spawns = Location:FindFirstChild("Spawns")
					if not Spawns then
						warn("Fast Travel Error: Spawns folder not found for: ".. Data.Location)
						return
					end

					local FinalLocation = nil
					local Children = Spawns:GetChildren()
					FinalLocation = Children[math.random(#Children)]

					if FinalLocation then
						Root.CFrame = FinalLocation.CFrame

						-- Effect
						task.delay(.5, function()
							Remotes.ClientFX:FireAllClients("Sound", {
								SoundName = "Travel",
								Parent = Root
							})
							Remotes.ClientFX:FireAllClients("LevelUpFX", {
								Type = "TravelPointUnlocked",
								Parent = Root
							})							
						end)
					end
				end)
			end
			--
		end
	end
end)