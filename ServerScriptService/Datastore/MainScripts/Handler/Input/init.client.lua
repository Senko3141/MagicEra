-- Client

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local ContextActionService = game:GetService("ContextActionService")

local Info = require(script:WaitForChild("Info"))
local Assets = ReplicatedStorage:WaitForChild("Assets")
local Animations = Assets.Animations

local KeyInfo = Info.KeyInfo
local Events = script.Parent:WaitForChild("Events")

local Player = Players.LocalPlayer
repeat task.wait() until Player.Character
local Character = Player.Character
local Humanoid = Character:WaitForChild("Humanoid")

local Camera = workspace.CurrentCamera
local PlayerData = Player:WaitForChild("Data")
local CharacterFolder = Character:WaitForChild("Data")
local StatusFolder = Character:WaitForChild("Status")
local CurrentWeapon = CharacterFolder:WaitForChild("CurrentWeapon")
local Bonuses = CharacterFolder:WaitForChild("Bonuses")
local Formulas = require(ReplicatedStorage:WaitForChild("Modules").Shared.Formulas)
local Settings = require(ReplicatedStorage:WaitForChild("Modules").Client.Settings)
local SoundModule = require(ReplicatedStorage:WaitForChild("Modules").Client.Effects.Sound)
local Emotes = ReplicatedStorage:WaitForChild("Emotes")

-- BlockMeter
local BlockMeter = Character:WaitForChild("HumanoidRootPart"):WaitForChild("BlockMeter")
BlockMeter.Background.Position = UDim2.new(-1,0,0,0)

