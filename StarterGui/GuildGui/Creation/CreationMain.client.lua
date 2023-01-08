-- Creation Main

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlayerData = Player:WaitForChild("Data")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Root = script.Parent

local Finish = Root:WaitForChild("Finish")
local Close = Root:WaitForChild("Close")
local GuildName = Root:WaitForChild("GuildName")
local GuildColor = Root:WaitForChild("GuildColor")
local ColorVisual = Root:WaitForChild("ColorVisual")

local NotifyEvent = script.Parent.Parent.Parent:WaitForChild("Notifications"):WaitForChild("Notify")

local IsPending = false

Close.MouseButton1Click:Connect(function()
	Root:TweenPosition(UDim2.new(0.5,0,-0.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
end)

local function getRGB(str)
	local splitted = str:split(",")

	local r = splitted[1]
	local g = splitted[2]
	local b = splitted[3]

	if tonumber(r) and tonumber(g) and tostring(b) then
		local toRGB = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
		if toRGB then
			return toRGB
		end
	end
	return nil
end

GuildColor:GetPropertyChangedSignal("Text"):Connect(function()
	local toRGB = getRGB(GuildColor.Text)
	if toRGB then
		ColorVisual.BackgroundColor3 = toRGB
	end
end)

local PreviousClick = os.clock()
local CickCooldown = 1

Finish.MouseButton1Click:Connect(function()
	if string.len(GuildName.Text) <= 1 then
		return
	end
	if not getRGB(GuildColor.Text) then
		return
	end
	
	if PlayerData.Guild.Value ~= "" then
		return -- already in a guild
	end
	if os.clock() - (PreviousClick or 0) < CickCooldown then
		return
	end
	
	PreviousClick = os.clock()
		
	Remotes.Guild:FireServer("Create", {
		["Name"] = GuildName.Text,
		["Color"] = getRGB(GuildColor.Text)
	})
end)