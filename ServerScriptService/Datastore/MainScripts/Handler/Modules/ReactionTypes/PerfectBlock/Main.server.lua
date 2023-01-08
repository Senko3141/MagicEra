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

	local Root = Character.HumanoidRootPart
	local VictimRoot = Target.HumanoidRootPart
	local VictimPlayer = Players:GetPlayerFromCharacter(Target)
	local CurrentWeapon = Character and Character:FindFirstChild("Data") and Character.Data:FindFirstChild("CurrentWeapon") or nil

	if CurrentWeapon.Value == "" then
		-- default to Combat
		CurrentWeapon = {Value = "Combat"}
	end

	if CurrentWeapon then
		
		local OverwriteSound = Assets.Sounds:FindFirstChild("PerfectBlock"..CurrentWeapon.Value)
		
		Remotes.ClientFX:FireAllClients("Sound", 
			{
				SoundName = (OverwriteSound and OverwriteSound.Name) or "PerfectBlock", 
				Parent = VictimRoot,
			}
		)
	end

	--[[
	Remotes.ClientFX:FireAllClients("Orbies", 
		{
			Parent = Target.HumanoidRootPart, 
			Speed = .4, 
			Color = Color3.fromRGB(145, 71, 255),
			Size = Vector3.new(.2, .3, 3.79), 
			Cframe = CFrame.new(0,0,5), 
			Amount = 3, 
			Circle = false, 
			Sphere = true
		}
	)
	Remotes.ClientFX:FireAllClients("Orbies", 
		{
			Parent = Target.HumanoidRootPart, 
			Speed = .4, 
			Color = Color3.fromRGB(210, 146, 255),
			Size = Vector3.new(.2, .3, 3.79), 
			Cframe = CFrame.new(0,0,5), 
			Amount = 3, 
			Circle = true, 
			Sphere = false
		}
	)
	]]--

	for _,v in pairs(VictimRoot.Core:GetChildren()) do
		if v.Name == "PerfectBlock" then
			v:Emit(1)
		end
	end

	Remotes.ClientFX:FireAllClients("DamageIndicator",
		{
			DamageAmount = "PERFECT BLOCKED",
			Victim = Target,
			Color = Color3.fromRGB(198, 99, 255),
			NormalColor = Color3.fromRGB(156, 86, 175),
		}
	)
	-- changed to Player.Character bc TargetFound thing

	if not IsNPC then
		Remotes.ClientFX:FireClient(Player, "CameraShake",
			{
				Type = "Preset",
				Preset = "Bump"
			}
		)
	end

	-- Perfect Block Animation
	--[[
	local Anim = Character.Humanoid:LoadAnimation(Assets.Animations.PerfectBlock)
	Anim:Play()
	]]--
	
	Remotes.ClientFX:FireAllClients("PerfectBlockFreeze", {
		["Target"] = Character,
	})

	if not IsNPC then
		Remotes.ClientFX:FireClient(Player, "Blur", {
			FinalSize = 15,
			Duration = 1.5
		})
	end

	-- Stun
	StunHandler:Stun(Character, 1.5)
	-- TakeDamage
	DamageHandler:Damage(Player, Target, DefaultDamage, {
		CanIndicate = true,
		Type = script.Name,
	})
end)