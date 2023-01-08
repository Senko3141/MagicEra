-- Loading Screen/Slots Client

local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

local HUD = script.Parent
local Root = HUD:WaitForChild("Root")
local LoadingFrame = Root.Loading

if Player:GetAttribute("FinishedClientLoading") == true then
	HUD.Enabled = false
	return
end

HUD.Enabled = true

-- Loading
local function LoadAssets()
	-- Setting up Gradient
	local Start = Vector2.new(1,0)
	local End = Vector2.new(-1,0)
	
	local AssetsLoaded = 0
	local AssetsToLoad = workspace:GetChildren()
	for i = 1, #AssetsToLoad do
		ContentProvider:PreloadAsync({AssetsToLoad[i]})
		AssetsLoaded += 1
		
		-- Tweening
		local NewOffset = Start:Lerp(End, AssetsLoaded/#AssetsToLoad)
		TweenService:Create(LoadingFrame.Logo.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Offset = NewOffset
		}):Play()
	end
	-- Finished
	Player:SetAttribute("FinishedClientLoading", true)
	
	local Connection
	local Pressed = false
	
	local TextTween = TweenService:Create(LoadingFrame.TextLabel, TweenInfo.new(1.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, true, 2), {
		TextColor3 = Color3.fromRGB(153, 153, 153)
	})
	TextTween:Play()
	TweenService:Create(LoadingFrame.TextLabel, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		TextTransparency = 0
	}):Play()
	
	Connection = UserInputService.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			Pressed = true
			TextTween:Cancel()
			
			TweenService:Create(LoadingFrame.TextLabel, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				TextTransparency = 1
			}):Play()
			TweenService:Create(LoadingFrame.Logo, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				ImageTransparency = 1
			}):Play()
			
			Connection:Disconnect()
			Connection = nil
			
			task.wait(1.5)
			-- Fading Out
			TweenService:Create(LoadingFrame, TweenInfo.new(.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
				GroupTransparency = 1
			}):Play()
			task.delay(.5, function()
				LoadingFrame.Visible = false
				HUD.Enabled = false
			end)
		end
	end)
end

LoadAssets()