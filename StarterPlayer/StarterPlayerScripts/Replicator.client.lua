-- Replicator --

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local collectionservice = game:GetService("CollectionService")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local LightningModule = require(Modules.Shared.ShinsLightning)

local MagicService = require(Modules.Shared.MagicService)

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Visuals = workspace:WaitForChild("Visuals")
local Camera = workspace.CurrentCamera
local sounds = Assets.Sounds

local Character = nil
local StatusFolder = nil
local StatusFolderConnection = nil

local function TweenValue(Start, Time, End, Object)
	local NumValue = Instance.new('NumberValue')
	NumValue.Value = Start
	TweenService:Create(NumValue, TweenInfo.new(Time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Value = End}):Play()
	game:GetService('Debris'):AddItem(NumValue, Time)

	if Object then
		NumValue.Changed:Connect(function(New)
			Object.Size = NumberSequence.new(New)
		end)
	end

	return NumValue
end

-- Updating Character
if Player.Character then
	Character = Player.Character
end
Player.CharacterAdded:Connect(function()
	Character = Player.Character or Player.CharacterAdded:Wait()

	if StatusFolderConnection then
		StatusFolderConnection:Disconnect()
		StatusFolderConnection = nil
	end

	StatusFolder = Character:WaitForChild("Status")

	local Darken = false
	local GravityPressure = false
	local KingsPillar = false

	StatusFolderConnection = StatusFolder.ChildAdded:Connect(function(Child)
		if Child.Name == "Darken" and not Darken then
			Darken = true
			TweenService:Create(
				game.Lighting.Dark,
				TweenInfo.new(0.4),
				{Brightness = -0.5; Contrast = -1.5; Saturation = 1; TintColor = Color3.fromRGB(108,108,108)}
			):Play()

			wait(0.45)

			repeat wait() until StatusFolder:FindFirstChild("Darken") == nil

			TweenService:Create(
				game.Lighting.Dark,
				TweenInfo.new(0.4),
				{Brightness = 0; Contrast = 0; Saturation = 0; TintColor = Color3.fromRGB(255,255,255)}
			):Play()

			wait(0.4)
			Darken = false
		end
		if Child.Name == "GravityPressure" and not GravityPressure then
			GravityPressure = true
			TweenService:Create(
				game.Lighting.GravityPressure,
				TweenInfo.new(0.4),
				{Brightness = -0.5; Contrast = -1.5; Saturation = 1; TintColor = Color3.fromRGB(255, 255, 255)}
			):Play()

			_G.ShakeCamera({
				["Type"] = "Sustained",
				["Preset"] = "Earthquake",
			})

			wait(0.45)

			repeat wait() until StatusFolder:FindFirstChild("GravityPressure") == nil

			_G.ShakeCamera({
				["Type"] = "StopSustained"
			})

			TweenService:Create(
				game.Lighting.GravityPressure,
				TweenInfo.new(0.4),
				{Brightness = 0; Contrast = 0; Saturation = 0; TintColor = Color3.fromRGB(255,255,255)}
			):Play()

			wait(0.4)
			GravityPressure = false
		end
	--[[
	if Child.Name == "KingsPillar" and not KingsPillar then
		KingsPillar = true
		TweenService:Create(
			game.Lighting.KingsPillar,
			TweenInfo.new(0.4),
			{Brightness = -0.5; Contrast = -1.5; Saturation = 1; TintColor = Color3.fromRGB(255, 108, 34)}
		):Play()

		_G.ShakeCamera({
			["Type"] = "Sustained",
			["Preset"] = "Earthquake",
		})

		wait(0.45)

		repeat wait() until StatusFolder:FindFirstChild("KingsPillar") == nil

		_G.ShakeCamera({
			["Type"] = "StopSustained"
		})

		TweenService:Create(
			game.Lighting.KingsPillar,
			TweenInfo.new(0.4),
			{Brightness = 0; Contrast = 0; Saturation = 0; TintColor = Color3.fromRGB(255,255,255)}
		):Play()

		wait(0.4)
		KingsPillar = false
	end
	]]--
		if Child.Name == "MAGIC_ROTATER" then
			--print("rotate client")

			local Gyro = Instance.new("BodyGyro", Character.HumanoidRootPart)
			Gyro.P = 30000
			Gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
			Gyro.CFrame = CFrame.new(Character.HumanoidRootPart.Position, Mouse.UnitRay.Direction*10000)

			local Stay = Instance.new("BodyPosition", Character.HumanoidRootPart)
			Stay.P = 10000
			Stay.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			Stay.Position = Character.HumanoidRootPart.Position + Vector3.new(0,1,0)

			while Child.Parent do
				Gyro.CFrame = CFrame.new(Character.HumanoidRootPart.Position, Mouse.UnitRay.Direction*10000)
				task.wait()
			end
			Gyro:Destroy()
			Stay:Destroy()
		elseif Child.Name == "MAGIC_ROTATER2" then
			local Gyro = Instance.new("BodyGyro", Character.HumanoidRootPart)
			Gyro.P = 30000
			Gyro.MaxTorque = Vector3.new(0, math.huge, 0)
			Gyro.CFrame = CFrame.new(Character.HumanoidRootPart.Position, Mouse.UnitRay.Direction*10000)

			local Stay = Instance.new("BodyPosition", Character.HumanoidRootPart)
			Stay.P = 10000
			Stay.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			Stay.Position = Character.HumanoidRootPart.Position + Vector3.new(0,1,0)

			while Child.Parent do
				Gyro.CFrame = CFrame.new(Character.HumanoidRootPart.Position, Mouse.UnitRay.Direction*10000)
				task.wait()
			end
			Gyro:Destroy()
			Stay:Destroy()
		elseif Child.Name == "MAGIC_ROTATER3" then
			local Gyro = Instance.new("BodyGyro", Character.HumanoidRootPart)
			Gyro.P = 30000
			Gyro.D = 0
			Gyro.MaxTorque = Vector3.new(0, math.huge, 0)
			Gyro.CFrame = CFrame.new(Character.HumanoidRootPart.Position, Mouse.Hit.Position)


			while Child.Parent do
				Gyro.CFrame = CFrame.new(Character.HumanoidRootPart.Position, Mouse.Hit.Position)
				task.wait()
			end
			Gyro:Destroy()
		end

	end)	

end)
repeat task.wait() until Character ~= nil

StatusFolder = Character:WaitForChild("Status")

-- Functions --
Remotes.MagicFX.OnClientEvent:Connect(function(SpellName, func_name, ...)
	local data = MagicService.fetch(SpellName)
	if data then
		local functions = data.functions
		if functions[func_name] then
			functions[func_name](...)
		end
	end
end)

