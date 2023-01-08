--[[
	SwingDuration || Handles how long the player will be slowed for. [Attacking]
	SwingCooldown+StartLag || Handles how long the player will actually be attacking for. [LightAttack]
	StartLag || Time before the hit starts detecting.
	SwingCooldownn || How long before you can hit again, after [LightAttack] is destroyed.
]]

local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeaponData = ReplicatedStorage.WeaponData
local Assets = ReplicatedStorage.Assets
local Remotes = ReplicatedStorage.Remotes

local ServerInfo = require(script.Parent.Parent.Input.Info)
local HitboxModule = require(ReplicatedStorage.Modules.Shared.HitboxModule)
local HitboxInfo = require(ReplicatedStorage.Modules.Shared.HitboxModule.Info)
local Formulas = require(ReplicatedStorage.Modules.Shared.Formulas)
local BodyVelocity = require(ReplicatedStorage.Modules.Client.Effects.BodyVelocity)

local ReactionTypes = script.Parent.ReactionTypes
local Reactions = {}

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

for _,m in pairs(ReactionTypes:GetChildren()) do
	if m:IsA("BindableEvent") then
		Reactions[m.Name] = m
	end
end

function module.Activate(Player, OtherData, OtherData2)	
	local skillType = nil
	local IsNPC = false
	if type(OtherData) == "table" then
		if OtherData.SkillType ~= nil then skillType = OtherData.SkillType end
		if OtherData.IsNPC == true then
			IsNPC = true
		end
	end

	local Character = (IsNPC and Player) or Player.Character

	local StatusFolder = Character:FindFirstChild("Status")
	local CharacterFolder = Character:FindFirstChild("Data")
	if not StatusFolder or not CharacterFolder then return end

	local CurrentWeapon = CharacterFolder:FindFirstChild("CurrentWeapon")
	if not CurrentWeapon or CurrentWeapon.Value == "" then return end

	local Weapon_Stats = WeaponData:FindFirstChild(CurrentWeapon.Value) and WeaponData[CurrentWeapon.Value].Stats or nil
	local cw = CurrentWeapon.Value
	
	if Weapon_Stats then
		local Cooldowns = Weapon_Stats.Cooldowns
		local AnimationsFolder = Assets.Animations:FindFirstChild(cw)

		local MaxSwings = Weapon_Stats.MaxSwings.Value
		local SwingCooldown = Cooldowns.Swing.Value
		local ResetTime = Cooldowns.ResetTime.Value
		local ComboCooldown = Cooldowns.Combo.Value

		local TraitsFolder = nil
		if not IsNPC then
			if Player:FindFirstChild("Data") and Player.Data:FindFirstChild("Traits") then
				TraitsFolder = Player.Data.Traits
			end
		end

		if TraitsFolder then
			if TraitsFolder:FindFirstChild("Fast Hands") then
				SwingCooldown = math.clamp(SwingCooldown-.00035,0,math.huge)
				ComboCooldown = math.clamp(ComboCooldown-.00035,0,math.huge)
			end
		end

		if os.clock() - (ServerInfo.PreviousCombo or 0) < ComboCooldown then
			return -- On CD
		end

		-- Reset Combo
		if os.clock() - (ServerInfo.PreviousSwing or 0) > ResetTime then
			ServerInfo.Swings = 0
		end
		if ServerInfo.Swings >= MaxSwings then
			ServerInfo.Swings = 0
			ServerInfo.PreviousCombo = os.clock()
			return
		end

		if os.clock() - (ServerInfo.PreviousSwing or 0) > SwingCooldown then
			--print(Player.Name, os.clock() - (ServerInfo.PreviousSwing or 0))
			--ServerInfo.PreviousSwing = os.clock()

			local AirCombo = {
				Bool = false,
				Type = "Aerial"
			}

			if ServerInfo.Swings == 3 then
				-- check for air combo


				-- RANDOMIZING NPC AIR COMBOS --
				if IsNPC then


					if Character.Name == "Air Combo Dummy" then
						AirCombo.Bool = true
					end

					if Character.Name == "Attack Dummy" then
						local randomized_air_combo = math.random(1,5)
						local ran = math.random(1,5)

						if randomized_air_combo == ran then
							AirCombo.Bool = true
						end						
					end	

				end

				-----------
				-- FOR NORMAL PLAYERS _-

				if not IsNPC and OtherData2.HoldingSpace then
					print("air combo")
					AirCombo.Bool = true

				end

			elseif (ServerInfo.Swings) == 0 then
				if not IsNPC and StatusFolder:FindFirstChild("Jump") ~= nil  then
					local pData = Player:FindFirstChild("Data")
					if pData then
						if pData.Stats.Agility.Value >= 80 then
							print("air combo")
							AirCombo.Bool = false
							skillType = "ForwardKick"
							AirCombo.Type = "Forward Kick"
						end
					end
				end

			end

			if StatusFolder:FindFirstChild("InAir") then 
				AirCombo.Bool = true
				AirCombo.Type = "Slam"
				-- resetting heavy cooldown
				ServerInfo.PreviousHeavy = os.clock()
			end

			ServerInfo.Swings += 1
			--ServerInfo.PreviousSwing = os.clock()

			-- NO JUMP --
			local NoJump = Instance.new("Folder")
			NoJump.Name = "NoJump"
			NoJump.Parent = StatusFolder
			game.Debris:AddItem(NoJump, 1)

			-- Dash Cancelled
			local DashCancelled = Instance.new("Folder")
			DashCancelled.Name = "DashCancelled"
			DashCancelled.Parent = StatusFolder
			game.Debris:AddItem(DashCancelled, .2)

			--	print(ServerInfo.Swings)

			-- Start Lag
			local start_lag = Weapon_Stats.StartLag.Value
			-- OVERWRITTING START LAG VALUES (IF NEEDED) --
			if ServerInfo.Swings == MaxSwings then
				ServerInfo.PreviousHeavy = os.clock() -- hevy
				
				if cw == "Greatsword" then

					start_lag += .4
				end
				if cw == "Battleaxe" then

					start_lag += .4
				end
			end

			--[[
			if AirCombo.Bool then
				if cw == "Katana" then
					-- resetting to 0, bc air combo is delayed w katana
					start_lag = 0
				end
			end
			]]--
			if ServerInfo.Swings == 1 and cw == "Katana" then
				start_lag = .5
			end
			if ServerInfo.Swings == 1 and cw == "SkullSpear" then
				start_lag = .5
			end
			if ServerInfo.Swings == 1 and cw == "Sacred Katana" then
				start_lag = .5
			end
			if ServerInfo.Swings == 1 and cw == "Excalibur" then
				start_lag = .5
			end

			-- Air Combo Stuff for Combat
			if AirCombo.Bool and ServerInfo.Swings == 4 and cw == "Combat" then
				start_lag = .35
			end
			if AirCombo.Bool and ServerInfo.Swings == 5 and cw == "Combat" then
				start_lag = .35
			end
			if AirCombo.Bool and ServerInfo.Swings == 4 and cw == "Caestus" then
				start_lag = .35
			end
			if AirCombo.Bool and ServerInfo.Swings == 5 and cw == "Caestus" then
				start_lag = .35
			end
			if AirCombo.Bool and ServerInfo.Swings == 4 and cw == "Silver Gauntlet" then
				start_lag = .35
			end
			if AirCombo.Bool and ServerInfo.Swings == 5 and cw == "Silver Gauntlet" then
				start_lag = .35
			end


			-- Air Combo Stuff For Katana
			if AirCombo.Bool and ServerInfo.Swings == 4 and cw == "Katana" then
				start_lag = .5
			end
			if AirCombo.Bool and ServerInfo.Swings == 5 and cw == "Katana" then
				start_lag = .5
			end
			if AirCombo.Bool and ServerInfo.Swings == 4 and cw == "SkullSpear" then
				start_lag = .5
			end
			if AirCombo.Bool and ServerInfo.Swings == 5 and cw == "SkullSpear" then
				start_lag = .5
			end
			if AirCombo.Bool and ServerInfo.Swings == 4 and cw == "Sacred Katana" then
				start_lag = .5
			end
			if AirCombo.Bool and ServerInfo.Swings == 5 and cw == "Sacred Katana" then
				start_lag = .5
			end
			if AirCombo.Bool and ServerInfo.Swings == 4 and cw == "Excalibur" then
				start_lag = .5
			end
			if AirCombo.Bool and ServerInfo.Swings == 5 and cw == "Excalibur" then
				start_lag = .5
			end


			--[[
			if ServerInfo.Swings == 1 and cw == "Combat" then
				start_lag = .27
			end
			]]--

			if TraitsFolder then
				if TraitsFolder:FindFirstChild("Fast Hands") then
					start_lag = math.clamp(start_lag-.1,0,math.huge)
				end
			end

			task.delay(SwingCooldown+start_lag, function()
				ServerInfo.PreviousSwing = os.clock()
			end)

			-- Do Animation/Detection
			local Attacking = Instance.new("Folder")
			Attacking.Name = "Attacking" -- for slowness
			Attacking.Parent = StatusFolder
			game.Debris:AddItem(Attacking, Weapon_Stats.SwingDuration.Value)

			local LightAttack = Instance.new("Folder")
			LightAttack.Name = "LightAttack"
			LightAttack.Parent = StatusFolder
			game.Debris:AddItem(LightAttack, SwingCooldown+start_lag)

			-- Pull Forward
			--[[
			local Root = Character.HumanoidRootPart
			local PULL_VELO = 5
			
			BodyVelocity({
				Name = "PullEffect",
				MaxForce = Vector3.new(4e4, 4e4, 4e4),
				Velocity = (Root.CFrame.LookVector) * PULL_VELO,
				Parent = Root,

				Duration = .2
			})
			]]--
			-----------

			local Animation: AnimationTrack
			local SpeedToAdjust = 1

			if TraitsFolder then
				if TraitsFolder:FindFirstChild("Fast Hands") then
					SpeedToAdjust += .02
				end
			end

			if StatusFolder:FindFirstChild("Sliding") then
				if Player and not IsNPC then
					local pData = Player:FindFirstChild("Data")
					if pData then
						if pData.Stats.Defense.Value >= 100 then
							if StatusFolder:FindFirstChild("SlideSkillCooldown") then
								return -- on cooldown
							end
							--
							local previousSlideSkill = Instance.new("Folder")
							previousSlideSkill.Name = "SlideSkillCooldown"
							previousSlideSkill.Parent = StatusFolder
							game.Debris:AddItem(previousSlideSkill, 1) -- 1 = SlideSkillCooldown

							-- Cancel, Yellow Thing
							print("Slide skill?")
							--
							local SlidePerk = Instance.new("Folder")
							SlidePerk.Name = "SlideSkill"
							SlidePerk.Parent = StatusFolder
							game.Debris:AddItem(SlidePerk, .3)
							--
							ReplicatedStorage.Remotes.ClientFX:FireAllClients("SlideSkill", {
								["Parent"] = Character,
								["Duration"] = .3,
							})
							--
							local orientation, size = Character:GetBoundingBox()
							--
							local hb = Instance.new("Part")
							hb.Name = "SlideSkill_Hitbox"
							hb.CanCollide = false
							hb.Massless = true
							hb.Transparency = 1
							hb.Color = Color3.fromRGB(255,0,0)
							hb.Size = size*1.2
							hb.CFrame = orientation
							hb.Parent = workspace.Visuals
							game.Debris:AddItem(hb, .3)
							--
							local weld = Instance.new("Motor6D")
							weld.Part0 = hb
							weld.Part1 = Character.HumanoidRootPart
							weld.Parent = Character
							--
							local _params = OverlapParams.new()
							_params.FilterDescendantsInstances = {workspace.Live}
							_params.FilterType = Enum.RaycastFilterType.Whitelist

							local foundHit = false

							task.spawn(function()
								while SlidePerk.Parent and foundHit == false do
									local found = workspace:GetPartsInPart(hb, _params)
									if found then
										for _,obj in pairs(found) do
											if obj.Parent and obj.Parent == Character then
												continue -- can't do character
											end
											--
											local targetChar = obj.Parent
											local targetStatusFolder = targetChar:FindFirstChild("Status")
											if targetStatusFolder then
												if targetStatusFolder:FindFirstChild("Intangibility") then
													continue -- intanged
												end
												-- normal
												
												local UnitVector = (Character.HumanoidRootPart.Position - targetChar.HumanoidRootPart.Position).Unit
												local VictimLook = targetChar.HumanoidRootPart.CFrame.lookVector
												local DotVector = UnitVector:Dot(VictimLook)
												local finalAction = "Heavy"
												local targetInfo = nil
												if targetChar:FindFirstChild("Handler") then
													targetInfo = require(targetChar.Handler.Input.Info)
												end
												
												if targetStatusFolder:FindFirstChild("Blocking") then
													if DotVector < 0 then
														-- behind
														finalAction = "Heavy"
													else
														if (os.clock() - (targetInfo.PreviousBlock or 0) < .3) or targetStatusFolder:FindFirstChild("Simulate_PB") then
															-- perfect block threshold is .3 for now
															-- perfect block
															print("perfect block")
															finalAction = "PerfectBlock"
														else
															finalAction = "Block"
														end				
													end
												else
													finalAction = "Heavy"
												end
												
												
												local DefaultDamage = Weapon_Stats
												DefaultDamage = Formulas.GetDamage(Player, DefaultDamage, {
													["Type"] = finalAction,
													["SkillType"] = "SlideSkill"
												})
												
												
												
												if Reactions[finalAction] then					
													Reactions[finalAction]:Fire({
														["Player"] = Player,
														["Target"] = targetChar,
														-- Other Variables
														["FinalHit"] = false,
														["DefaultDamage"] = DefaultDamage,
														["IsNPC"] = IsNPC,
														SkillType = "SlideSkill",
														["Type"] = finalAction,
													})
												end
												foundHit = true
												-- resetting
												ServerInfo.Swings = 0
												ServerInfo.PreviousCombo = os.clock()
												--
												break -- break loop
											end
										end
									end
									task.wait(.1)
								end
							end)
						end
					end
				end
			end

			if AnimationsFolder then
				if AirCombo.Bool then

					if AirCombo.Type == "Aerial" then -- for slideSkill
						Animation = Character.Humanoid:LoadAnimation(AnimationsFolder["AirCombo"][cw.."KickUp"])
					elseif AirCombo.Type == "Slam" then
						Animation = Character.Humanoid:LoadAnimation(AnimationsFolder["AirCombo"][cw.."SlamDown"])
					end

				else

					if StatusFolder:FindFirstChild("SlideSkill") then
						Animation = Character.Humanoid:LoadAnimation(AnimationsFolder["AirCombo"][cw.."KickUp"])
					elseif AirCombo.Type == "Forward Kick" then
						Animation = Character.Humanoid:LoadAnimation(AnimationsFolder["AirCombo"][cw.."ForwardKick"])

					else
						Animation = Character.Humanoid:LoadAnimation(AnimationsFolder["M1"][cw.."L"..ServerInfo.Swings])
					end

				end				

				Animation:Play(.015,ServerInfo.Swings)
				if StatusFolder:FindFirstChild("SlideSkill") then
					return -- return
				end
				
				if AirCombo.Type == "Forward Kick" then
					BodyVelocity({
						Name = "Knockback",
						MaxForce = Vector3.new(4e4, 4e4, 4e4),
						Velocity = Character.HumanoidRootPart.CFrame.LookVector * 60,
						Parent = Character.HumanoidRootPart,

						Duration = .2
					})
				end
				--Animation:Play()


				if cw == "Greatsword" or cw == "Battleaxe" then
					SpeedToAdjust = 1
				end
				if cw == "Katana" then
					SpeedToAdjust = .9
				end
				if cw == "SkullSpear" then
					SpeedToAdjust = .9
				end
				if cw == "Sacred Katana" then
					SpeedToAdjust = .9
				end
				if cw == "Excalibur" then
					SpeedToAdjust = .9
				end
				if cw == "Dagger" then
					SpeedToAdjust = 1.3
				end


				--Animation:AdjustWeight(7)
				Animation:AdjustSpeed(SpeedToAdjust)
			end

			local AttackCancelled = false
			local Connection
			Connection = StatusFolder.ChildAdded:Connect(function(Child)
				if Child.Name == "Stunned" or Child.Name == "Stun" then
					AttackCancelled = true
					Connection:Disconnect()
					Connection = nil
					Attacking:Destroy()
					LightAttack:Destroy()
					--if Animation then Animation:Stop(0.1) end -- Stopping Animation
				end
			end)

			-- sword trail
			task.spawn(function()
				if cw ~= "Combat" then
					local WeaponMain = Character:FindFirstChild(cw.."_Main")

					if WeaponMain then
						while LightAttack.Parent or StatusFolder:FindFirstChild("LightAttack") and cw ~= "Combat" do
							toggleSwordTrail(WeaponMain, true)
							task.wait()
						end
						toggleSwordTrail(WeaponMain, false)
					end

					--[[
					local WeaponMain = Character:FindFirstChild(cw.."_Main")
					if WeaponMain then
						toggleSwordTrail(WeaponMain, true)
						task.delay(SwingCooldown+start_lag, function()
							toggleSwordTrail(WeaponMain, false)
						end)
					end
					]]--
				else
					-- is combat
					--[[
					while LightAttack.Parent or StatusFolder:FindFirstChild("LightAttack") and cw == "Combat" do
						togglePunchTrail(Character, true)
						task.wait()
					end
					]]
					--togglePunchTrail(Character, false)
				end
			end)

			--------------------------------------------------			
			task.wait(start_lag) -- startlag is time before iniatigin attack			

			-- PunchAir Sound
			local PunchAir = nil
			if cw == "Greatsword" then
				PunchAir = Assets.Sounds.SwingAir:Clone()
			end
			if cw == "Battleaxe" then
				PunchAir = Assets.Sounds.SwingAir:Clone()
			end
			if cw == "Katana" then
				PunchAir = Assets.Sounds["KatanaSwing"..tostring(ServerInfo.Swings)]:Clone()
			end
			if cw == "SkullSpear" then
				PunchAir = Assets.Sounds["SkullSpearSwing"..tostring(ServerInfo.Swings)]:Clone()
			end
			if cw == "Sacred Katana" then
				PunchAir = Assets.Sounds["Sacred KatanaSwing"..tostring(ServerInfo.Swings)]:Clone()
			end
			if cw == "Excalibur" then
				PunchAir = Assets.Sounds["ExcaliburSwing"..tostring(ServerInfo.Swings)]:Clone()
			end
			if cw == "Baroque" then
				PunchAir = Assets.Sounds["ExcaliburSwing"..tostring(ServerInfo.Swings)]:Clone()
			end
			if cw == "ScarletBlade" then
				PunchAir = Assets.Sounds["KatanaSwing"..tostring(ServerInfo.Swings)]:Clone()
			end
			if cw == "Dagger" then
				PunchAir = Assets.Sounds["DaggerSwing"..tostring(ServerInfo.Swings)]:Clone()
			end
			if cw == "Combat" then
				PunchAir = Assets.Sounds.PunchAir:Clone()
			end
			if cw == "Caestus" or cw == "Silver Gauntlet" then
				PunchAir = Assets.Sounds.PunchAir:Clone()
			end
			if PunchAir ~= nil then
				PunchAir.Parent = Character.HumanoidRootPart
				PunchAir:Play()
				game.Debris:AddItem(PunchAir, PunchAir.TimeLength)
			end

			local DefaultDamage = Weapon_Stats

			-- Edit based on stats

			-- Stuff 
			if cw == "Greatsword" then
				-- freeze player
				--	warn("Freeze?")
				local Freeze = Instance.new("Folder")
				Freeze.Name = "Frozen"
				Freeze.Parent = Character.Status
				game.Debris:AddItem(Freeze, .5)
			end
			--


			-- Get Target
			local Hitbox = {
				whitelist = {Character},
				range = Weapon_Stats.Range.Value,
				origin = Character.HumanoidRootPart.CFrame,
				character = Character,
			}
			local finalAction
			
			--[[
			if cw == "" then
				return -- unequipped
			end
			]]
			
			-- Checking for Foresight Mode
			local ForesightModeActive = false
			if StatusFolder:FindFirstChild("Foresight") and StatusFolder:FindFirstChild("Intangibility") then
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

				HitboxInfo.fetch(Character, cw),
				Weapon_Stats.DetectionTime.Value,
				false, -- Visualize
				"Multi"
			)

			--warn(targets)

			if targets then
				for i = 1, #targets do
					if AttackCancelled then
						break
					end
					local target = targets[i]



					local target_status = target:FindFirstChild("Status")
					if not target_status then continue end

					local target_info = target:FindFirstChild("Handler") and require(target.Handler.Input.Info) or nil
					if not target_info then continue end

					if target_status:FindFirstChild("Intangibility") then

						if target_status:FindFirstChild("Foresight") then
							local DodgesLeft = target_status.Foresight:FindFirstChild("DodgesLeft")
							if DodgesLeft then
								DodgesLeft.Value = math.clamp(DodgesLeft.Value-1,0,10)
							end
							
							local dodgeAnim = math.random(1, 2)
							local a = Assets.Animations.Foresight["Dodge"..tostring(dodgeAnim)]

							a = target.Humanoid:LoadAnimation(a)
							a:Play()

							local c = Assets.EvadeFX:Clone()
							c.Parent = target.HumanoidRootPart
							c:Emit(100)
							game.Debris:AddItem(c, 1.5)

							Remotes.ClientFX:FireAllClients("Sound", {
								SoundName = "Evade",
								Parent = target.HumanoidRootPart
							})

							Remotes.ClientFX:FireAllClients("DamageIndicator",
								{
									DamageAmount = "DODGED!",
									Victim = target,
									Color = Color3.fromRGB(255, 255, 255),
									NormalColor = Color3.fromRGB(194, 194, 194)
								}
							)
						end
						continue
					end

					if not IsNPC then
						-- not an npc
						local targetPlayer = game.Players:GetPlayerFromCharacter(target)
						if targetPlayer then

							local target_player_data = targetPlayer:FindFirstChild("Data")
							if target_player_data then
								local traitsFolder = target_player_data:FindFirstChild("Traits")								
								if traitsFolder then
									if traitsFolder:FindFirstChild("Reaction Demon") then
										local randomizedChance = math.random(1,100)
										if randomizedChance <= 10 then
											-- dodge
											local dodgeAnim = math.random(1, 2)
											local a = Assets.Animations.Foresight["Dodge"..tostring(dodgeAnim)]

											a = target.Humanoid:LoadAnimation(a)
											a:Play()

											local c = Assets.EvadeFX:Clone()
											c.Parent = target.HumanoidRootPart
											c:Emit(100)
											game.Debris:AddItem(c, 1.5)

											Remotes.ClientFX:FireAllClients("Sound", {
												SoundName = "Evade",
												Parent = target.HumanoidRootPart
											})

											Remotes.ClientFX:FireAllClients("DamageIndicator",
												{
													DamageAmount = "REACTION DEMON!",
													Victim = target,
													Color = Color3.fromRGB(94, 62, 255),
													NormalColor = Color3.fromRGB(144, 116, 255)
												}
											)

											local intang = Instance.new("Folder")
											intang.Name = "Intangibility"
											intang.Parent = target_status
											game.Debris:AddItem(intang, .5)

											continue
										end
									end
								end
							end
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
						continue
					end

					--[[
					if PunchAir.Parent then
						if cw == "Combat" then
							game.Debris:AddItem(PunchAir, 0)
						end
						-- dont do for greatsword
					end
					]]--

					local isBlocking = target_status:FindFirstChild("Blocking")
					local targetD = target:FindFirstChild("Data")
					if isBlocking then

						-- Checking if behind
						local UnitVector = (Character.HumanoidRootPart.Position - target.HumanoidRootPart.Position).Unit
						local VictimLook = target.HumanoidRootPart.CFrame.lookVector
						local DotVector = UnitVector:Dot(VictimLook)

						if DotVector < 0 then
							-- behind
							finalAction = 
								(ServerInfo.Swings == MaxSwings and "Heavy") or "Light"
						else
							--		if (os.clock() - (target_info.PreviousBlock or 0) < .3) or target_status:FindFirstChild("Simulate_PB") then
							-- perfect block threshold is .3 for now
							-- perfect block
							--print("perfect block")
							--	finalAction = "PerfectBlock"
							--	else


							local BlockAmount = targetD:FindFirstChild("BlockAmount")
							if math.clamp(BlockAmount.Value-20,0,100) > 0 then
								BlockAmount.Value = math.clamp(BlockAmount.Value-20,0,100)
								print("do normal block")
								finalAction = "Block"
							else
								-- block break
								BlockAmount.Value = 0
								print("block break")
								finalAction = "BlockBreak"
							end
							--end
							--end						
						end
					else
						-- not blocking

						if ServerInfo.Swings == MaxSwings then
							finalAction = "Heavy"
						end
						if ServerInfo.Swings-1 == 3 then
							if AirCombo.Bool then
								finalAction = "Aerial"
							end
						end
						if AirCombo.Bool and AirCombo.Type == "Slam" then
							finalAction = "Slam"
						end

						if skillType == "ForwardKick" then
							finalAction = "Heavy"
						end

						if finalAction == nil then
							-- Default to Light
							finalAction = "Light"
						end



						--	warn(s.Bool, AirCombo.Type)
					end

					-- Final Stuff
					local FinalHit = (ServerInfo.Swings == MaxSwings and true) or false

					-- UPDATING DAMAGE --
					DefaultDamage = Formulas.GetDamage(Player, DefaultDamage, {
						["Type"] = finalAction,
						["SkillType"] = nil
					})

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
						if StatusFolder:FindFirstChild("True Shadow Judgment") then
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

					if target:FindFirstChild("Settings") then
						if target.Settings:FindFirstChild("Team").Value == "Hodra" then
							if ServerInfo.Swings == MaxSwings then
								finalAction = "Heavy"
							else
								finalAction = "Light"
							end
						end
					end
					
					if not game.Players:GetPlayerFromCharacter(target) then
						-- Is an NPC
						if StatusFolder then
							local foundDisplay = StatusFolder:FindFirstChild("DisplayTargetHealth")
							if foundDisplay then
								foundDisplay.Value = target
							else
								local objectValue = Instance.new("ObjectValue")
								objectValue.Name = "DisplayTargetHealth"
								objectValue.Value = target
								objectValue.Parent = StatusFolder
								game.Debris:AddItem(objectValue, 10)
							end
						end
					end
					

					print(AirCombo.Type)
					if Reactions[finalAction] and skillType ~= "ForwardKick" then					
						Reactions[finalAction]:Fire({
							["Player"] = Player,
							["Target"] = target,
							-- Other Variables
							["FinalHit"] = false,
							["DefaultDamage"] = DefaultDamage,
							["IsNPC"] = IsNPC,
							SkillType = skillType,
							["Type"] = finalAction,
							["CurrentWeapon"] = cw,
						})
					else
						Reactions[finalAction]:Fire({
							["Player"] = Player,
							["Target"] = target,
							-- Other Variables
							["FinalHit"] = false,
							["DefaultDamage"] = DefaultDamage,
							["IsNPC"] = IsNPC,
							SkillType = "ForwardKick",
							["Type"] = finalAction,
							["CurrentWeapon"] = cw,
						})
					end
				end
			end
		end
	end
end

return module