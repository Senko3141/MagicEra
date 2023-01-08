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

local function getRandomShrugAnimation(folder)
	local children = folder:GetChildren()
	local amount = #children

	return children[math.random(amount)]
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

local Formulas = require(ReplicatedStorage.Modules.Shared.Formulas)

-- SKILL TYPES IGNORE --
local TO_SET_PATTERN = {
	["Fire Bullet"] = 5,
	["Fire Volley"] = 5,
	["King's Shot"] = 5,
	["King's Spear"] = 5,

	["Gravity Force"] = 5,
	["Gravity Trap"] = 5,
	["Thunder God Orbs"] = 5,
	["Thunder Claws"] = 5,
	["Globus"] = 5,
	["Thunder Roar"] = 5,
	["Shadow Dragon Roar"] = 5,
	["Iron Dragon's Roar"] = 5,
	["Rest"] = 5,
	["Dark Spear"] = 5,
	["Blinding Shot"] = 5,
	["Dark Bomb"] = 5,
	["Water Bullet"] = 5,
	["Water Trap"] = 5,
	["Water Dragon"] = 5,
	["Water Sharks"] = 5,
	["Wind Cutter"] = 5,
	["Wind Bullets"] = 5,
	["Wind Tornado"] = 5,

	["Earth Dragon"] = 5,
	["Earth Smash"] = 5,

	["Ice Age"] = 5,
	["Ice Spikes"] = 5,
	["Ice Bird"] = 5,
	["Ice Blade"] = 5,

	["Magic Bullets"] = 5,
	["Piercing Shot"] = 5,
	["Grimoire Ray"] = 5,
	
	["Jiu Leixing"] = 5,
	["Pleiades"] = 5,
	["Altairis"] = 5,
	["Heaven's Gate"] = 5,

	["Poison Spit"] = 5,
	["Poison Grab"] = 5,
	["Poison Eruption"] = 5,
	["Gravity Pressure"] = 5,
	["King's Pillar"] = 5,
	["Fire Strike"] = 5,
	["Soul Punch"] = 5,
	
	["Fragment"] = 3,
	["SlideSkill"] = 5,
	
	["Iron Dragon's Club"] = 5,
	["Shadow Travel"] = 5,
	["Conquer"] = 5,
	["Soumetsu"] = 5,
	["Meta Grab"] = 5,

}
local TO_IGNORE_ANIMS = {
	["Gravity Pressure"] = true,
	["Soul Punch"] = true,
}
local TO_SET_VELO = {
	["Fire Volley"] = 30,
	["King's Spear"] = 60,
	["Dark Spear"] = 60,
	["Gravity Force"] = 0,
	["Gravity Trap"] = 0,
	["Thunder God Orbs"] = 0,
	["Thunder Claws"] = 60,
	["Globus"] = 75,
	["Thunder Roar"] = 0,
	["Shadow Dragon Roar"] = 0,
	["Blinding Shot"] = 15,
	["Dark Bomb"] = 30,
	["Water Bullet"] = 50,
	["Water Trap"] = 0,
	["Water Dragon"] = 70,
	["Water Sharks"] = 40,
	["Wind Cutter"] = 60,
	["Wind Bullets"] = -40,
	["Earth Dragon"] = 70,
	["Earth Smash"] = 0,

	["Ice Age"] = 0,
	["Ice Spikes"] = 30,
	["Ice Bird"] = 65,
	["Ice Blade"] = 10,
	["ForwardKick"] = 30,

	["Magic Bullets"] = 10,
	["Piercing Shot"] = 60,
	["Grimoire Ray"] = 60,	
	["Poison Spit"] = 60,
	["Poison Grab"] = 0,
	["Poison Eruption"] = 0,
	["Gravity Pressure"] = 0,
	["King's Pillar"] = 0,
	["Fire Strike"] = 0,
	["SlideSkill"] = 0,
	["Soumetsu"] = 0,
	["Soul Punch"] = 0,
	["Meta Grab"] = 0,
	["Waxing Wing"] = 0,
}
local IGNORE_VELO = {
	["Wind Tornado"] = true,
	["Poison Grab"] = true,
	["Poison Eruption"] = true,
	["King's Pillar"] = true,
	["Fire Strike"] = true,
	["SlideSkill"] = true,
	
	["Iron Dragon's Club"] = true,
	["Soumetsu"] = true,
	["Soul Punch"] = true,
	["Meta Grab"] = true,
	["Waxing Wing"] = true,


}
local IGNORE_FLOOR_BLOCKS = {
	["Fire Volley"] = true,
	["King's Spear"] = true,
	["Gravity Force"] = true,
	["Gravity Trap"] = true,
	["Thunder God Orbs"] = true,
	["Thunder Claws"] = true,
	["Globus"] = true,
	["Thunder Roar"] = true,
	["Shadow Dragon Roar"] = true,
	["Dark Spear"] = true,
	["Dark Bomb"] = true,
	["Water Bullet"] = true,
	["Water Trap"] = true,
	["Water Dragon"] = true,
	["Water Sharks"] = true,
	["Wind Cutter"] = true,
	["Wind Bullets"] = true,
	["Wind Tornado"] = true,
	["Earth Dragon"] = true,
	["Earth Smash"] = true,
	["Poison Eruption"] = true,

	["Ice Age"] = true,
	["Ice Spikes"] = true,
	["Ice Bird"] = true,
	["Ice Blade"] = true,

	["Magic Bullets"] = true,
	["Piercing Shot"] = true,
	["Grimoire Ray"] = true,
	
	["Jiu Leixing"] = true,
	["Pleiades"] = true,
	["Altairis"] = true,
	["Heaven's Gate"] = true,

	["Poison Spit"] = true,
	["Poison Grab"] = true,
	["Gravity Pressure"] = true,
	["King's Pillar"] = true,
	["Fire Strike"] = true,
	["SlideSkill"] = true,
	
	["Iron Dragon's Club"] = true,
	["Shadow Travel"] = true,
	["Conquer"] = true,
	["Soumetsu"] = true,
	["Soul Punch"] = true,
	["Meta Grab"] = true,
	["Waxing Wing"] = true,



}
local IGNORE_SCREEN_SHAKE = {

	["Fire Bullet"] = true,
	["Fire Volley"] = true,
	["King's Shot"] = true,
	["King's Spear"] = true,
	["Gravity Force"] = true,
	["Gravity Trap"] = true,
	["Thunder God Orbs"] = true,
	["Thunder Claws"] = true,
	["Globus"] = true,
	["Thunder Roar"] = true,
	["Shadow Dragon Roar"] = true,
	["Dark Spear"] = true,
	["Dark Bomb"] = true,
	["Water Bullet"] = true,
	["Water Trap"] = true,
	["Water Dragon"] = true,
	["Water Sharks"] = true,
	["Wind Cutter"] = true,
	["Wind Bullets"] = true,
	["Wind Tornado"] = true,
	["Earth Dragon"] = true,
	["Earth Smash"] = true,

	["Ice Age"] = true,
	["Ice Spikes"] = true,
	["Ice Bird"] = true,
	["Ice Blade"] = true,
	["Magic Bullets"] = true,
	["Piercing Shot"] = true,
	["Grimoire Ray"] = true,	
	["Poison Spit"] = true,
	["Poison Grab"] = false,
	["Poison Eruption"] = true,
	["Gravity Pressure"] = true,
	["King's Pillar"] = true,
	["Fire Strike"] = true,
	["SlideSkill"] = true,
	["Soumetsu"] = true,
	["Soul Punch"] = true,
	["Meta Grab"] = false,
	["Waxing Wing"] = true,


}
local IGNORE_DEFAULT_SOUNDS = {
	["Thunder Claws"] = true,
	["Gravity Pressure"] = true,
	["Shadow Travel"] = true,
	["Conquer"] = true,
	["Soumetsu"] = true,
	["Meta Grab"] = true,
	["Poison Shot"] = true,



}
local MOVES_TO_RAGDOLL = {
	["King's Shot"] = true,
	["Thunder Claws"] = false,
	["Globus"] = true,
	["Fire Bullet"] = true,
	["King's Spear"] = true,
	["Dark Spear"] = true,
	["Blinding Shot"] = true,
	["Dark Bomb"] = true,
	["Water Bullet"] = true,
	["Water Dragon"] = true,
	["Water Sharks"] = false,
	["Wind Cutter"] = true,
	["Wind Bullets"] = true,
	["Wind Tornado"] = true,
	["Earth Dragon"] = true,
	["Earth Smash"] = true,
	["Hit"] = true,

	["Ice Spikes"] = true,
	["Ice Bird"] = true,
	["Magic Bullets"] = false,
	["Piercing Shot"] = true,
	["Grimoire Ray"] = true,
	["Poison Spit"] = true,
	["Poison Grab"] = true,
	["Poison Eruption"] = false,
	["Gravity Pressure"] = false,
	["King's Pillar"] = false,
	["Fire Strike"] = true,
	["SlideSkill"] = true,
	
	["Iron Dragon's Club"] = true,
	["Soul Punch"] = false,
	["Meta Grab"] = true,
	["Waxing Wing"] = false,


	--["Soumetsu"] = true,
}
local IGNORE_BLUR = {
	["Soumetsu"] = true,
}

