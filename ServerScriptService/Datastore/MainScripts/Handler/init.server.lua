-- Handler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local MarketPlaceService = game:GetService("MarketplaceService")
local serverstorage = game:GetService("ServerStorage")
local collectionservice = game:GetService("CollectionService")

local Remotes = ReplicatedStorage.Remotes
local Assets = ReplicatedStorage.Assets

local Player = game.Players:GetPlayerFromCharacter(script.Parent) or nil
local Character = script.Parent
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")
local Client = script.Input

local Events = script.Events

local ScriptModules = script.Modules
local ServerInfo = require(script.Input.Info)
local FaceVictim = require(ReplicatedStorage.Modules.Client.Effects.FaceVictim)
local StunHandler = require(ServerScriptService.Modules.StunHandler)
local Ragdoller = require(ServerScriptService.Modules.Ragdoll)
local Formulas = require(ReplicatedStorage.Modules.Shared.Formulas)
local KnockHandler = require(ServerScriptService.Modules.Knock)
local ServerEvents = ServerScriptService.Events

local Modules = {}

-- BlockMeter
local BlockMeter = script.BlockMeter:Clone()
BlockMeter.Parent = Character:WaitForChild("HumanoidRootPart")
--
-- EXP Bar
local EXPBar = script.EXPBar:Clone()
EXPBar.Parent = Character:WaitForChild("HumanoidRootPart")
--

local StatusFolder = Instance.new("Folder")
StatusFolder.Name = "Status" -- For stun and stuff like that.
StatusFolder.Parent = Character

local CharacterData = Instance.new("Folder")
CharacterData.Name = "Data"
CharacterData.Parent = Character

local BlockAmount = Instance.new("IntValue")
BlockAmount.Name = "BlockAmount"
BlockAmount.Value = 100
BlockAmount.Parent = CharacterData

local Equipped = Instance.new("StringValue")
Equipped.Name = "CurrentWeapon"
Equipped.Value = ""
Equipped.Parent = CharacterData

local ManaAuraEnabled = Instance.new("BoolValue")
ManaAuraEnabled.Name = "AuraEnabled"
ManaAuraEnabled.Value = false
ManaAuraEnabled.Parent = CharacterData

local AppliedTraits = Instance.new("Folder")
AppliedTraits.Name = "AppliedTraits"
AppliedTraits.Parent = CharacterData

local Bonuses = Instance.new("Folder")
Bonuses.Name = "Bonuses"
Bonuses.Parent = CharacterData
local valueHistory = {}

for i = 1, #Formulas.StatsOrder do
	local d = Formulas.StatsOrder[i]
	local c = Instance.new("IntValue")
	c.Name = d
	c.Parent = Bonuses

	c.Changed:Connect(function()
		c.Value = math.clamp(c.Value, -100, math.huge) -- 100 is unreasonable

		if c.Name == "Defense" then
			if game.Players:GetPlayerFromCharacter(Character) then
				local newMaxHealth = Formulas.GetMaxHealth(Player)
				Humanoid.MaxHealth = newMaxHealth
			end
		end
	end)
end

collectionservice:AddTag(Character,"chars")
-- Would Handler
script.WoundHandler.Enabled = true

AppliedTraits.ChildAdded:Connect(function(c)
	if c.Name == "Quick Feet" then
		Bonuses.Agility.Value += 5
	end
	if c.Name == "Tank" then
		Bonuses.Defense.Value += 60
	end
	if c.Name == "Kind Soul" then
		Bonuses.Mana.Value += 10
	end
	if c.Name == "Mage" then
		Bonuses.Mana.Value += 30
	end
	if c.Name == "Warlord" then
		Bonuses.Strength.Value += 1
		Bonuses.Defense.Value += 45
	end
end)
AppliedTraits.ChildRemoved:Connect(function(c)
	if c.Name == "Quick Feet" then
		Bonuses.Agility.Value -= 5
	end
	if c.Name == "Tank" then
		Bonuses.Defense.Value -= 60
	end
	if c.Name == "Kind Soul" then
		Bonuses.Mana.Value -= 10
	end
	if c.Name == "Mage" then
		Bonuses.Mana.Value -= 30
	end
	if c.Name == "Warlord" then
		Bonuses.Strength.Value -= 1
		Bonuses.Defense.Value -= 45
	end
end)

-- Last Player to damage --
local LastDamage = Instance.new("ObjectValue")
LastDamage.Name = "LastHit"
LastDamage.Parent = CharacterData

local LastHealthPack = Instance.new("IntValue")
LastHealthPack.Name = "LastHealthPack"
LastHealthPack.Value = 0
LastHealthPack.Parent = CharacterData

local Mana = Instance.new("IntValue")
Mana.Name = "Mana"
Mana.Value = 100

local PlayerData = Player and Player:WaitForChild("Data")

if Player then
	Mana.Value = Formulas.GetMaxMana(Player)
end

Mana.Changed:Connect(function()
	Mana.Value = math.clamp(Mana.Value, 0, Formulas.GetMaxMana(Player)) -- MaxMana is 450
	--print("Current: ".. Mana.Value.." | Max: ".. Formulas.GetMaxMana(Player))
end)
Mana.Parent = CharacterData

-- Mana Regen --
task.spawn(function()
	-- starts off at 2
	-- 5 levels goes up by 1

	if Player then
		while true do
			if StatusFolder:FindFirstChild("Dead") then
				break
			end

			local CurrentHunger = 100
			if Player then
				if PlayerData then
					if PlayerData.Traits:FindFirstChild("Chubby") then
						CurrentHunger += 50
					end
				end
				
				CurrentHunger = PlayerData.Hunger.Value
			end

			-- can't regen without hunger
			if CurrentHunger > 0 and Mana.Value < Formulas.GetMaxMana(Player) then
				if not ManaAuraEnabled.Value then

					if AppliedTraits:FindFirstChild("Vampiracy") then
						if game.Lighting.ClockTime >= 18 and game.Lighting.ClockTime <= 7 then
							Mana.Value += 0.03*Formulas.GetMaxMana(Player)
							PlayerData.Hunger.Value = PlayerData.Hunger.Value - .2
						else
							Mana.Value += 0.005*Formulas.GetMaxMana(Player)
							PlayerData.Hunger.Value = PlayerData.Hunger.Value - .2
						end
					else
						Mana.Value += 0.01*Formulas.GetMaxMana(Player)
						PlayerData.Hunger.Value = PlayerData.Hunger.Value - .2
					end					
				end
			end

			if ManaAuraEnabled.Value then
				if Mana.Value <= 0 then
					-- out of mana
					ManaAuraEnabled.Value = false
				end
				Mana.Value -= 1
			end

			task.wait(.5)
		end
	end
end)
------------

