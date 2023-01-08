-- Reroll Client

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local MarketPlaceService = game:GetService("MarketplaceService")

local Player = Players.LocalPlayer
repeat task.wait() until Player:GetAttribute("DataLoaded") == true

local PlayerData = Player:WaitForChild("Data")
local GlobalData = Player:WaitForChild("GlobalData")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Rates = require(Modules.Shared.Rates)
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local Sound = require(Modules.Client.Effects.Sound)
local HUD = script.Parent
local Root = HUD:WaitForChild("Root")
local RatesFrame = Root.Rates
local RatesList = RatesFrame.List
local NotifyEvent = script.Parent.Parent:WaitForChild("Notifications"):WaitForChild("Notify")
local UISettings = script.Parent.Parent:WaitForChild("UISettings")
local Gamepasses = require(Modules.Shared.Gamepasses)

local RollButton = Root.Roll.Main
local Finish = Root.Finish.Main
local Result = Root.Result
local RatesInfoList = Root.Info.List
local SpinsLabel = Root.Spins
local BuySpins = Root.BuySpins_Button.Main
local SpinsFrame = Root.BuySpins

local SkipSpin = Root.SkipSpin.Main
local SkipFrame = Root.SkipFrame
local LuckActiveLabel = Root.LuckActive

local MagicStorage = Root.MagicStorage.Main
local StorageFrame = Root.Storage

local OrderedElements = Rates:GetElementsInOrder()
local OrderedPercentages = Rates:GetPercentagesInOrder()
local OrderedPityElements = Rates:GetPityElementsInOrder()

local Skip_Spins = false

--[[
local function movingbackground()
	local cancelled = false

	Root.Overlay.Lines.Position = UDim2.new(0,0,-1,0)
	local Tween = TweenService:Create(Root.Overlay.Lines, TweenInfo.new(40, Enum.EasingStyle.Linear), {
		Position = UDim2.new(-1,0,0,0)
	})
	Tween:Play()

	Tween.Completed:Connect(function()
		if cancelled then return end
		movingbackground()
	end)

	-- checking if current loctaion changed
	while UISettings.Location.Value == "Reroll" do
		task.wait()
	end
	cancelled = true
	Tween:Cancel()
	Root.Overlay.Lines.Position = UDim2.new(0,0,-1,0)
	Tween:Destroy()
end

task.spawn(function()
	UISettings.Location.Changed:Connect(function()
		if UISettings.Location.Value == "Reroll" then
			movingbackground()
		end
	end)
end)
]]--

local function updateList()
	for _,v in pairs(RatesList:GetChildren()) do
		if not v:IsA("UIListLayout") then
			v:Destroy()
		end
	end
	for _,v in pairs(RatesInfoList:GetChildren()) do
		if not v:IsA("UIListLayout") then
			v:Destroy()
		end
	end
	for i = 1,#OrderedElements do
		local info = OrderedElements[i]
		local Clone = script.Template:Clone()
		Clone.Name = info.Name
		Clone.Main.Text = info.Name
		Clone.Main.TextColor3 = Rates.CategoryToColor[info.Category]
		
		Clone.ImageColor3 = Rates.CategoryToColor[info.Category]
		
		Clone.Parent = RatesList
	end
	for i = 1,#OrderedPercentages do
		local info = OrderedPercentages[i]
		local Clone = script.TemplateInfo:Clone()
		Clone.Name = info.Name
		Clone.Main.Text = info.Name..": ".. info.Rate.."%"
		Clone.Main.TextColor3 = Rates.CategoryToColor[info.Name]
		
		Clone.ImageColor3 = Rates.CategoryToColor[info.Name]
		
		Clone.Parent = RatesInfoList
	end
end
local function updateSpins()
	SpinsLabel.Text = "Spins Left: ".. tostring(GlobalData.Spins.Value)
end

-- Updating List
updateList()
-- Button
local IsSpinning = false