Remotes.Camera.OnClientEvent:connect(function(effect)
	print("fired the client")
	if effect == "CameraZoomEffect" then
		--workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
		local player = game.Players.LocalPlayer
		local createInfo = function(duration, style, direction)
			local tweenInfo = TweenInfo.new(duration, style, direction)
			return tweenInfo
		end
		local color = Instance.new("ColorCorrectionEffect")
		color.Parent = game.Lighting

		local tween1 = TweenService:Create(workspace.CurrentCamera, createInfo(3, Enum.EasingStyle.Bounce, Enum.EasingDirection.In), {FieldOfView = 5})
		print(workspace.CurrentCamera.FieldOfView)
		local tween2 = TweenService:Create(workspace.CurrentCamera, createInfo(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {FieldOfView = 70})
		local tween3 = TweenService:Create(color, createInfo(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Brightness = 1})
		local tween4 = TweenService:Create (color, createInfo(3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Brightness = 0})
		tween3:Play()
		tween1:Play()
		tween1.Completed:connect(function()
			tween2:Play()
			tween2.Completed:connect(function()
				--workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
			end)
		end)
		tween3.Completed:connect(function()
			tween4:Play()
		end)

	end
end)


Visuals.ChildAdded:Connect(function(Child)
	if (Child:IsA("BasePart") or Child:IsA("MeshPart") or Child:IsA("UnionOperation")) and string.find(Child.Name, "Server") then
		if Character then
			local b = Child.Position
			local a = Character.HumanoidRootPart.Position

			local distance = (b-a).Magnitude
			--print(Child.Name.."'s distance is ".. distance.." studs from the LocalPlayer")
			if distance >= 250 then
				return
			end
		end
	end

	if string.find(Child.Name, "ShadowTravelServer") then
		local Clone = script.ShadowTravel:Clone()

		-- Weld
		local Weld = Instance.new("Motor6D")
		Weld.Part0 = Clone
		Weld.Part1 = Child
		Weld.Parent = Clone

		Clone.Parent = workspace.Visuals

		for _,v in pairs(Clone:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = true
			elseif v:IsA("PointLight") then
				TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Range = v:GetAttribute("Range") or 15
				}):Play()
			end
		end

		-- Play Sound
		Clone.Sound:Play()

		local Connection
		Connection = RunService.RenderStepped:Connect(function(dt)
			if Child.Parent then
			else
				Connection:Disconnect()
				Connection = nil

				for _,v in pairs(Clone:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						v.Enabled = false
					elseif v:IsA("PointLight") then
						TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Range = 0
						}):Play()
					end
				end

				-- Clone Explosion
				local Explode = script.ShadowTravelExplosion:Clone()
				Explode.CFrame = CFrame.new(Clone.Position+Vector3.new(0,1.5,0))
				Explode.Parent = workspace.Visuals
				Explode.Explosion:Play()
				for _,v in pairs(Explode:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						v.Enabled = true
						task.delay(1.5, function()
							v.Enabled = false -- disabling
						end)
					elseif v:IsA("PointLight") then
						TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Range = v:GetAttribute("Range") or 15
						}):Play()
					end
				end

				task.delay(.5, function()
					for _,v in pairs(Explode:GetDescendants()) do
						if v:IsA("ParticleEmitter") then
						elseif v:IsA("PointLight") then
							TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
								Range = 0
							}):Play()
						end
					end
				end)
				--
				Debris:AddItem(Explode, 4)
				Debris:AddItem(Clone, 2)
			end
		end)
	end
	if Child.Name == "StrikeMockServer" then
		local Clone = Assets.Models.FireStrike.Strike:Clone()
		Clone.CFrame = Child.CFrame
		Clone.Parent = workspace.Effects

		for _,v in pairs(Clone:GetDescendants()) do
			if v:IsA("PointLight") then
				TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Range = v:GetAttribute("Range") or 15
				}):Play()
			end
		end

		for _,v in pairs(Clone:GetDescendants()) do
			if v:IsA("Beam") then
				local prev0 = v.Width0
				local prev1 = v.Width1

				TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Width0 = 0,
					Width1 = 0
				}):Play()

				task.delay(.2, function()
					TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Width0 = prev0,
						Width1 = prev1
					}):Play()
				end)
			end
		end

		local Connection
		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then

			else
				Connection:Disconnect()
				Connection = nil

				for _,v in pairs(Clone:GetDescendants()) do
					if v:IsA("PointLight") then
						TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Range = 0
						}):Play()
					end
				end

				for _,v in pairs(Clone:GetDescendants()) do
					if v:IsA("Beam") then
						TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Width0 = 0,
							Width1 = 0
						}):Play()
					elseif v:IsA("ParticleEmitter") then
						v.Enabled = false
					end
				end


				task.delay(4, function()
					Clone:Destroy()
				end)

			end
		end)
	end
	if Child.Name == "PreStrikeMockServer" then
		local Clone = Assets.Models.FireStrike.Mesh:Clone()
		Clone:SetPrimaryPartCFrame(Child.CFrame)
		Clone.Parent = workspace.Effects

		for _,v in pairs(Clone:GetDescendants()) do
			-- make bigger, then shrink down
			if v:IsA("BasePart") then
				TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Size = v.Size*1.5
				}):Play()
			end
		end

		task.delay(.5, function()
			for _,v in pairs(Clone:GetDescendants()) do
				-- make bigger, then shrink down
				if v:IsA("BasePart") and v.Name == "GoAway" then
					TweenService:Create(v, TweenInfo.new(.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
						Transparency = 1,
						Size = Vector3.new(v.Size.X*1.5,0,v.Size.Z*1.5)
					}):Play()

					task.delay(2, function()
						v:Destroy()
					end)
				end
			end
		end)

		local OgSize = Vector3.new(30.984, 30.984, 0.867)

		local PreviousGrow = os.clock()
		local GrowInterval = .2
		local Big = false

		local Connection
		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				Clone:SetPrimaryPartCFrame(Clone:GetPrimaryPartCFrame() * CFrame.Angles(0,math.rad(15),0))		


				if os.clock() - (PreviousGrow) >= GrowInterval then
					PreviousGrow = os.clock()

					Big = not Big

					if Big then
						TweenService:Create(Clone.Thingy, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Size = Vector3.new(OgSize.X*1.2, OgSize.Y, OgSize.Z*1.2)
						}):Play()
					else
						TweenService:Create(Clone.Thingy, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Size = OgSize
						}):Play()						
					end

				end

			else
				Connection:Disconnect()
				Connection = nil

				for _,v in pairs(Clone:GetDescendants()) do
					-- make bigger, then shrink down
					if v:IsA("BasePart") then
						TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Size = v.Size*2,
							Transparency = 1
						}):Play()
					end
				end

				task.delay(2, function()
					Clone:Destroy()
				end)
			end
		end)
	end

	if Child.Name == "HealingZoneServer" then
		local Clone = Assets.Healing:Clone()

		Clone.Parent = workspace.Visuals
		Clone:SetPrimaryPartCFrame(Child.CFrame)

		for _,v in pairs(Clone:GetDescendants()) do
			if v:IsA("PointLight") then
				TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Range = v:GetAttribute("Range") or 18
				}):Play()
			end
		end

		for _,v in pairs(Clone:GetDescendants()) do
			if v:IsA("ParticleEmitter") and v:GetAttribute("EmitMain") == 1 then
				warn("test?")
				v:Emit(1)
			end
		end



		local Connection

		local PreviousEmit = os.clock()
		local EmitInterval = .5

		Connection = RunService.RenderStepped:Connect(function(dt)
			if Child.Parent then
				Clone.Sign.CFrame = Clone.Sign.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(2),0,0)

				for _,forcefield in pairs(Clone.ForceFields:GetChildren()) do
					forcefield.CFrame = forcefield.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(1),math.rad(-1),math.rad(1))
				end

				if os.clock() - (PreviousEmit) >= EmitInterval then
					PreviousEmit = os.clock()
					Clone.Aura.Attachment.Shockwave:Emit(1)
				end
			else
				for _,v in pairs(Clone:GetDescendants()) do
					if v:IsA("PointLight") then
						TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Range = 1
						}):Play()
					elseif v:IsA("ParticleEmitter") then
						v.Enabled = false
					elseif v:IsA("Beam") then
						v.Enabled = false
					elseif v:IsA("Texture") then
						TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Transparency = 1
						}):Play()
					elseif v:IsA("ImageLabel") then
						TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							ImageTransparency = 1
						}):Play()
					elseif v:IsA("BasePart") and v.Transparency ~= 1 then
						TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Transparency = 1
						}):Play()
					end
				end

				task.delay(4, function()
					Clone:Destroy()
				end)
			end
		end)
	end
	if Child.Name == "JiuServer1" or Child.Name == "JiuServer2" or  Child.Name == "JiuServer3" or  Child.Name == "JiuServer4" or  Child.Name == "JiuServer5" or  Child.Name == "JiuServer6" or  Child.Name == "JiuServer7" then
		local Sword = Assets.Sword:Clone()
		Sword.Parent = workspace.Visuals
		Sword.CFrame = Child.CFrame

		TweenService:Create(Sword, TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Transparency = 0}):Play()

		for _,v in pairs(Sword:GetDescendants()) do
			if v:IsA("ParticleEmitter") and v.Name ~= "Explosion" then
				v.Enabled = true
			elseif v:IsA("PointLight") or v:IsA("SpotLight") then
				TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Range = v:GetAttribute("Range") or 10
				}):Play()
			end
		end

		local Connection
		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(Sword, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame}):Play()
			else
				task.delay(.1, function()
					Sword:Destroy()
				end)

				for _,v in pairs(Sword:GetDescendants()) do
					if v:IsA("ParticleEmitter") and v.Name ~= "Explosion" then
						v.Enabled = false
					elseif v:IsA("PointLight") then
						TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Range = 0
						}):Play()
					elseif v:IsA("SpotLight") then
						TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Range = 0
						}):Play()
					elseif v:IsA("ParticleEmitter") and v.Name == "Explosion" then
						v:Emit(75)
					end
				end

				Connection:Disconnect()
				return
			end
		end)
	end
	if Child.Name == "AltairisServer" then
		local Connection

		local Altairis = Assets.Altairis:Clone()
		Altairis.CFrame = Child.CFrame
		Altairis.Parent = workspace.Visuals

		for _,v in pairs(Altairis:GetDescendants()) do
			if v:IsA("ParticleEmitter") and v.Name == "Attach1" then
				v.Enabled = true
			end
		end

		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(Altairis, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame}):Play()
			else
				task.delay(10, function()
					Altairis:Destroy()
				end)
				for _,v in pairs(Altairis:GetDescendants()) do
					if v:IsA("ParticleEmitter") and v.Name == "Attach1" then
						v.Enabled = false
					elseif v:IsA("PointLight") then
						TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Range = 0
						}):Play()
					elseif v:IsA("SpotLight") then
						TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Range = 0
						}):Play()
					elseif v:IsA("ParticleEmitter") and v.Name == "Attach2" then
						v:Emit(75)
						print(v.Name)
					end
				end
				Connection:Disconnect()
				return
			end

		end)
	end
	if Child.Name == "MagicCircleServer" then
		repeat task.wait() until Child:GetAttribute("MagicType")

		local Connection

		local Fireball = Assets.MagicCircles[Child:GetAttribute("MagicType")]
		for _,v in pairs(Fireball:GetChildren()) do
			if v:IsA("Decal") then
				local clone = v:Clone()
				clone.Parent = Child
			end
		end
	end
	if Child.Name == "PoisonSpitServer" then
		local Connection

		local Fireball = Assets["Poision Spit"]:Clone()
		Fireball.CFrame = Child.CFrame
		Fireball.Parent = workspace.Visuals

		task.spawn(function()
			for _,v in pairs(Fireball:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v:Emit(100)
				end
			end	
		end)

		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(Fireball, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame}):Play()
			else
				Fireball:Destroy()
				Connection:Disconnect()
				return
			end
		end)
	end
	if Child.Name == "CloneEffect" then
		local Clone = Assets.CloneEffect:Clone()
		Clone.Parent = Child
		local w = Instance.new("Motor6D")
		w.Part0 = Clone
		w.Part1 = Child
		w.Parent = Child

		Clone.Blur:Emit(50)
		Clone.Attachment.Fire:Emit(20)
	end
	if Child.Name == "SpeedBoostServer" then
		local fx = Assets.SpeedFX:Clone()
		fx.Parent = Child
		fx:Emit(50)
		task.wait(14)
		fx.Enabled = false
	end
	if Child.Name == "SelfHealingServer" then
		local clone = Assets.SelfHeal:Clone()
		local weld = Instance.new("Motor6D")
		weld.Part0 = clone
		weld.Part1 = Child
		weld.Parent = Child

		clone.Parent = Child

		for _,v in pairs(clone:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(20)
			end
		end
	end
	if Child.Name == "HealServer" then
		local clone = Assets.SelfHeal:Clone()
		local weld = Instance.new("Motor6D")
		weld.Part0 = clone
		weld.Part1 = Child
		weld.Parent = Child

		clone.Parent = Child

		for _,v in pairs(clone:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(20)
			end
		end

		task.wait(.5)
		for _,v in pairs(clone:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = false
			end
		end
	end
	if Child.Name == "AdrenalineServer" then
		local fx = Assets.SpeedFX:Clone()
		fx.Parent = Child
		fx:Emit(50)

		task.wait(19)
		fx.Enabled = false
	end
	if Child.Name == "WindSlashServer" then
		local Connection

		local Fireball = Assets.WindSlash:Clone()
		Fireball.CFrame = Child.CFrame
		Fireball.Parent = workspace.Visuals

		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(Fireball, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame}):Play()
			else
				Fireball:Destroy()
				Connection:Disconnect()
				return
			end
		end)
	end
	if Child.Name == "PoisonEruptionServer" then
		local Connection

		local Fireball = script.PoisonEruption:Clone()
		Fireball.CFrame = Child.CFrame * CFrame.new(0,5,0)
		Fireball.Parent = workspace.Visuals

		for _,v in pairs(Fireball:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(40)
			end
		end

		task.delay(3, function()
			for _,v in pairs(Fireball:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = false
				end
			end
			task.delay(2, function()
				Fireball:Destroy()
			end)
		end)
	end
	if Child.Name == "WaxingWingServer" then
		local Connection

		local Fireball = script.WaxingWing:Clone()
		Fireball.CFrame = Child.CFrame * CFrame.new(0,5,0)
		Fireball.Parent = workspace.Visuals

		for _,v in pairs(Fireball:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(40)
			end
		end

		task.delay(1, function()
			for _,v in pairs(Fireball:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = false
				end
			end
			task.delay(1, function()
				Fireball:Destroy()
			end)
		end)
	end
	if Child.Name == "KingsPillarServer" then
		local Connection

		local Fireball = script.FirePillar:Clone()
		Fireball.CFrame = Child.CFrame * CFrame.new(0,0,0)
		Fireball.Parent = workspace.Visuals

		for _,v in pairs(Fireball:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(80)
			end
		end

		task.delay(3, function()
			for _,v in pairs(Fireball:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = false
				end
			end
			task.delay(2, function()
				Fireball:Destroy()
			end)
		end)
	end
	if Child.Name == "GravityPressureServer" then
		local Connection

		local Fireball = script.GravityPressure:Clone()
		Fireball.CFrame = Child.CFrame * CFrame.new(0,.6,0)
		Fireball.Parent = workspace.Visuals

		for _,v in pairs(Fireball:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(60)
			end
		end

		task.delay(3, function()
			for _,v in pairs(Fireball:GetDescendants()) do
				if v:IsA("ParticleEmitter") or v:IsA("Beam") or v:IsA("Trail") then
					v.Enabled = false
				end
			end

			task.delay(2, function()
				Fireball:Destroy()
			end)
		end)
	end
	if Child.Name == "ConquerSpellServer" then
		local Connection

		local Clone = script.Conquer:Clone()

		local weld = Instance.new("Motor6D")
		weld.Part0 = Clone
		weld.Part1 = Child
		weld.Parent = Clone

		Clone.Parent = workspace.Visuals

		for _,v in pairs(Clone:GetDescendants()) do
			if v:IsA("PointLight") then
				TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Range = v:GetAttribute("Range") or 21
				}):Play()
			end
		end

		Connection = RunService.RenderStepped:Connect(function()
			if not Child.Parent then
				Connection:Disconnect()
				Connection = nil

				--

				weld:Destroy()
				Clone.Anchored = true
				for _,v in pairs(Clone:GetDescendants()) do
					if v:IsA("PointLight") then
						TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Range = 0
						}):Play()
					elseif v:IsA("ParticleEmitter") then
						v:Emit(20)
						v.Enabled = false
					end
				end
				task.delay(4, function()
					Clone:Destroy()
				end)
			end
		end)
	end
	if Child.Name == "SoumetsuSkillServer" then
		local Connection

		local Ayaka = script.Ayaka:Clone()
		Ayaka.CFrame = Child.CFrame
		Ayaka.Parent = workspace.Visuals

		Connection = RunService.Heartbeat:Connect(function()
			if Child.Parent then
				TweenService:Create(Ayaka, TweenInfo.new(0.005, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {CFrame = Child.CFrame}):Play()
			else
				Connection:Disconnect()

				local Val = TweenValue(3, 0.135, 15)
				TweenService:Create(Ayaka.AttachmentMain.PointLight, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Range = 35}):Play()

				for _,v in pairs(Ayaka:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						v.Enabled = false
						v:Emit(v:GetAttribute("EmitCount") or 5)
					end
				end

				Val.Changed:Connect(function(New)
					for _,v in pairs(Ayaka:GetDescendants()) do
						if v:IsA("ParticleEmitter") and v:GetAttribute("ChangeSize") == true then
							v.Size = NumberSequence.new({v.Size.Keypoints[1], NumberSequenceKeypoint.new(1, New)})
							v.Size = NumberSequence.new({v.Size.Keypoints[1], NumberSequenceKeypoint.new(1, (New * 2))})	
						end
					end
				end)

				task.wait(0.35)
				TweenService:Create(Ayaka.AttachmentMain.PointLight, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Brightness = 0}):Play()
				game:GetService('Debris'):AddItem(Ayaka, 2)
				return
			end
		end)
	end
	if Child.Name == "MagicBulletStartServer" then
		local Connection

		local Fireball = script.MagicBulletStart:Clone()
		Fireball.CFrame = Child.CFrame
		Fireball.Parent = workspace.Visuals

		Fireball.Ground.fx:Emit(20)
		task.wait(.5)
		Fireball.Ground.fx.Enabled = false
	end
	if Child.Name == "WindBallServer" then
		local Connection

		local Fireball = Assets.WindBall:Clone()
		Fireball.CFrame = Child.CFrame
		Fireball.Parent = workspace.Visuals

		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(Fireball, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame}):Play()
			else
				Fireball:Destroy()
				Connection:Disconnect()
				return
			end
		end)
	end
	if Child.Name == "PiercingShotServer" then
		local Connection

		local Fireball = script.PiercingShot:Clone()
		Fireball.CFrame = Child.CFrame
		Fireball.Parent = workspace.Visuals

		for _,v in pairs(Fireball:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(math.random(15,30))				
			end
		end

		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(Fireball, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame}):Play()
			else

				for _,v in pairs(Fireball:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						v.Enabled = false
					elseif v:IsA("Beam") then
						v.Enabled = false
					end
				end

				task.delay(2, function()
					Fireball:Destroy()
				end)

				Connection:Disconnect()
				return
			end
		end)
	end
	if Child.Name == "GrimoireRayServer" then
		local Connection

		local Fireball = Assets.GrimoireRay:Clone()
		Fireball.CFrame = Child.CFrame
		Fireball.Parent = workspace.Visuals

		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(Fireball, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame}):Play()
			else
				Fireball:Destroy()
				Connection:Disconnect()
				return
			end
		end)
	end
	if Child.Name == "WindTornadoServer" then
		local Connection

		local Fireball = Assets.WindTornado:Clone()
		Fireball.CFrame = Child.CFrame
		Fireball.Parent = workspace.Visuals

		for _,v in pairs(Fireball:GetDescendants()) do
			if v:IsA("PointLight") then
				TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Range = tonumber(v:GetAttribute("Range")) or 15
				}):Play()
			end
		end

		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(Fireball, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame}):Play()
			else
				for _,v in pairs(Fireball:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						v.Enabled = false
					elseif v:IsA("Beam") then
						v.Enabled = false
					elseif v:IsA("PointLight") then
						for _,v in pairs(Fireball:GetDescendants()) do
							if v:IsA("PointLight") then
								TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
									Range = 0
								}):Play()
							end
						end
					end
				end
				task.delay(5, function()
					Fireball:Destroy()
				end)

				Connection:Disconnect()
				return
			end
		end)
	end
	if Child.Name == "WindTornadoSkillServer" then
		local Connection

		local Fireball = Assets.WindTornado:Clone()
		Fireball.CFrame = Child.CFrame
		Fireball.Parent = workspace.Visuals

		for _,v in pairs(Fireball:GetDescendants()) do
			if v:IsA("PointLight") then
				TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Range = tonumber(v:GetAttribute("Range")) or 15
				}):Play()
			end
		end

		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(Fireball, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame}):Play()
			else
				for _,v in pairs(Fireball:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						v.Enabled = false
					elseif v:IsA("Beam") then
						v.Enabled = false
					elseif v:IsA("PointLight") then
						for _,v in pairs(Fireball:GetDescendants()) do
							if v:IsA("PointLight") then
								TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
									Range = 0
								}):Play()
							end
						end
					end
				end
				task.delay(5, function()
					Fireball:Destroy()
				end)

				Connection:Disconnect()
				return
			end
		end)
	end
	if Child.Name == "WaterSharkServer" then
		local Connection

		local Fireball = Assets.WaterShark:Clone()
		Fireball.CFrame = Child.CFrame
		Fireball.Parent = workspace.Visuals

		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(Fireball, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame}):Play()
			else
				Fireball:Destroy()
				Connection:Disconnect()
				return
			end
		end)
	end
	if Child.Name == "WaterDragonServer" then
		local Connection

		local Fireball = Assets.WaterDragon:Clone()
		Fireball.CFrame = Child.CFrame
		Fireball.Parent = workspace.Visuals

		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(Fireball, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame}):Play()
			else
				Fireball:Destroy()
				Connection:Disconnect()
				return
			end
		end)
	end
	if Child.Name == "EarthDragonServer" then
		local Connection

		local Fireball = Assets.EarthDragon:Clone()
		Fireball.CFrame = Child.CFrame
		Fireball.Parent = workspace.Visuals

		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(Fireball, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame}):Play()
			else
				Fireball:Destroy()
				Connection:Disconnect()
				return
			end
		end)
	end
	if Child.Name == "SemaServer" then
		local Connection

		local sema = Assets.Sema:Clone()
		sema.CFrame = Child.CFrame
		sema.Parent = workspace.Visuals
		task.delay(10, function()
			sema:FindFirstChild("LightningAttach"):Destroy()
		end)

		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(sema, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame}):Play()
			else

				task.delay(30, function()
					sema:Destroy()
				end)
				for _,v in pairs(sema:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						v.Enabled = false
					elseif v:IsA("PointLight") then
						TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Range = 0
						}):Play()
					elseif v:IsA("SpotLight") then
						TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Range = 0
						}):Play()
					elseif v:IsA("ParticleEmitter") and v.Name == "Attach2" then
						v:Emit(75)
						print(v.Name)
					end
				end
				Connection:Disconnect()
				return
			end

		end)
	end
	if Child.Name == "WaterBulletServer" then
		local Connection

		local Fireball = Assets.WaterBall:Clone()
		Fireball.CFrame = Child.CFrame
		Fireball.Parent = workspace.Visuals

		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(Fireball, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame}):Play()
			else
				Fireball:Destroy()
				Connection:Disconnect()
				return
			end
		end)
	end
	if Child.Name == "FireballServer" then
		local Connection

		local Fireball = Assets.Fireball:Clone()
		Fireball.CFrame = Child.CFrame
		Fireball.Parent = workspace.Visuals

		for _,v in pairs(Fireball:GetDescendants()) do
			if v:IsA("PointLight") then
				TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Range = v:GetAttribute("Range") or 50
				}):Play()
			elseif v:IsA("SpotLight") then
				TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Range = v:GetAttribute("Range") or 50
				}):Play()
			end
		end

		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(Fireball, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame}):Play()
			else
				Connection:Disconnect()

				for _,v in pairs(Fireball:GetDescendants()) do
					if v:IsA("PointLight") then
						TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Range = 0
						}):Play()
					elseif v:IsA("SpotLight") then
						TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Range = 0
						}):Play()
					elseif v:IsA("ParticleEmitter") then
						v.Enabled = false
					end
				end

				task.delay(1, function()
					Fireball:Destroy()
				end)
				return
			end
		end)
	end
	if Child.Name == "MagicBulletsServer" then
		local Connection

		local MagicBullet = Assets.MagicBullet:Clone()
		MagicBullet.CFrame = Child.CFrame
		MagicBullet.Parent = workspace.Visuals

		for _,v in pairs(MagicBullet:GetDescendants()) do
			if v:IsA("PointLight") then
				TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Range = v:GetAttribute("Range") or 50
				}):Play()
			elseif v:IsA("SpotLight") then
				TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Range = v:GetAttribute("Range") or 50
				}):Play()
			end
		end

		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(MagicBullet, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame}):Play()
			else
				Connection:Disconnect()

				for _,v in pairs(MagicBullet:GetDescendants()) do
					if v:IsA("PointLight") then
						TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Range = 0
						}):Play()
					elseif v:IsA("SpotLight") then
						TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Range = 0
						}):Play()
					elseif v:IsA("ParticleEmitter") then
						v.Enabled = false
					end
				end

				task.delay(1, function()
					MagicBullet:Destroy()
				end)
				return
			end
		end)
	end
	if Child.Name == "DarkBeamServer" then
		local Connection

		local Fireball = Assets.DarkBeam:Clone()
		Fireball.CFrame = Child.CFrame
		Fireball.Parent = workspace.Visuals

		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(Fireball, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame}):Play()
			else
				Fireball:Destroy()
				Connection:Disconnect()
				return
			end
		end)
	end
	if Child.Name == "DarkSpearServer" then
		local Connection

		local Fireball = Assets.ShadowSpear:Clone()
		Fireball.CFrame = Child.CFrame
		Fireball.Parent = workspace.Visuals


		for _,v in pairs(Fireball:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(50)
			end
		end

		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(Fireball, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame}):Play()
			else
				Fireball:Destroy()
				Connection:Disconnect()
				return
			end
		end)
	end
	if Child.Name == "KingShotServer" then
		local Connection

		local Fireball = Assets.KingsShot:Clone()
		Fireball.CFrame = Child.CFrame
		Fireball.Parent = workspace.Visuals

		task.spawn(function()
			for _,v in pairs(Fireball:GetDescendants()) do
				if v:IsA("ParticleEmitter") then
					v:Emit(50)
				end
			end	
		end)

		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(Fireball, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame}):Play()
			else
				Fireball:Destroy()
				Connection:Disconnect()
				return
			end
		end)
	end
	if Child.Name == "ThunderClawServer" then
		local Connection

		local Fireball = Assets.ThunderClaw:Clone()
		Fireball.CFrame = Child.CFrame
		Fireball.Parent = workspace.Visuals

		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(Fireball, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame}):Play()
			else
				Fireball:Destroy()
				Connection:Disconnect()
				return
			end
		end)
	end
	if Child.Name == "ThunderTransformationServer" then
		local c = Assets.ThunderTransformation:Clone()

		local weld = Instance.new("Weld")
		weld.Name = "Weld2"
		weld.Part0 = c
		weld.Part1 = Child

		weld.C0 = CFrame.new(0,1,0)

		weld.Parent = c
		c.Parent = workspace.Visuals

		local Connection
		Connection = RunService.RenderStepped:Connect(function()
			if not Child.Parent then
				Connection:Disconnect() Connection = nil

				for _,v in pairs(c:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						v.Enabled = false
					elseif v:IsA("Beam") then
						TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Width0 = 0,
							Width1 = 0
						}):Play()
					elseif v:IsA("PointLight") then
						TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Range = 0
						}):Play()
					end
				end
				Debris:AddItem(c, 4)

			end
		end)

	end
	if Child.Name == "KingTransformationServer" then
		local c = Assets.KingTransformation:Clone()

		local foundWeld = Child:WaitForChild("Weld")

		local weld = Instance.new("Weld")
		weld.Name = "Weld2"
		weld.Part0 = c
		weld.Part1 = Child

		weld.C0 = CFrame.new(0,1,0)

		weld.Parent = Child
		c.Parent = Child

		local fxs = {}

		for _,v1 in pairs(foundWeld.Part1.Parent:GetChildren()) do
			if v1.Name == "Left Arm" or v1.Name == "Right Arm" or v1.Name == "Left Leg" or v1.Name == "Right Leg" or v1.Name == "Torso" or v1.Name == "Head" then
				for _,v in pairs(Assets.KingTransformation2:GetChildren()) do
					if v:IsA("ParticleEmitter") then
						local clone = v:Clone()
						clone.Parent = v1
						table.insert(fxs, clone)
					end
				end	
			end
		end

		local Connection
		Connection = RunService.RenderStepped:Connect(function()
			if not Child.Parent then
				Connection:Disconnect()
				Connection = nil

				for i = 1,#fxs do
					local fx = fxs[i]
					fx.Enabled = false
					game.Debris:AddItem(fx, 2)
				end
			end
		end)

	end
	if Child.Name == "PoisonSkinServer" then
		repeat task.wait() until Child:FindFirstChild("Owner")

		local Owner = Child.Owner
		if Owner.Value then
			for _,v in pairs(Owner.Value:GetChildren()) do
				if v:IsA("BasePart") then
					if v.Name == "Left Arm" or v.Name == "Right Arm" or v.Name == "Head" or v.Name == "Left Leg" or v.Name == "Right Leg" or v.Name == "Torso" or v.Name == "HumanoidRootPart" then
						for _,v2 in pairs(Assets.PoisonSkin:GetChildren()) do
							local c = v2:Clone()
							c.Parent = v
							task.delay(9.5, function()
								c.Enabled = false
								c:Destroy()
							end)
						end
					end
				end
			end
		end
	end
	if Child.Name == "ForesightFormServer" then
		local c = Assets.ForesightTransformation:Clone()

		local weld = Instance.new("Weld")
		weld.Name = "Weld2"
		weld.Part0 = c
		weld.Part1 = Child

		weld.C0 = CFrame.new(0,1,0)

		weld.Parent = Child
		c.Parent = Child
	end
	if Child.Name == "ShadowTransformationServer" then
		local c = Assets.ShadowTransformation:Clone()

		local weld = Instance.new("Weld")
		weld.Name = "Weld2"
		weld.Part0 = c
		weld.Part1 = Child

		weld.C0 = CFrame.new(0,1,0)

		weld.Parent = c
		c.Parent = workspace.Visuals

		local Connection
		Connection = RunService.RenderStepped:Connect(function()
			if not Child.Parent then
				weld.Part1 = Character.HumanoidRootPart
				Connection:Disconnect() Connection = nil

				for _,v in pairs(c:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						v.Enabled = false
					elseif v:IsA("Beam") then
						TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Width0 = 0,
							Width1 = 0
						}):Play()
					elseif v:IsA("PointLight") then
						TweenService:Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Range = 0
						}):Play()
					end
				end
				Debris:AddItem(c, 4)

			end
		end)

	end
	if Child.Name == "KingDivineForm_Start" then
		local Clone = Assets.KingTransform_Start:Clone()
		local Weld = Instance.new("Motor6D")

		Weld.Name = "Weld"
		Weld.Part0 = Clone
		Weld.Part1 = Child
		Weld.Parent = Child

		Clone.Parent = Child
		-- emitting --
		for _,v in pairs(Clone:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(10)
			end
		end

		task.wait(3.5)
		for _,v in pairs(Clone:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = false
			end
		end
	end
	if Child.Name == "ThunderGodForm_Start" then
		local Clone = Assets.ThunderTransform_Start:Clone()
		local Weld = Instance.new("Motor6D")

		Weld.Name = "Weld"
		Weld.Part0 = Clone
		Weld.Part1 = Child
		Weld.Parent = Child

		Clone.Parent = Child
		-- emitting --
		for _,v in pairs(Clone:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(10)
			end
		end

		task.wait(3.5)
		for _,v in pairs(Clone:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = false
			end
		end
	end
	if Child.Name == "ForesightForm_Start" then
		local Clone = Assets.ForesightForm_Start:Clone()
		local Weld = Instance.new("Motor6D")

		Weld.Name = "Weld"
		Weld.Part0 = Clone
		Weld.Part1 = Child
		Weld.Parent = Child

		Clone.Parent = Child
		-- emitting --
		for _,v in pairs(Clone:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(10)
			end
		end

		task.wait(3.5)
		for _,v in pairs(Clone:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = false
			end
		end
	end
	if Child.Name == "Overdrive_Start" then
		local Clone = Assets.Overdrive_Start:Clone()
		local Weld = Instance.new("Motor6D")

		Weld.Name = "Weld"
		Weld.Part0 = Clone
		Weld.Part1 = Child
		Weld.Parent = Child

		Clone.Parent = Child
		-- emitting --
		for _,v in pairs(Clone:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(10)
			end
		end

		task.wait(3.5)
		for _,v in pairs(Clone:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = false
			end
		end
	end
	if Child.Name == "ShadowForm_Start" then
		local Clone = Assets.ShadowTransform_Star:Clone()
		local Weld = Instance.new("Motor6D")

		Weld.Name = "Weld"
		Weld.Part0 = Clone
		Weld.Part1 = Child
		Weld.Parent = Child

		Clone.Parent = Child
		-- emitting --
		for _,v in pairs(Clone:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(10)
			end
		end

		task.wait(3.5)
		for _,v in pairs(Clone:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = false
			end
		end
	end
	if string.find(Child.Name, "KingSpearServer") and Child:IsA("Folder") then
		for _,C in pairs(Child:GetChildren()) do
			print("bru")
			local Clone = Assets.KingSpear:Clone()
			Clone.Parent = C
			local Weld = Instance.new("Weld")
			Weld.Name = "Weld"
			Weld.Part0 = Clone
			Weld.Part1 = C
			Weld.Parent = Clone

			local Connection

			Connection = RunService.RenderStepped:Connect(function()
				if C.Parent then
					TweenService:Create(Clone, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = C.CFrame}):Play()
				else
					Clone:Destroy()
					Connection:Disconnect()
					return
				end
			end)
		end
	end
	if string.find(Child.Name, "ThunderGodOrbs") and Child:IsA("Folder") then
		for _,C in pairs(Child:GetChildren()) do
			print("bru")
			local Clone = Assets.ThunderOrb:Clone()
			Clone.Parent = C
			local Weld = Instance.new("Weld")
			Weld.Name = "Weld"
			Weld.Part0 = Clone
			Weld.Part1 = C
			Weld.Parent = Clone

			local Connection

			Connection = RunService.RenderStepped:Connect(function()
				if C.Parent then
					TweenService:Create(Clone, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = C.CFrame}):Play()
				else
					Clone:Destroy()
					Connection:Disconnect()
					return
				end
			end)
		end
	end
	if Child.Name == "GravityMeteorServer" then
		local Connection

		local Fireball = Assets.Meteor:Clone()
		Fireball.CFrame = Child.CFrame
		Fireball.Parent = workspace.Visuals

		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(Fireball, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame}):Play()
			else
				Fireball:Destroy()
				Connection:Disconnect()
				return
			end
		end)
	end
	if Child.Name == "ThunderSphereServer" then
		local Connection

		local Fireball = Assets.ThunderSphere:Clone()
		Fireball.CFrame = Child.CFrame
		Fireball.Parent = workspace.Visuals

		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(Fireball, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame}):Play()
			else
				Fireball:Destroy()
				Connection:Disconnect()
				return
			end
		end)
	end
	if Child.Name == "DarkBombServer" then
		local Connection

		local Fireball = Assets.DarkBomb:Clone()

		Fireball.CFrame = Child.CFrame
		Fireball.Parent = workspace.Visuals

		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(Fireball, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame}):Play()
			else
				Fireball:Destroy()
				Connection:Disconnect()
				return
			end
		end)
	end
	if Child.Name == "GravityTrapProjectileServer" then
		local Connection

		local Fireball = Assets.GravityProjectile:Clone()
		Fireball.CFrame = Child.CFrame
		Fireball.Parent = workspace.Visuals

		for _,v in pairs(Fireball:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(100)
			end
		end

		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(Fireball, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame}):Play()
			else
				Fireball:Destroy()
				Connection:Disconnect()
				return
			end
		end)
	end
	if Child.Name == "GravityTrap" then
		local Clone = Assets.GravityTrap:Clone()

		local Weld = Instance.new("Motor6D")
		Weld.Name = "Weld"
		Weld.Part0 = Clone
		Weld.Part1 = Child

		Weld.Parent = Child
		Clone.Parent = Child

		Clone.Attachment.sparks:Emit(10)

		task.wait(3)
		Clone.Attachment.sparks.Enabled = false
	end
	if Child.Name == "WaterTrap" then
		local Clone = Assets.WaterTrap:Clone()

		local Weld = Instance.new("Motor6D")
		Weld.Name = "Weld"
		Weld.Part0 = Clone
		Weld.Part1 = Child

		Weld.Parent = Child
		Clone.Parent = Child

		for _,v in pairs(Clone:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(25)
			end
		end

		task.wait(1)
		for _,v in pairs(Clone:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = false
			end
		end
	end
	if string.find(Child.Name, "GravityDefenseServer") then
		local Clone = Assets.GravityDefense:Clone()
		Clone.Name = "CoolThing"

		local w = Instance.new("Motor6D")
		w.Name = "Weld2"
		w.Part0 = Clone
		w.Part1 = Child
		w.C0 = CFrame.new(0,0,0)*CFrame.Angles(0,math.rad(180),0)
		w.Parent = Clone

		Clone.Parent = Child
	end
	if Child.Name == "ThunderRoarServer" then
		local Clone = Assets.ThunderRoar:Clone()

		local Connection

		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(Clone, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame}):Play()
			else
				Clone:Destroy()
				Connection:Disconnect()
				return
			end
		end)
		Clone.Parent = Child
	end

	if Child.Name == "ThunderSpearServer" then
		wait()
		while Child.Parent ~= nil do
			task.spawn(function()
				if math.random(1,2) == 2 then
					LightningModule.new(table.unpack({
						"cylinder",			--Block Usage (can be set to cylinder or cube) 
						ColorSequence.new{
							ColorSequenceKeypoint.new(0, Color3.fromRGB(103, 155, 219)),
							ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 255, 29)),
							ColorSequenceKeypoint.new(.55, Color3.fromRGB(103, 155, 219)),
							ColorSequenceKeypoint.new(1, Color3.fromRGB(103, 155, 219))
						},					--BlockColor (lighting color)
						3,					--ColorOffset Howfast u want the color to travel through the lightning
						true,				--ColorJuggle turn on if u want to juggle the colors of the color squence
						Child.A,		--Start Point
						Child.B,	--End Point
						false,				--Focused or Spread (will spread to the part depending on what u set it to)
						.7,	--Size (lightning size)
						15,					--Main Segments (basically how many segments u want the lighting to have going above 600 can lag the game)
						.6,				--OffSet (set to higher number to make more zigzag effect)
						nil,				--Fade effect (set to nil if u want the lightning to strike imidielty)
						.25,					--Aniamtion Speed (basically how long it would take for the lightning to disapear)
						2,				--FadeMovement (set to 0 to make it fade to the middle the higher it is the more it fade's to the side)
						2					--Sparks set to nil to disable	
					}))
				else
					LightningModule.new(table.unpack({
						"cylinder",			--Block Usage (can be set to cylinder or cube) 
						ColorSequence.new{
							ColorSequenceKeypoint.new(0, Color3.fromRGB(103, 155, 219)),
							ColorSequenceKeypoint.new(1, Color3.fromRGB(103, 155, 219))
						},					--BlockColor (lighting color)
						3,					--ColorOffset Howfast u want the color to travel through the lightning
						true,				--ColorJuggle turn on if u want to juggle the colors of the color squence
						Child.A,		--Start Point
						Child.B,	--End Point
						false,				--Focused or Spread (will spread to the part depending on what u set it to)
						.7,	--Size (lightning size)
						15,					--Main Segments (basically how many segments u want the lighting to have going above 600 can lag the game)
						.6,				--OffSet (set to higher number to make more zigzag effect)
						nil,				--Fade effect (set to nil if u want the lightning to strike imidielty)
						.25,					--Aniamtion Speed (basically how long it would take for the lightning to disapear)
						2,				--FadeMovement (set to 0 to make it fade to the middle the higher it is the more it fade's to the side)
						2					--Sparks set to nil to disable	
					}))
				end
			end)

			wait(.05)
		end
	end

	if Child.Name == "ThunderSpearBullet" then
		for i = 1, 1 do
			coroutine.wrap(function()
				while Child.Parent ~= nil do
					local Trail = script.TrailPart:Clone()
					Trail.Parent = workspace.Effects
					Trail.Position = Child.Position
					Trail.CFrame *= CFrame.Angles(math.rad(math.random(-360,360)), math.rad(math.random(-360,360)), math.rad(math.random(-360,360)))

					if math.random(1,2) == 1 then
						Trail.Trail.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,0)), ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,0))}
					end

					coroutine.wrap(function()
						for i = 1, math.random(6,25) do
							Trail.CFrame = Trail.CFrame * CFrame.new(0,0,math.random(20,100)/-100)


							Trail.CFrame *= CFrame.Angles(math.rad(math.random(-120,120)), math.rad(math.random(-120,120)), math.rad(math.random(-120,120)))

							if math.random(1,4) == 1 then
								local Trail2 = script.TrailPart:Clone()
								Trail2.Parent = workspace.Effects
								Trail2.Trail.Color = Trail.Trail.Color
								Trail2.CFrame = Trail.CFrame * CFrame.Angles(math.rad(math.random(-360,360)), math.rad(math.random(-360,360)), math.rad(math.random(-360,360)))

								coroutine.wrap(function()
									for i = 1, math.random(3,3) do
										Trail2.CFrame = Trail2.CFrame * CFrame.new(0,0,math.random(20,100)/-100)

										Trail2.CFrame *= CFrame.Angles(math.rad(math.random(-60,60)), math.rad(math.random(-60,60)), math.rad(math.random(-60,60)))
									end
									game:GetService("Debris"):AddItem(Trail2, 12)
								end)()
							end
							task.wait(0.01)
						end

						game:GetService("Debris"):AddItem(Trail, 12)
					end)()

					wait(0.01)
				end
			end)()
			wait(0.01)
		end
	end
	if Child.Name == "ShadowRoarServer" then
		local Clone = Assets.ShadowDragonRoar:Clone()

		local Connection

		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(Clone, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame}):Play()
			else
				Clone:Destroy()
				Connection:Disconnect()
				return
			end
		end)
		Clone.Parent = Child
	end
	if Child.Name == "RestServer" then
		local Clone = Assets.Rest2:Clone()

		local Connection

		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(Clone, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame}):Play()
			else
				Clone:Destroy()
				Connection:Disconnect()
				return
			end
		end)
		Clone.Parent = Child
	end
	if Child.Name == "IronRoarServer" then
		local Clone = Assets.IronDragonRoar2:Clone()

		local Connection

		Connection = RunService.RenderStepped:Connect(function()
			if Child.Parent then
				TweenService:Create(Clone.Front, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame * CFrame.new(0,0,-10)}):Play()
				TweenService:Create(Clone.Middle, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame * CFrame.new(0,0,-20)}):Play()
				TweenService:Create(Clone.End, TweenInfo.new(0.0055, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = Child.CFrame * CFrame.new(0,0,-70)}):Play()
			else
				Clone:Destroy()
				Connection:Disconnect()
				return
			end
		end)
		Clone.Parent = Child
	end

	if Child.Name == "EarthSpikesSmash" then
		local Particle = Assets.Smash:Clone()
		Particle.Position = Child.Position
		Particle.Parent = workspace.Effects
		Particle.Dust:Emit(35)
		Particle.Rocks:Emit(35)
		Particle.Impact:Emit(35)
		Particle.Spark:Emit(35)
		game:GetService("Debris"):AddItem(Particle, 3)

		--wait(0.5)

		--local Spikes = Assets.EarthSpikes:Clone()
		--Spikes.Parent = workspace.Effects
		--Spikes.Root.CFrame = Child.CFrame
	end

	if Child.Name == "IceSpikes" then
		local Spikes = Assets.IceSpikes:Clone()
		Spikes.Parent = workspace.Effects
		Spikes.Root.CFrame = Child.CFrame
	end

	if Child.Name == "NearSightEffect" then
		repeat wait() until Child.Active.Value

		while Child.Active.Value do
			local Vector, OnScreen = Camera:WorldToScreenPoint(Child.Position)
			local Ray = Ray.new(Camera.CFrame.Position, CFrame.new(Camera.CFrame.Position, Child.Position).LookVector * 1000)
			local Hit, Pos = workspace:FindPartOnRay(Ray)

			if OnScreen and Hit == Child and Child.User.Value ~= nil then
				if Character == Child.User.Value then return end
				local Value = Instance.new("Folder")
				Value.Name = "Darken"
				Value.Parent = StatusFolder
				Debris:AddItem(Value, 1)
			end
			wait(0.25)
		end
	end

	if Child.Name == "Splash" then
		local effect = Assets["Water Splash"]:Clone()
		effect.Position = Child.Value
		effect.Parent = workspace.Effects
		Debris:AddItem(effect,3)
		for _,v in pairs(effect:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(10)
			end
		end
		effect.WaterSplash:Play()
	end

	if Child.Name == "ChestReward" then
		local plr = string.split(Child.Value,",")[1]
		local char = workspace.Live[plr]

		local chest = workspace.Chests:FindFirstChild(string.split(Child.Value,",")[2])
		local chestassets = ReplicatedStorage.Assets.ChestVfx

		local orb = chestassets["White Orb"]:Clone()
		local aura = chestassets["Short Aura"]
		local lvl = aura["Level Up"]:Clone()
		local deb = aura["Debris"]:Clone()

		local ChestOrb = sounds.ChestOrb:Clone()
		local ChestShoot = sounds.ChestShoot:Clone()
		local ChestHit = sounds.ChestHit:Clone()
		local ChestRepulse = sounds.ChestRepulse:Clone()
		local ChestShimmer = sounds.ChestShimmer:Clone()
		ChestShimmer.Parent = chest.Bottom
		ChestShimmer:Play()

		chest.White.PointLight.Enabled = true

		orb.Parent = workspace.Effects
		orb.Position = chest.Bottom.Position
		ChestOrb.Parent = orb
		ChestOrb:Play()
		TweenService:Create(orb, TweenInfo.new(1.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = orb.Position + Vector3.new(0,4,0)}):Play()
		wait(3)
		orb.Anchored = false
		local alignposition = Instance.new("AlignPosition")
		alignposition.Parent = orb
		alignposition.Attachment0 = orb.Attachment
		alignposition.Attachment1 = char.HumanoidRootPart.RootAttachment
		alignposition.Responsiveness = 20
		ChestShoot.Parent = orb
		ChestShoot:Play()
		while task.wait() do 
			if (orb.Position - char.HumanoidRootPart.Position).Magnitude < 1 then 
				orb:Destroy()

				ChestHit.Parent = char.HumanoidRootPart
				ChestHit:Play()
				Debris:AddItem(ChestHit,2)

				lvl.Parent = char.HumanoidRootPart
				lvl.Root.Part0 = char.HumanoidRootPart
				lvl.Root.C0 = CFrame.new(0, -3.40000153, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)

				ChestRepulse.Parent = char.HumanoidRootPart
				ChestRepulse:Play()
				Debris:AddItem(ChestRepulse,1)

				for _,v in pairs(lvl:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						v:Emit(10)
					end
				end

				Debris:AddItem(lvl,1)

				deb.Parent = char.HumanoidRootPart
				deb.Root.Part0 = char.HumanoidRootPart
				deb.Root.C0 = CFrame.new(0, -3.40000153, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)

				for _,v in pairs(deb:GetDescendants()) do
					if v:IsA("ParticleEmitter") then
						v:Emit(10)
					end
				end

				Debris:AddItem(deb,1)





				break 
			end
		end



	end


	if Child.Name == "HostageFreeVfx" then

		local char
		for i,v in pairs(workspace.QuestMisc:GetChildren()) do
			if v.Name == "Hostage" then
				if collectionservice:HasTag(v, Child.Value) then
					char = v
					break
				end
			end
		end

		local chestassets = ReplicatedStorage.Assets.ChestVfx

		local orb = chestassets["White Orb"]:Clone()
		local aura = chestassets["Short Aura"]
		local lvl = aura["Level Up"]:Clone()
		local deb = aura["Debris"]:Clone()

		lvl.Parent = char.HumanoidRootPart
		lvl.Root.Part0 = char.HumanoidRootPart
		lvl.Root.C0 = CFrame.new(0, -3.40000153, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)

		for _,v in pairs(lvl:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(10)
			end
		end

		Debris:AddItem(lvl,1)

		deb.Parent = char.HumanoidRootPart
		deb.Root.Part0 = char.HumanoidRootPart
		deb.Root.C0 = CFrame.new(0, -3.40000153, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)

		for _,v in pairs(deb:GetDescendants()) do
			if v:IsA("ParticleEmitter") then
				v:Emit(10)
			end
		end

		Debris:AddItem(lvl,1)

	end

end)



game.ReplicatedStorage.Remotes.Assassination.OnClientEvent:connect(function(action, target)
	local assassinGUI = Player.PlayerGui.AssassinGUI

	if action == "Poster" then
		local highlight = Instance.new("Highlight")
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Parent = target
		task.delay(10, function()
			highlight:Destroy()
		end)
		local indicator = assassinGUI.Indicator:clone()
		indicator.Parent = target["HumanoidRootPart"]
		indicator.Adornee = target["HumanoidRootPart"]
		indicator.Enabled = true
		task.delay(60, function()
			indicator:Destroy()
		end)
		local R = 0
		print(target)
		local targetPlayer = game.Players:GetPlayerFromCharacter(target)
		local viewportFrame = Player.PlayerGui.AssassinGUI.ViewportFrame
		local viewportCam = Instance.new("Camera", workspace.ViewportFolder)
		viewportCam.CameraType = Enum.CameraType.Scriptable
		viewportFrame.CurrentCamera = viewportCam
		local item = target:Clone()
		-- destroying scripts
		for _,v in pairs(item:GetChildren()) do
			if v:IsA("Script") or v:IsA("LocalScript") then
				v:Destroy()
			end
		end
		--
		item.Parent = viewportFrame
		local newCF = CFrame.new(0,0,0) * CFrame.Angles(0,math.rad(180),0)
		item:SetPrimaryPartCFrame(newCF)
		local cframe,size = item:GetBoundingBox()
		local max = math.max(size.X,size.Y,size.Z)
		local distance = (max/math.tan(math.rad(viewportCam.FieldOfView))) * 1.5
		local currentDistance = (max/2) + distance
		assassinGUI.Frame.TargetName.Text = "Assassinate".." "..targetPlayer.Data.FirstName.Value.." "..targetPlayer.Data.LastName.Value
		assassinGUI.Enabled = true
		viewportCam.CFrame = CFrame.lookAt(Vector3.new(0,0,0) + Vector3.new(0,0, currentDistance), Vector3.new(0,0,0))
	--[[elseif action == "Finished" then
		assassinGUI.ViewportFrame.Visible = false
		assassinGUI.Frame.Visible = false
		assassinGUI.TargetName.Visible = false
		local info = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		for i,v in pairs(rewards:GetDescendants()) do
			if v:IsA("TextLabel") then
				local tween1 = TweenService:Create(v, info, {TextTransparency = 0})
				local tween2 = TweenService:Create(v, info, {TextTransparency = 1})
				tween1:Play()
				wait(2)
				tween2:Play()
				tween2.Completed:connect(function()
					assassinGUI.Enabled = false
				end)
			end
		end]]
	else
		for i,v in pairs(assassinGUI.ViewportFrame:GetChildren()) do
			v:Destroy()
		end
		assassinGUI.Enabled = false
	end
end)

local promptService = game:GetService("ProximityPromptService")
local clothingUI = Player.PlayerGui.ClothingSystem
local dummy = nil

promptService.PromptTriggered:connect(function(prompt)
	if prompt.Name == "ClothingPrompt" then
		local storedAccs = {}
		dummy = prompt.Parent
		Camera.CameraType = Enum.CameraType.Scriptable
		Camera.CFrame = dummy["HumanoidRootPart"].CFrame * CFrame.new(0,0,-5) * CFrame.Angles(0,math.rad(180),0)
		clothingUI.Enabled = true
		Remotes.Clothing:FireServer("Start")
		prompt.MaxActivationDistance = .1
		task.spawn(function()
			for i,v in pairs(Character:GetDescendants()) do
				if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
					if v.Parent:IsA("Accessory") ~= true then
						v.Transparency = 1 
					end
				elseif v:IsA("Accessory") then
					table.insert(storedAccs, v.Name)
					v.Parent = game.ReplicatedStorage.Assets.Clothes.Storage
				elseif v:IsA("Decal") then
					v.Transparency = 1
				end
			end
		end)
		repeat wait() until
		Camera.CameraType == Enum.CameraType.Custom
		for i,v in pairs(Character:GetDescendants()) do
			if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" and v.Name ~= "FakeHead" then
				if v.Parent:IsA("Accessory") ~= true then
					v.Transparency = 0
				end
			elseif v:IsA("Decal") then
				v.Transparency = 0
			end
		end
		for i,v in pairs(game.ReplicatedStorage.Assets.Clothes.Storage:GetChildren()) do
			for a,b in pairs(storedAccs) do
				if b == v.Name then
					v.Parent = Character
				end
			end
		end
		prompt.MaxActivationDistance = 10
		for i,v in pairs(dummy:GetChildren()) do
			if v:IsA("Shirt") or v:IsA("Pants") then
				v:Destroy()
			end
		end
		local newShirt = ReplicatedStorage.Assets.Clothing["Starter"].Shirt:clone()
		newShirt.Parent = dummy
		local newPants = ReplicatedStorage.Assets.Clothing["Starter"].Pants:clone()
		newPants.Parent = dummy
	elseif prompt.Name == "Loot" then
		local target = prompt.Parent.Name
		Remotes.LootRemote:FireServer("Loot", target)


	end
end)

promptService.PromptButtonHoldBegan:connect(function(prompt, player)
	local target = prompt.Parent.Name
	if prompt.Name == "Loot" then
		local character = player.Character
		local human = character["Humanoid"]
		local anim = human.Animator:LoadAnimation(ReplicatedStorage.Assets.Animations.Loot)
		anim:Play()
		Remotes.LootRemote:FireServer("Start", target)
		anim:GetMarkerReachedSignal("Take"):wait()
		anim:AdjustSpeed(0)

	end


end)

promptService.PromptButtonHoldEnded:connect(function(prompt, player)
	local target = prompt.Parent.Name
	if prompt.Name == "Loot" then
		Remotes.LootRemote:FireServer("End", target)
		local character = player.Character
		local human = character["Humanoid"]
		for i,v in pairs(human.Animator:GetPlayingAnimationTracks()) do
			if v.Name == "Loot" then
				v:Stop()
			end
		end
	end


end)

clothingUI.Frame.Right.Activated:connect(function()
	Remotes.Clothing:FireServer("Forward")
end)

clothingUI.Frame.Left.Activated:connect(function()
	Remotes.Clothing:FireServer("Back")
end)

clothingUI.Frame.Purchase.Activated:connect(function()
	Remotes.Clothing:FireServer("Purchase")
end)

clothingUI.Frame.Exit.Activated:connect(function()
	clothingUI.Enabled = false
	Camera.CameraType = Enum.CameraType.Custom
end)

Remotes.Clothing.OnClientEvent:connect(function(statTable, name, numberOn, statToString)
	local clothingUI = Player.PlayerGui.ClothingSystem
	if clothingUI.Enabled == false then
		clothingUI.Enabled = true
	end
	if dummy ~= nil then
		for i,v in pairs(dummy:GetChildren()) do
			if v:IsA("Shirt") or v:IsA("Pants") then
				v:Destroy()
			end
		end
		local amt
		local statLabel = clothingUI:FindFirstChild("Frame").Stats
		statLabel.Text = "Stats: "..statToString



		local cost = ReplicatedStorage.Assets.Clothes[name].Cost
		local costOnScreen = clothingUI:FindFirstChild("Frame").Cost
		costOnScreen.Text = "Cost: "..cost.Value
		local newShirt = ReplicatedStorage.Assets.Clothes[name].Shirt:clone()
		newShirt.Parent = dummy
		local newPants = ReplicatedStorage.Assets.Clothes[name].Pants:clone()
		newPants.Parent = dummy


	end
end)

