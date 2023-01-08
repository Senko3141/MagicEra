-- Notify Client

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local List = script.Parent.List
local Simulate = script.Parent.Simulate
local LargeNotificationsFrame = script.Parent.LargeNotifications

local SoundModule = require(Modules.Client.Effects.Sound)
local increment = .03

local function getNextPosition()
	local children = List:GetChildren()
	local lastSpot = children[#children]
		
	if #children == 0 then
		return UDim2.new(0,0,0,0)
	end
	return UDim2.new(0,0,#children*increment,0)
end
local function getDirection()
	local direction = math.random(2)
	if direction == 2 then
		return UDim2.new(2,0,0,0)
	end
	return UDim2.new(-2,0,0,0)	
end


local function notify(Text, Duration, Data)
	if not Duration then Duration = 2 end
	
	-- Sound --
	task.spawn(function()
		local Sound = nil
		if Data and Data.Sound then
			if Data.Sound ~= "NONE" then
				Sound = ReplicatedStorage.Assets.Sounds[Data.Sound]:Clone()
			end
		else
			Sound = ReplicatedStorage.Assets.Sounds.Notification:Clone()
		end	
		if Sound then
			Sound.Parent = script.Parent
			Sound:Play()
			Debris:AddItem(Sound, Sound.TimeLength)		
		end
	end)
	
	local newPos = getNextPosition()
	
	local Clone = script.Template:Clone()
	Clone.Name = #List:GetChildren() + 1
	Clone.Text = Text
	Clone.Parent = List
	Clone.Visible = true
	
	Clone:TweenPosition(newPos, Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
	
	local direction = getDirection()
	
	task.delay(Duration-.5, function()
		Clone.Parent = Simulate
		Clone:TweenPosition(Clone.Position+direction, Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.5, true)
	end)
	
	Debris:AddItem(Clone, Duration)
	
	-- Confetti if possible
	if typeof(Data) == "table" then
		local Confetti = Data.Confetti
		if Confetti then
			SoundModule({
				SoundName = "Confetti",
				Parent = script.Parent
			})
			script.Parent.Confetti:Fire()
		end
	end
end

local function childRemoved(child)
	local children = List:GetChildren()
	
	local start = UDim2.new(0,0,0,0)
	
	for _,obj in pairs(children) do
		obj:TweenPosition(start, Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
		start = start + UDim2.new(0,0,increment,0)
	end
end

script.Parent.Notify.Event:Connect(function(Text, Duration, Data)
	notify(Text, Duration, Data)
end)

Remotes.Notify.OnClientEvent:Connect(function(Text, Duration, Data)
	notify(Text, Duration, Data)
end)

List.ChildRemoved:Connect(childRemoved)

-- Notify Large
local function NotifyLarge(Data)
	-- Checking if something is already there
	local Children = LargeNotificationsFrame:GetChildren()
	if #Children > 0 then
		for i = 1, #Children do
			local child = Children[i]
			local value = Instance.new("Folder")
			value.Name = "Destroy"
			value.Parent = child
		end
	end
	
	local Clone = script.LargeTemplate:Clone()
	Clone.Name = "Notification"
	Clone.Parent = LargeNotificationsFrame
	
	Clone:TweenSize(UDim2.new(0.4,0,0.15,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
	
	Clone.Title.MaxVisibleGraphemes = 0
	Clone.Description.MaxVisibleGraphemes = 0
	
	Clone.Title.Text = Data.Text
	Clone.Description.Text = Data.Description
	
	-- Typing
	local Cancelled = false
	Clone.ChildAdded:Connect(function(Child)
		if Child.Name == "Destroy" then
			-- Destroy
			Cancelled = true
			Clone:Destroy()
		end
	end)
	
	local Duration = Data.Duration or 5
	local TypeDuration = Duration/4
	
	task.spawn(function()
		for i = 1,#Clone.Title.Text do
			if Cancelled then
				break
			end
			Clone.Title.MaxVisibleGraphemes = i
			task.wait(.03*TypeDuration)
		end		
	end)
	task.spawn(function()
		for i = 1,#Clone.Description.Text do
			if Cancelled then
				break
			end
			Clone.Description.MaxVisibleGraphemes = i
			task.wait(.03*TypeDuration)
		end
	end)
	
	task.wait(TypeDuration)

	if not Cancelled then
		task.delay(Duration-TypeDuration, function()
			if Cancelled then
				return
			end
			Clone.Title.Text = ""
			Clone.Description.Text = ""
			Clone:TweenSize(UDim2.new(0,0,0.15,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
			task.delay(.5, function()
				if Clone.Parent then
					Clone:Destroy()
				end
			end)
		end)
	end
end

Remotes.NotifyLarge.OnClientEvent:Connect(function(Data)
	NotifyLarge(Data)
end)