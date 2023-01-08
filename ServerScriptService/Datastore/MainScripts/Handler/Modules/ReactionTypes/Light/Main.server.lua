local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerModules = ServerScriptService.Modules
local Remotes = ReplicatedStorage.Remotes
local Assets = ReplicatedStorage.Assets
local ServerInfo = require(script.Parent.Parent.Parent.Parent.Input.Info)

local StunHandler = require(ServerModules.StunHandler)
local BodyVelocity = require(ReplicatedStorage.Modules.Client.Effects.BodyVelocity)
local FaceVictim = require(ReplicatedStorage.Modules.Client.Effects.FaceVictim)
local ServerInfo = require(script.Parent.Parent.Parent.Parent.Input.Info)
local DamageHandler = require(ServerModules.DamageHandler)
local Formulas = require(ReplicatedStorage.Modules.Shared.Formulas)

local TO_SET_PATTERN = {
	["Iron Dragon's Lance"] = 2,
	["Soul Punch"] = 2,
}

local function getRandomShrugAnimation(folder)
	local children = folder:GetChildren()
	local amount = #children

	return children[math.random(amount)]
end

script.Parent.Event:Connect(function(Data)
	local Player = Data.Player
	local Target = Data.Target
	local DefaultDamage = Data.DefaultDamage
	local IsNPC = Data.IsNPC

	local Character = (IsNPC and Player) or Player.Character

	local Root = Character.HumanoidRootPart
	local VictimRoot = Target.HumanoidRootPart
	local VictimPlayer = Players:GetPlayerFromCharacter(Target)

	local CurrentWeapon = Character and Character:FindFirstChild("Data") and Character.Data:FindFirstChild("CurrentWeapon") or nil

	if Target.Status:FindFirstChild("Evade") then
		return -- Evaded Attack
	end

	if CurrentWeapon.Value == "" then
		-- default to Combat
		CurrentWeapon = {Value = Data.CurrentWeapon or "Combat"}
	--	CurrentWeapon = {Value = "Combat"}
	end

	if not IsNPC then
		Remotes.ComboCounter:FireClient(Player) -- add Hit
	end


	-- No need to check if blocking/behind bc stunned thing already detects

	-- Playing Sounds, and Hit Reactions
	if CurrentWeapon then
		local pattern = ServerInfo.Swings

		if TO_SET_PATTERN[Data.SkillType] then
			pattern = TO_SET_PATTERN[Data.SkillType]
		end
		local soundAsset = Assets.Sounds:FindFirstChild(CurrentWeapon.Value.."Hit"..pattern)

		if soundAsset then
			Remotes.ClientFX:FireAllClients("Sound", {
				SoundName = soundAsset.Name,
				Parent = VictimRoot
			})
		end

		-- playing animation
		-- checking if target is a player
		if VictimPlayer then
			Target.Handler.Events.Animation:FireClient(VictimPlayer, "PlayAnimation", {
				Directory = CurrentWeapon.Value.."/Reactions/"..CurrentWeapon.Value.."Hit"..pattern
			})
		else
			local animation = Target.Humanoid:LoadAnimation(
				Assets.Animations[CurrentWeapon.Value].Reactions[CurrentWeapon.Value.."Hit"..pattern]
			)
			animation:Play()
		end
	end

	-- Face Victim
	FaceVictim({
		Character = Character,
		Victim = Target,
	})

	-- Stun Target
	local StunTime = .45

	local KB_VELO = 1
	local PULL_VELO = 8

	if CurrentWeapon.Value == "Greatsword" or CurrentWeapon.Value == "Battleaxe" then
		StunTime = 1
	end

	local can_ragdoll = false
	if CurrentWeapon.Value == "Greatsword" then
		--	can_ragdoll = true
	end

	-- Imbedding Stuff/Trait Stuff --
	if not IsNPC then
		task.spawn(function()
			if Character.Data.AuraEnabled.Value then
				if Player.Data.ImbuedType.Value == "Thunder Dragon Slayer" then
					StunTime += .5

					game.ReplicatedStorage.Remotes.ClientFX:FireAllClients("Sound", {
						SoundName = "LightningSizzle",
						Parent = Character.HumanoidRootPart
					})

					for _,v in pairs(Character:GetChildren()) do
						if v:IsA("BasePart") then
							local fx = ServerScriptService.Datastore.Effects.Lightning:Clone()
							fx.Parent = Target.HumanoidRootPart

							for _,v in pairs(fx:GetDescendants()) do
								if v:IsA("ParticleEmitter") then
									v:Emit(10)
								end
							end
							game.Debris:AddItem(fx, .5)
						end
					end
				end
				if Player.Data.ImbuedType.Value == "King's Flame" then
					if not Target.Status:FindFirstChild("Burn") then
						local burn = Instance.new("Folder")
						burn.Name = "Burn"
						
						local pData = Player:FindFirstChild("Data")
						if pData and pData:FindFirstChild("Equipment") then
							if pData.Equipment.Value == "Natsu's Cloak" then
								burn:SetAttribute("NatsuCloak", true)
							end
						end
						
						burn:SetAttribute("NoDisplay", true)
						burn.Parent = Target.Status
						game.Debris:AddItem(burn, 1)
					end
				end
				if Player.Data.ImbuedType.Value == "Shadow Dragon Slayer" then
					local burn = Instance.new("Folder")
					burn.Name = "Burn"
					
					local pData = Player:FindFirstChild("Data")
					if pData and pData:FindFirstChild("Equipment") then
						if pData.Equipment.Value == "Natsu's Cloak" then
							burn:SetAttribute("NatsuCloak", true)
						end
					end
					
					burn:SetAttribute("NoDisplay", true)
					burn.Parent = Target.Status
					game.Debris:AddItem(burn, 1)
				end
				if Player.Data.ImbuedType.Value == "Devil's Shadow" then
					local Darken = Instance.new("Folder")
					Darken.Name = "Darken"
					Darken.Parent = Target.Status
					game.Debris:AddItem(Darken, .45)
					
					if VictimPlayer then
						-- testing for now
						Target.Data.Mana.Value -= 10
					end
					Character.Data.Mana.Value += 3
				end
				if Player.Data.ImbuedType.Value == "Foresight" then
					local ForesightSlowness = Instance.new("Folder")
					ForesightSlowness.Name = "ForesightSlowness"
					ForesightSlowness.Parent = Target.Status
					game.Debris:AddItem(ForesightSlowness, 3)
				end
			end
			
			local PlayerData = Player:FindFirstChild("Data")
			if PlayerData then
				local TraitsFolder = PlayerData.Traits
				
				if TraitsFolder:FindFirstChild("Carnivore") then
					local random = math.random(1,100)

					if random <= 20 then
						local HealthToSubtract = Target.Humanoid.MaxHealth*0.03
						
						Target.Humanoid.Health -= HealthToSubtract
						Character.Humanoid.Health += HealthToSubtract
						
						local newVal = Instance.new("Folder")
						newVal.Name = "CarnivoreEffect"
						newVal.Parent = Character.Status
						
					end
				elseif TraitsFolder:FindFirstChild("Magic Glutton") then
					local random = math.random(1,100)
					
					if random <= 25 then
						if VictimPlayer then
							local enemyMaxMana = Formulas.GetMaxMana(VictimPlayer)
							
							local manaToDecrease = enemyMaxMana*0.04
							
							Target.Data.Mana.Value -= manaToDecrease
							Character.Data.Mana.Value += manaToDecrease
							
							-- Do Effect
							local newVal = Instance.new("Folder")
							newVal.Name = "GluttonEffect"
							newVal.Parent = Character.Status
						end
					end
					
				end
			end
		end)
	end
	
	if Data.SkillType and Data.SkillType == "Soul Punch" then
		StunTime = 2
	end

	StunHandler:Stun(Target, StunTime, can_ragdoll, Data.Type or script.Name)
	-- TakeDamage
	DamageHandler:Damage(Player, Target, DefaultDamage, {
		CanIndicate = true,
		Type = script.Name,
	})
	-- Effects

	if CurrentWeapon.Value == "Greatsword" then
		--	PULL_VELO = 0
		--	KB_VELO = 80
	end

	BodyVelocity({
		Name = "Knockback",
		MaxForce = Vector3.new(4e4, 4e4, 4e4),
		Velocity = (VictimRoot.CFrame.p - Root.CFrame.p).Unit * KB_VELO,
		Parent = VictimRoot,

		Duration = .2
	})
	
	BodyVelocity({
		Name = "PullEffect",
		MaxForce = Vector3.new(4e4, 4e4, 4e4),
		Velocity = (VictimRoot.CFrame.p - Root.CFrame.p).Unit * PULL_VELO,
		Parent = Root,

		Duration = .2
	})


	for _,v in pairs(VictimRoot.Core:GetChildren()) do
		if CurrentWeapon.Value == "Combat" then
			if v.Name == "HitFX" then
				local emit_count = v:GetAttribute("EmitCount")
				v:Emit(emit_count or 1)
			end
		end
		if CurrentWeapon.Value == "Caestus" or CurrentWeapon.Value == "Silver Gauntlet" then
			if v.Name == "HitFX" then
				local emit_count = v:GetAttribute("EmitCount")
				v:Emit(emit_count or 1)
			end
		end
		if CurrentWeapon.Value == "Katana" then
			if v.Name == "HitFX_Slash" then
				local emit_count = v:GetAttribute("EmitCount")
				v:Emit(emit_count or 1)
			end
		end
		if CurrentWeapon.Value == "SkullSpear" then
			if v.Name == "HitFX_Slash" then
				local emit_count = v:GetAttribute("EmitCount")
				v:Emit(emit_count or 1)
			end
		end
		if CurrentWeapon.Value == "Sacred Katana" then
			if v.Name == "HitFX_Slash" then
				local emit_count = v:GetAttribute("EmitCount")
				v:Emit(emit_count or 1)
			end
		end
		if CurrentWeapon.Value == "Baroque" then
			if v.Name == "HitFX_Slash" then
				local emit_count = v:GetAttribute("EmitCount")
				v:Emit(emit_count or 1)
			end
		end
		if CurrentWeapon.Value == "Excalibur" then
			if v.Name == "HitFX_Slash" then
				local emit_count = v:GetAttribute("EmitCount")
				v:Emit(emit_count or 1)
			end
		end
		if CurrentWeapon.Value == "ScarletBlade" then
			if v.Name == "HitFX_Slash" then
				local emit_count = v:GetAttribute("EmitCount")
				v:Emit(emit_count or 1)
			end
		end
		if CurrentWeapon.Value == "Dagger" then
			if v.Name == "HitFX_Slash" then
				local emit_count = v:GetAttribute("EmitCount")
				v:Emit(emit_count or 1)
			end
		end
		if CurrentWeapon.Value == "Greatsword" then
			if v.Name == "HitFX_Slash" then
				local emit_count = v:GetAttribute("EmitCount")
				v:Emit(emit_count or 1)
			end
		end
		if CurrentWeapon.Value == "Battleaxe" then
			if v.Name == "HitFX_Slash" then
				local emit_count = v:GetAttribute("EmitCount")
				v:Emit(emit_count or 1)
			end
		end
	end


	--VictimRoot.Core.HitEffect:Emit(1)
	--[[
	Remotes.ClientFX:FireAllClients("Orbies", 
		{
			Parent = VictimRoot, 
			Speed = .4, 
			Color = Color3.fromRGB(255, 255, 255),
			Size = Vector3.new(.05, .1, 1.79), 
			Cframe = CFrame.new(0,0,5), 
			Amount = 7, 
			Circle = true, 
			Sphere = true
		}
	)
	Remotes.ClientFX:FireAllClients("Orbies", 
		{
			Parent = VictimRoot, 
			Speed = .4, 
			Color = Color3.fromRGB(255, 253, 172),
			Size = Vector3.new(.05, .05, 1), 
			Cframe = CFrame.new(0,0,3), 
			Amount = 7, 
			Circle = false, 
			Sphere = true
		}
	)
	]]--
	-- CameraShake
	if not IsNPC then
		Remotes.ClientFX:FireClient(Player, "CameraShake", {
			Type = "Settings",
			Info = {1, 1, 0.1, 0.75}
		})
	end

	-- Last Damage for EXP/Gold --
	local target_data = Target:FindFirstChild("Data")
	if target_data and target_data:FindFirstChild("LastHit") then
		if not IsNPC then
			target_data.LastHit.Value = Character
		end
	end
end)