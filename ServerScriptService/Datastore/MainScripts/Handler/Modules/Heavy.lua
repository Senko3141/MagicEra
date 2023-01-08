local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeaponData = ReplicatedStorage.WeaponData
local Assets = ReplicatedStorage.Assets
local Remotes = ReplicatedStorage.Remotes

local ServerInfo = require(script.Parent.Parent.Input.Info)
local HitboxModule = require(ReplicatedStorage.Modules.Shared.HitboxModule)
local HitboxInfo = require(ReplicatedStorage.Modules.Shared.HitboxModule.Info)
local Formulas = require(ReplicatedStorage.Modules.Shared.Formulas)

local ReactionTypes = script.Parent.ReactionTypes

local function getRandomHeavyAnim(folder)
	local children = folder:GetChildren()
	local amount = #children

	return children[math.random(amount)]
end
local function toggleSwordTrail(Model, Bool)
	for _,v in pairs(Model:GetDescendants()) do
		if v:IsA("Trail") and v.Name == "SwordTrail" then
			v.Enabled = Bool
		end
	end
end
local function togglePunchTrail(Model, Bool)
	for _,v in pairs(Model:GetDescendants()) do
		if v:IsA("Trail") and v.Name == "PunchTrail" then
			v.Enabled = Bool
		end
	end
end

local Reactions = {}
for _,m in pairs(ReactionTypes:GetChildren()) do
	if m:IsA("BindableEvent") then
		Reactions[m.Name] = m
	end
end

