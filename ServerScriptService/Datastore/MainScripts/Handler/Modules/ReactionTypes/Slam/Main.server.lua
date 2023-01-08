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
	else
		CurrentWeapon = CurrentWeapon.Value
	end

	
	if CurrentWeapon then
		local pattern = ServerInfo.Swings
		
		local swingName = ""
		local hitName = ""
		
		if CurrentWeapon == "Katana" then
			swingName = "KatanaSwing5"
			hitName = "KatanaHit5"
		end
		if CurrentWeapon == "Dagger" then
			swingName = "DaggerSwing5"
			hitName = "DaggerHit5"
		end
		if CurrentWeapon == "Combat" then
			swingName = "PunchAir"
			hitName = "CombatHit5"
		end
		
		Remotes.ClientFX:FireAllClients("Sound", {SoundName = swingName, ["Parent"] = Character.HumanoidRootPart});
		Remotes.ClientFX:FireAllClients("Sound", {SoundName = hitName, Parent = Character.HumanoidRootPart});
	end	
	Remotes.ClientFX:FireAllClients("Sound", {SoundName = "SlamDown", Parent = Character.HumanoidRootPart});

	if not IsNPC then
		Remotes.ClientFX:FireClient(Player, "CameraShake",
			{
				Type = "Settings",
				Info = {10, 10, 0, 1.5}
			}
		)
	end

	if not IsNPC then
		Remotes.ComboCounter:FireClient(Player) -- add Hit
	end

	if VictimPlayer then
		Remotes.ClientFX:FireClient(VictimPlayer, "CameraShake",
			{
				Type = "Preset",
				Preset = "Bump"
			}
		)
	end

	StunHandler:Stun(Target, .8)
--	Target.HumanoidRootPart.Anchored = true

	DamageHandler:Damage(Player, Target, DefaultDamage, {
		CanIndicate = true,
		Type = script.Name,
	})

	local HitWall = false

	local Origin = Target.HumanoidRootPart.Position
	local Direction = Character.HumanoidRootPart.CFrame.LookVector*1000 - Vector3.new(20,1000,0)

	local Params = RaycastParams.new()
	Params.FilterDescendantsInstances = {workspace.Visuals, workspace.Effects, Target, Character}
	Params.FilterType = Enum.RaycastFilterType.Blacklist

	local Result = workspace:Raycast(Origin, Direction, Params)

	if Result then

		Target.HumanoidRootPart.Anchored = true
		Target.Humanoid.PlatformStand = true

		local TargetHH = Target.Humanoid.HipHeight
		local distance = (Origin - Result.Position).Magnitude

		--[[
			local p = Instance.new("Part")
			p.Anchored = true
			p.CanCollide = false
			p.Size = Vector3.new(0.1, 0.1, distance)
			p.CFrame = CFrame.lookAt(Origin, Result.Position)*CFrame.new(0, 0, -distance/2)
			p.Parent = workspace
		]]--
		local timeTake = .5
		
		
		local NewCFrame = CFrame.new(Result.Position,Result.Position + Result.Normal)
		local TargetCFrame = NewCFrame * CFrame.new(0,0,-.5)
		local X,Y,Z = TargetCFrame:ToOrientation()
		local Rot = Target.HumanoidRootPart.CFrame - Target.HumanoidRootPart.Position
		local Cframe = CFrame.new(TargetCFrame.Position) * Rot				

		local NewtoCFrame = Cframe --* CFrame.Angles(X,0,Z)

		local tween = game.TweenService:Create(Target.HumanoidRootPart, TweenInfo.new(timeTake, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			CFrame = TargetCFrame
		})
		tween:Play()
		
		local SlamTarget_Anim = Target.Humanoid:LoadAnimation(Assets.Animations.SlamTarget)
		SlamTarget_Anim:Play()

		task.delay(timeTake-.1, function()

			--CharacterFunctions.PlayAnimation(Hit, Assets.Animations.SlamTarget)
			Remotes.ClientFX:FireAllClients("SlamDown", {["Character"] = Character, ["Target"] = Target})

			Remotes.ClientFX:FireAllClients("FlyingRocks", 
				{
					["Instance"] = Result.Instance, 
					["Position"] = Result.Position, 
					["Size"] = Vector3.new(2.434, 1.32, 2.719), 
					["Count"] = 6					
				}
			)

			task.delay(.3+.1, function()
				Target.HumanoidRootPart.Anchored = false
				if not Target.Status:FindFirstChild("Knocked") then
					Target.Humanoid.PlatformStand = false
				end

				local GetupAnim = Target.Humanoid:LoadAnimation(Assets.Animations.GetUp)
				GetupAnim:Play()

				SlamTarget_Anim:Stop(.1)
			end)
			task.delay(1, function()
				--	CharacterFunctions.SetNetworkOwner(Hit, nil)
				Target.HumanoidRootPart.Anchored = false
				--	Hit.Humanoid.HipHeight = TargetHH
			end)
		end)
		task.delay(timeTake, function()

			local inAir_Object = Target.Status:FindFirstChild("InAir")
			if inAir_Object then
				local des = Instance.new("Folder")
				des.Name = "Destroy"
				des.Parent = inAir_Object
			end

			--Hit:SetAttribute("InAir", false)
		end)
	end

end)