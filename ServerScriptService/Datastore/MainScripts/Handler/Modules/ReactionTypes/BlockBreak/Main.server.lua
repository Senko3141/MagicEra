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

script.Parent.Event:Connect(function(Data)
	local Player = Data.Player
	local Target = Data.Target
	local DefaultDamage = Data.DefaultDamage

	local IsNPC = Data.IsNPC

	local Character = (IsNPC and Player) or Player.Character

	local VictimRoot = Target.HumanoidRootPart
	local Root = Character.HumanoidRootPart
	local VictimPlayer = Players:GetPlayerFromCharacter(Target)

	--[[
	local CurrentWeapon = Character and Character:FindFirstChild("Data") and Character.Data:FindFirstChild("CurrentWeapon") or nil
	if CurrentWeapon then
		Remotes.ClientFX:FireAllClients("Sound", {
			SoundName = "BlockBreak",
			Parent = VictimRoot
		})
		if VictimPlayer then
			Target.Handler.Events.Animation:FireClient(VictimPlayer, "PlayAnimation", {
				Directory = CurrentWeapon.Value.."/Block/"..CurrentWeapon.Value.."BlockBreak"
			})
		else
			local animation = Target.Humanoid:LoadAnimation(
				Assets.Animations[CurrentWeapon.Value].Block[CurrentWeapon.Value.."BlockBreak"]
			)
			animation:Play()
		end
	end
	]]--

	Remotes.ClientFX:FireAllClients("Sound", {
		SoundName = "BlockBreak",
		Parent = VictimRoot
	})
	if VictimPlayer then
		Target.Handler.Events.Animation:FireClient(VictimPlayer, "PlayAnimation", {
			Directory = "Combat/Block/CombatBlockBreak"
		})
	else
		local animation = Target.Humanoid:LoadAnimation(
			Assets.Animations.Combat.Block.CombatBlockBreak
		)
		animation:Play()
	end

	if not IsNPC then
		Remotes.ComboCounter:FireClient(Player) -- add Hit
	end
	
	-- 6 Seconds before Evade Again
	local VictimStatus = Target:FindFirstChild("Status")
	if VictimStatus then
		if not VictimStatus:FindFirstChild("BlockBreakEvadeCooldown") then
			-- Not Found
			local f = Instance.new("Folder")
			f.Name = "BlockBreakEvadeCooldown"
			f.Parent = VictimStatus
			game.Debris:AddItem(f, 6)
		end
		
		if VictimPlayer then
			Remotes.Cooldown:FireClient(VictimPlayer, "Evade", 6)
		end
	end

	-- Stun
	StunHandler:Stun(Target, 1.5)

	--[[
	Remotes.ClientFX:FireAllClients("Orbies", 
		{
			Parent = Target.HumanoidRootPart, 
			Speed = .4, 
			Color = Color3.fromRGB(255, 38, 41),
			Size = Vector3.new(.2, .3, 3.79), 
			Cframe = CFrame.new(0,0,5), 
			Amount = 15, 
			Circle = false, 
			Sphere = true
		}
	)
	Remotes.ClientFX:FireAllClients("Orbies", 
		{
			Parent = Target.HumanoidRootPart, 
			Speed = .4, 
			Color = Color3.fromRGB(255, 255, 255),
			Size = Vector3.new(.2, .3, 3.79), 
			Cframe = CFrame.new(0,0,5), 
			Amount = 3, 
			Circle = true, 
			Sphere = false
		}
	)
	]]--

	for _,v in pairs(VictimRoot.Core:GetChildren()) do
		if v.Name == "BlockBreak" then
			v:Emit(3)
		end
	end

	-- CameraShake
	if not IsNPC then

		if Data.SkillType ~= "Fire Volley" then
			Remotes.ClientFX:FireClient(Player, "CameraShake",
				{
					Type = "Settings",
					Info = {2,2,.25,.15,1.5,1.5}
				}
			)			
		end
	end
	if VictimPlayer then
		Remotes.ClientFX:FireClient(VictimPlayer, "CameraShake",
			{
				Type = "Preset",
				Preset = "Bump"
			}
		)
	end
	--
	Remotes.ClientFX:FireAllClients("DamageIndicator", {
		DamageAmount = "GUARD BROKEN",
		["Victim"] = Target,
		Color = Color3.fromRGB(255, 128, 130),
		NormalColor = Color3.fromRGB(229, 63, 65),
	})
	-- TakeDamage
	DamageHandler:Damage(Player, Target, DefaultDamage, {
		CanIndicate = true,
		Type = script.Name,
	})	
end)