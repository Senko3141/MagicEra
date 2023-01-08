-- Drop System

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local PlayerData = Player:WaitForChild("Data")

local LastEquipped = nil
local CurrentTarget = nil

local PreviousDrop = nil
local DropCooldown = 2

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Modules = ReplicatedStorage:WaitForChild("Modules")

local ShopItems = require(Modules.Shared.Items)

local NotifyEvent = script.Parent.Parent:WaitForChild("Notifications"):WaitForChild("Notify")
local Root = script.Parent:WaitForChild("Root")

local ConfirmationFrame = Root.Confirmation

Player.Character.ChildAdded:Connect(function(Child)
	if Child.ClassName == 'Tool' then
		LastEquipped = Child
	end
end)
Player.Character.ChildRemoved:Connect(function(Child)
	if Child == LastEquipped and task.wait() and LastEquipped == Child then -- shutup
		LastEquipped = nil
	end
end)

ContextActionService:BindAction('DropItem', function(Action, State, Object)
	if State == Enum.UserInputState.Begin then
		if not LastEquipped then
			return
		end
		warn(LastEquipped)
		
		local ItemInfo = ShopItems[LastEquipped.Name]
		
		if ItemInfo then
			if not ItemInfo.CAN_DROP or not LastEquipped:FindFirstChild("CanDrop") then
				NotifyEvent:Fire("You cannot drop this item.", 4)
				return
			end
			if os.clock() - (PreviousDrop or 0) < DropCooldown then
				local TimeLeft = DropCooldown - (os.clock() - (PreviousDrop or 0))
				TimeLeft = string.format("%0.1f", TimeLeft)

				NotifyEvent:Fire("Please wait ".. TimeLeft.."s before attempting to drop another item.")
				return
			end
			
			ConfirmationFrame:TweenPosition(UDim2.new(0.5,0,0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			
			CurrentTarget = LastEquipped
			ConfirmationFrame.Title.Text = "How much of ["..CurrentTarget.Name.."] would you like to drop?"
		else
			NotifyEvent:Fire("You cannot drop this item.", 4)
		end
	end
end, true, Enum.KeyCode.Backspace)

local function reset_ui()
	ConfirmationFrame:TweenPosition(UDim2.new(0.5,0,-0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
	ConfirmationFrame.Title.Text = "How much of [--] would you like to drop?"	
end
ConfirmationFrame.No.Main.MouseButton1Click:Connect(function()
	reset_ui()
	CurrentTarget = nil
end)
ConfirmationFrame.Yes.Main.MouseButton1Click:Connect(function()
	if CurrentTarget ~= nil then
		local ItemInfo = ShopItems[CurrentTarget.Name]
		
		if ItemInfo then
			if not ItemInfo.CAN_DROP then
				return
			end
			if ItemInfo.MAX_DROP_COUNT == nil then
				return
			end
			
			local Amount = tonumber(ConfirmationFrame.Amount.Text)
			if not Amount then
				NotifyEvent:Fire("Please specify a valid integer of how much you want to drop.", 4)
				return
			end
			if Amount < 1 then
				NotifyEvent:Fire("The amount to drop must be greater than 1.", 4)
				return
			end
			if Amount%1 > 0 then
				-- Decimal
				NotifyEvent:Fire("The amount to drop cannot be a decimal.", 4)
				return
			end
			if Amount ~= Amount then
				return
			end
			if Amount > ItemInfo.MAX_DROP_COUNT then
				NotifyEvent:Fire("You can only drop [".. ItemInfo.MAX_DROP_COUNT.."] of this item at a time.", 4)
				return
			end
			if os.clock() - (PreviousDrop or 0) < DropCooldown then
				local TimeLeft = DropCooldown - (os.clock() - (PreviousDrop or 0))
				TimeLeft = string.format("%0.1f", TimeLeft)
				
				NotifyEvent:Fire("Please wait ".. TimeLeft.."s before attempting to drop another item.")
				return
			end
			
			-- Checking Type, and if player has in inventory --
			local FoundCategory = PlayerData.Items:FindFirstChild(ItemInfo.Category)
			if not FoundCategory then
				return
			end
			if FoundCategory[ItemInfo.Name].Value < Amount then
				NotifyEvent:Fire("You do not have enough of ["..ItemInfo.Name.."] to drop this amount.", 4)
				return
			end
			
			Remotes.Drop:FireServer({
				["Item"] = CurrentTarget,
				["Amount"] = Amount
			})
			CurrentTarget = nil
			PreviousDrop = os.clock()		
			
			reset_ui()
		end
	end
end)