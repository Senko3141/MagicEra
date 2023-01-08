-- Client

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
repeat task.wait() until Player:GetAttribute("DataLoaded") == true

local PlayerData = Player:WaitForChild("Data")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local FormatNumber = require(Modules.Shared.FormatNumber2)
local MarketItems = require(Modules.Shared.MarketItems)

local NotificationsGui = script.Parent.Parent:WaitForChild("Notifications")
local NotifyEvent = NotificationsGui:WaitForChild("Notify")

local HUD = script.Parent
local Root = HUD:WaitForChild("Root")
local Main = Root.Main
local Confirmation = Root.Confirmation
local ClientEvents = HUD:WaitForChild("Events")

local CurrentSelections = {}

local function UpdateTotal()
	Main.Info.Total.Text = "--"
	
	local AmountInTable = 0
	for _,v in pairs(CurrentSelections) do
		AmountInTable += 1
	end
	
	local Total = nil
	if AmountInTable > 0 then
		Total = 0
		
		for name,value in pairs(CurrentSelections) do
			local ItemInfo = MarketItems[name]
			
			if ItemInfo then
				local Price = ItemInfo.Price
				Total += (value*Price)
			end
		end
	end
	
	if Total ~= nil then
		Main.Info.Total.Text = "Total: $"..FormatNumber.FormatLong(Total)
	end
	return Total
end
local function UpdateDisplay()
	-- Clearing
	for _,v in pairs(Main.Info.List:GetChildren()) do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end
	
	--
	for Name,Data in pairs(MarketItems) do
		local Category = Data.Category
		
		local FoundCategory = PlayerData.Items:FindFirstChild(Category)
		if FoundCategory then
			local FoundItem = FoundCategory:FindFirstChild(Name)
			
			if FoundItem and FoundItem.Value > 0 then
				local Clone = script.Template:Clone()
				Clone.Name = Name
				Clone.Title.Text = Name
				Clone.Parent = Main.Info.List
								
				local CurrentValue = 0
				CurrentSelections[Name] = CurrentValue
				
				local function UpdateCurrentValue()
					Clone.Main.Amount.Text = tostring(CurrentValue)
					if CurrentSelections[Name] then
						CurrentSelections[Name] = CurrentValue
					end
					
					UpdateTotal()
				end
				UpdateCurrentValue()
				
				Clone.Main.Amount.Text = tostring(CurrentValue)
				
				Clone.Main.Amount.FocusLost:Connect(function()
					-- Clicked off of it
					if tonumber(Clone.Main.Amount.Text) then
						
						local NumberedAmount = tonumber(Clone.Main.Amount.Text)
						NumberedAmount = math.clamp(NumberedAmount, 0, FoundItem.Value)
						
						CurrentValue = NumberedAmount
						UpdateCurrentValue()
					else
						-- reset to before
						UpdateCurrentValue()
					end
				end)
				Clone.Main.Max.MouseButton1Click:Connect(function()
					CurrentValue = FoundItem.Value -- Setting to Max
					UpdateCurrentValue()
				end)
			end
			
		end
	end
end
ClientEvents.Update.Event:Connect(UpdateDisplay)

--

Main.Info.Sell.Main.MouseButton1Click:Connect(function()
	Confirmation:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
end)
Confirmation.Yes.Main.MouseButton1Click:Connect(function()
	Confirmation:TweenPosition(UDim2.new(0.5,0,-0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
	
	local Total = UpdateTotal()
	if Total ~= nil then
		-- Resetting
		Main:TweenPosition(UDim2.new(0.5,0,-0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
		
		-- Firing Server
		Remotes.Sell:FireServer(CurrentSelections)
		--
		CurrentSelections = {}
		-- Clearing List
		for _,v in pairs(Main.Info.List:GetChildren()) do
			if v:IsA("Frame") then
				v:Destroy()
			end
		end
		
	end
end)

Confirmation.No.Main.MouseButton1Click:Connect(function()
	Confirmation:TweenPosition(UDim2.new(0.5,0,-0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
end)

-- CONFIRMATION WEAPON --
Root.ConfirmationWeapon.Yes.Main.MouseButton1Click:Connect(function()
	if PlayerData.Weapon.Value == "Combat" then
		NotifyEvent:Fire("You already have [Combat] as a weapon. Cannot sell.", 4)
		return
	end
	Root.ConfirmationWeapon:TweenPosition(UDim2.new(0.5,0,-0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
	Remotes.SellWeapon:FireServer()
end)

Root.ConfirmationWeapon.No.Main.MouseButton1Click:Connect(function()
	Root.ConfirmationWeapon:TweenPosition(UDim2.new(0.5,0,-0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
end)


Main.Close.MouseButton1Click:Connect(function()
	CurrentSelections = {}
	-- Clearing List
	for _,v in pairs(Main.Info.List:GetChildren()) do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end
	
	Main:TweenPosition(UDim2.new(0.5,0,-0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
end)
