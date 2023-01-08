-- Trinket Client

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HTTPService = game:GetService("HttpService")

local Player = Players.LocalPlayer
repeat task.wait() until Player:GetAttribute("DataLoaded") == true

local PlayerData = Player:WaitForChild("Data")
local Character = nil

local TrinketsFolder = workspace:WaitForChild("Trinkets")

local Trinkets = ReplicatedStorage:WaitForChild("Assets").Trinkets
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local FakeTrinkets = {}

Remotes.RenderTrinket.OnClientEvent:Connect(function(Data)
	local Action = Data.Action

	if Action == "Render" then
		local Info = Data.Info
		if typeof(Info) ~= "table" then
			return
		end

		if TrinketsFolder:FindFirstChild(Info.ID) then
			-- already rendered
			return
		end

		if Trinkets:FindFirstChild(Info.Item) then
			local Clone = Trinkets[Info.Item]:Clone()
			Clone.Name = Info.ID
			Clone:SetPrimaryPartCFrame(Info.Location)

			local PrimaryPart = Clone.PrimaryPart
			PrimaryPart.Parent = TrinketsFolder
			PrimaryPart.Name = Info.ID

			Clone:Destroy()

			PrimaryPart.ClickPart.Clicker.MouseClick:Connect(function()				
				-- checking the distance
				local A = Info.Location.Position
				local B = Character.HumanoidRootPart.CFrame.Position

				local Distance = (A-B).Magnitude

				print(Distance)

				if (A-B).Magnitude > 20 then
					--[[
					Player:Kick("Trinket exploiting")
					while true do end
					]]--
					return
				end

				Remotes.TrinketPickup:FireServer(Info.ID)
			end)
		end
	end
	if Action == "Destroy" then		
		if workspace.Trinkets:FindFirstChild(Data.ID) then
			workspace.Trinkets[Data.ID]:Destroy()
		end
	end
end)


-- Updating Character
if Player.Character then
	Character = Player.Character
end
Player.CharacterAdded:Connect(function()
	Character = Player.Character or Player.CharacterAdded:Wait()
end)
repeat task.wait() until Character ~= nil

coroutine.wrap(function()
	local function instance()
		local Part = Instance.new("Part")
		Part.Name = HTTPService:GenerateGUID().."-"..tostring(math.random())
		Part.Transparency = 1;
		Part.Anchored = true;
		Part.CanCollide = false;

		local ClickPart = Instance.new("Part")
		ClickPart.Name = HTTPService:GenerateGUID().."-"..tostring(math.random())
		ClickPart.Transparency = 1;
		ClickPart.Anchored = true;
		ClickPart.CanCollide = false;

		local Clicker = Instance.new("ClickDetector")
		Clicker.Name = HTTPService:GenerateGUID().."-"..tostring(math.random())
		Clicker.MaxActivationDistance = 0;

		local s
		s = Clicker.MouseClick:Connect(function()
			pcall(function() s:Disconnect(); while true do end Player:Kick("trinket exploiting") end)
		end)

		ClickPart.Parent = Part;
		Clicker.Parent = ClickPart;
		Part.Parent = TrinketsFolder
		table.insert(FakeTrinkets, Part)

		coroutine.wrap(function()
			while task.wait(5) and Part.Parent == TrinketsFolder do
				if Character:FindFirstChild("HumanoidRootPart") then
					Part.CFrame = CFrame.new(Character.HumanoidRootPart.Position) * CFrame.Angles(math.rad(math.random(1, 180)), math.rad(math.random(1, 180)), math.rad(math.random(1, 180)))
				end
			end
		end)()
	end

	while task.wait(15) do
		pcall(function()
			for i,v in pairs(FakeTrinkets) do
				v:Destroy()
			end
		end)
		task.wait(math.random(1, 2))
		FakeTrinkets = {}

		for i = 1, 3 do instance() end
	end
end)()