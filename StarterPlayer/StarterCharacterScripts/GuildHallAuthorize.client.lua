-- Guild Hall Authorizer

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Character = script.Parent
local Player = Players:GetPlayerFromCharacter(Character)

local PlayerData = Player:WaitForChild("Data", 999)
local Level = PlayerData.Level

local PlayerGui = Player:WaitForChild("PlayerGui", 999)
local RootPart = Character:WaitForChild("HumanoidRootPart", 999)

-- Try
local Tries = 0; local MaxTries = 6
local Place = workspace:WaitForChild("Place", 999)
local GuildHall = nil
for i = 1, MaxTries do
	Tries += 1
	
	local found = workspace:FindFirstChild("GuildHall")
	if found then
		GuildHall = found
		break
	end
end

if not GuildHall then
	warn("[GuildHallAuthorize] Could not find GuildHall in Place folder.")
	return
end
local GuildCollidePart = workspace:WaitForChild("MouseIgnore"):WaitForChild("GuildCollide", 999)

local CF, Size = GuildHall:GetBoundingBox()
--
local PreviousRemoval = os.clock()
local RemovalCooldown = 1
local MinimumLevel = 10

-- Main
GuildCollidePart.Touched:Connect(function(hit)
	if hit.Parent and hit.Parent == Character then
		if Level.Value >= MinimumLevel then
			-- Turn off Collide
			GuildCollidePart.CanCollide = false
		else
			GuildCollidePart.CanCollide = true
			if os.clock() - (PreviousRemoval or 0) > RemovalCooldown then
				PreviousRemoval = os.clock()
				pcall(function()
					PlayerGui.Notifications.Notify:Fire("You need to be at least E-Rank to enter...", 5)
				end)
			end
		end
	end
end)

-- Extra
RunService.RenderStepped:Connect(function()
	local Magnitude = (CF.Position - RootPart.Position).Magnitude
	
	if Level.Value < MinimumLevel then
		-- Not E-Rank Yet
		if Magnitude <= 104 then
			-- Kick Out
			Character:SetPrimaryPartCFrame(CFrame.new(1034.321, 74.479, -192.431))
			if os.clock() - (PreviousRemoval or 0) > RemovalCooldown then
				PreviousRemoval = os.clock()
				pcall(function()
					PlayerGui.Notifications.Notify:Fire("You need to be at least E-Rank to enter...", 5)
				end)
			end
		end
	end
end)