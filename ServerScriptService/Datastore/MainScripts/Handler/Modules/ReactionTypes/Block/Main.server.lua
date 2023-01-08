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

local function getRandomShrugAnimation(folder)
	local children = folder:GetChildren()
	local amount = #children

	return children[math.random(amount)]
end

script.Parent.Event:Connect(function(Data)
	local Player = Data.Player
	local Target = Data.Target
	local DefaultDamage = Data.DefaultDamage

	-- SCALING DAMAGE IF HAS SKILLTYPE --
	if Data.SkillType ~= nil then
		DefaultDamage = Formulas.GetDamage(Player, DefaultDamage, {
			["Type"] = Data.Type,
			["SkillType"] = Data.SkillType
		})
	end

	local IsNPC = Data.IsNPC
	local Character = (IsNPC and Player) or Player.Character

	local VictimRoot = Target.HumanoidRootPart
	local Root = Character.HumanoidRootPart
	local VictimPlayer = Players:GetPlayerFromCharacter(Target)

	local CurrentWeapon = Character and Character:FindFirstChild("Data") and Character.Data:FindFirstChild("CurrentWeapon") or nil
	if CurrentWeapon.Value == "" then
		-- default to Combat
		CurrentWeapon = {Value = "Combat"}
	end

	if CurrentWeapon then
		Remotes.ClientFX:FireAllClients("Sound", {
			SoundName = CurrentWeapon.Value.."BlockHit",
			Parent = VictimRoot
		})
		local shrugAnimation = getRandomShrugAnimation(Assets.Animations[CurrentWeapon.Value].Block.Reactions)

		if VictimPlayer then
			Target.Handler.Events.Animation:FireClient(VictimPlayer, "PlayAnimation", {
				Directory = CurrentWeapon.Value.."/Block/Reactions/"..shrugAnimation.Name
			})
		else
			local animation = Target.Humanoid:LoadAnimation(
				shrugAnimation
			)
			animation:Play()
		end
		
		-- Playing Animation for Character
		task.spawn(function()
			for _,v in pairs(Character.Humanoid:GetPlayingAnimationTracks()) do
				if v.Name == "ParryHit" then
					v:Stop(.1)
				end
			end
		end)
		
		-- no attack for player --
		local NoAttack = Instance.new("Folder")
		NoAttack.Name = "NoAttack"
		NoAttack.Parent = Character.Status
		task.delay(.5, function()
			NoAttack:Destroy()
		end)
		
		if not Data.SkillType then
			local AnimNew = Character.Humanoid:LoadAnimation(Assets.Animations.ParryHit)
			AnimNew:Play()
		end
	end
	
	-- Player Status
	local VictimStatus = Target:FindFirstChild("Status")
	if VictimStatus then
		print("??? slow down")
		local SlowDown = Instance.new("Folder")
		SlowDown.Name = "SlowDown"
		SlowDown:SetAttribute("SlowPercentage", .4)
		SlowDown.Parent = VictimStatus
		game.Debris:AddItem(SlowDown, .2)
	end

	--[[
	Remotes.ClientFX:FireAllClients("Orbies", 
		{
			Parent = Target.HumanoidRootPart, 
			Speed = .4, 
			Color = Color3.fromRGB(255, 241, 34),
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
		if v.Name == "Block" then
			v:Emit(1)
		end
	end

	-- TakeDamage
	DamageHandler:Damage(Player, Target, DefaultDamage, {
		CanIndicate = true,
		Type = script.Name,
	})
end)