function module.Activate(Player, OtherData, otherData2)
	local IsNPC = false
	local SkillType = ""

	if type(OtherData) == "table" then
		if OtherData.IsNPC == true then
			IsNPC = true
		end
		SkillType = OtherData.SkillType
	end

	local Character = (IsNPC and Player) or Player.Character

	local StatusFolder = Character:FindFirstChild("Status")
	local CharacterFolder = Character:FindFirstChild("Data")
	if not StatusFolder or not CharacterFolder then return end

	local CurrentWeapon = CharacterFolder:FindFirstChild("CurrentWeapon")
	if not CurrentWeapon then return end
	CurrentWeapon = CurrentWeapon.Value

	if CurrentWeapon == "" or CurrentWeapon == "None" then
		CurrentWeapon = OtherData.CurrentWeapon or nil
	end

	local Weapon_Stats = WeaponData:FindFirstChild(CurrentWeapon) and WeaponData[CurrentWeapon].Stats or nil
	if Weapon_Stats then
		local Cooldowns = Weapon_Stats.Cooldowns
		local AnimationsFolder = Assets.Animations:FindFirstChild(CurrentWeapon)

		local MaxSwings = Weapon_Stats.MaxSwings
		local SwingCooldown = Cooldowns.Swing
		local ResetTime = Cooldowns.ResetTime
		local ComboCooldown = Cooldowns.Combo

		if os.clock() - (ServerInfo.PreviousHeavy or 0) < Cooldowns.Heavy.Value then
			return -- on cooldown
		end
		local AttackCancelled = false

		ServerInfo.PreviousHeavy = os.clock()

		-- NO JUMP --
		local NoJump = Instance.new("Folder")
		NoJump.Name = "NoJump"
		NoJump.Parent = StatusFolder
		game.Debris:AddItem(NoJump, 1)

		-- doing heavy
		local DoingHeavy = Instance.new("Folder")
		DoingHeavy.Name = "DoingHeavy"
		DoingHeavy.Parent = StatusFolder
		game.Debris:AddItem(DoingHeavy, Weapon_Stats.HeavyDuration.Value)

		local HeavyAttack = Instance.new("Folder")
		HeavyAttack.Name = "HeavyAttack"
		HeavyAttack.Parent = StatusFolder
		game.Debris:AddItem(HeavyAttack, Weapon_Stats.HeavyDuration.Value)

		-- Setting Swings to 5
		ServerInfo.Swings = 5

		-- Dash Cancelled
		local DashCancelled = Instance.new("Folder")
		DashCancelled.Name = "DashCancelled"
		DashCancelled.Parent = StatusFolder
		game.Debris:AddItem(DashCancelled, .2)

		-- Playing Animation
		local Animation = Character.Humanoid:LoadAnimation(getRandomHeavyAnim(game.ReplicatedStorage.Assets.Animations[CurrentWeapon].M2))
		local pData = Player:FindFirstChild("Data")
		if not IsNPC and otherData2.HoldingSpace and pData.Stats.Strength.Value >= 50 or SkillType == "Hit" then

			Animation = Character.Humanoid:LoadAnimation(AnimationsFolder["M2Slam"])	


		end
		--Animation:Play(0.15,ServerInfo.Swings)
		--Animation.Priority = Enum.AnimationPriority.Action4
		Animation:Play()

		-- Checking if Stunned
		local Connection
		Connection = StatusFolder.ChildAdded:Connect(function(Child)
			if Child.Name == "Stunned" or Child.Name == "Stun" then
				AttackCancelled = true
				Connection:Disconnect()
				Connection = nil
				DoingHeavy:Destroy()
				HeavyAttack:Destroy()
				if Animation then Animation:Stop(0.1) end -- Stopping Animation
			end
		end)
		if AttackCancelled then return end

		-- Cloning Effect

		local FX = Assets.M2_Effect.Main:Clone()
		if Character:FindFirstChild("Left Leg") then
			FX.Parent = Character["Left Leg"]
			task.spawn(function()
				local amount = 1
				for i = 1,amount do
					task.spawn(function()
						for _,v in pairs(FX:GetDescendants()) do
							if v:IsA("ParticleEmitter") then
								local emit_count = v:GetAttribute("EmitCount")
								v:Emit(emit_count or 1)
							end
						end
					end)
					task.wait(Weapon_Stats.HeavyChargeTime.Value/amount)
				end
			end)
			task.delay(.2+Weapon_Stats.HeavyChargeTime.Value+.2, function()
				FX:Destroy()
			end)
		end
		task.wait(.2)
		Animation:AdjustSpeed(0)
		task.wait(Weapon_Stats.HeavyChargeTime.Value)
		-- checking if stunned
		if AttackCancelled then return end

		Animation:AdjustSpeed(3)
		-- PunchAir
		local PunchAir = nil
		if CurrentWeapon == "Greatsword" then
			PunchAir = Assets.Sounds.SwingAirM2:Clone()
		end
		if CurrentWeapon == "Battleaxe" then
			PunchAir = Assets.Sounds.SwingAirM2:Clone()
		end
		if CurrentWeapon == "Katana" then
			PunchAir = Assets.Sounds.KatanaSwing5:Clone()
		end
		if CurrentWeapon == "SkullSpear" then
			PunchAir = Assets.Sounds.KatanaSwing5:Clone()
		end
		if CurrentWeapon == "Sacred Katana" then
			PunchAir = Assets.Sounds.KatanaSwing5:Clone()
		end
		if CurrentWeapon == "Excalibur" then
			PunchAir = Assets.Sounds.KatanaSwing5:Clone()
		end
		if CurrentWeapon == "Baroque" then
			PunchAir = Assets.Sounds.KatanaSwing5:Clone()
		end
		if CurrentWeapon == "ScarletBlade" then
			PunchAir = Assets.Sounds.KatanaSwing5:Clone()
		end
		if CurrentWeapon == "Dagger" then
			PunchAir = Assets.Sounds.KatanaSwing5:Clone()
		end
		if CurrentWeapon == "Combat" then
			PunchAir = Assets.Sounds.PunchAirM2:Clone()
		end
		if CurrentWeapon == "Caestus" or CurrentWeapon == "Silver Gauntlet" then
			PunchAir = Assets.Sounds.PunchAirM2:Clone()
		end
		PunchAir.Parent = Character.HumanoidRootPart
		PunchAir:Play()
		game.Debris:AddItem(PunchAir, PunchAir.TimeLength)

		--task.wait(.2)
		--FX:Destroy()
		-- Hit Detection

		if CurrentWeapon == "Greatsword" or CurrentWeapon == "Battleaxe" then
			-- freeze player
			--warn("Freeze?")
			local Freeze = Instance.new("Folder")
			Freeze.Name = "Frozen"
			Freeze.Parent = Character.Status
			game.Debris:AddItem(Freeze, .5)
		end

		-- Foresight Mode
		-- Checking for Foresight Mode
		local ForesightModeActive = false
		if StatusFolder:FindFirstChild("Foresight") and StatusFolder:FindFirstChild("Intangibility") and SkillType ~= "Hit" then
			ForesightModeActive = true
		end

		-- Getting Nearest Targets
		if ForesightModeActive then
			local Nearest = {}
			for _,v in pairs(workspace.Live:GetChildren()) do
				if v ~= Character then
					local _Root = v:FindFirstChild("HumanoidRootPart")
					local v_Status = v:FindFirstChild("Status")
					if _Root and v_Status then
						if v_Status:FindFirstChild("Knocked") then
							continue
						end

						local b = _Root.Position
						local a = Character.HumanoidRootPart.Position

						local distance = (b-a).Magnitude

						if distance <= 25 then
							table.insert(Nearest, {["Root"] = _Root, ["Distance"] = distance})
						end
					end
				end
			end
			table.sort(Nearest, function(a,b)
				return (a.Distance > b.Distance)
			end)
			-- Teleport
			local N = Nearest[1]
			if N then
				Character.HumanoidRootPart.Position = (N.Root.CFrame * CFrame.new(0,0,-3)).Position

				local c = Assets.EvadeFX:Clone()
				c.Parent = Character.HumanoidRootPart
				c:Emit(100)
				game.Debris:AddItem(c, 1.5)

				Remotes.ClientFX:FireAllClients("Sound", {
					SoundName = "Evade",
					Parent = Character.HumanoidRootPart
				})

				Remotes.ClientFX:FireAllClients("DamageIndicator",
					{
						DamageAmount = "TELEPORT",
						Victim = Character,
						Color = Color3.fromRGB(255, 255, 255),
						NormalColor = Color3.fromRGB(194, 194, 194)
					}
				)
			end
		end
		--

		local targets = HitboxModule.Cast(
			Character,

			HitboxInfo.fetch(Character, CurrentWeapon, "Heavy", SkillType),
			Weapon_Stats.HeavyAttackDuration.Value,
			false, -- Visualize
			"Multi"

		)

		task.spawn(function()
			--[[
			if CurrentWeapon ~= "Combat" then

				local WeaponMain = Character:FindFirstChild(CurrentWeapon.."_Main")
				if WeaponMain then
					toggleSwordTrail(WeaponMain, true)
					task.delay(Weapon_Stats.DetectionTime.Value, function()
						toggleSwordTrail(WeaponMain, false)
					end)
				end

			end
			]]--
			if CurrentWeapon ~= "Combat" then
				local WeaponMain = Character:FindFirstChild(CurrentWeapon.."_Main")

				if WeaponMain then
					while HeavyAttack.Parent or StatusFolder:FindFirstChild("HeavyAttack") and CurrentWeapon ~= "Combat" do
						toggleSwordTrail(WeaponMain, true)
						task.wait()
					end
					toggleSwordTrail(WeaponMain, false)
				end

					--[[
					local WeaponMain = Character:FindFirstChild(CurrentWeapon.Value.."_Main")
					if WeaponMain then
						toggleSwordTrail(WeaponMain, true)
						task.delay(SwingCooldown.Value+start_lag, function()
							toggleSwordTrail(WeaponMain, false)
						end)
					end
					]]--
			else
				-- is combat
				while HeavyAttack.Parent or StatusFolder:FindFirstChild("HeavyAttack") and CurrentWeapon == "Combat" do
					togglePunchTrail(Character, true)
					task.wait()
				end
				togglePunchTrail(Character, false)
			end
		end)

		if targets then			
			for i = 1,#targets do	
				local target = targets[i]

				if AttackCancelled then return end

				local finalAction
				local DefaultDamage = Weapon_Stats.HeavyDamage.Value

				-- Checking if Blocking/Perfect Blocking
				local target_status = target:FindFirstChild("Status")
				if not target_status then return end

				local target_info = target:FindFirstChild("Handler") and require(target.Handler.Input.Info) or nil
				if not target_info then return end

				if target_status:FindFirstChild("Evade") then
					-- iframes
					Remotes.ClientFX:FireAllClients("DamageIndicator",
						{
							DamageAmount = "EVADED!",
							Victim = Character,
							Color = Color3.fromRGB(107, 255, 251),
							NormalColor = Color3.fromRGB(65, 176, 176)
						}
					)	
					return
				end
				-- intangible
				if target_status:FindFirstChild("Intangibility") then

					if target_status:FindFirstChild("Foresight") then
						local DodgesLeft = target_status.Foresight:FindFirstChild("DodgesLeft")
						if DodgesLeft then
							DodgesLeft.Value = math.clamp(DodgesLeft.Value-1,0,10)
						end

						local c = Assets.EvadeFX:Clone()
						c.Parent = target.HumanoidRootPart
						c:Emit(100)
						game.Debris:AddItem(c, 1.5)

						Remotes.ClientFX:FireAllClients("Sound", {
							SoundName = "Evade",
							Parent = Character.HumanoidRootPart
						})

						Remotes.ClientFX:FireAllClients("DamageIndicator",
							{
								DamageAmount = "DODGED!",
								Victim = Player.Character,
								Color = Color3.fromRGB(255, 255, 255),
								NormalColor = Color3.fromRGB(194, 194, 194)
							}
						)
						return
					end
					-- You can still hit someone while their Ragdolled with magics/m2s.
					if target_status:FindFirstChild("Ragdoll") then
					else
						return -- works?
					end
				end
				-- EVADE --
				if target_status:FindFirstChild("EvadeAttempt") then
					local EvadeObject = target_status.EvadeAttempt

					local _type = Instance.new("StringValue")
					_type.Name = "Success"
					_type.Value = "Normal"
					_type.Parent = EvadeObject

					local _target = Instance.new("ObjectValue")
					_target.Name = "Target"
					_target.Value = Character
					_target.Parent = EvadeObject
					return
				end

				local isBlocking = target_status:FindFirstChild("Blocking")
				local targetD = target:FindFirstChild("Data")
				if isBlocking then

					-- Checking if behind
					local UnitVector = (Character.HumanoidRootPart.Position - target.HumanoidRootPart.Position).Unit
					local VictimLook = target.HumanoidRootPart.CFrame.lookVector
					local DotVector = UnitVector:Dot(VictimLook)

					if DotVector < 0 then
						-- behind
						finalAction = "Heavy"
					else
						if (os.clock() - (target_info.PreviousBlock or 0) < .3) or target_status:FindFirstChild("Simulate_PB") then
							-- perfect block threshold is .3 for now
							-- perfect block
							print("perfect block")
							finalAction = "PerfectBlock"
						else
							-- block break
							local blockAmount = targetD:FindFirstChild("BlockAmount")
							if blockAmount then
								blockAmount.Value = 0
							end

							print("block break")
							finalAction = "BlockBreak"
							--end
						end						
					end
				elseif not IsNPC and otherData2.HoldingSpace and Player.Data.Stats:FindFirstChild("Strength").Value >= 50 then
					finalAction = "Slam"
				else

					-- not blocking
					--
					finalAction = "Heavy"		
				end

				-- Final Stuff
				local FinalHit = false -- heavy thing so not final hit

				-- Scaling with level --

				if finalAction == "Light" or finalAction == "Heavy" or finalAction == "Aerial" or finalAction == "Slam" then
					if StatusFolder:FindFirstChild("King's Divine Form") then	
						if not StatusFolder:FindFirstChild("Burn") then
							local burn = Instance.new("Folder")
							burn.Name = "Burn"

							local pData = Player:FindFirstChild("Data")
							if pData and pData:FindFirstChild("Equipment") then
								if pData.Equipment.Value == "Natsu's Cloak" then
									burn:SetAttribute("NatsuCloak", true)
								end
							end

							burn.Parent = target_status
						end
					end
					if StatusFolder:FindFirstChild("Overdrive") then
						if not StatusFolder:FindFirstChild("Blind") then
							local burn = Instance.new("Folder")
							burn.Name = "Blind"
							burn.Parent = target_status
							game.Debris:AddItem(burn, .8)
						end
					end
					if StatusFolder:FindFirstChild("Thunder God's Final Act") then
						if not StatusFolder:FindFirstChild("Lightning") then
							local burn = Instance.new("Folder")
							burn.Name = "Lightning"
							burn.Parent = target_status
							game.Debris:AddItem(burn, .6)
						end
					end
				end

				if StatusFolder:FindFirstChild("Earth Hands") then
					local _sound = Assets.Sounds.Crumble:Clone()
					_sound.Parent = target.HumanoidRootPart
					_sound:Play()
					game.Debris:AddItem(_sound, _sound.TimeLength)
				end

				if not game.Players:GetPlayerFromCharacter(target) then
					-- Is an NPC
					if StatusFolder then
						local foundDisplay = StatusFolder:FindFirstChild("DisplayTargetHealth")
						if foundDisplay then
							if foundDisplay.Value ~= target then
								-- Set new Target
								foundDisplay.Value = target
							end
						else
							local objectValue = Instance.new("ObjectValue")
							objectValue.Name = "DisplayTargetHealth"
							objectValue.Value = target
							objectValue.Parent = StatusFolder
							game.Debris:AddItem(objectValue, 10)
						end
					end
				end

				-- UPDATING DAMAGE --
				DefaultDamage = Formulas.GetDamage(Player, DefaultDamage, {
					["Type"] = finalAction,
					["SkillType"] = nil
				})			
				if Reactions[finalAction] then
					Reactions[finalAction]:Fire({
						["Player"] = Player,
						["Target"] = target,
						-- Other Variables
						["FinalHit"] = false,
						["DefaultDamage"] = DefaultDamage,
						["IsNPC"] = IsNPC,
						SkillType = (type(OtherData) == "table" and OtherData.SkillType) or nil,
						["Type"] = finalAction,
					})
				end
			end
		end


	end
end

return module