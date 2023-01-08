-- Client

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local StatusFolder = Character:WaitForChild("Status", 999)

local CurrentFadeTween = nil

local HUD = script.Parent
local Root = HUD:WaitForChild("Root")
local Main = Root.Main

local function StopCurrentTween()
	if CurrentFadeTween ~= nil then
		CurrentFadeTween:Cancel()
		CurrentFadeTween:Destroy()
		CurrentFadeTween = nil
	end
end

if not StatusFolder:FindFirstChild("DisplayTargetHealth") then
	-- Toggle
	StopCurrentTween()

	local Tween = TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		GroupTransparency = 1
	})
	CurrentFadeTween = Tween
	CurrentFadeTween:Play()
end

StatusFolder.ChildAdded:Connect(function(Child)
	if Child.Name == "DisplayTargetHealth" then
		local Model = Child.Value

		-- Setting Properties
		Main.NPC.Text = Model.Name
		local Humanoid = Model:FindFirstChild("Humanoid")
		local TargetStatus = Model:FindFirstChild("Status")
		if Humanoid then
			task.spawn(function()
				while Child.Parent ~= nil do
					-- Updating Health
					if Model.Name ~= Child.Value.Name then
						-- New Child
						Model = Child.Value
						Humanoid = Model:FindFirstChild("Humanoid")
						
						Main.NPC.Text = Model.Name
						
						if not Humanoid then
							StopCurrentTween()
							local Tween = TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
								GroupTransparency = 1
							})
							CurrentFadeTween = Tween
							CurrentFadeTween:Play()
							break
						end
					end
					
					
					if TargetStatus then
						if TargetStatus:FindFirstChild("Dead") then
							-- Dead
							StopCurrentTween()
							local Tween = TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
								GroupTransparency = 1
							})
							CurrentFadeTween = Tween
							CurrentFadeTween:Play()
							break
						end
					end
					if Humanoid.Health == 0 then
						-- Dead
						StopCurrentTween()
						local Tween = TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							GroupTransparency = 1
						})
						CurrentFadeTween = Tween
						CurrentFadeTween:Play()
						break
					end
					
					
					local HealthPercentage = Humanoid.Health/Humanoid.MaxHealth
					Main.Health.Main:TweenSize(UDim2.new(HealthPercentage-.02,0,0.6,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
					task.wait()
				end
			end)
		end

		StopCurrentTween()
		local Tween = TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			GroupTransparency = 0
		})
		CurrentFadeTween = Tween
		CurrentFadeTween:Play()
	end
end)
StatusFolder.ChildRemoved:Connect(function(Child)
	if Child.Name == "DisplayTargetHealth" then
		StopCurrentTween()
		local Tween = TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			GroupTransparency = 1
		})
		CurrentFadeTween = Tween
		CurrentFadeTween:Play()
	end
end)