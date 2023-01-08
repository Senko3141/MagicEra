local MainFrame = script.Parent:WaitForChild("MainFrame")
local ScrollingFrame = MainFrame:WaitForChild("ScrollingFrame", 1)
local UILL = ScrollingFrame:WaitForChild("UIListLayout", 1)
local PlayerFrame = script:WaitForChild("PlayerFrame", 1)
local StarterGui = game:GetService("StarterGui")

local Debounce = false
local Players = {}

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

UILL.Changed:Connect(function(Property)
	if not Property == "AbsoluteContentSize" then return end
	local Y = UILL.AbsoluteContentSize.Y
	MainFrame.Visible = Y > 0
	MainFrame.Size = UDim2.new(0.02, 200, 0, (math.min(Y + 20, 400)))
	ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, Y)
end)

local function UpdatePlayerFrames()
	if Debounce then return end
	Debounce = true

	local ToSort = {}

	for _, Player in next, game.Players:GetPlayers() do
		if Players[Player] then			
			local PlayerData = Player:FindFirstChild("Data")
			if PlayerData and PlayerData:FindFirstChild("FirstName") then
				table.insert(ToSort, Player)
			end
		end
	end

	table.sort(ToSort, function(I1, I2)
		if not I1 then
			return true
		end
		if not I2 then
			return false
		end
		local I1Guild = I1.Data.Guild.Value
		local I2Guild = I2.Data.Guild.Value
		if I1Guild ~= "" and I2Guild == "" then
			return true
		end
		if I1Guild == "" and I2Guild ~= "" then
			return false
		end
		if I1Guild ~= I2Guild then
			return I1Guild < I2Guild
		end
		local I1FirstName = I1.Data.FirstName.Value
		local I2FirstName = I2.Data.FirstName.Value
		if I1FirstName ~= I2FirstName then
			return I1FirstName < I2FirstName
		end
		local I1LastName = I1.Data.FirstName.Value
		local I2LastName = I2.Data.LastName.Value
		if I1LastName ~= "" and I2LastName == "" then
			return true
		end
		if I1LastName == "" and I2LastName ~= "" then
			return false
		end
		if I1LastName ~= I2LastName then
			return I1LastName < I2LastName
		end
		return I1.Name < I2.Name
	end)

	for Index, Player in next, ToSort do
		local PlayerFrame = Players[Player]
		PlayerFrame.LayoutOrder = Index
		PlayerFrame.Visible = true
	end
	Debounce = false
end

local function AddPlayerFrame(Player)
	if Players[Player] then
		return
	end

	Players[Player] = true

	local PlayerFrameClone = PlayerFrame:Clone()
	Players[Player] = PlayerFrameClone

	local Guild = Player:WaitForChild("Data").Guild.Value


	PlayerFrameClone.Guild.Text = Guild ~= "" and "<i>[".. Guild.."]</i>" or PlayerFrameClone.Guild.Text
	PlayerFrameClone.Guild.Visible = Guild ~= ""
	PlayerFrameClone.Size = UDim2.new(1, 0, 0, Guild ~= "" and 30 or 20)

	PlayerFrameClone.Player.Text = "["..Player.Data.Rank.."-Class] ".. Player.Data.FirstName.Value.. " "..Player.Data.LastName.Value


	PlayerFrameClone.MouseEnter:Connect(function()
		PlayerFrameClone.Player.Text = Player.Name
		PlayerFrameClone.Player.TextTransparency = 0.3
		PlayerFrameClone.Guild.TextTransparency = 0.3
	end)

	PlayerFrameClone.MouseLeave:Connect(function()
		PlayerFrameClone.Player.Text = Player.DisplayName
		PlayerFrameClone.Player.TextTransparency = 0
		PlayerFrameClone.Guild.TextTransparency = 0
	end)

	PlayerFrameClone.Parent = ScrollingFrame

	UpdatePlayerFrames()

	return PlayerFrameClone
end

for _, Player in next, game.Players:GetPlayers() do
	pcall(AddPlayerFrame, Player)
end

game.Players.PlayerAdded:Connect(AddPlayerFrame)

game.Players.PlayerRemoving:Connect(function(Player)
	if not Players[Player] then return end
	pcall(game.Destroy, Players[Player])
	Players[Player] = nil
	UpdatePlayerFrames()
end)

while task.wait(1) do
	UpdatePlayerFrames()
end