script.Parent.Event:Connect(function(Data)
	local Player = Data.Player
	local Target = Data.Target
	local FinalHit = Data.FinalHit
	local DefaultDamage = Data.DefaultDamage
	local IsNPC = Data.IsNPC

	print(Data.SkillType, IsNPC)

	-- SCALING DAMAGE IF HAS SKILLTYPE --
	if Data.SkillType ~= nil then
		DefaultDamage = Formulas.GetDamage(Player, DefaultDamage, {
			["Type"] = Data.Type,
			["SkillType"] = Data.SkillType
		})
	end

	local Character = (IsNPC and Player) or Player.Character

	local Root = Character.HumanoidRootPart
	local VictimRoot = Target.HumanoidRootPart
	local VictimPlayer = Players:GetPlayerFromCharacter(Target)

	if Target.Status:FindFirstChild("Evade") then
		return
	end

	if Target.Status:FindFirstChild("InAir") then
		-- FLING PREVENTION FOR INAIR PPL --
		local destroy_inair = Instance.new("Folder")
		destroy_inair.Name = "Destroy"
		destroy_inair.Parent = Target.Status.InAir
	end

	if Data.SkillType == "Blinding Shot" then
		-- BLIND --
		if not Target.Status:FindFirstChild("Blind") then
			local Blinded = Instance.new("Folder")
			Blinded.Name = "Blind"
			Blinded.Parent = Target.Status
			game.Debris:AddItem(Blinded, 3)
		end
	end

	if Data.SkillType == "Poison Spit" then
		-- POISON --
		if not Target.Status:FindFirstChild("Poison") then
			local Blinded = Instance.new("Folder")
			Blinded.Name = "Poison"
			Blinded.Parent = Target.Status
			game.Debris:AddItem(Blinded, 3)
		end
	end
	if Data.SkillType == "Poison Grab" then
		-- POISON --
		if not Target.Status:FindFirstChild("Poison") then
			local Blinded = Instance.new("Folder")
			Blinded.Name = "Poison"
			Blinded.Parent = Target.Status
			game.Debris:AddItem(Blinded, 6)
		end
	end

	if Data.SkillType ~= nil then
		-- give exp


		if not IsNPC then
			local PlayerData = Player:FindFirstChild("Data")
			if PlayerData then
				game.ServerScriptService.Events.GiveData:Fire(
					Player,
					{
						["Element_Experience"] = 3,
					}
				)
				--	PlayerData.Element_Experience.Value += 5
			end
		end

	end
	--[[
	if not Data.SkillType then
		-- do trails
		toggleDashTrail(Target, true)
		task.delay(1, function()
			toggleDashTrail(Target, false)
		end)
	end
	]]

	local CurrentWeapon = Character and Character:FindFirstChild("Data") and Character.Data:FindFirstChild("CurrentWeapon") or nil
	-- Playing Sounds, and Hit Reactions
	if CurrentWeapon.Value == "" then
		-- default to Combat
		CurrentWeapon = {Value = "Combat"}
	end

	if CurrentWeapon then
		local pattern = ServerInfo.Swings
		
		ServerInfo.PreviousCombo = os.clock() -- resetting combo

		if TO_SET_PATTERN[Data.SkillType] then
			pattern = TO_SET_PATTERN[Data.SkillType]
		end

		local soundAsset = Assets.Sounds:FindFirstChild(CurrentWeapon.Value.."Hit"..pattern)

		if soundAsset then

			if not IGNORE_DEFAULT_SOUNDS[Data.SkillType] then
				Remotes.ClientFX:FireAllClients("Sound", {
					SoundName = soundAsset.Name,
					Parent = VictimRoot
				})
			end
		end

		-- playing animation
		-- checking if target is a player
		if not TO_IGNORE_ANIMS[Data.SkillType] then
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
	end

	if not IsNPC then
		Remotes.ComboCounter:FireClient(Player) -- add Hit
	end

	-- Face Victim
	FaceVictim({
		Character = Character,
		Victim = Target,
	})

	-- Stun Target
	local StunTime = .6
	if Data.SkillType == "Hit" then
		--StunTime = 3
		StunTime = .6
	end
	if CurrentWeapon.Value == "Greatsword" then
		StunTime = 1
	end
	if CurrentWeapon.Value == "Battleaxe" then
		StunTime = 1
	end
	if Data.SkillType == "Soul Punch" then
		StunTime = 2
	end
	if Data.SkillType == "Rest" then
		StunTime = 3
	end

	-- Imbedding Stuff --
	if not IsNPC then
		task.spawn(function()
			if Character.Data.AuraEnabled.Value and Data.SkillType == nil then
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
						Target.Data.Mana.Value -= 20
					end
					Character.Data.Mana.Value += 1
				end
				if Player.Data.ImbuedType.Value == "Foresight" then
					local ForesightSlowness = Instance.new("Folder")
					ForesightSlowness.Name = "ForesightSlowness"
					ForesightSlowness.Parent = Target.Status
					game.Debris:AddItem(ForesightSlowness, 1)
				end
			end
		end)
	end

	local can_ragdoll = false
	if MOVES_TO_RAGDOLL[Data.SkillType] then
		can_ragdoll = true
	end
	if Data.SkillType == nil then
		can_ragdoll = true
	end
	
	
	if Target:FindFirstChild("Settings")then
		if Target.Settings:FindFirstChild("Team").Value == "Hodra" then
			can_ragdoll = false
		end
	end
	StunHandler:Stun(Target, StunTime, can_ragdoll, Data.Type or script.Name)

	-- TakeDamage
	DamageHandler:Damage(Player, Target, DefaultDamage, {
		CanIndicate = true,
		Type = script.Name,
	})
	
	-- Effects
	local Velo = 70
	local Direction = (VictimRoot.CFrame.p - Root.CFrame.p).Unit
	if TO_SET_VELO[Data.SkillType] then
		Velo = TO_SET_VELO[Data.SkillType]
	end

	if not IGNORE_VELO[Data.SkillType] then
		BodyVelocity({
			Name = "Knockback",
			MaxForce = Vector3.new(6000, 6000, 6000),
			Velocity = Direction * Velo,
			Parent = VictimRoot,

			Duration = .1
		})
	elseif Data.SkillType == "SlideSkill" then
		BodyVelocity({
			Name = "Knockback",
			MaxForce = Vector3.new(4e4,4e4,4e4),
			Velocity = VictimRoot.CFrame.UpVector*60,
			Parent = VictimRoot,
			Duration = .2,
		})
	elseif Data.SkillType == "Soul Punch" then
		
		BodyVelocity({
			Name = "Knockback",
			MaxForce = Vector3.new(4e4, 4e4, 4e4),
			Velocity = (VictimRoot.CFrame.p - Root.CFrame.p).Unit * 2,
			Parent = VictimRoot,

			Duration = .2
		})
	end

	Remotes.ClientFX:FireAllClients("Dirt", Target)

	if not IGNORE_FLOOR_BLOCKS[Data.SkillType] then
		-- ignore if weapon is katana
		local ig = true -- false
		if CurrentWeapon.Value == "Katana" or CurrentWeapon.Value == "Dagger" then
			ig = true
		end

		if not ig then
			Remotes.ClientFX:FireAllClients("FloorBlocks", {
				["Direction"] = Direction,
				["Position"] = Character.HumanoidRootPart.Position,
				
			})
			Remotes.ClientFX:FireAllClients("Sound", {
				SoundName = "Boom",
				Parent = VictimRoot
			})
		end
	end

	Remotes.ClientFX:FireAllClients("Orbies", 
		{
			Parent = VictimRoot, 
			Speed = .4, 
			Color = (not FinalHit and Color3.fromRGB(255, 58, 61)) or Color3.fromRGB(255,255,255),
			Size = Vector3.new(.2, .3, 3.79), 
			Cframe = CFrame.new(0,0,7), 
			Amount = 7, 
			Circle = true, 
			Sphere = true
		}
	)
	-- CameraShake
	if not IsNPC then

		if not IGNORE_SCREEN_SHAKE[Data.SkillType] then
			Remotes.ClientFX:FireClient(Player, "CameraShake", {
				Type = "Settings",
				Info = {8, 7, 0, 1}
			})
		end
		if not IGNORE_BLUR[Data.SkillType] then
			Remotes.ClientFX:FireClient(Player, "Blur", {
				FinalSize = 7,
				Duration = .25
			})
		end
	end

	-- Last Damage for EXP/Gold --
	local target_data = Target:FindFirstChild("Data")
	if target_data and target_data:FindFirstChild("LastHit") then
		if not IsNPC then
			target_data.LastHit.Value = Character
		end
	end
end)