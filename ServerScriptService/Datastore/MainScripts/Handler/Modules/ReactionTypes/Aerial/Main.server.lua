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

local AirTime = 1.5
local TargetStunTime = 1
local CharacterStunTime = .5

script.Parent.Event:Connect(function(Data)
	local Player = Data.Player
	local Target = Data.Target
	local DefaultDamage = Data.DefaultDamage
	if Target:FindFirstChild("Settings")then
		if Target.Settings.Team.Value == "Hodra" then
			return
		end
	end
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


	-- Stun Target
	StunHandler:Stun(Target, TargetStunTime)
	StunHandler:Stun(Character, CharacterStunTime)
	-- TakeDamage
	DamageHandler:Damage(Player, Target, DefaultDamage, {
		CanIndicate = true,
		Type = script.Name,
	})
	
	-- Negating Fall Damage
	if Character:FindFirstChild("Status") then
		local NegatefallDmg1 = Instance.new("Folder")
		NegatefallDmg1.Name = "NegateFallDamage"
		NegatefallDmg1:SetAttribute("Percentage", 100)
		NegatefallDmg1.Parent = Character:FindFirstChild("Status")
		game.Debris:AddItem(NegatefallDmg1, AirTime+1)
	end
	if Target:FindFirstChild("Status") then
		local NegatefallDmg1 = Instance.new("Folder")
		NegatefallDmg1.Name = "NegateFallDamage"
		NegatefallDmg1:SetAttribute("Percentage", 100)
		NegatefallDmg1.Parent = Target:FindFirstChild("Status")
		game.Debris:AddItem(NegatefallDmg1, AirTime+1)
	end
	--
	
	if CurrentWeapon then
		local pattern = ServerInfo.Swings
		local soundAsset = Assets.Sounds:FindFirstChild(CurrentWeapon.Value.."Hit5")

		if soundAsset then
			Remotes.ClientFX:FireAllClients("Sound", {
				SoundName = soundAsset.Name,
				Parent = VictimRoot
			})
		end
	end

	if not IsNPC then
		Remotes.ComboCounter:FireClient(Player) -- add Hit
	end

	if not IsNPC then
		Remotes.ClientFX:FireClient(Player, "CameraShake",
			{
				Type = "Settings",
				Info = {1, 1, 0.1, 0.75}
			}
		)
	end

	-- CREATING IN AIR OBJECTS --
	local InAir_Character = Instance.new("Folder")
	InAir_Character.Name = "InAir"
	InAir_Character.Parent = Character.Status

	local InAir_Target = Instance.new("Folder")
	InAir_Target.Name = "InAir"
	InAir_Target.Parent = Target.Status

	-- Air Stuff	
	Character.Humanoid.AutoRotate = false

	local Origin = Character.HumanoidRootPart.Position
	local Direction = Character.HumanoidRootPart.CFrame.UpVector * 10
	local FinalPos = Character.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0)

	local Params = RaycastParams.new()
	Params.FilterDescendantsInstances = {workspace.Visuals, workspace.Effects, Character}
	Params.IgnoreWater = true
	Params.FilterType = Enum.RaycastFilterType.Blacklist

	local Result = workspace:Raycast(Origin, Direction, Params)
	if Result then
		--FinalPos = CFrame.new(Result.Position)
	end

	if Players:GetPlayerFromCharacter(Target) == nil and Target and Player then
		if Target.HumanoidRootPart and Target.HumanoidRootPart.Anchored == false then
			for _,v in ipairs(Target:GetChildren()) do
				if v:IsA("BasePart") and v.Anchored == false then
					v:SetNetworkOwner(Target)
				end
			end
		end
	end

	Remotes.ClientFX:FireAllClients("AerialLift", {
		["Character"] = Character,
	})
	Remotes.ClientFX:FireAllClients("ImpactLines", {
		["Character"] = Character,
		Amount = 15,
		Type = "aerial_up"
	})

	if not IsNPC then
		Remotes.ClientFX:FireClient(Player, "Blur", {FinalSize = 10, Duration = .05})
	end

	local tp = Players:GetPlayerFromCharacter(Target)
	if tp then
		Remotes.ClientFX:FireClient(tp, "Blur", {FinalSize = 10, Duration = .05})
	end

	local BodyPosition = Instance.new("BodyPosition")
	BodyPosition.Name = "PullUp"
	BodyPosition.MaxForce = Vector3.new(9e9,9e9,9e9)
	BodyPosition.P = 2e4
	--BodyPosition.D = 350
	BodyPosition.Position = Origin + Direction


	local TargetBodyPos = Instance.new("BodyPosition")
	TargetBodyPos.Name = "PullUp"
	TargetBodyPos.MaxForce = Vector3.new(9e9,9e9,9e9)
	TargetBodyPos.P = 2e4
	--TargetBodyPos.D = 350
	TargetBodyPos.Position = (FinalPos*CFrame.new(0,0,-3)).p

	BodyPosition.Parent = Character.HumanoidRootPart
	TargetBodyPos.Parent = Target.HumanoidRootPart
	-----------

	local C = nil
	local C2 = nil
	local WasDestroyed = false

	C = InAir_Target.ChildAdded:Connect(function(Child)
		-- FLING PREVENTION --
		if Child.Name == "Destroy" then
			C:Disconnect()
			C = nil

			WasDestroyed = true
			game.Debris:AddItem(BodyPosition, 0)
			game.Debris:AddItem(TargetBodyPos, 0)
			game.Debris:AddItem(InAir_Character, 0)
			game.Debris:AddItem(InAir_Target, 0)
			Character.Humanoid.AutoRotate = true
		end
	end)


	-- DESTROYING --
	task.delay(AirTime, function()
		if WasDestroyed then return end
		game.Debris:AddItem(BodyPosition, 0)
		game.Debris:AddItem(TargetBodyPos, 0)
		game.Debris:AddItem(InAir_Character, 0)
		game.Debris:AddItem(InAir_Target, 0)

		Character.Humanoid.AutoRotate = true
	end)
end)