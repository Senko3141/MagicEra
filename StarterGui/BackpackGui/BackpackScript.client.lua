-- Backpack Script

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local PlayerGui: PlayerGui = Player:WaitForChild("PlayerGui")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Backpack = Player:WaitForChild("Backpack")
local Modules = ReplicatedStorage:WaitForChild("Modules")

repeat task.wait() until Player:GetAttribute("DataLoaded") == true
local PlayerData = Player:WaitForChild("Data")

local Gui = script.Parent
local Root = Gui:WaitForChild("Root")
local BackpackFrame = Root.BackpackFrame
local InventoryFrame = Root.Inventory.Main
local DraggingFrame = Root.DraggingFrame

local TweeningInventory = false
local InventoryOpen = false
local DraggingObject = nil
local SelectedObject = nil
local BackpackConfiguration = script:WaitForChild("Configuration")

local ShopItems = require(Modules.Shared.Items)

local CurrentSlots = {}
CurrentSlots = Remotes.GetSlots:InvokeServer()
if typeof(CurrentSlots) ~= "table" or #CurrentSlots > 10 then
	CurrentSlots = {
		[1] = "",
		[2] = "",
		[3] = "",
		[4] = "",
		[5] = "",
		[6] = "",
		[7] = "",
		[8] = "",
		[9] = "",
		[10] = "",
	}
end

--warn("TESTTT ", CurrentSlots)

local Order = {
	"One",
	"Two",
	"Three",
	"Four",
	"Five",
	"Six",
	"Seven",
	"Eight",
	"Nine",
	"Zero",
}
local StringToNumber = {One = "1", Two = "2", Three = "3", Four = "4", Five = "5", Six = "6", Seven = "7", Eight = "8", Nine = "9", Zero = "0"}

local function IsMagicSkill(Name)
	for _,v in pairs(ReplicatedStorage.Modules.Shared.MagicService:GetDescendants()) do
		--print(v.Name, Name)
		if v.Name == Name and v.Parent:IsA("Folder") then
			return true
		end
	end
	return false
end
local function GetSwapObject(IgnoreList)
	local MousePosition = UserInputService:GetMouseLocation()-game.GuiService:GetGuiInset()
	local ObjectsAtMouse = PlayerGui:GetGuiObjectsAtPosition(MousePosition.X, MousePosition.Y)

	for i = 1,#ObjectsAtMouse do
		local Object = ObjectsAtMouse[i]		
		if Object.Parent == BackpackFrame and not table.find(IgnoreList, Object) then
			return Object
		end
	end
	return nil
end
local function SlotIsEmpty(SlotNumber)
	if typeof(SlotNumber) ~= "number" then
		SlotNumber = typeof(SlotNumber)
	end

	if SlotNumber then
		if CurrentSlots[SlotNumber] == "" then
			return true
		end
	end
	return false
end
local function GetOpenSlot()
	local OpenSlot = ""
	for i = 1,#CurrentSlots do
		local SlotName = CurrentSlots[i]
		if SlotName == "" then			
			OpenSlot = i
			break
		end
	end
	return OpenSlot
end
local function UpdateSelectedSlot()
	-- Resetting
	for _,v in pairs(BackpackFrame:GetChildren()) do
		if v:IsA("ImageLabel") then
			--[[
			v.ImageColor3 = Color3.fromRGB(255,255,255)
			v.Button.UIStroke.Transparency = 1
			]]--

			v.Size = UDim2.new(0.093,0,1,0)

			if v:FindFirstChild("Button") then
				if IsMagicSkill(v.Button.Text) then
					v.Button.TextColor3 = BackpackConfiguration.MagicTextColor.Value
				else
					v.Button.TextColor3 = BackpackConfiguration.DefaultTextColor.Value
				end
			end
		end
	end

	for _,Slot in pairs(BackpackFrame:GetChildren()) do
		if Slot:IsA("ImageLabel") then
			if Slot.Name == StringToNumber[SelectedObject] then
				--[[
				Slot.ImageColor3 = Color3.fromRGB(255, 255, 255)
				Slot.Size = UDim2.new(0.105,0,1.1,0)
				Slot.Button.UIStroke.Transparency = 0
				]]--

				Slot.Size = UDim2.new(0.105,0,1.1,0)
				if Slot:FindFirstChild("Button") then
					if IsMagicSkill(Slot.Button.Text) then
						Slot.Button.TextColor3 = BackpackConfiguration.SelectedMagicTextColor.Value
					else
						Slot.Button.TextColor3 = BackpackConfiguration.SelectedDefaultTextColor.Value
					end
				end
			end
		end
	end

	if SelectedObject ~= nil and SelectedObject ~= "" then
		local SlotNumber = table.find(Order, SelectedObject)
		if SlotNumber then
			local SlotValue = CurrentSlots[SlotNumber]
			local FoundTool = Character:FindFirstChild(SlotValue)
			if FoundTool and FoundTool:IsA("Tool") then
				return
			else
				-- EquipTool
				local BackpackTool = Player.Backpack:FindFirstChild(SlotValue)
				if BackpackTool then
					Character.Humanoid:EquipTool(BackpackTool)
				end
			end	
		end
	else
		Character.Humanoid:UnequipTools()
	end
