-- Client Effects

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local EffectsFolder = Modules.Client.Effects

local StoredModules = {}

Remotes.ClientFX.OnClientEvent:Connect(function(Action, TableData)
	if type(TableData) ~= "table" then return end
	if StoredModules[Action] then
		StoredModules[Action](TableData)
	end
end)

for _,module in pairs(EffectsFolder:GetChildren()) do
	if module:IsA("ModuleScript") then
		StoredModules[module.Name] = require(module)
	end
end