local function createInstance(ClassName, Name, Value, Parent, Duration)
	local inst = Instance.new(ClassName)
	inst.Name = Name
	local s,e = pcall(function()
		local t = inst.Value
	end)
	if s then
		inst.Value = Value
	end
	inst.Parent = Parent
	if Duration then
		task.delay(Duration, function()
			Debris:AddItem(inst, 0)
		end)
	end
	return inst
end
local function toggleDashTrail(Character, Bool)
	coroutine.resume(coroutine.create(function()
		for _,obj in pairs(Character:GetDescendants()) do
			if obj.Name == "DashTrail" then
				obj.Enabled = Bool
			end
		end		
	end))
end
local function toggleRunTrail(Character, Bool)
	coroutine.resume(coroutine.create(function()
		for _,obj in pairs(Character:GetDescendants()) do
			if obj.Name == "RunTrail" then
				obj.Enabled = Bool
			end
		end		
	end))
end
local function toggleSwordTrail(Model, Bool)
	for _,v in pairs(Model:GetDescendants()) do
		if v:IsA("Trail") and v.Name == "SwordTrail" then
			v.Enabled = Bool
		end
	end
end

local function StopBlock(Player, CurrentWeapon)
	-- Stop Blocking
	ServerInfo.PreviousBlock = os.clock()
	StatusFolder.Blocking:Destroy()
	Remotes.ClientFX:FireClient(Player, "FOV", {
		Amount = 70,
	})
	Events.Animation:FireClient(Player, "StopAnimation", {
		Directory = CurrentWeapon.."/Block/"..CurrentWeapon.."BlockIdle"
	})
end


Events.Crouch.OnServerEvent:Connect(function(Player, Bool)
	if Bool and not StatusFolder:FindFirstChild("Crouching") then
		if ServerInfo:StunCheck(Player.Character, "Crouch") then return end -- Stunned
		if os.clock() - (ServerInfo.PreviousCrouch or 0) < ServerInfo.CrouchCooldown then
			return -- On Cooldown
		end

		local Crouching = Instance.new("Folder")
		Crouching.Name = "Crouching"
		Crouching.Parent = StatusFolder

		-- Hiding NameTag
		local RankTags = Character:WaitForChild("HumanoidRootPart"):FindFirstChild("RankGui")
		RankTags.Enabled = false

		while true do
			local Stunned = ServerInfo:StunCheck(Player.Character, "Crouch")
			if Stunned then
				Crouching:Destroy()
				ServerInfo.PreviousCrouch = os.clock()
				break
			end
			if not StatusFolder:FindFirstChild("Crouching") then
				ServerInfo.PreviousCrouch = os.clock()
				break
			end
			task.wait()
		end
		RankTags.Enabled = true
	end
	if not Bool and StatusFolder:FindFirstChild("Crouching") then
		StatusFolder["Crouching"]:Destroy()
		ServerInfo.PreviousCrouch = os.clock()
	end
end)
Events.Slide.OnServerEvent:Connect(function(Player, Bool)
	if Bool and not StatusFolder:FindFirstChild("Sliding") then
		if ServerInfo:StunCheck(Player.Character, "Slide") then return end -- Stunned
		if os.clock() - (ServerInfo.PreviousSlide or 0) < ServerInfo.SlideCooldown then
			return -- On Cooldown
		end
		if Humanoid.FloorMaterial == Enum.Material.Air then
			return
		end

		local Sliding = Instance.new("Folder")
		Sliding.Name = "Sliding"
		Sliding.Parent = StatusFolder
		Debris:AddItem(Sliding, ServerInfo.SlideDuration)

		--
		local SlideSound = ReplicatedStorage.Assets.Sounds.Slide:Clone()
		SlideSound.Parent = Character.HumanoidRootPart
		SlideSound:Play()
		Debris:AddItem(SlideSound, SlideSound.TimeLength)
		--
		--[[
		Remotes.ClientFX:FireAllClients("Sound", {
			SoundName = "Slide",
			Parent = Character.HumanoidRootPart
		})
		]]
		--[[
		Remotes.ClientFX:FireClient(Player, "FOV", {
			Amount = 80,
		})
		]]--
		Remotes.ClientFX:FireAllClients("Slide", {Target = Player})
		--toggleDashTrail(Character, true)

		local PreviousUsage = os.clock()
		local Interval_ = .05

		while true do
			local Stunned = ServerInfo:StunCheck(Player.Character, "Slide")
			if Stunned then
				game.TweenService:Create(SlideSound, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Volume = 0
				}):Play()
				--Sliding:Destroy()
				ServerInfo.PreviousSlide = os.clock()
				--task.delay(.5, function()
				--	toggleDashTrail(Character, false)
				--end)
				break
			end
			if not StatusFolder:FindFirstChild("Sliding") then
				ServerInfo.PreviousSlide = os.clock()
				--task.delay(.5, function()
				--	toggleDashTrail(Character, false)
				--end)
				break
			end

			if os.clock() - (PreviousUsage) >= Interval_ then
				PreviousUsage = os.clock()
				Remotes.ClientFX:FireAllClients("RunParticles", {
					["Character"] = Player.Character,
					Parent = Character.HumanoidRootPart

				})
				Remotes.ClientFX:FireAllClients("RunParticles2", {
					["Character"] = Player.Character,
					Parent = Character.HumanoidRootPart

				})
			end

			task.wait()
		end
		if SlideSound.Parent then
			game.TweenService:Create(SlideSound, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Volume = 0
			}):Play()
			--SlideSound:Destroy()
		end
		--[[
		Remotes.ClientFX:FireClient(Player, "FOV", {
			Amount = 70,
		})
		]]--

	end
	if not Bool and StatusFolder:FindFirstChild("Sliding") then
		StatusFolder["Sliding"]:Destroy()
		ServerInfo.PreviousSlide = os.clock()
	end