end
local function UpdateSlotVisibility()
	if InventoryOpen then
		-- Set all Visible
		for _,v in pairs(BackpackFrame:GetChildren()) do
			if v:IsA("ImageLabel") then
				v.Visible = true
			end
		end
	else
		for _,v in pairs(BackpackFrame:GetChildren()) do
			if v:IsA("ImageLabel") then
				local Button = v:FindFirstChild("Button")
				if Button then
					if Button.Text == "" then
						-- Not Filled
						v.Visible = false
					else
						v.Visible = true
					end
				end
			end
		end
	end
end

local SlotConnections = {}

local function UpdateSlots()
	--warn(CurrentSlots)
	for i = 1,#CurrentSlots do
		local SlotValue = CurrentSlots[i]

		local CurrentIndex = Order[i]
		CurrentIndex = StringToNumber[CurrentIndex]

		local SlotObject = BackpackFrame:FindFirstChild(tostring(CurrentIndex))
		SlotObject.Button.Text = SlotValue
		
		--- magic
		if IsMagicSkill(SlotObject.Button.Text) then
			SlotObject.Button.TextColor3 = BackpackConfiguration.MagicTextColor.Value
		else
			SlotObject.Button.TextColor3 = BackpackConfiguration.DefaultTextColor.Value
		end
		
		-- resetting
		if SlotConnections[SlotObject] then
			SlotConnections[SlotObject]:Disconnect()
			SlotConnections[SlotObject] = nil
		end
		SlotObject.Quantity.Visible = false

		local ItemInfo = ShopItems[SlotValue]
		if ItemInfo then
			if ItemInfo.CAN_DROP then
				SlotObject.Quantity.Visible = true

				local Category = ItemInfo.Category
				local FoundCategory = PlayerData.Items:FindFirstChild(Category)

				if FoundCategory then
					local FoundItem = FoundCategory:FindFirstChild(SlotValue)
					if FoundItem then
						SlotObject.Quantity.Title.Text = FoundItem.Value
						SlotConnections[SlotObject] = FoundItem.Changed:Connect(function()
							SlotObject.Quantity.Title.Text = FoundItem.Value
						end)
					end
				end
			end
		end
	end
	UpdateSlotVisibility()

	Remotes.UpdateSlotData:FireServer(CurrentSlots)
