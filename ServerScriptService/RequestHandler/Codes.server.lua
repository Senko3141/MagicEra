-- Codes System

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes
local Modules = ReplicatedStorage.Modules

local CodesModule = require(Modules.Shared.Codes)

local ValidTypes = {
	["Claim"] = true,
}

Remotes.Codes.OnServerEvent:Connect(function(Player, Action, Data)
	if not ValidTypes[Action] then
		return
	end
	if typeof(Data) ~= "table" then
		return
	end	
	local PlayerData = Player:FindFirstChild("Data")
	if not PlayerData then return end

	if Action == "Claim" then
		local CodeName = Data.CodeName
		if not CodeName then
			Remotes.Notify:FireClient(Player, 
				'<font color="rgb(0, 150, 255)">[CODES]</font> INVALID CODE',
				5
			)
			return
		end

		local CodeInfo = CodesModule[CodeName]
		if not CodeInfo then 
			Remotes.Notify:FireClient(Player, 
				'<font color="rgb(0, 150, 255)">[CODES]</font> INVALID CODE ['.. tostring(CodeName).."]",
				5
			)
			return 
		end

		if PlayerData.Codes:FindFirstChild(CodeInfo.Name) then
			-- Already Claimed
			Remotes.Notify:FireClient(Player, 
				'<font color="rgb(0, 150, 255)">[CODES]</font> You have already claimed this code! ['.. CodeInfo.Name.."]",
				5
			)
			return
		end

		-- Not Claimed Yet
		local Response = CodeInfo.ClaimFunc(Player, PlayerData)
		if Response then
			local NewInstance = Instance.new("Folder")
			NewInstance.Name = CodeInfo.Name
			NewInstance.Parent = PlayerData.Codes
			-- Notify
			Remotes.Notify:FireClient(Player, 
				'<font color="rgb(0, 150, 255)">[CODES]</font> Successfully claimed code! ['.. CodeInfo.Name.."]",
				5,
				{Confetti = true}
			)

		end
		----
	end
end)