local BlockAmount = CharacterFolder:WaitForChild("BlockAmount")
BlockAmount.Changed:Connect(function()
	BlockMeter.Background.Frame:TweenSizeAndPosition(UDim2.new(1,0,BlockAmount.Value/100,0), UDim2.new(0,0,1-BlockAmount.Value/100,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
end)
--

local DirectionKeys = {
	["W"] = CFrame.Angles(0,0,0);
	["A"] = CFrame.Angles(0,math.rad(90),0);
	["S"] = CFrame.Angles(0,math.rad(180),0);
	["D"] = CFrame.Angles(0,math.rad(-90),0);}

local shorterdashcd = true

-- Loading Animations
local LoadedAnimations = {}
local function loadAnims(parent)
	local function currentFunction(newParent)
		local returnedData = {}
		for i,v in pairs(newParent:GetChildren()) do
			if v:IsA("Folder") then
				returnedData[v.Name] = currentFunction(v)
			else
				returnedData[v.Name] = Humanoid:LoadAnimation(v)
			end
		end
		return returnedData
	end
	local constructedTable = currentFunction(parent)
	return constructedTable
end
local function GetAnimationFromDirectory(Directory)
	local Anim = nil
	local ToSearch = LoadedAnimations
	Directory = Directory:split("/")
	for i = 1, #Directory do
		Anim = ToSearch[Directory[i]]
		ToSearch = Anim
	end
	return Anim
end
local function GetKeybindFromAction(Action)
	for key,_action in pairs(KeyInfo) do
		if Action == _action then
			return Enum.KeyCode[key]
		end
	end
	return nil
end
function IsShiftLock()
	if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
		return true
	else
		return false
	end
end
-- Fall Damage Functions
local function ResetFallTime()
	local FallingTime = StatusFolder:FindFirstChild("FallingTime")
	if FallingTime then
		local i = Instance.new("BoolValue")
		i.Name = "Reset"
		i.Value = true
		i.Parent = FallingTime
	end
end

LoadedAnimations = loadAnims(Animations)
-- Sprint Functions
local function Sprint(Bool)
	-- Passed All Checks
	if Bool then
		Events.Sprint:FireServer(true)					

		-- Check if Stunned/Attacking/Etc
		while StatusFolder:FindFirstChild("Running") do
			if Info:StunCheck(Character) then
				Sprint(false)
			end		
			task.wait()
		end
	end
	if not Bool then
		if StatusFolder:FindFirstChild("Running") then
			-- Your Running
			Events.Sprint:FireServer(false)
			Info.PreviousSprint = os.clock()
		end
	end
end
local function StopSprintAnimations()
	-- Checking if being Played

	for name,value in pairs(LoadedAnimations["Movement"]) do
		if string.find(name, "Run") then
			if value.IsPlaying then
				value:Stop()
			end
		end
	end

	--[[
	if LoadedAnimations["Movement"].DefaultRun.IsPlaying then
		LoadedAnimations.Movement.DefaultRun:Stop()
	end
	if LoadedAnimations["Movement"].GreatswordRun.IsPlaying then
		LoadedAnimations.Movement.GreatswordRun:Stop()
	end
	if LoadedAnimations["Movement"].BattleaxeRun.IsPlaying then
		LoadedAnimations.Movement.BattleaxeRun:Stop()
	end
	if LoadedAnimations["Movement"].KatanaRun.IsPlaying then
		LoadedAnimations.Movement.KatanaRun:Stop()
	end
	if LoadedAnimations["Movement"].DaggeRRun.IsPlaying then
		LoadedAnimations.Movement.KatanaRun:Stop()
	end
	]]--
end

-- Block Functions
local function Block(Bool)
	-- Passed All Checks
	local blockKeybind = GetKeybindFromAction("Block")
	if Bool then
		-- Stop Sprinting
		Sprint(false)
		--
		Events.Block:FireServer(true)

		-- Check if Stunned/Attacking/Etc
		while StatusFolder:FindFirstChild("Blocking") do
			if Info:StunCheck(Character, "Blocking") then
				Block(false)
				break
			end
			-- checking if stopped holding key
			if not UserInputService:IsKeyDown(blockKeybind) then

				Block(false)
				break
			end
			task.wait()
		end
	end
	if not Bool then
		-- Stop Blocking
		if StatusFolder:FindFirstChild("Blocking") then
			Info.PreviousBlock = os.clock()

			Events.Block:FireServer(false)
		end
	end
end

-- Slide Functions
local function Slide(Bool)
	local SlideKeybind = GetKeybindFromAction("Slide/Crouch")
	if Bool then
		-- slide
		-- passed stun checks, checking if already sliding
		if StatusFolder:FindFirstChild("Sliding") then
			return -- already sliding
		end
		if not StatusFolder:FindFirstChild("Running") then
			return -- should be sprinting to be able to slide
		end
		if Humanoid.FloorMaterial == Enum.Material.Air then
			return
		end

		--	Sprint(false)

		local SlideVelocity = Instance.new("BodyVelocity")
		SlideVelocity.Name = "SlideVelocity"
		SlideVelocity.MaxForce = Vector3.new(99999, 0, 99999)
		SlideVelocity.Parent = Character.HumanoidRootPart

		LoadedAnimations["Slide"]:Play()

		local Connection = nil
		local Elapsed = 0

		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Whitelist
		params.FilterDescendantsInstances = {workspace.Place}

		Connection = RunService.RenderStepped:Connect(function(dt)
			if Elapsed >= Info.SlideDuration or Info:StunCheck(Character, "Slide") or not UserInputService:IsKeyDown(SlideKeybind) or os.clock() - (Info.PreviousJumpRequest or 0) < .1 then
				Connection:Disconnect()
				Connection = nil
				SlideVelocity:Destroy()
				Info.PreviousSlide = os.clock()
				LoadedAnimations["Slide"]:Stop(0.3)

				if os.clock() - (Info.PreviousJumpRequest or 0) < .1 then
					Info.PreviousJump = os.clock()

					local BV = Instance.new("BodyVelocity")
					BV.Name = "BunnyHop"
					BV.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
					BV.Velocity = Character.HumanoidRootPart.CFrame.LookVector * 60 + Vector3.new(0,30,0)
					BV.Parent = Character.HumanoidRootPart

					Debris:AddItem(BV, .2)

					local Animation = Humanoid:LoadAnimation(script.BunnyHop)
					Animation:Play()

					if StatusFolder:FindFirstChild("Sliding") then
						Events.Slide:FireServer(false)
					end
				end

				return
			else
				Elapsed += dt

				local raycastResult = workspace:Raycast(Character.HumanoidRootPart.Position, Vector3.new(0,-20,0), params)
				if raycastResult then
					local spd = math.abs(raycastResult.Normal.X) + math.abs(raycastResult.Normal.Z)
					--warn(spd)
					if spd > 0.25 and Character.HumanoidRootPart.Velocity.Y < .1 then
						--	print("Slope?")
						-- Sliding Config
						local Percentage = Elapsed/Info.SlideDuration
						local Velocity = Info.SlopSlideStartVelocity - (Percentage*Info.SlopSlideStartVelocity)

						SlideVelocity.Velocity = Character.HumanoidRootPart.CFrame.LookVector * Velocity						
					else
						-- Default Config
						local Percentage = Elapsed/Info.SlideDuration
						local Velocity = Info.SlideStartVelocity - (Percentage*Info.SlideStartVelocity)

						SlideVelocity.Velocity = Character.HumanoidRootPart.CFrame.LookVector * Velocity						
					end
				end

			end
		end)

		Events.Slide:FireServer(true)		
	else
		if StatusFolder:FindFirstChild("Sliding") then
			Info.PreviousSlide = os.clock()
			Events.Slide:FireServer(false)
			LoadedAnimations["Slide"]:Stop(0.3)
		end
	end
end

-- Double Jump/Jump Request
local jumpCD = false
UserInputService.JumpRequest:Connect(function()
	if jumpCD == true then return end
	jumpCD = true
	task.delay(5, function()
		jumpCD = false
	end)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	Events.Jump:FireServer()
end)

local ActionFunctions = {
	["Punch"] = function(Input, Processed, Type)
		if Type == "Start" then
			if StatusFolder:FindFirstChild("NoLight") then return end
			if Info:StunCheck(Character, "Attack") then return end -- Stunned
			if CurrentWeapon.Value == "" then return end

			--[[
			--print("Player Request: Punch")
			Sprint(false) -- Stop Sprinting
			Events.Punch:FireServer({HoldingSpace = UserInputService:IsKeyDown(Enum.KeyCode.Space)})
			]]--

			while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
				if not Info:StunCheck(Character, "Attack") and CurrentWeapon.Value ~= "" then
					Sprint(false)
					Events.Punch:FireServer({HoldingSpace = UserInputService:IsKeyDown(Enum.KeyCode.Space)})
				end
				task.wait()
			end

		end
	end,
	["Heavy"] = function(Input, Processed, Type)
		if Type == "Start" then
			if StatusFolder:FindFirstChild("NoHeavy") then return end
			if UserInputService.MouseBehavior == Enum.MouseBehavior.LockCenter then
				if CurrentWeapon.Value == "" then return end
				-- In ShiftLock
				if Info:StunCheck(Character, "Heavy") then return end -- Stunned

				--print("Player Request: Heavy")
				Sprint(false)
				Events.Heavy:FireServer({HoldingSpace = UserInputService:IsKeyDown(Enum.KeyCode.Space)})
			end
		end
	end,
	["Block"] = function(Input, Processed, Type)
		if Type == "Start" then
			if CurrentWeapon.Value == "" then return end
			if Info:StunCheck(Character) then return end

			if os.clock() - (Info.PreviousBlock or 0) < Info.BlockCooldown then
				return
			end

			if UserInputService:IsKeyDown(Enum.KeyCode.F) then
				Block(true)
			end
		end
		--[[
		if Type == "End" then
			Block(false)
		end
		]]
	end,
	["Sprint"] = function(Input, Processed, Type)
		if Type == "Start" and not StatusFolder:FindFirstChild("Running") then
			if StatusFolder:FindFirstChild("NoRun") then return end
			if os.clock() - (Info.PreviousSprint or 0) < Info.SprintCooldown then return end
			if os.clock() - (Info.PreviousW or 0) <= Info.SprintInterval then
				-- Sprint
				if not Info:StunCheck(Character) then
					-- Not Stunned
					Sprint(true)
				end
			else
				Info.PreviousW = os.clock()
			end	
		end
		if Type == "End" then
			Sprint(false)
		end
	end,	
	["Dash"] = function(Input, Processed, Type)
		if Type == "Start" then
			local dashcd = Info.DashCooldown

			if shorterdashcd == false then
				task.spawn(function()
					shorterdashcd = "Changing"
					task.wait(3)
					shorterdashcd = true
				end)
			end

			if PlayerData.Stats.Agility.Value >= 60 then
				if shorterdashcd == true then
					dashcd = .1
					task.spawn(function()
						task.wait(.7)
						shorterdashcd = false
					end)
				end
			end
			if StatusFolder:FindFirstChild("NoDash") then return end
			if Info:StunCheck(Character, "Dashing") then return end -- Stunned

			if StatusFolder:FindFirstChild("Dashing") then
				-- cancel
				Events.Dash:FireServer(false)
				return
			end

			if os.clock() - (Info.PreviousDash or 0) > dashcd then
				Info.PreviousDash = os.clock()

				local keyHeld = nil				
				for keyName,_ in pairs(Info.DashKeys) do
					if UserInputService:IsKeyDown(Enum.KeyCode[keyName]) then
						keyHeld = keyName
						break
					end
				end

				if keyHeld then
					--Sprint(false)

					-- found held key
					if keyHeld == "S" and not IsShiftLock() then
						LoadedAnimations["Movement"]["DashW"]:Play()
					else
						LoadedAnimations["Movement"]["Dash"..keyHeld]:Play()
					end

					local function GetCameraDirection()
						if keyHeld == "S" and not IsShiftLock() then
							return Vector3.new(Camera.CFrame.LookVector.X,0,Camera.CFrame.LookVector.Z)*-10000000
						else
							return Vector3.new(Camera.CFrame.LookVector.X,0,Camera.CFrame.LookVector.Z)*10000000
						end
					end

					local function GetDirection()
						local Direction
						if keyHeld == "W" or keyHeld == "S" then
							local CameraCFramePart = Instance.new("Part")
							CameraCFramePart.CFrame = Camera.CFrame
							CameraCFramePart.Orientation = Vector3.new(0,CameraCFramePart.Orientation.Y,CameraCFramePart.Orientation.Z)
							local CameraCFrame = CameraCFramePart.CFrame
							Direction = (CameraCFrame*DirectionKeys[keyHeld]).LookVector
							CameraCFramePart:Destroy()
						else
							Direction = (Camera.CFrame*DirectionKeys[keyHeld]).LookVector
						end
						return Direction
					end

					local BodyVelocity = Instance.new("BodyVelocity")
					BodyVelocity.Name = "DashVelocity"
					BodyVelocity.MaxForce = Vector3.new(50000, 0, 50000)
					BodyVelocity.Parent = Character.HumanoidRootPart

					local BodyGyro = Instance.new("BodyGyro")
					BodyGyro.Name = "DashGyro"
					BodyGyro.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
					BodyGyro.D = -10
					BodyGyro.Parent = Character.HumanoidRootPart

					local Connection = nil
					local TimePassed = 0



					Connection = RunService.RenderStepped:Connect(function(dt)
						if TimePassed >= Info.DashDuration or Info:StunCheck(Character, "Dashing") or StatusFolder:FindFirstChild("DashCancelled") then
							-- passed
							Connection:Disconnect()
							Connection = nil
							Debris:AddItem(BodyVelocity, 0)
							Debris:AddItem(BodyGyro,0)
						else
							TimePassed += dt

							local CurrentDirection = GetDirection()
							BodyVelocity.Velocity = CurrentDirection*Info.DashForce
							BodyGyro.CFrame = CFrame.new(Character.HumanoidRootPart.Position,GetCameraDirection())

						end
					end)

					Events.Dash:FireServer(true) -- For reduction stuff
				end

				--	print("Player Request: Dash")
			end
		end
	end,
	["Jump"] = function(Input, Processed, Type) -- Jump/Double Jump
		if Type == "Start" then			
			if StatusFolder:FindFirstChild("Stunned") then
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
				return
			end

			if Info:StunCheck(Character, "Jump") then
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
				return
			end -- Stunned

			-- Setting PreviousRequest
			Info.PreviousJumpRequest = os.clock()

			if os.clock() - (Info.PreviousJump or 0) > Info.JumpCooldown then
				-- Can Jump
				if Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
					return
				end
				Info.PreviousJump = os.clock()
				Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				return
			else
				-- On Cooldown
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
			end
			-- Can DoubleJump
			if Info.PreviousJumpRequest - Info.PreviousJump <= Info.DoubleJumpInterval and PlayerData.Stats.Agility.Value > 29 then
				if os.clock() - (Info.PreviousDoubleJump or 0) < Info.DoubleJumpCooldown then return end -- On Cooldown


				local anim = Humanoid:FindFirstChildOfClass("Animator"):LoadAnimation(Animations.Movement.DoubleJump):Play()

				local bvel = Instance.new("BodyVelocity",Character.HumanoidRootPart)
				bvel.MaxForce = Vector3.new(0,100000,0)
				bvel.Velocity = Vector3.new(0,50,0)
				game.Debris:AddItem(bvel, 0.1)
				Info.PreviousDoubleJump = os.clock()

				SoundModule({
					SoundName = "DoubleJump",
					["Parent"] = Character.HumanoidRootPart
				})

				-- Resetting
				ResetFallTime()
				local Connection
				Connection = Humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
					if Humanoid.FloorMaterial ~= Enum.Material.Air then
						Connection:Disconnect()
						Connection = nil
						ResetFallTime()
						print("Touched ground from double jump")
					end
				end)
			end
		end
	end,
	["Evade"] = function(Input, Processed, Type)
		if Type == "Start" then
			--if CurrentWeapon.Value == "" then return end
			Events.Evade:FireServer()
		end
	end,

	["Carry"] = function(Input, Processed, Type)
		if Type == "Start" then
			Events.Carry:FireServer()
		end
	end,
	["Grip"] = function(Input, Processed, Type)
		if Type == "Start" then
			if CurrentWeapon.Value == "" then return end
			Events.Grip:FireServer()
		end
	end,
	["Slide/Crouch"] = function(Input, Processed, Type)
		if Type == "Start" then
			if StatusFolder:FindFirstChild("Running") then
				if Info:StunCheck(Character, "Slide") then
					return -- can't slide
				end
				if os.clock() - (Info.PreviousSlide or 0) < Info.SlideCooldown then
					return -- on cooldown
				end
				Slide(true)
				return
			else
				-- Crouch
				if Info:StunCheck(Character, "Crouch") then
					return -- can't slide
				end
				if os.clock() - (Info.PreviousCrouch or 0) < Info.CrouchCooldown then
					return -- on cooldown
				end			
				if StatusFolder:FindFirstChild("Crouching") then
					Events.Crouch:FireServer(false)
				else
					Events.Crouch:FireServer(true)
				end
				return
			end
		end
		if Type == "End" then
			if StatusFolder:FindFirstChild("Sliding") then
				Slide(false)
			end
		end
	end,
	["ToggleAura"] = function(Input, Processed, Type)
		if Type == "Start" then
			if not PlayerData.ImbuedMagic.Value then
				return
			end

			ReplicatedStorage.Remotes.ManaAura:FireServer()
		end
	end,
}

local function getActionName(Input)
	return KeyInfo[Input.KeyCode.Name] or KeyInfo[Input.UserInputType.Name]
end
local function InputBegan(Input, Processed)
	if Processed then return end

	local ActionName = getActionName(Input)
	if ActionName then
		ActionFunctions[ActionName](Input, Processed, "Start")
	end
end
local function InputEnded(Input, Processed)
	local ActionName = getActionName(Input)
	if ActionName then
		ActionFunctions[ActionName](Input, Processed, "End")
	end
end

UserInputService.InputBegan:Connect(InputBegan)
UserInputService.InputEnded:Connect(InputEnded)

-- Enabling Nested Scripts
for _,v in pairs(script:GetDescendants()) do
	if v:IsA("LocalScript") then
		v.Disabled = false
	end
end

--//Slow Run In Air
Humanoid.StateChanged:Connect(function(oldState, newState)
	if newState == Enum.HumanoidStateType.Jumping then
		if StatusFolder:FindFirstChild("Running") then
			for name,value in pairs(LoadedAnimations["Movement"]) do
				if string.find(name, "Run") then
					if value.IsPlaying then
						value:AdjustSpeed(.3)
					end
				end
			end	
		end
	end
	if newState == Enum.HumanoidStateType.Freefall then
		if StatusFolder:FindFirstChild("Running") then
			for name,value in pairs(LoadedAnimations["Movement"]) do
				if string.find(name, "Run") then
					if value.IsPlaying then
						value:AdjustSpeed(.3)
					end
				end
			end	
		end
	end
	if newState == Enum.HumanoidStateType.Landed then
		if StatusFolder:FindFirstChild("Running") then
			for name,value in pairs(LoadedAnimations["Movement"]) do
				if string.find(name, "Run") then
					if value.IsPlaying then
						value:AdjustSpeed(1)
					end
				end
			end	
		end
	end
end)

-- ChildAdded for BlockMeter
StatusFolder.ChildAdded:Connect(function(Child)
	if Child.Name == "Blocking" then
		BlockMeter.Background:TweenPosition(UDim2.new(0,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
	end
	if Child.Name == "DisplayBlockAmount" then
		BlockMeter.Background:TweenPosition(UDim2.new(0,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
	end
end)
StatusFolder.ChildRemoved:Connect(function(Child)
	if Child.Name == "Blocking" then
		BlockMeter.Background:TweenPosition(UDim2.new(-1,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
	end
	if Child.Name == "DisplayBlockAmount" and not StatusFolder:FindFirstChild("DisplayBlockAmount") then
		BlockMeter.Background:TweenPosition(UDim2.new(-1,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
	end
end)

-- Updater
RunService.Stepped:Connect(function()
	if StatusFolder:FindFirstChild("Dead") then
		return
	end

	local walk_speed, jump_power = Formulas.GetDefaultWalkspeed(Player), 50

	-- Checking if Low
	if (Humanoid.Health/Humanoid.MaxHealth) <= .3 then
		if PlayerData.Traits:FindFirstChild("Runner") then
		else
			walk_speed -= walk_speed*.25
		end
	end

	if StatusFolder:FindFirstChild("Running") then
		walk_speed += walk_speed*.4

		if StatusFolder:FindFirstChild("Carrying") then
			-- slow down
			
			if PlayerData.Traits:FindFirstChild("Savior") then
				walk_speed += walk_speed*.1
			else
				walk_speed -= walk_speed*.2
			end
			
		end

	end
	if StatusFolder:FindFirstChild("Running") then
		-- Do Animation
		local CurrentWeapon = CharacterFolder:FindFirstChild("CurrentWeapon") and CharacterFolder.CurrentWeapon.Value
		if CurrentWeapon == "" then
			CurrentWeapon = "Combat" -- defaulting to combat
		end
		if CurrentWeapon then

			if StatusFolder:FindFirstChild("Sliding") then
				StopSprintAnimations()
			else
				if CurrentWeapon == "Combat" and not LoadedAnimations["Movement"].DefaultRun.IsPlaying then
					StopSprintAnimations()
					LoadedAnimations.Movement.DefaultRun:Play()
				end

				if CurrentWeapon ~= "Combat" then
					if LoadedAnimations["Movement"][CurrentWeapon.."Run"] ~= nil then
						if not LoadedAnimations.Movement[CurrentWeapon.."Run"].IsPlaying then
							StopSprintAnimations()
							LoadedAnimations.Movement[CurrentWeapon.."Run"]:Play()
						end
					end
				end
			end
		end
	else
		StopSprintAnimations()
	end

	--[[
	if StatusFolder:FindFirstChild("Thunder God's Final Act") then
		walk_speed *= 1.5
	end
	if StatusFolder:FindFirstChild("Speed Boost") then
		walk_speed *= 1.15
	end
	if StatusFolder:FindFirstChild("Adrenaline") then
		walk_speed *= 1.4
	end
	]]--
	walk_speed += Bonuses.Agility.Value

	if StatusFolder:FindFirstChild("SlowDown") then
		local SlowDownFolder = StatusFolder:FindFirstChild("SlowDown")
		if SlowDownFolder then
			local Attribute = SlowDownFolder:GetAttribute("SlowPercentage")
			if typeof(Attribute) == "number" then
				walk_speed -= walk_speed*Attribute or .4
			end
		end
	end

	-- Slide Fix?
	if not UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		if StatusFolder:FindFirstChild("Sliding") then
			Slide(false)
		end
	end
	-- Block Fix
	if not UserInputService:IsKeyDown(Enum.KeyCode.F) then
		if StatusFolder:FindFirstChild("Blocking") then
			Block(false)
		end
	end
	if StatusFolder:FindFirstChild("HasLog") then
		walk_speed -= walk_speed*.3
		jump_power = 0
		Sprint(false)
	end
	if StatusFolder:FindFirstChild("Crouching") then
		walk_speed -= walk_speed*.5
		jump_power = 0
		Sprint(false)

		--
		if not LoadedAnimations.Movement.Crouch.IsPlaying then
			LoadedAnimations.Movement["Crouch"]:Play()
		end

		-- Checking if moving
		if Humanoid.MoveDirection.Magnitude > 0 then
			if not LoadedAnimations.Movement.CrouchWalk.IsPlaying then
				LoadedAnimations.Movement.CrouchWalk:Play()
			end
		else
			-- Not moving
			if LoadedAnimations.Movement.CrouchWalk.IsPlaying then
				LoadedAnimations.Movement.CrouchWalk:Stop(.3)
			end
		end
	else
		if LoadedAnimations.Movement.Crouch.IsPlaying then
			LoadedAnimations.Movement["Crouch"]:Stop(0.3)
			warn("Stopped?")

			if LoadedAnimations.Movement.CrouchWalk.IsPlaying then
				LoadedAnimations.Movement.CrouchWalk:Stop(.3)
			end
		end
	end
	if StatusFolder:FindFirstChild("Blocking") then
		walk_speed -= walk_speed*.6
		jump_power = 0
	end
	if StatusFolder:FindFirstChild("Attacking") then
		walk_speed -= walk_speed*.4375
		jump_power = 0
	end
	if StatusFolder:FindFirstChild("HeavyAttack") then
		walk_speed -= walk_speed*.4
		jump_power = 0
	end
	if StatusFolder:FindFirstChild("Stunned") then
		local Attribute = StatusFolder.Stunned:GetAttribute("SlowPercentage")
		if typeof(Attribute) == "number" then
			walk_speed -= walk_speed*Attribute or .4
		else
			walk_speed = 0
		end
		jump_power = 0
	end

	if StatusFolder:FindFirstChild("Action") then
		Sprint(false)
		jump_power = 0
		walk_speed = 0
	end
	if StatusFolder:FindFirstChild("Emoting") then
		Sprint(false)
		jump_power = 0
		walk_speed = 0
		
		-- Playing Animation
		local AlreadyPlaying = false
		for _,v in pairs(Humanoid:GetPlayingAnimationTracks()) do
			if v.Name == "EmoteAnimation" then
				AlreadyPlaying = true
				break
			end
		end
		
		if not AlreadyPlaying then
			local EmoteObject = StatusFolder.Emoting
			if Emotes:FindFirstChild(EmoteObject.Value) then
				local Anim: Animation = Emotes[EmoteObject.Value]
				if Anim.AnimationId ~= "" then
					local c = Anim:Clone()
					c.Name = "EmoteAnimation"
					
					local Loaded = Humanoid:LoadAnimation(c)
					Loaded:Play()
					
					c:Destroy()
				end
			end
		end
		--
		
		if Info:StunCheck(Character, "Default") then
			-- Stop Emoting
			local found_ = StatusFolder:FindFirstChild("Emoting")
			if found_ then
				found_:Destroy()
			end
		end
	else
		for _,v in pairs(Humanoid:GetPlayingAnimationTracks()) do
			if v.Name == "EmoteAnimation" then
				v:Stop(.1)
			end
		end
	end
	if StatusFolder:FindFirstChild("InteractingWaypoint") then
		Sprint(false)
		jump_power = 0
		walk_speed = 0
	end

	if StatusFolder:FindFirstChild("NoSprint") then
		Sprint(false)
	end
	if StatusFolder:FindFirstChild("Burn") then
		if StatusFolder:FindFirstChild("Burn"):GetAttribute("NoDisplay") == nil then
			game.Lighting.Burn.Enabled = true
		end
	else
		game.Lighting.Burn.Enabled = false
	end
	if StatusFolder:FindFirstChild("Lightning") then
		game.Lighting.Lightning.Enabled = true
	else
		game.Lighting.Lightning.Enabled = false
	end
	if StatusFolder:FindFirstChild("Blind") then
		game.Lighting.Blind.Enabled = true
	else
		game.Lighting.Blind.Enabled = false
	end
	if StatusFolder:FindFirstChild("UsingMagic") then
		walk_speed -= walk_speed*.7
		jump_power = 0
		Sprint(false)
	end
	if StatusFolder:FindFirstChild("Frozen") then
		walk_speed = 0
		jump_power = 0
		Sprint(false)
	end
	if StatusFolder:FindFirstChild("NoJump") then
		jump_power = 0
	end
	if StatusFolder:FindFirstChild("DoingTraining") then
		-- frozen
		walk_speed = 0
		jump_power = 0
		Sprint(false)
	end
	if StatusFolder:FindFirstChild("ForesightSlowness") then
		-- finding the amount of children called fs
		local amount = 0
		for _,v in pairs(StatusFolder:GetChildren()) do
			if v.Name == "ForesightSlowness" then
				amount += 1
			end
		end

		walk_speed -= (amount*0.3)
	end
	if StatusFolder:FindFirstChild("IsResetting") then
		walk_speed = 0
		jump_power = 0
		Sprint(false)
	end

	-- Sprinting Fix
	if not UserInputService:IsKeyDown(Enum.KeyCode.W) then
		Sprint(false)
	end
	---

	Humanoid.WalkSpeed = walk_speed
	Humanoid.JumpPower = jump_power

	if Humanoid.WalkSpeed ~= walk_speed then
		--Player:Kick("WalkSpeed Spoofing")
	elseif Humanoid.JumpPower ~= jump_power then
		--Player:Kick("JumpPower Spoofing")
	end

	-- rank tag stuff --
	local rank_tag = Character:FindFirstChild("HumanoidRootPart").RankGui
	if rank_tag then
		if PlayerData.Settings.EnableClientTags.Value then
			-- enable
			if not rank_tag.Enabled then
				rank_tag.Enabled = true
			end
		else
			if rank_tag.Enabled then
				rank_tag.Enabled = false
			end
		end
	end
end)

-- Disabling Tripping States
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)

-- FireClient Events
Events.Animation.OnClientEvent:Connect(function(Action, Data)
	if Action == "PlayAnimation" then		
		local AnimationToPlay = GetAnimationFromDirectory(Data.Directory)
		--print(Data.Directory)
		AnimationToPlay:Play()
	end
	if Action == "StopAnimation" then
		local AnimationToStop = GetAnimationFromDirectory(Data.Directory)
		AnimationToStop:Stop()
	end
	if Action == "Test" then
		local a = GetAnimationFromDirectory(Data.Directory)
		print(a, a.IsPlaying)
	end
end)