end
local function CreateInventorySlot(Name)
	if InventoryFrame.List:FindFirstChild(Name) then
		return
	end

	local Clone = script.Template:Clone()

	-- Checking if is a magic
	--print(Name)
	if IsMagicSkill(Name) then
		Clone.Button.TextColor3 = BackpackConfiguration.MagicTextColor.Value
	else
		Clone.Button.TextColor3 = BackpackConfiguration.DefaultTextColor.Value
	end


	Clone.Name = Name
	Clone.Title.Visible = false

	Clone.Button.Text = Name
	Clone.Parent = InventoryFrame.List

	Clone.Button.MouseButton1Down:Connect(function()
		if DraggingObject ~= nil then
			return
		end

		DraggingObject = Name

		local OldPosition = UserInputService:GetMouseLocation()
		local NewPosition = Vector2.new()

		-- Setting New Values
		-- Setting New Values
		local DraggingClone = script.DraggingTemplate:Clone() --Clone:Clone()
		DraggingClone.Parent = DraggingFrame

		-- Setting Properties
		DraggingClone.Name = Clone.Name
		DraggingClone.Title.Text = Clone.Title.Text
		DraggingClone.Button.Text = Clone.Button.Text
		DraggingClone.Button.UIStroke.Transparency = Clone.Button.UIStroke.Transparency

		if IsMagicSkill(DraggingClone.Button.Text) then
			DraggingClone.Button.TextColor3 = BackpackConfiguration.MagicTextColor.Value
		else
			DraggingClone.Button.TextColor3 = BackpackConfiguration.DefaultTextColor.Value
		end

		while true do
			if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
				break
			end
			if DraggingObject == nil then
				break
			end

			local MouseLocation = UserInputService:GetMouseLocation()
			DraggingClone.Position = UDim2.new(0,MouseLocation.X,0,MouseLocation.Y)

			task.wait()
		end

		NewPosition = UserInputService:GetMouseLocation()
		-- Destroying
		DraggingClone:Destroy()
		DraggingObject = nil

		local SwapObject = GetSwapObject({Clone})
		--warn(SwapObject)

		if SwapObject ~= nil then
			--print("Change ".. Name.." with ".. SwapObject.Name..".")

			local TargetSlotNumber = nil
			for n,v in pairs(StringToNumber) do
				if v == SwapObject.Name then
					TargetSlotNumber = table.find(Order, n)
					break
				end
			end 

			if TargetSlotNumber then
				-- Put into InventoryFrame
				if SelectedObject == Order[TargetSlotNumber] then
					SelectedObject = nil
					UpdateSelectedSlot()
					-- deslecting beause moving to inventory frame
				end

				local ItemName = CurrentSlots[TargetSlotNumber]

				if ItemName ~= "" then
					-- making sure that slot isnt empty
					CurrentSlots[TargetSlotNumber] = ""
					CreateInventorySlot(ItemName)
				end

				-- Changing currentslot
				CurrentSlots[TargetSlotNumber] = Clone.Name
				Clone:Destroy()

				UpdateSlots()
			end

		end
	end)
end
local function PutIntoInventoryFrame(SlotNumber)
	if SelectedObject == Order[SlotNumber] then
		SelectedObject = nil
		UpdateSelectedSlot()
		-- deslecting beause moving to inventory frame
	end

	local ItemName = CurrentSlots[SlotNumber]

	CurrentSlots[SlotNumber] = ""
	CreateInventorySlot(ItemName)
	UpdateSlots()
end
local function FillInSlot(SlotNumber, NewValue)
	CurrentSlots[SlotNumber] = NewValue
	UpdateSlots()
end
local function SwapSlot(Slot, Target)
	local SlotValue = CurrentSlots[Slot]
	local TargetSlotValue = CurrentSlots[Target]

	CurrentSlots[Slot] = TargetSlotValue
	CurrentSlots[Target] = SlotValue

	if table.find(Order, SelectedObject) == Slot then
		SelectedObject = TargetSlotValue
		UpdateSelectedSlot()
	end

	UpdateSlots()
end

