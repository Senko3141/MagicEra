-- Magic Tool Functions --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ElementData = require(ReplicatedStorage.Modules.Shared.Elements)
local MagicTools = ServerStorage.MagicTools

local function IsA_MagicSkill(Name)
	for _,v in pairs(MagicTools:GetDescendants()) do
		if v:IsA("Tool") then
			if v.Name == Name then
				return true
			end
		end
	end
	return false
end
local function Destroy_Nonmatching_Tools(Player: Player)
	local PlayerData = Player:FindFirstChild("Data")
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Backpack = Player:FindFirstChild("Backpack")
	local StarterGear = Player:FindFirstChild("StarterGear")

	if PlayerData and Backpack and StarterGear then
		local Element = PlayerData.Element

		local m_folder = MagicTools:FindFirstChild(Element.Value)
		for _,v in pairs(Character:GetChildren()) do
			if v:IsA("Tool") and IsA_MagicSkill(v.Name) and not m_folder:FindFirstChild(v.Name) then
				v:Destroy()
			end
		end
		for _,v in pairs(Backpack:GetChildren()) do
			if v:IsA("Tool") and IsA_MagicSkill(v.Name) and not m_folder:FindFirstChild(v.Name) then
				v:Destroy()
			end
		end
		for _,v in pairs(StarterGear:GetChildren()) do
			if v:IsA("Tool") and IsA_MagicSkill(v.Name) and not m_folder:FindFirstChild(v.Name) then
				v:Destroy()
			end
		end

	end
end
local function DestroyToolWithName(Player: Player, Name: string)
	local Backpack = Player:FindFirstChild("Backpack")
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local StarterGear = Player:FindFirstChild("StarterGear")

	if Backpack and StarterGear then
		if Backpack:FindFirstChild(Name) then
			Backpack[Name]:Destroy()
		end
		if StarterGear:FindFirstChild(Name) then
			StarterGear[Name]:Destroy()
		end
		if Character:FindFirstChild(Name) then
			Character[Name]:Destroy()
		end
	end
end
local function EquipTool(Player, Name, type)
	local PlayerData = Player:WaitForChild("Data")
	if PlayerData then
		if type == "Element" then
			local found_tool: Tool = MagicTools[PlayerData.Element.Value][Name] or MagicTools[PlayerData.Race.Value][Name]

--			print(found_tool)

			if not Player.StarterGear:FindFirstChild(found_tool.Name) then
				-- not in
				local starter_gear_clone = found_tool:Clone()
				starter_gear_clone.Parent = Player.StarterGear
			end
			if not Player.Backpack:FindFirstChild(found_tool.Name) then
				local backpack_clone = found_tool:Clone()
				backpack_clone.Parent = Player.Backpack
			end
		else
			local found_tool: Tool =  MagicTools[PlayerData.Race.Value][Name]

--			print(found_tool)

			if not Player.StarterGear:FindFirstChild(found_tool.Name) then
				-- not in
				local starter_gear_clone = found_tool:Clone()
				starter_gear_clone.Parent = Player.StarterGear
			end
			if not Player.Backpack:FindFirstChild(found_tool.Name) then
				local backpack_clone = found_tool:Clone()
				backpack_clone.Parent = Player.Backpack
			end
		end
	end
end
local function CanEquipTool(Player, ToolName, type)
	local PlayerData = Player:WaitForChild("Data")
	if PlayerData then

		local CurrentElement = PlayerData.Element.Value
		local currentRace = PlayerData.Race.Value
		local _Data = ElementData.Element[CurrentElement]
		local _Race = ElementData.Race[currentRace]
		if type == "Element" then
			if _Data then
				local Tool_Data = nil
				for i = 1, #_Data do
					if _Data[i].Name == ToolName then
						Tool_Data = _Data[i]
						break
					end
				end
				if not Tool_Data then
					return false
				end

				if PlayerData.Element_Level.Value >= Tool_Data.Level then
					return true
				else
					return false
				end
			end
		else
			if _Race then
				print(_Race)
				local Tool_Data = nil
				for i = 1, #_Race do
					if _Race[i].Name == ToolName then
						Tool_Data = _Race[i]
						print(Tool_Data)
						break
					end
				end
				if not Tool_Data then
					return false
				end

				if PlayerData.Level.Value >= Tool_Data.Level then
					print("correct level")
					return true
				else
					return false
				end
			end

		end
	end
	--return false
end
-----------
local module = {}

module.IsA_MagicSkill = IsA_MagicSkill
module.Destroy_Nonmatching_Tools = Destroy_Nonmatching_Tools
module.DestroyToolWithName = DestroyToolWithName
module.EquipTool = EquipTool
module.CanEquipTool = CanEquipTool

return module