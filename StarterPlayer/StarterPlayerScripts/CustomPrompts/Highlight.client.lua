-- Highlight Test

local ProximityPromptService = game:GetService("ProximityPromptService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local NPCs = workspace:WaitForChild("NPCs", 999)

local Cache = {}

local function CreateHighlight(Parent)
	local Highlight = Instance.new("Highlight")
	Highlight.Name = "PromptHighlight"
	Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	Highlight.OutlineColor = Color3.fromRGB(255,255,255)
	Highlight.OutlineTransparency = 1
	Highlight.FillTransparency = 1

	Highlight.Parent = Parent
	return Highlight
end

ProximityPromptService.PromptShown:Connect(function(prompt)
	if prompt.Parent ~= nil then
		if prompt:IsDescendantOf(NPCs) then
			local Model: Model = prompt.Parent.Parent or nil
			if Model then
				local Highlight = CreateHighlight(Model)
				TweenService:Create(Highlight, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					OutlineTransparency = .1
				}):Play()
			end
		else
			-- Normal
			local Highlight = CreateHighlight(prompt.Parent)
			TweenService:Create(Highlight, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				OutlineTransparency = .1
			}):Play()
		end
	end
end)
ProximityPromptService.PromptHidden:Connect(function(prompt)
	if prompt.Parent ~= nil then
		if prompt:IsDescendantOf(NPCs) then
			local Model: Model = prompt.Parent.Parent or nil
			if Model then
				local PromptHighlight = Model:FindFirstChild("PromptHighlight")
				if PromptHighlight then
					TweenService:Create(PromptHighlight, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						OutlineTransparency = 1
					}):Play()
					Debris:AddItem(PromptHighlight, .5)
				end
			end
		else
			local PromptHighlight = prompt.Parent:FindFirstChild("PromptHighlight")
			if PromptHighlight then
				TweenService:Create(PromptHighlight, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					OutlineTransparency = 1
				}):Play()
				Debris:AddItem(PromptHighlight, .5)
			end
		end
	end
end)