UserInputService.InputBegan:Connect(function(Input, Processed)
	if Processed then
		return
	end
	if Input.KeyCode == Enum.KeyCode.Backquote then
		if TweeningInventory then
			return
		end
		InventoryOpen = not InventoryOpen
		TweeningInventory = true

		task.delay(.3, function()
			TweeningInventory = false
		end)
		if InventoryOpen then
			InventoryFrame:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
		else
			InventoryFrame:TweenPosition(UDim2.new(0.5,0,1.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
		end

		UpdateSlotVisibility()
	end

	-- KeyCode --
	if table.find(Order, Input.KeyCode.Name) then
		--print("Pressed Key: ".. Input.KeyCode.Name)

		if SlotIsEmpty(table.find(Order, Input.KeyCode.Name)) then
			return -- empty
		end

		local RealName = Input.KeyCode.Name
		if SelectedObject == RealName then
			-- Deselect
			SelectedObject = nil
		else
			SelectedObject = RealName
		end

		UpdateSelectedSlot()
	end
end)

-- Setting Up
for _,v in pairs(BackpackFrame:GetChildren()) do
	if v:IsA("ImageLabel") then
		v:Destroy()
	end
end
for i = 1, #Order do
	local Name = Order[i]

	local Clone = script.Template:Clone()
	Clone.Name = StringToNumber[Name]
	Clone.Title.Text = StringToNumber[Name]
	Clone.Parent = BackpackFrame
	Clone.Button.Text = ""

	if not Backpack:FindFirstChild(CurrentSlots[i]) then
		-- A bugged, happened, not in backpack
		CurrentSlots[i] = ""
	end

	local FoundSlot = CurrentSlots[i]
	if FoundSlot ~= "" then
		Clone.Button.Text = FoundSlot

		if IsMagicSkill(Clone.Button.Text) then
			Clone.Button.TextColor3 = BackpackConfiguration.MagicTextColor.Value
		else
			Clone.Button.TextColor3 = BackpackConfiguration.DefaultTextColor.Value
		end
	end

	-- Dragging Stuff
	Clone.Button.MouseButton1Down:Connect(function()
		if DraggingObject ~= nil then
			return
		end
		if SlotIsEmpty(i) then
			return
		end

		DraggingObject = Name

		local OldPosition = UserInputService:GetMouseLocation()
		local NewPosition = Vector2.new()

		-- Setting New Values
		local DraggingClone = script.DraggingTemplate:Clone() --Clone:Clone()
		DraggingClone.Parent = DraggingFrame

		-- Setting Properties
		DraggingClone.Name = Clone.Name
		DraggingClone.Title.Text = Clone.Title.Text
		DraggingClone.Button.Text = Clone.Button.Text

		if IsMagicSkill(DraggingClone.Button.Text) then
			DraggingClone.Button.TextColor3 = BackpackConfiguration.MagicTextColor.Value
		else
			DraggingClone.Button.TextColor3 = BackpackConfiguration.DefaultTextColor.Value
		end

		DraggingClone.Button.UIStroke.Transparency = Clone.Button.UIStroke.Transparency

		--DraggingClone.Size = UDim2.new(0.034,0,0.075,0)

		while true do
			if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
				break
			end
			if DraggingObject == nil then
				break
			end

			local MouseLocation = UserInputService:GetMouseLocation()
			DraggingClone.Position = UDim2.new(0,MouseLocation.X,0,MouseLocation.Y)

			task.wait()
		end

		NewPosition = UserInputService:GetMouseLocation()
		-- Destroying
		DraggingClone:Destroy()
		DraggingObject = nil

		--
		local Distance = (NewPosition.Magnitude-OldPosition.Magnitude)
		--print(Distance)

		-- Checking if can swap
		local SwapObject = GetSwapObject({Clone})
		--warn(SwapObject)

		if SwapObject ~= nil then
			--print("Swap ".. Name.." with ".. SwapObject.Name..".")

			local TargetSlotNumber = nil
			for n,v in pairs(StringToNumber) do
				if v == SwapObject.Name then
					TargetSlotNumber = table.find(Order, n)
					break
				end
			end

			if TargetSlotNumber then
				SwapSlot(i, TargetSlotNumber)
			end
		else
			-- Check if in BackpackFrame
			local MousePosition = UserInputService:GetMouseLocation()-game.GuiService:GetGuiInset()
			local ObjectsAtMouse = PlayerGui:GetGuiObjectsAtPosition(MousePosition.X, MousePosition.Y)

			local InInventory = false

			for index = 1,#ObjectsAtMouse do
				local o = ObjectsAtMouse[index]
				if o == InventoryFrame then
					InInventory = true
					break
				end
			end

			if InInventory then
				--	print("Put ".. Name.." to InventoryFrame")
				PutIntoInventoryFrame(i)
			end
		end

		if Distance >= 0 and Distance < 15 then
			if SelectedObject == Name then
				-- Deslect
				--print("Deselct Item")
				SelectedObject = ""
			else
				-- Select New Item
				SelectedObject = Name
			end
			UpdateSelectedSlot()
		end
	end)
end
UpdateSlotVisibility()
UpdateSlots()

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

-- Backpack Items
local BackpackChildren = Backpack:GetChildren()
for i = 1,#BackpackChildren do
	local Object = BackpackChildren[i]

	local Replicate = true
	if table.find(CurrentSlots, Object.Name) then
		-- Already there
		Replicate = false
	end
	for _,v in pairs(InventoryFrame.List:GetChildren()) do
		if v:IsA("ImageLabel") and v.Name == Object.Name then
			-- Already in the InventoryFrame
			Replicate = false
		end
	end

	-- Since not in CurrentSlots	
	--CreateInventorySlot(Object.Name)


	if Replicate then
		-- Put in InventoryFrame
		CreateInventorySlot(Object.Name)

		--[[
		local OpenSlot = GetOpenSlot()
		if OpenSlot == "" then
			-- Put in InventoryFrame
			CreateInventorySlot(Object.Name)
		else
			-- Fill In
			--print("Open Slot ".. OpenSlot, Object.Name)
			FillInSlot(tonumber(OpenSlot), Object.Name)
		end
		]]--
	end

end

Character.ChildAdded:Connect(function(Child)
	if not Child:IsA("Tool") then
		return
	end
	if table.find(CurrentSlots, Child.Name) then
		local Index = table.find(CurrentSlots, Child.Name)

		SelectedObject = Order[Index]
		UpdateSelectedSlot()
	end
end)
Character.ChildRemoved:Connect(function(Child)
	if not Child:IsA("Tool") then
		return
	end

	if table.find(CurrentSlots, Child.Name) then
		local Index = table.find(CurrentSlots, Child.Name)

		if SelectedObject == Order[Index] then
			SelectedObject = nil
			UpdateSelectedSlot()
		end
	end

	-- Checking if back in the Backpack
	local foundInBackpack = Backpack:FindFirstChild(Child.Name)
	if foundInBackpack and foundInBackpack:IsA("Tool") then
	else
		-- not in backpack, was destroyed
		local SlotIndex = table.find(CurrentSlots, Child.Name)
		if SlotIndex then
			CurrentSlots[SlotIndex] = ""

			if SelectedObject == StringToNumber[Order[SlotIndex]] then
				SelectedObject = nil
			end
			UpdateSelectedSlot()
			UpdateSlots()
			UpdateSlotVisibility()
		else
			-- Finding in InventoryFrame
			local FoundObject = InventoryFrame.List:FindFirstChild(Child.Name)
			if FoundObject then
				if DraggingObject == FoundObject.Name then
					DraggingObject = nil
				end
				FoundObject:Destroy()
			end
		end
	end
end)
Backpack.ChildAdded:Connect(function(Child)
	if not Child:IsA("Tool") then
		return
	end

	local Replicate = true
	if table.find(CurrentSlots, Child.Name) then
		-- Already there
		Replicate = false
	end
	for _,v in pairs(InventoryFrame.List:GetChildren()) do
		if v:IsA("ImageLabel") and v.Name == Child.Name then
			-- Already in the InventoryFrame
			Replicate = false
		end
	end

	if Replicate then
		local OpenSlot = GetOpenSlot()
		if OpenSlot == "" then
			-- Put in InventoryFrame
			CreateInventorySlot(Child.Name)
		else
			-- Fill In
			--print("Open Slot ".. OpenSlot, Child.Name)
			FillInSlot(tonumber(OpenSlot), Child.Name)
		end
	end
end)
Backpack.ChildRemoved:Connect(function(Child)
	if not Child:IsA("Tool") then
		return
	end

	-- Finding Child in Character
	local Object = nil
	for _,v in pairs(Character:GetChildren()) do
		if v:IsA("Tool") and v.Name == Child.Name then
			Object = v
			break
		end
	end

	if Object then
	else
		-- Was Removed
		--	warn("test?")
		local SlotIndex = table.find(CurrentSlots, Child.Name)
		if SlotIndex then
			CurrentSlots[SlotIndex] = ""

			if SelectedObject == StringToNumber[Order[SlotIndex]] then
				SelectedObject = nil
			end
			UpdateSelectedSlot()
			UpdateSlots()
			UpdateSlotVisibility()
		else
			-- Finding in InventoryFrame
			local FoundObject = InventoryFrame.List:FindFirstChild(Child.Name)
			if FoundObject then
				if DraggingObject == FoundObject.Name then
					DraggingObject = nil
				end
				FoundObject:Destroy()
			end
		end
	end
end)