-- Get Mouse

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local GetMouse = Remotes.GetMouse

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

GetMouse.OnClientInvoke = function(Distance, IgnoreListExtra, NoAliveInList)
	local Distance = Distance or 5000
	local IgnoreList = { Player.Character, workspace.CurrentCamera, workspace.Live }

	if NoAliveInList then IgnoreList[3] = nil end
	if IgnoreListExtra and typeof(IgnoreListExtra) and #IgnoreListExtra > 0 == 'table' then table.foreach(IgnoreListExtra, function(i, v) table.insert(IgnoreList, v) end) end

	local Ray = Ray.new(Mouse.UnitRay.Origin, Mouse.UnitRay.Direction * Distance)
	local Hit, Position, Normal, Material

	while true do
		Hit, Position, Normal, Material = workspace:FindPartOnRayWithIgnoreList(Ray, IgnoreList)

		if Hit and (Hit.Transparency >= 1 or not Hit.CanCollide) then
			IgnoreList[#IgnoreList + 1] = Hit
		else
			break
		end
	end

	return Hit, Position, Normal, Material, Ray
end
Remotes.GetMousePos.OnClientInvoke = function()
	return Mouse.Hit.Position
end