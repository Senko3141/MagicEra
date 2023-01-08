-- Clothing Client

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local ClothingUIs = PlayerGui:WaitForChild("ClothingUIs", 999)

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Modules = ReplicatedStorage:WaitForChild("Modules")

local ClothingModule = require(Modules.Shared.Clothing)
local ClothingFolder = workspace:WaitForChild("Clothing")

local Template = script:WaitForChild("Template", 999)

-- Update
local function UpdateDisplay()
	for _,v in pairs(ClothingFolder:GetChildren()) do
		local Info = nil
		local Number = nil
		for i = 1, #ClothingModule.Clothing do
			local d = ClothingModule.Clothing[i]
			if d.Name == v.Name then
				Info = d
				Number = i
				break
			end
		end
		--
		if Info and Number then
			local Display = v.Dummy:FindFirstChild("Display")
			if Display then
				
				local alreadyFound = Display:FindFirstChild("Information")
				if not alreadyFound then
					local Clone = Template:Clone()
					Clone.Name = "Information"
					Clone.Adornee = Display
					
					Clone.Main.Title.Text = Info.Name
					Clone.Main.Buy.Text = "PURCHASE ("..Info.Price..")"

					Clone.Main.Buy.MouseButton1Click:Connect(function()
						Remotes.Clothing:FireServer("Purchase", Number)
					end)

					Clone.Main.Size = UDim2.new(0,0,0,0)
					Clone.Parent = ClothingUIs
				end
			end
		end
	end
end
UpdateDisplay()

RunService.RenderStepped:Connect(function()
	local Character = Player.Character
	if Character then
		local Root = Character:FindFirstChild("HumanoidRootPart")
		if Root then
			for _,npc in pairs(ClothingFolder:GetChildren()) do
				local b = npc.Dummy.HumanoidRootPart.Position
				local a = Root.Position
				
				local Display = npc.Dummy.Display
				local Gui = nil
				
				for _,v in pairs(ClothingUIs:GetChildren()) do
					if v:IsA("SurfaceGui") then
						if v.Adornee == Display then
							Gui = v.Main
							break
						end
					end
				end
				
				if Gui then
					local distance = (b-a).Magnitude
					if distance <= 8 then
						-- Display
						Gui:TweenSize(UDim2.new(1,0,1,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
					else
						-- Stop Displaying
						Gui:TweenSize(UDim2.new(0,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
					end
				end
			end
		end
	end
end)