local StorageFrameOpen = false
local ProcessingSwitch = false
local SpinsFrameOpen = false
local ProcessingSpin = false

RollButton.MouseButton1Click:Connect(function()
	if GlobalData.Spins.Value <= 0 then
		NotifyEvent:Fire(
			'<font color="rgb(255, 255, 0)">[SPINS]</font> You do not have enough spins.',
			1.5
		)
		return
	end
	if IsSpinning then return end
	if ProcessingSwitch then
		return
	end
	if StorageFrameOpen then
		return
	end
	if SpinsFrameOpen then
		return
	end
	
	-- Testing
	if ProcessingSpin then
		return
	end	

	Sound({
		SoundName = "Click",
		Parent = script.Parent.Parent.Effects
	})
	
	-- Change text to Rolling --
	RollButton.Text = "Rolling..."
	ProcessingSpin = true
	
	local Success, Chosen = Remotes.Spin:InvokeServer(Skip_Spins)
	
	print("Spinning Debug", Success, Chosen, ProcessingSwitch)
	
	if Success then
		IsSpinning = true
		
		for i = 1,50 do
			if Skip_Spins then
				break
			end
			
			if PlayerData.SpinPity.Value >= 300 then
				local ran = OrderedPityElements[math.random(1, #OrderedPityElements)]
				Result.Text = ran.Name
				Result.TextColor3 = Rates.CategoryToColor[ran.Category]
			else
				local ran = OrderedElements[math.random(1, #OrderedElements)]
				Result.Text = ran.Name
				Result.TextColor3 = Rates.CategoryToColor[ran.Category]
			end
			task.wait(.05)
		end
		Result.Text = Chosen
		Result.TextColor3 = Rates.CategoryToColor[Rates.Elements[Chosen]]
		task.wait(.3)
		
		ProcessingSpin = false
		IsSpinning = false
		RollButton.Text = "Roll"
	else
		RollButton.Text = "Roll"
		task.wait(.3)
		
		IsSpinning = false
		ProcessingSpin = false
	end
end)
-- Hover/UnHover
local function hovered(object, bool)
	if object:FindFirstChild("UIStroke") then
		if bool then
			TweenService:Create(object.UIStroke, TweenInfo.new(.3), {
				Transparency = 0,
			}):Play()
		else
			TweenService:Create(object.UIStroke, TweenInfo.new(.3), {
				Transparency = 1,
			}):Play()
		end
	end
end
RollButton.MouseEnter:Connect(function()
	hovered(RollButton, true)
	Sound({
		SoundName = "MouseHover",
		Parent = script.Parent.Parent.Effects
	})	
end)
RollButton.MouseLeave:Connect(function()
	hovered(RollButton, false)
end)
Finish.MouseEnter:Connect(function()
	hovered(Finish, true)
	Sound({
		SoundName = "MouseHover",
		Parent = script.Parent.Parent.Effects
	})	
end)
Finish.MouseLeave:Connect(function()
	hovered(Finish, false)
end)
-- Finish Button
Finish.MouseButton1Click:Connect(function()
	if IsSpinning then return end
	if ProcessingSwitch then
		return
	end
	if StorageFrameOpen then
		return
	end
	if SpinsFrameOpen then
		return
	end
	
	Sound({
		SoundName = "Click",
		Parent = script.Parent.Parent.Effects
	})
	Root:TweenPosition(UDim2.new(0.5,0,-0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
	script.Parent.Parent.StartScreen.Root.Visible = true
	UISettings.Location.Value = "Start"
	task.wait(1)
	UISettings.CanClick.Value = true
end)
-- Buy Spins
BuySpins.MouseButton1Click:Connect(function()
	SpinsFrameOpen = not SpinsFrameOpen
	Sound({
		SoundName = "Click",
		Parent = script.Parent.Parent.Effects
	})
	if SpinsFrameOpen then
		SpinsFrame:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
	else
		SpinsFrame:TweenPosition(UDim2.new(0.5,0,-.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
	end
end)
local AlreadyBuying = false
for _,SpinOption in pairs(SpinsFrame.Info.List:GetChildren()) do
	if SpinOption:IsA("Frame") then
		
		if SpinOption:FindFirstChild("Toggle") then
			local with_robux = SpinOption.Toggle:FindFirstChild("Robux").Main
						
			with_robux.MouseButton1Click:Connect(function()
				Sound({
					SoundName = "Click",
					Parent = script.Parent.Parent.Effects
				})
				
				if AlreadyBuying then return end
				
				local found_id = Gamepasses.GetGamepassIdFromName(SpinOption.Name)
				--warn(found_id, SpinOption.Name)
				
				if found_id then
					MarketPlaceService:PromptProductPurchase(Player, found_id)
				end
			end)
		end
	end
end

-- Skip Spins
SkipSpin.MouseButton1Click:Connect(function()
	if StorageFrameOpen then
		return
	end
	if SpinsFrameOpen then
		return
	end
	
	if MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, Gamepasses.GetGamepassIdFromName("Instant Spin Skip")) then
		-- notify
		NotifyEvent:Fire("[GAMEPASSES] You have already bought this gamepass.", 3)
		Sound({
			SoundName = "Click",
			Parent = script.Parent.Parent.Effects
		})
		return
	end
	MarketPlaceService:PromptGamePassPurchase(Player, Gamepasses.GetGamepassIdFromName("Instant Spin Skip"))
end)
local function updateToggled()
	local finalPos = UDim2.new()
	if Skip_Spins then
		finalPos = UDim2.new(0.43,0,0,0)
		-- change color
		SkipFrame.Toggle.Button.BackgroundColor3 = Color3.fromRGB(82, 255, 74)
		SkipFrame.Toggle.Button.Text = "ON"
	else
		finalPos = UDim2.new(0,0,0,0)
		-- change color
		SkipFrame.Toggle.Button.BackgroundColor3 = Color3.fromRGB(255,71,74)
		SkipFrame.Toggle.Button.Text = "OFF"
	end
	SkipFrame.Toggle.Button:TweenPosition(finalPos, Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true)
end
SkipFrame.Toggle.Button.MouseButton1Click:Connect(function()
	if StorageFrameOpen then
		return
	end
	if SpinsFrameOpen then
		return
	end
	
	Sound({
		SoundName = "Click",
		Parent = script.Parent.Parent.Effects
	})
	if not MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, Gamepasses.GetGamepassIdFromName("Instant Spin Skip")) then
		NotifyEvent:Fire("[GAMEPASSES] You do not own this gamepass.", 3)
		return
	end

	Skip_Spins = not Skip_Spins
	updateToggled()
end)
-- Magic Storage
local function updateStorageFrame()
	-- clearing
	for _,v in pairs(StorageFrame.Info.List:GetChildren()) do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end

	if not MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, Gamepasses.GetGamepassIdFromName("Magic Storage")) then
		-- hasn't bought, don't update
		return
	end
	--
	local PreviousRolls = PlayerData:FindFirstChild("PreviousRolls")
	if PreviousRolls then
		local Children = PreviousRolls:GetChildren()
		for i = 1,#OrderedElements do
			local info = OrderedElements[i]

			local Clone = script.StorageTemplate:Clone()
			Clone.Name = tostring(i)

			Clone.Title.Text = info.Name
			Clone.Title.TextColor3 = Rates.CategoryToColor[info.Category]

			Clone.Main.Button.Text = "LOCKED"
			Clone.Main.Button.BackgroundColor3 = Color3.fromRGB(231, 71, 74)

			if PreviousRolls:FindFirstChild(info.Name) then
				-- previously rolled, can select
				local IsCurrentElement = (PlayerData.Element.Value == info.Name and true) or false

				if IsCurrentElement then
					-- is already the player's element
					Clone.Main.Button.Text = "SELECTED"
					Clone.Main.Button.BackgroundColor3 = Color3.fromRGB(221, 213, 60)
				else
					Clone.Main.Button.Text = "SELECT"
					Clone.Main.Button.BackgroundColor3 = Color3.fromRGB(100, 202, 100)

					-- Click Connection
					Clone.Main.Button.MouseButton1Click:Connect(function()
						if IsCurrentElement then
							return
						end
						if ProcessingSwitch then
							return
						end
						if IsSpinning then
							return 
						end
						if SpinsFrameOpen then
							return
						end
						
						-- cant do when spinning, processing, etc
						
						warn("change element to: ".. info.Name)
						
						ProcessingSwitch = true
						
						local Response = Remotes.SwitchMagic:InvokeServer(info.Name)
						if Response then
							NotifyEvent:Fire("[MAGIC STORAGE] Successfully switched current element to: [".. info.Name.."]!", 6)
							
							Result.Text = info.Name
							Result.TextColor3 = Rates.CategoryToColor[Rates.Elements[info.Name]]
							
							updateStorageFrame()
							
							task.wait(.5)
							ProcessingSwitch = false
						else
							NotifyEvent:Fire("[MAGIC STORAGE] There was an error when trying to change your element to: [".. info.Name.."]!", 6)
							task.wait(.5)
							ProcessingSwitch = false
						end
					end)
				end
			end
			
			Clone.Parent = StorageFrame.Info.List

		end
	end
end

MagicStorage.MouseButton1Click:Connect(function()
	if SpinsFrameOpen then
		return
	end
	
	Sound({
		SoundName = "Click",
		Parent = script.Parent.Parent.Effects
	})

	if not MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, Gamepasses.GetGamepassIdFromName("Magic Storage")) then
		-- notify, hasn't bought
		NotifyEvent:Fire("[GAMEPASSES] You need the [Magic Storage] gamepass to use this.", 5)		
		MarketPlaceService:PromptGamePassPurchase(Player, Gamepasses.GetGamepassIdFromName("Magic Storage"))
		return
	end
	-- has bought
	if StorageFrameOpen == true then
		return
	end
	
	StorageFrameOpen = true
	updateStorageFrame()

	if StorageFrameOpen then
		StorageFrame:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
	else
		StorageFrame:TweenPosition(UDim2.new(0.5,0,-.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
	end
end)
StorageFrame.Close.MouseButton1Click:Connect(function()
	Sound({
		SoundName = "Click",
		Parent = script.Parent.Parent.Effects
	})
	
	if StorageFrameOpen then
		StorageFrameOpen = false
		
		if StorageFrameOpen then
			StorageFrame:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
		else
			StorageFrame:TweenPosition(UDim2.new(0.5,0,-.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
		end
	end
end)

--
GlobalData.Spins.Changed:Connect(function()
	updateSpins()
end)
updateSpins()
-- setting current
Result.Text = PlayerData.Element.Value
if PlayerData.Element.Value ~= "None" then
	Result.TextColor3 = Rates.CategoryToColor[Rates.Elements[PlayerData.Element.Value]]
end

-- checking if has 2x luck gamepass
if MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, Gamepasses.GetGamepassIdFromName("2x Magic Chance")) then
	LuckActiveLabel.Visible = true
else
	LuckActiveLabel.Visible = false
end

-- updating more
PlayerData.PreviousRolls.ChildAdded:Connect(function()
	updateStorageFrame()
end)
PlayerData.PreviousRolls.ChildRemoved:Connect(function()
	updateStorageFrame()
end)
-- Changed
PlayerData.SpinPity.Changed:Connect(function()
	Root.Pity.Text = "PITY: ".. PlayerData.SpinPity.Value
end)
Root.Pity.Text = "PITY: ".. PlayerData.SpinPity.Value