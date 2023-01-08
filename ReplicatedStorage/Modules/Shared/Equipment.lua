local module = {}








module.EquipArmor = function(player,Tool)
	local tools = game.ServerStorage.Tools
	if player then
		local Character = player.Character
		local PlayerData = player:FindFirstChild("Data")
		if PlayerData then
			if player:FindFirstChild("InCombat") then
				game.ReplicatedStorage.Remotes.Notify:FireClient(player, "You cannot change equipment in combat.", 3)
				return
			end
			if PlayerData.Equipment.Value ~= nil or "" then
				local equipmentToGive = tools:FindFirstChild(PlayerData.Equipment.Value)
				if equipmentToGive then
					local givenitem = player.Data.Items.Equipments:FindFirstChild(PlayerData.Equipment.Value)
					if givenitem then
						givenitem.Value += 1
					else
						local NewValue = Instance.new("IntValue")
						NewValue.Name = PlayerData.Equipment.Value
						NewValue.Value = 1
						NewValue.Parent = player.Data.Items.Equipments
					end
				end
			end

			PlayerData.Equipment.Value = Tool.Name
			----
			PlayerData.Items.Equipments[Tool.Name].Value -= 1		
		end
	end
end


module.EquipWeapon = function(player, tool, bypassInCombat)
	local tools = game.ServerStorage.Tools
	if player then
		if player:FindFirstChild("InCombat") and not bypassInCombat then
			game.ReplicatedStorage.Remotes.Notify:FireClient(player, "You cannot change equipment in combat.", 3)
			return
		end
		local character = player.Character
		local data = player:FindFirstChild("Data")
		local weapons = data.Items.Weapons
		if data then
			local weapon = data:FindFirstChild("Weapon")
			
			
			local potentialWeapon = player.Backpack:FindFirstChild(weapon.Value) or character:FindFirstChild(weapon.Value)
			local currentWeapon = nil
			for i,v in pairs(potentialWeapon:GetChildren()) do
				if v.Parent:FindFirstChild("CanDrop") == nil then
					currentWeapon = v.Parent
				end
			end

			print(currentWeapon)
			print(potentialWeapon)
			if currentWeapon == nil and data.Items.Weapons:FindFirstChild(tool.Name).Value > 0 then
				print(tool)
				tool:Destroy()
				local newTool = game.ServerStorage.Weapons[tool.Name]:clone()
				newTool.Parent = player.Backpack
				weapon.Value = newTool.Name
				--data.Items.Weapons:FindFirstChild(tool.Name).Value -= 1
			elseif currentWeapon ~= nil and data.Items.Weapons:FindFirstChild(tool.Name).Value > 0 then
				if character:FindFirstChild(weapon.Value.."_Back") ~= nil then
					character:FindFirstChild(weapon.Value.."_Back"):Destroy()
				elseif character:FindFirstChild(weapon.Value.."_Main") ~= nil then
					character:FindFirstChild(weapon.Value.."_Main"):Destroy()
				end
				currentWeapon:Destroy()
				tool:Destroy()
				if currentWeapon.Name ~= "Combat" then
					local equippableTool = tools[currentWeapon.Name]:clone()
					equippableTool.Parent = player.Backpack
				end
				local newTool = game.ServerStorage.Weapons[tool.Name]:clone()
				newTool.Parent = player.Backpack
				weapon.Value = newTool.Name
			--[[elseif weapon ~= nil and weapon.Value ~= tool.Name and weapon.Value ~= "Combat" and weapon.Value ~= "" then
				
				
				currentWeapon:Destroy()
				tool:Destroy()
				local equippableTool = tools[tool.Name]:clone()
				equippableTool.Parent = player.Backpack
				local newTool = game.ServerStorage.Weapons[tool.Name]:clone()
				newTool.Parent = player.Backpack--]]
			end
		end
	end
end

module.RemoveWeapon = function(player)
	local character = player.Character
	local data = player.Data
	local weapon = data.Weapon
	
	local potentialWeapon = player.Backpack:FindFirstChild(weapon.Value) or character:FindFirstChild(weapon.Value) or nil
	if potentialWeapon ~= nil then
		if character:FindFirstChild(weapon.Value.."_Back") ~= nil then
			character:FindFirstChild(weapon.Value.."_Back"):Destroy()
		elseif character:FindFirstChild(weapon.Value.."_Main") ~= nil then
			character:FindFirstChild(weapon.Value.."_Main"):Destroy()
		end
		for i,v in pairs(data:GetDescendants()) do
			if v.Name == weapon.Value then
				v:Destroy()
			end
		end
		potentialWeapon:Destroy()
		local newTool = game.ServerStorage.Weapons["Combat"]:clone()
		newTool.Parent = player.Backpack
		weapon.Value = newTool.Name
	end
	
	
end






return module