end)
Events.Jump.OnServerEvent:connect(function(player)
	local jump = Instance.new("Folder")
	jump.Name = "Jump"
	jump.Parent = StatusFolder
	task.delay(.3, function()
		jump:Destroy()
	end)
end)
Events.Sprint.OnServerEvent:Connect(function(Player, Bool)
	if Bool and not StatusFolder:FindFirstChild("Running") and not ServerInfo:StunCheck(Player.Character, "Sprint") then
		createInstance("Folder", "Running", nil, StatusFolder, nil)
		Remotes.ClientFX:FireClient(Player, "FOV", {
			Amount = 80,
		})

		-- Sprint Effect Connection
		local Connection = nil
		local PreviousEmit = nil
		local EmitCooldown = .1

		--toggleRunTrail(Character, true)

		Connection = RunService.Heartbeat:Connect(function()
			if os.clock() - (PreviousEmit or 0) > EmitCooldown then
				if ServerInfo:StunCheck(Player.Character, "Sprint") or not StatusFolder:FindFirstChild("Running") then
					Connection:Disconnect()
					Connection = nil
					Remotes.ClientFX:FireClient(Player, "FOV", {
						Amount = 70,
					})

					--toggleRunTrail(Character, false)
					toggleSwordTrail(Character, false)
					return
				end

				--		if Equipped.Value == "Katana" or Equipped.Value == "Dagger" then
				--	toggleSwordTrail(Character, true)
				--	else
				toggleSwordTrail(Character, false)
				--	end

				PreviousEmit = os.clock()
				if not StatusFolder:FindFirstChild("Dashing") and not StatusFolder:FindFirstChild("Sliding") then -- particles shouldnt appear when dashing
					Remotes.ClientFX:FireAllClients("RunParticles", {
						["Character"] = Player.Character,
						Parent = Character.HumanoidRootPart

					})
					Remotes.ClientFX:FireAllClients("RunParticles2", {
						["Character"] = Player.Character,
						Parent = Character.HumanoidRootPart

					})
				end
			end
		end)
	end
	if not Bool then
		-- Not Running
		local found = StatusFolder:FindFirstChild("Running")
		if found then
			found:Destroy()
			Remotes.ClientFX:FireClient(Player, "FOV", {
				Amount = 70,
			})
		end
	end
end)
Events.Block.OnServerEvent:Connect(function(Player, Bool)
	if Bool and not StatusFolder:FindFirstChild("Blocking") then -- Start Blocking
		if ServerInfo:StunCheck(Player.Character) then return end -- Stunned
		if Equipped.Value == "" then return end

		if os.clock() - (ServerInfo.PreviousBlock or 0) > ServerInfo.BlockCooldown then
			ServerInfo.PreviousBlock = os.clock()
			createInstance("Folder", "Blocking", nil, StatusFolder, nil)
			Remotes.ClientFX:FireClient(Player, "FOV", {
				Amount = 60,
			})

			local CurrentWeapon = Equipped.Value
			local BlockAnimations = Assets.Animations:FindFirstChild(CurrentWeapon) and Assets.Animations[CurrentWeapon].Block or nil
			if BlockAnimations then
				Events.Animation:FireClient(Player, "PlayAnimation", {
					Directory = CurrentWeapon.."/Block/"..CurrentWeapon.."BlockIdle"
				})

				while true do
					if not StatusFolder:FindFirstChild("Blocking") then
						break
					end
					if ServerInfo:StunCheck(Player.Character, "Blocking") then
						StopBlock(Player, CurrentWeapon)
						break
					end
					if Equipped.Value == "" then
						StopBlock(Player, CurrentWeapon)
						break
					end
					if Equipped.Value ~= CurrentWeapon then
						-- switched weapons
						StopBlock(Player, CurrentWeapon)
						break
					end
					task.wait()
				end
			end
		end
	end
	if not Bool and StatusFolder:FindFirstChild("Blocking") then -- Stop Blocking
		local CurrentWeapon = Equipped.Value
		StopBlock(Player, CurrentWeapon)
	end
end)
Events.Dash.OnServerEvent:Connect(function(Player, Bool)
	if ServerInfo:StunCheck(Player.Character, "Dashing") then return end
	local dashcd = ServerInfo.DashCooldown
	if PlayerData.Stats.Agility.Value >= 60 then
		dashcd = .1
	end

	if Bool then
		if os.clock() - (ServerInfo.PreviousDash or 0) > dashcd then
			-- Can Dash
			ServerInfo.PreviousDash = os.clock()
			--[[
			Events.Animation:FireClient(Player, "Test", {
				Directory = "Combat/M1/CombatL1"
			})
			]] -- worked

			-- Dodge --
			local EvadeFolder = Instance.new("Folder")
			EvadeFolder.Name = "EvadeAttempt"
			EvadeFolder.Parent = StatusFolder

			local CancelDestroy = false

			task.delay(.2, function()
				if CancelDestroy then return end
				EvadeFolder:Destroy()
			end)

			local Connection
			Connection = EvadeFolder.ChildAdded:Connect(function(Child)
				if Child.Name == "Success" then
					CancelDestroy = true

					Connection:Disconnect()
					Connection = nil

					local EvadeType = Child.Value
					repeat task.wait() until EvadeFolder:FindFirstChild("Target")
					local TargetToEvade = EvadeFolder.Target and EvadeFolder.Target.Value

					task.spawn(function()
						Remotes.ClientFX:FireAllClients("Sound", {
							SoundName = "DODGED",
							Parent = Character.HumanoidRootPart
						})

						local c = Assets.EvadeFX:Clone()
						c.Parent = Character.HumanoidRootPart
						c:Emit(100)
						Debris:AddItem(c, 1.5)
					end)

					Remotes.ClientFX:FireAllClients("DamageIndicator",
						{
							DamageAmount = "DODGED!",
							Victim = Player.Character,
							Color = Color3.fromRGB(255, 74, 77),
							NormalColor = Color3.fromRGB(176, 36, 39)
						}
					)

					task.delay(.5, function()
						EvadeFolder:Destroy()
					end)
				end
			end)
			--

			local DashingDuration = ServerInfo.DashDuration
			-- Edit based on stats, create instance
			local StartTime = os.clock()
			local DashFolder = createInstance("Folder", "Dashing", nil, StatusFolder, DashingDuration)
			-- Do Effects
			--Remotes.ClientFX:FireAllClients("Dash", {Target = Player})

			task.spawn(function()
				for i = 1, 10 do
					if ServerInfo:StunCheck(Character, "Dashing") then
						break
					end
					Remotes.ClientFX:FireAllClients("Dash", {
						["Character"] = Player.Character,
						Parent = Character.HumanoidRootPart
					})									
					task.wait(.03)
				end
			end)


			Remotes.ClientFX:FireClient(Player, "Blur", {
				FinalTime = .3,
				Duration = .1,
			})
			Remotes.ClientFX:FireAllClients("Sound", {
				SoundName = "Dash",
				Parent = Character.HumanoidRootPart
			})
			--toggleDashTrail(Player.Character, true)

			-- Checking for burn --
			if StatusFolder:FindFirstChild("Burn") then
				for _,v in pairs(StatusFolder:GetChildren()) do
					if v.Name == "Burn" then
						v:Destroy()
					end
				end
			end


			-- Checks
			while true do
				if StatusFolder:FindFirstChild("DashCancelled") then
					--[[
					local Anim = Humanoid:LoadAnimation(Assets.Animations.DashEvade)
					Anim:Play()
					]]--

					task.spawn(function()
						Remotes.ClientFX:FireAllClients("Sound", {
							SoundName = "DashCancel",
							Parent = Character.HumanoidRootPart
						})

						local c = Assets.EvadeFX:Clone()
						c.Parent = Character.HumanoidRootPart
						c:Emit(100)
						Debris:AddItem(c, 1.5)

						--[[
						Remotes.ClientFX:FireAllClients("DamageIndicator",
							{
								DamageAmount = "DASH CANCEL!",
								Victim = Player.Character,
								Color = Color3.fromRGB(107, 255, 251),
								NormalColor = Color3.fromRGB(65, 176, 176)
							}
						)
						]]--
					end)

					break
				end

				local Stunned = ServerInfo:StunCheck(Player.Character, "Dashing")
				if Stunned then
					DashFolder:Destroy()
					break
				end

				if os.clock() - (StartTime) > DashingDuration then
					break
				end
				task.wait()
			end
			-- Turn off Dash Trail
			--toggleDashTrail(Player.Character, false)
		end
	end
	if Bool == false then
		-- cancel
		--[[
		if StatusFolder:FindFirstChild("Dashing") then
			-- cancel dash
			StatusFolder["Dashing"]:Destroy()
			
			local DashCancelled = Instance.new("Folder")
			DashCancelled.Name = "DashCancelled"
			DashCancelled.Parent = StatusFolder
			Debris:AddItem(DashCancelled, .5)
			
			local Anim = Humanoid:LoadAnimation(Assets.Animations.DashEvade)
			Anim:Play()

			task.spawn(function()
				Remotes.ClientFX:FireAllClients("Sound", {
					SoundName = "DashCancel",
					Parent = Character.HumanoidRootPart
				})

				local c = Assets.EvadeFX:Clone()
				c.Parent = Character.HumanoidRootPart
				c:Emit(100)
				Debris:AddItem(c, 1.5)
				
				Remotes.ClientFX:FireAllClients("DamageIndicator",
					{
						DamageAmount = "DASH CANCEL!",
						Victim = Player.Character,
						Color = Color3.fromRGB(107, 255, 251),
						NormalColor = Color3.fromRGB(65, 176, 176)
					}
				)
			end)
		end
		]]--
	end
end)
-- Evading
Events.Evade.OnServerEvent:Connect(function(Player)
	--if Equipped.Value == "" then return end
	
	if StatusFolder:FindFirstChild("BlockBreakEvadeCooldown") then
		return
	end
	
	if os.clock() - (ServerInfo.PreviousEvade or 0) > ServerInfo.EvadeCooldown then
		-- Can Evade
		if StatusFolder:FindFirstChild("EvadeAttempt") then
			return -- already attempeting to evade
		end

		if StatusFolder:FindFirstChild("GravityTrap") then
			return -- stuck in gravity trap
		end

		local EvadeFolder = Instance.new("Folder")
		EvadeFolder.Name = "EvadeAttempt"
		EvadeFolder.Parent = StatusFolder

		ReplicatedStorage.Remotes.ClientFX:FireAllClients("EvadeEffect", {
			["Parent"] = Character,
			["Duration"] = .3,
		})

		local CancelDestroy = false
		local AttemptDuration = .2 -- Default
		
		if PlayerData then
			if PlayerData.Traits:FindFirstChild("Quick Thinker") then
				AttemptDuration += .2
			end
		end
		
		task.delay(AttemptDuration, function()
			if CancelDestroy then return end
			EvadeFolder:Destroy()
			Remotes.Cooldown:FireClient(Player, "Evade", ServerInfo.EvadeCooldown)
			ServerInfo.PreviousEvade = os.clock()
		end)

		local Connection
		Connection = EvadeFolder.ChildAdded:Connect(function(Child)
			if Child.Name == "Success" then
				CancelDestroy = true

				Connection:Disconnect()
				Connection = nil

				local EvadeType = Child.Value
				repeat task.wait() until EvadeFolder:FindFirstChild("Target")
				local TargetToEvade = EvadeFolder.Target and EvadeFolder.Target.Value

				-- Animation
				local Animation = Humanoid:LoadAnimation(Assets.Animations.Evade)
				Animation:Play()

				if EvadeType == "Normal" then
					task.spawn(function()
						Remotes.ClientFX:FireAllClients("Sound", {
							SoundName = "Evade",
							Parent = Character.HumanoidRootPart
						})

						local c = Assets.EvadeFX:Clone()
						c.Parent = Character.HumanoidRootPart
						c:Emit(100)
						Debris:AddItem(c, 1.5)
					end)

					-- teleporting, facing
					local TargetCFrame = TargetToEvade.HumanoidRootPart.CFrame
					Character.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame + (-Character.HumanoidRootPart.CFrame.LookVector) * 10

					for _,obj in pairs(StatusFolder:GetChildren()) do
						if obj.Name == "Stunned" then
							obj:Destroy()
						end
					end

					Remotes.ClientFX:FireAllClients("DamageIndicator",
						{
							DamageAmount = "EVADED!",
							Victim = Player.Character,
							Color = Color3.fromRGB(107, 255, 251),
							NormalColor = Color3.fromRGB(65, 176, 176)
						}
					)
				end
				if EvadeType == "Magic" then
					task.spawn(function()
						Remotes.ClientFX:FireAllClients("Sound", {
							SoundName = "Evade",
							Parent = Character.HumanoidRootPart
						})

						local c = Assets.EvadeFX:Clone()
						c.Parent = Character.HumanoidRootPart
						c:Emit(100)
						Debris:AddItem(c, 1.5)
					end)

					task.spawn(function()
						local Anim = Character.Humanoid:LoadAnimation(game.ReplicatedStorage.Assets.Animations.Movement.DashS)
						Anim:Play()			
					end)

					-- teleporting, facing
					local TargetCFrame = TargetToEvade.HumanoidRootPart.CFrame
					Character.HumanoidRootPart.CFrame = Character.HumanoidRootPart.CFrame - Character.HumanoidRootPart.CFrame.RightVector * 10

					for _,obj in pairs(StatusFolder:GetChildren()) do
						if obj.Name == "Stunned" then
							obj:Destroy()
						end
					end

					Remotes.ClientFX:FireAllClients("DamageIndicator",
						{
							DamageAmount = "EVADED!",
							Victim = Player.Character,
							Color = Color3.fromRGB(118, 84, 255),
							NormalColor = Color3.fromRGB(87, 57, 176)
						}
					)
				end
				print("Evade: "..TargetToEvade.Name.." \nType: ".. EvadeType)

				task.delay(.5, function()
					EvadeFolder:Destroy()
					Remotes.Cooldown:FireClient(Player, "Evade", ServerInfo.EvadeCooldown)
					ServerInfo.PreviousEvade = os.clock()
				end)
			end
		end)

	end
end)

