-- Backpack System

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes

Remotes.UpdateSlotData.OnServerEvent:Connect(function(Player, Data)
	if typeof(Data) ~= "table" or #Data > 10 then
		return
	end
	
	
	local PlayerData = Player:FindFirstChild("Data")
	if PlayerData then
		local BackpackSlots = PlayerData:FindFirstChild("BackpackSlots")
		if BackpackSlots then
			for i = 1,10 do
				BackpackSlots[tostring(i)].Value = Data[i]
			end
		end
	end
end)
Remotes.GetSlots.OnServerInvoke = function(Player, Data)
	local PlayerData = Player:FindFirstChild("Data")
	
	if PlayerData then
		local BackpackSlots = PlayerData:FindFirstChild("BackpackSlots")
		if BackpackSlots then
			local Slots = {}
			for i = 1, #BackpackSlots:GetChildren() do
				local Slot = BackpackSlots:FindFirstChild(tostring(i))
				if Slot then
					Slots[i] = Slot.Value
				end
			end
			return Slots
		end
	end	
	
	return nil
end