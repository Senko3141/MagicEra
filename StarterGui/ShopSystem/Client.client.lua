-- Client

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Modules = ReplicatedStorage:WaitForChild("Modules")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local PlayerData = Player:WaitForChild("Data")
local ShopItems = workspace:WaitForChild("ShopItems")

local ChosenItem = nil
local OnScreen = {}
local DesiredDistance = 7

local Root = script.Parent:WaitForChild("Root")
local ConfirmationFrame = Root:WaitForChild("Confirmation")
local IsOpen = false

local ItemsModule = require(Modules.Shared.Items)
local NotifyEvent = script.Parent.Parent:WaitForChild("Notifications"):WaitForChild("Notify")
local SoundMoodule = require(Modules.Client.Effects.Sound)

local function GetClosest()
	local Sorted = {}
	
	for _,item in pairs(ShopItems:GetChildren()) do
		if not Character:FindFirstChild("HumanoidRootPart") then
			break
		end
		
		local Distance = (Character.HumanoidRootPart.Position - item.Position).Magnitude
		
		if Distance <= DesiredDistance then
			table.insert(Sorted, {
				item,
				Distance
			})
		end
	end
	
	table.sort(Sorted, function(a,b)
		return a[2] < b[2]
	end)
	
	if #Sorted > 0 then
		return Sorted[1][1]
	end
	return nil
end
local function UpdatePrice()
	local BulkAmount = ConfirmationFrame.Amount.Text
	BulkAmount = tonumber(BulkAmount)

	if BulkAmount then
		BulkAmount = math.floor(BulkAmount+.5)
		
		local ItemInfo = ItemsModule[ChosenItem.Name]
		if not ItemInfo then
			return
		end

		if BulkAmount then
			local FinalPrice = ItemInfo.Price * BulkAmount
			ConfirmationFrame.Yes.Main.Text = "Purchase ($".. FinalPrice..")"
		end
	else
		ConfirmationFrame.Yes.Main.Text = "Purchase (--)"
	end
end

RunService.RenderStepped:Connect(function()
	local Closest = GetClosest()
	if Closest ~= nil then
		if ChosenItem ~= nil then
			-- Tween Out
			ChosenItem.Info.Root.Main:TweenPosition(UDim2.new(0.5,0,1.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			
			if OnScreen[ChosenItem] then
				OnScreen[ChosenItem] = nil
				ChosenItem = nil
			end
		end
		ChosenItem = Closest
		ChosenItem.Info.Root.Main:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
		
		OnScreen[Closest] = Closest
	end
	
	-- Tweening OnScreen Stuff if too far away
	for _,item in pairs(OnScreen) do
		local a = Character.HumanoidRootPart.Position
		local b = item.Position

		if (a-b).Magnitude > DesiredDistance then
			OnScreen[item] = nil
			ChosenItem = nil
			item.Info.Root.Main:TweenPosition(UDim2.new(0.5,0,1.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
		end
	end
end)

UserInputService.InputBegan:Connect(function(Input, Processed)
	if Processed then return end
	
	if Input.KeyCode == Enum.KeyCode.E then
		if ChosenItem ~= nil then			
			TweenService:Create(ChosenItem.Info.Root.Main, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				BackgroundColor3 = Color3.fromRGB(44, 44, 44)
			}):Play()
			task.delay(.2, function()
				TweenService:Create(ChosenItem.Info.Root.Main, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					BackgroundColor3 = Color3.fromRGB(58, 58, 58)
				}):Play()
			end)
			
			-- Tween Confirm
			-- update with info
			IsOpen = true
			
			ConfirmationFrame.Title.Text = "Would you like to buy [".. ChosenItem.Name.."]?"
			--
			ConfirmationFrame:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			
			UpdatePrice()
		end
	end
end)

ConfirmationFrame.No.Main.MouseButton1Click:Connect(function()
	IsOpen = false
	ConfirmationFrame:TweenPosition(UDim2.new(0.5,0,-0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
end)
ConfirmationFrame.Yes.Main.MouseButton1Click:Connect(function()
	if ChosenItem == nil then
		return
	end
	local BulkAmount = ConfirmationFrame.Amount.Text
	BulkAmount = tonumber(BulkAmount)
	
	local ItemInfo = ItemsModule[ChosenItem.Name]
	if not ItemInfo then
		return
	end
	
	if BulkAmount then
		if BulkAmount > ItemInfo.MAX_BULK_AMOUNT then
			NotifyEvent:Fire("[SHOP SYSTEM] You can only buy up to [".. ItemInfo.MAX_BULK_AMOUNT .."] of this item at a time.")
			return
		end
		if BulkAmount < 1 then
			NotifyEvent:Fire("[SHOP SYSTEM] Your input has to be greater than 1.")
			return
		end
		
		local FoundCategory = PlayerData.Items:FindFirstChild(ItemInfo.Category)
		if not FoundCategory and not ItemInfo.IGNORE_CATEGORY_CHECK then
			return
		end
		if not ItemInfo.IGNORE_CATEGORY_CHECK and FoundCategory[ItemInfo.Name].Value+BulkAmount > ItemInfo.MAX_STACK then
			NotifyEvent:Fire("[SHOP SYSTEM] You can only have ["..ItemInfo.MAX_STACK.."] of this item at a time.", 5)
			return
		end
		
		if ItemInfo.Category == "PrimaryWeapon" then
			if ItemInfo.OVERRIDE_WEAPON then
				if PlayerData.Weapon.Value == ItemInfo.Name then
					NotifyEvent:Fire("[SHOP SYSTEM] You already own this weapon.")
					return
				end
			end
		end
		------------------
		
		local FinalPrice = ItemInfo.Price * BulkAmount
		if PlayerData.Gold.Value < FinalPrice then
			NotifyEvent:Fire("[SHOP SYSTEM] Error: you do not have enough jewels to purchase ["..ItemInfo.Name.."]! TOTAL PRICE: $".. FinalPrice..".")
			return
		end
		Remotes.Purchase:FireServer(ItemInfo.Name, BulkAmount)
	end
end)

ConfirmationFrame:WaitForChild("Amount"):GetPropertyChangedSignal("Text"):Connect(function()
	UpdatePrice()
end)
UpdatePrice()