-- Carry
Events.Carry.OnServerEvent:Connect(function(Player)
	-- checking if already carrying	
	if StatusFolder:FindFirstChild("Carrying") then
		-- is carrying, toggle
		if os.clock() - (ServerInfo.PreviousCarry or 0) < ServerInfo.CarryToggleCooldown then
			return -- can't toggle carry
		end
		ServerInfo.PreviousCarry = os.clock()
		ServerEvents.StopCarry:Fire(Player)
		--	Modules["Carry"].Activate(Player)
	else
		if ServerInfo:StunCheck(Character, "Carry") then return end -- stunned
		if os.clock() - (ServerInfo.PreviousCarry or 0) < ServerInfo.CarryCooldown then
			return -- not carrying, and on cooldown
		end
		ServerInfo.PreviousCarry = os.clock()
		ServerEvents.Carry:Fire(Player)
		--	Modules["Carry"].Activate(Player)
	end
end)
-- Grip
Events.Grip.OnServerEvent:Connect(function(Player)	
	if StatusFolder:FindFirstChild("Gripping") then
		-- is carrying, toggle
		if os.clock() - (ServerInfo.PreviousGrip or 0) < ServerInfo.GripToggleCooldown then
			return -- can't toggle carry
		end
		ServerInfo.PreviousGrip = os.clock()
		ServerEvents.StopGrip:Fire(Player)
		--Modules["Grip"].Activate(Player)
	else
		if ServerInfo:StunCheck(Character, "Grip") then return end -- stunned
		if os.clock() - (ServerInfo.PreviousGrip or 0) < ServerInfo.GripCooldown then
			return -- not carrying, and on cooldown
		end
		ServerInfo.PreviousGrip = os.clock()
		ServerEvents.Grip:Fire(Player)
		--Modules["Grip"].Activate(Player)
	end
end)
-- Fall Damage
local InCombat = require(ServerScriptService.Modules.InCombat)
Events.FallDamage.OnServerEvent:Connect(function(Player, FallingTime)
	if typeof(FallingTime) ~= "number" then
		return
	end
	if FallingTime ~= FallingTime then
		return
	end
	if FallingTime < 0 then
		return
	end
	if FallingTime >= ServerInfo.MinimumFallInterval then
		if os.clock() - (ServerInfo.PreviousFall or 0) < ServerInfo.FallCooldown then
			return
		end

		ServerInfo.PreviousFall = os.clock()
		Events.Animation:FireClient(Player, "PlayAnimation", {
			Directory = "Movement/LandGround"
		})

		warn("Do Fall Damage")
		local MaxHealth = Humanoid.MaxHealth
		local MaxHealthToLose = MaxHealth*.5
		local HealthToLose = 0

		if FallingTime > 4 then
			HealthToLose = MaxHealthToLose
		elseif FallingTime > 3 then
			HealthToLose = MaxHealthToLose*.5
		elseif FallingTime >= ServerInfo.MinimumFallInterval then
			HealthToLose = MaxHealthToLose*.2
		end

		if StatusFolder:FindFirstChild("NegateFallDamage") then
			local list = {}
			for _,v in pairs(StatusFolder:GetChildren()) do
				if v.Name == "NegateFallDamage" then
					table.insert(list, v:GetAttribute("Percentage"))
				end
			end
			table.sort(list, function(a,b)
				return a > b
			end)

			HealthToLose = MaxHealthToLose-MaxHealthToLose*(list[1]/100)
		end
		-- Removing Negate Fall Damage
		for _,v in pairs(StatusFolder:GetChildren()) do
			if v.Name == "NegateFallDamage" then
				v:Destroy()
			end
		end

		if HealthToLose > 0 then
			Humanoid:TakeDamage(HealthToLose)
			InCombat.PutInCombat(Player, Character, 45)

			local Stunned = Instance.new("Folder")
			Stunned.Name = "Stunned"
			Stunned:SetAttribute("SlowPercentage", .1)
			Stunned.Parent = StatusFolder

			Debris:AddItem(Stunned, 1)
		end

		-- Effects
		Remotes.ClientFX:FireAllClients("FallDust", {
			["Character"] = Character,
			["FallingTime"] = FallingTime
		})
		Remotes.ClientFX:FireAllClients("Sound", {
			SoundName = "Land",
			Parent = Character.HumanoidRootPart
		})
		Remotes.ClientFX:FireClient(Player, "Blur", {
			FinalTime = .3,
			Duration = .1,
		})		
	end
end)

