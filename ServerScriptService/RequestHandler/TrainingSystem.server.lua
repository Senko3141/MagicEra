-- Trainings System

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes
local Modules = ReplicatedStorage.Modules

Remotes.Training.OnServerEvent:Connect(function(Player, Action, Data)
	local Character = Player.Character
	local StatusFolder = Character:FindFirstChild("Status")
	
	if not StatusFolder then return end
	
	if Action == "InputKey" then
		local DoingTraining = StatusFolder:FindFirstChild("DoingTraining")
		if not DoingTraining then
			return
		end
		
		local Key = Data.Key
		if Key then
			DoingTraining.InputKey:Fire(Player, Key)
		end
	end
end)