-- Burn Stuff --
local BURN_DAMAGE_PERCENT = .03
local MAX_BURN_TIMES = 3

local CurrentEquipment = PlayerData:WaitForChild("Equipment")


StatusFolder.ChildAdded:Connect(function(Child)
	if Child.Name == "Ragdoll" then
		Ragdoller:Ragdoll(Character)

		Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)

		Humanoid.AutoRotate = false
		Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 1)
		
		-- Setting to NonCollidable
		for _,v in pairs(Character:GetDescendants()) do
			if v:IsA("BasePart") then
				game.PhysicsService:SetPartCollisionGroup(v, "NonCollidable")
			end
		end
		
	end
	if Child.Name == "Burn" then
		local burnTimes = 0
		local fx = Assets.BurningFX:Clone()
		fx.Parent = Character.HumanoidRootPart		

		local sound = Assets.Sounds.BurnSound:Clone()
		sound.Parent = Character.HumanoidRootPart
		sound:Play()

		while StatusFolder:FindFirstChild("Burn") do
			if burnTimes > MAX_BURN_TIMES then
				break
			end
			if Humanoid.Health <= Formulas.HealthToKnock then
				break
			end
			burnTimes += 1

			local burnObject = StatusFolder:FindFirstChild("Burn")
			local perc = .01
			if burnObject:GetAttribute("NatsuCloak") == true then
				perc = .03
			end

			Humanoid.Health -= Humanoid.Health*perc
			task.wait(1)
		end
		fx.Enabled = false
		sound:Destroy()
		fx.FireSparkles.Enabled = false
		task.delay(.1, function()
			fx:Destroy()
		end)
	end
	if Child.Name == "Poison" then
		local burnTimes = 0
		local fx = Assets.PoisonFX:Clone()
		fx.Parent = Character.HumanoidRootPart		

		while StatusFolder:FindFirstChild("Poison") do
			if burnTimes > 5 then
				break
			end
			if Humanoid.Health <= Formulas.HealthToKnock then
				break
			end
			burnTimes += 1
			Humanoid.Health -= Humanoid.MaxHealth*0.015

			game.ReplicatedStorage.Remotes.ClientFX:FireAllClients("Sound", {
				SoundName = "Poison Grab",
				Parent = Character.HumanoidRootPart
			})

			task.wait(1.5)
		end
		fx.Enabled = false
		fx.PoisonSparkles.Enabled = false
		task.delay(.1, function()
			fx:Destroy()
		end)
	end
	if Child.Name == "Lightning" then
		local f = {}

		game.ReplicatedStorage.Remotes.ClientFX:FireAllClients("Sound", {
			SoundName = "LightningSizzle",
			Parent = Character.HumanoidRootPart
		})

		for _,v in pairs(Character:GetChildren()) do
			if v:IsA("BasePart") then
				local fx = ServerScriptService.Datastore.Effects.Lightning:Clone()
				fx.Parent = Character.HumanoidRootPart
				StunHandler:Stun(Character, .6)

				table.insert(f, fx)

				for _,v in pairs(fx:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						v:Emit(10)
					end
				end

			end
		end
		StunHandler:Stun(Character, .6)

		task.wait(.6)
		for i = 1,#f do
			f[i]:Destroy()
		end
	end
	if Child.Name == "Enlarged" then
		Humanoid.MaxHealth = Humanoid.MaxHealth + 100
	end
	if Child.Name == "CarnivoreEffect" then
		for _,v in pairs(Assets.Particles.BloodDrops:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				local Clone = v:Clone()
				Clone.Parent = Character:WaitForChild("Head")

				Clone:Emit(math.random(15, 30))

				task.delay(3, function()
					Clone:Destroy()
				end)
			end
		end
		task.delay(.5, function()
			Child:Destroy()
		end)
	end	
	if Child.Name == "GluttonEffect" then
		for _,v in pairs(Assets.Particles.Glutton:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				local Clone = v:Clone()
				Clone.Parent = Character:WaitForChild("Torso")

				Clone:Emit(math.random(15,30))

				task.delay(3, function()
					Clone:Destroy()
				end)
			end
		end
		task.delay(.5, function()
			Child:Destroy()
		end)
	end	
end)
StatusFolder.ChildRemoved:Connect(function(Child)
	if Child.Name == "Ragdoll" then
		if not StatusFolder:FindFirstChild("Ragdoll") then
			Ragdoller:UnRagdoll(Character)

			--Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
			Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			Humanoid.AutoRotate = true
			
			task.delay(.5, function()
				for _,v in pairs(Character:GetDescendants()) do
					if v:IsA("BasePart") then
						game.PhysicsService:SetPartCollisionGroup(v, "Players")
					end
				end
			end)
		end
	end
	if Child.Name == "Enlarged" then
		Humanoid.MaxHealth = Humanoid.MaxHealth - 100
	end
end)

-- Attacking
Events.Punch.OnServerEvent:Connect(function(Player, OtherData)
	if ServerInfo:StunCheck(Player.Character, "Attack") then return end
	if StatusFolder:FindFirstChild("Sliding") and PlayerData.Stats.Defense.Value < 100 then
		return -- Hasn't unlocked yet
	end

	Modules["Light"].Activate(Player, nil, OtherData)
end)
Events.Heavy.OnServerEvent:Connect(function(Player, data)
	if ServerInfo:StunCheck(Player.Character, "Heavy") then return end
	Modules["Heavy"].Activate(Player, nil, data)
end)

if Player and Player.UserId then
	Client.Enabled = true
end

for _,m in pairs(ScriptModules:GetChildren()) do
	if m:IsA("ModuleScript") then
		Modules[m.Name] = require(m)
	end
end
for _,m in pairs(game.ServerScriptService.Modules:GetChildren()) do
	Modules[m.Name] = require(m)
end

-- Disabling Tripping States
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

-- HealthChanged

Humanoid.HealthChanged:Connect(function()
	if StatusFolder:FindFirstChild("KillBrick") then
		return
	end
	if StatusFolder:FindFirstChild("BeenGripped") then
		return -- Has been gripped
	end
	
	Humanoid.Health = math.clamp(Humanoid.Health, Formulas.HealthToKnock, 10000)

	if Humanoid.Health <= Formulas.HealthToKnock and Humanoid:GetState() ~= Enum.HumanoidStateType.Dead and not StatusFolder:FindFirstChild("Knocked") then
		print("Knock: ".. Character.Name..".")
		-- KNOCK HERE --
		KnockHandler:Knock(Character, 10)
		ServerEvents.HealthPacks:Fire(LastDamage.Value)
	else
		if PlayerData then
			if PlayerData.Traits:FindFirstChild("Will Fighter") and Humanoid.Health <= Humanoid.MaxHealth*0.3 then
				-- Will Fight Trait
				if Player then
					if Player:FindFirstChild("WillFighterDebounce") then
						return
					end
				else
					-- Heal
					local Debounce = Instance.new("Folder")
					Debounce.Name = "WillFighterDebounce"
					Debounce.Parent = Player
					Debris:AddItem(Debounce, 360)
					
					Humanoid.Health = Humanoid.Health + Humanoid.MaxHealth*0.1
					Remotes.Notify:FireClient(Player, "[Will Fighter] +10% HP", {
						Duration = 4
					})
				end
			end
		end
	end
end)

local OverlapP = OverlapParams.new()
OverlapP.FilterDescendantsInstances = {workspace.Areas}
OverlapP.FilterType = Enum.RaycastFilterType.Blacklist

local PreviousBlockRegen = os.clock()
local BlockRegenTime = 3


RunService.Heartbeat:Connect(function()
	if PlayerData then
		if StatusFolder:FindFirstChild("Dead") then
			return
		end

		--
		if not StatusFolder:FindFirstChild("Blocking") and BlockAmount.Value < 100 and not StatusFolder:FindFirstChild("Stunned") then
			if os.clock() - (PreviousBlockRegen) >= BlockRegenTime then
				PreviousBlockRegen = os.clock()
				BlockAmount.Value = math.clamp(BlockAmount.Value+20,0,100)

				local display = Instance.new("Folder")
				display.Name = "DisplayBlockAmount"
				display.Parent = StatusFolder
				game.Debris:AddItem(display, 1.5)
			end
		end
		--
		
		if Character:FindFirstChild("HumanoidRootPart") then
			local SavedPosition = PlayerData.SavedPosition
			local CurrentPosition = Character.HumanoidRootPart.Position

			local CanUpdatePosition = true

			for _,object in pairs(workspace.Areas:GetChildren()) do
				if object:GetAttribute("IgnorePosSaving") == true then
					for _,part in pairs(object:GetChildren()) do
						local objectsInPart = workspace:GetPartsInPart(part, OverlapP)

						for i = 1, #objectsInPart do
							local p = objectsInPart[i]
							if p and p.Parent == Character then
								CanUpdatePosition = false
								break
							end
						end
					end
				end
			end

			if not CanUpdatePosition then
			else
				SavedPosition.Value = math.floor(CurrentPosition.X+.5)..","..math.floor(CurrentPosition.Y+.5)..","..math.floor(CurrentPosition.Z+.5)
			end
		end

		-- AURA STUFF --
		if ManaAuraEnabled.Value then
			for _,v in pairs(Character:GetDescendants()) do
				if v:IsA("ParticleEmitter") and string.find(v.Name, "ManaAura") then
					if v:GetAttribute("IgnoreAura") == false then
						if v.Parent and v.Parent.Name == "Left Arm" or v.Parent.Name == "Right Arm" then
							if Equipped.Value ~= "Combat" then
								v.Enabled = false
							else
								v.Enabled = true
							end
						else					
							if not v.Enabled then
								v.Enabled = true
							end
						end
					elseif v:GetAttribute("IgnoreAura") == true then
						if v.Enabled then
							v.Enabled = false
						end
					end
				end
			end
		else
			for _,v in pairs(Character:GetDescendants()) do
				if v:IsA("ParticleEmitter") and string.find(v.Name, "ManaAura") then
					if v.Enabled then
						v.Enabled = false
					end
				end
			end
		end

	end
end)


-- HEALING --
task.spawn(function()
	local REGEN_STEP = 5 -- Wait this long between each regeneration step.
	while true do
		-- Checking if InCombat
		local IsInCombat = false
		if Player then
			if Player:FindFirstChild("InCombat") then
				IsInCombat = true
			end 
		end

		local CurrentHunger = 100
		if Player then
			CurrentHunger = PlayerData.Hunger.Value
		end
		-- cant regen without hunger
		if CurrentHunger > 0 then
			-- Checking for Time
			if AppliedTraits:FindFirstChild("Vampiracy") then

				if game.Lighting.ClockTime >= 18 or game.Lighting.ClockTime <= 7 then
					if not Character:FindFirstChild("VampiracyEyes") then
						local VampiracyEyes = Assets.Particles.VampiracyEyes:Clone()
						VampiracyEyes.Parent = Character

						local weld = Instance.new("Motor6D")
						weld.Name = "Weld"
						weld.Part0 = VampiracyEyes
						weld.Part1 = Character:WaitForChild("Head")
						weld.Parent = VampiracyEyes
					end
				else
					if Character:FindFirstChild("VampiracyEyes") then
						Character.VampiracyEyes:Destroy()
					end
				end
			else
				if Character:FindFirstChild("VampiracyEyes") then
					Character.VampiracyEyes:Destroy()
				end
			end
			
			if Humanoid.Health < Humanoid.MaxHealth then
				if not IsInCombat then
					-- not in combat
					Humanoid.Health = Humanoid.Health + (0.2*Humanoid.MaxHealth)
					-- Reducing Hunger
					PlayerData.Hunger.Value = PlayerData.Hunger.Value - 1
					--
				else
					-- in combat
					if AppliedTraits:FindFirstChild("Bloodbourne") then
						Humanoid.Health = Humanoid.Health + (0.05*Humanoid.MaxHealth)
						-- Reducing Hunger
						PlayerData.Hunger.Value = PlayerData.Hunger.Value - 1
						--
						-- Emit Here
					elseif AppliedTraits:FindFirstChild("Vampiracy") then
						if game.Lighting.ClockTime >= 18 or game.Lighting.ClockTime <= 7 then
							Humanoid.Health = Humanoid.Health + (0.05*Humanoid.MaxHealth)
							-- Reducing Hunger
							PlayerData.Hunger.Value = PlayerData.Hunger.Value - 1
							--
						else
							Humanoid.Health = Humanoid.Health + (0.005*Humanoid.MaxHealth)
							-- Reducing Hunger
							PlayerData.Hunger.Value = PlayerData.Hunger.Value - 1
							--
						end
					else
						Humanoid.Health = Humanoid.Health + (0.01*Humanoid.MaxHealth)
						-- Reducing Hunger
						PlayerData.Hunger.Value = PlayerData.Hunger.Value - 1
						--
					end				
				end
			end
		else
			Humanoid.Health = Humanoid.Health + (0.005*Humanoid.MaxHealth)
			--
		end

		task.wait(REGEN_STEP)
	end	
end)
-- HUNGER --
--[[
task.spawn(function()
	if PlayerData then
		while true do
			if not Character:FindFirstChild("Safezone_ForceField") then
				if PlayerData.Hunger.Value > 0 then
					PlayerData.Hunger.Value = PlayerData.Hunger.Value - 1 -- every ~16 minutes you'll run out of hunger
				end
			end
			task.wait(10)
		end
	end
end)
]]


--// Equipment, Senko was here

local PreviousArmorBonuses = {
	Strength = 0,
	Defense = 0,
	Mana = 0,
	Agility = 0,
	["Magic Power"] = 0,
}

local function updateEquipment()
	local amountDestroyed = 0
	for _,v in pairs(Character:GetDescendants()) do
		if v:GetAttribute("IsEquipment") == true then
			amountDestroyed += 1
			v:Destroy()
		end
	end

	-- Removing Bonuses
	for name,prev in pairs(PreviousArmorBonuses) do
		local foundBonus = Bonuses:FindFirstChild(name)
		if foundBonus then foundBonus.Value -= prev PreviousArmorBonuses[name] = 0 end
	end
	-- Adding Bonuses
	if CurrentEquipment.Value == "Scarlet Fighter" then
		PreviousArmorBonuses.Agility += 2
		PreviousArmorBonuses.Defense += 60
	elseif CurrentEquipment.Value == "Fairy Tail Cloak" then
		PreviousArmorBonuses.Defense += 35
	elseif CurrentEquipment.Value == "Fairy Tail Sleeveless" then
		PreviousArmorBonuses.Defense += 35
	elseif CurrentEquipment.Value == "Dragneel Cloak" then
		PreviousArmorBonuses.Defense += 65
		PreviousArmorBonuses.Mana += 15
	elseif CurrentEquipment.Value == "Leather Shoulder Pads" then
		PreviousArmorBonuses.Defense += 25
	elseif CurrentEquipment.Value == "Rusty Knight's Armor" then
		PreviousArmorBonuses.Defense += 75
	elseif CurrentEquipment.Value == "White Beater" then
		PreviousArmorBonuses.Defense += 40
	elseif CurrentEquipment.Value == "Iron Slayer" then
		PreviousArmorBonuses.Defense += 130
	elseif CurrentEquipment.Value == "Iron Drifter" then
		PreviousArmorBonuses.Defense += 90
	end
	-- Adding Bonuses to Character
	for name,prev in pairs(PreviousArmorBonuses) do
		local foundBonus = Character.Data.Bonuses:FindFirstChild(name)
		if foundBonus then foundBonus.Value += prev end

		if prev >= 0 then
			game.ReplicatedStorage.Remotes.Notify:FireClient(Player, "+"..prev.." "..name.."!", 7)
		else
			game.ReplicatedStorage.Remotes.Notify:FireClient(Player, "-"..prev.." "..name.."!", 7)
		end
	end
	--
	game.ReplicatedStorage.Remotes.Notify:FireClient(Player, "Updated passives for equipment: ".. PlayerData.Equipment.Value..".", 4)

	local E = serverstorage.Equipment:FindFirstChild(CurrentEquipment.Value)

	if E then
		local clone = E:FindFirstChild(CurrentEquipment.Value)

		if clone then
			for i,v in pairs(clone:GetChildren()) do
				if v:IsA("Model") then
					local equipmentclone = v:Clone()
					equipmentclone[v.Name].Weld.Part1 = Character[v.Name]
					equipmentclone[v.Name].Weld.C1 = CFrame.new(equipmentclone[v.Name]:GetAttribute("C1")) 
					equipmentclone.Parent = Character[v.Name]

					equipmentclone:SetAttribute("IsEquipment", true)
				end
				if v:IsA("MeshPart") then
					local equipmentclone = v:Clone()
					equipmentclone.Weld.Part1 = Character[v.Name]
					equipmentclone.Weld.C1 = CFrame.new(equipmentclone:GetAttribute("C1")) 
					equipmentclone.Parent = Character[v.Name]

					equipmentclone:SetAttribute("IsEquipment", true)
				end
			end
		end
	end
end

updateEquipment()
CurrentEquipment.Changed:Connect(function()
	updateEquipment()
end)

--//InvincibilityPatch

StatusFolder.ChildRemoved:Connect(function(c)
	if c.Name == "Gripper" or c.Name == "Knocked" or c.Name == "Ragdoll" or c.Name == "Carrier" then
		spawn(function()
			task.wait(1)
			for i,v in pairs(StatusFolder:GetChildren()) do
				if v.Name == "Intangibility" then
					v:Destroy()
				end
			end

		end)
	end

end)
